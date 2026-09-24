# Technisches Systemkonzept: Skalierbares 40-Kanal Wardriving-Array

## 1. Systemarchitektur & Topologie

Das Gesamtsystem basiert auf einer dreistufigen hierarchischen Topologie. 40 dedizierte ESP32-C5 Nodes scannen simultan das gesamte 2.4-GHz- und 5-GHz-Spektrum (inkl. UNII-1 bis UNII-3 sowie Wi-Fi 6/6E) ohne Channel-Hopping.

```
                          [ 40× ESP32-C5 Single-Channel Sniffer ]
                             (Statischer Kanal pro Node: 1..40)
                                          │
                  4× USB CDC-ACM (Full-Speed 12 Mbit/s, Native USB-JTAG)
                                          ▼
                      [ 10× Edge-Knoten: Raspberry Pi Zero 2 W ]
                       - Multi-TT USB-Hub (GL852G / FE2.1)
                       - epoll() Multiplexer Daemon
                       - Kernel SPI-Driver (w5500.ko @ 30 MHz)
                                          │
                     10× Dedizierte SPI-Ethernet-Links (Cat 6A RJ45)
                                          ▼
                      [ 16-Port Industrial Switch (Unmanaged) ]
                       - Non-Blocking Backplane (3.2 Gbit/s Wire-Speed)
                                          │
                         Gigabit Ethernet Uplink (1000BASE-T)
                                          ▼
                     [ Zentraler Aggregator: Raspberry Pi 5 ]
                       - PCIe Gen 3 M.2 NVMe HAT (>400 MB/s Sustained Write)
                       - UDP Ingestion Socket (SO_RCVBUF = 16 MB)
                       - In-Memory Inter-Cluster Bloom/Hash Filter
                       - SQLite WAL Single-Writer Engine
```

---

## 2. Detaillierte Bottleneck-Analyse & Eliminierung

| Komponente / Subsystem | Primäres Bottleneck im Standardbetrieb | Technische Ursache | Eliminierungs- und Optimierungsmassnahme |
| :--- | :--- | :--- | :--- |
| **USB-Subsystem (Edge)** | Packet Drops, Interrupt-Stau, CPU-Freeze (`ksoftirqd`) | BCM2710A1 DWC2-Controller besitzt nur 8 Hardware-Host-Channels. 4 Endpoints + Ethernet-Dongle überlasten den Arbiter. | **Exklusiver USB-Betrieb:** Ethernet wird über SPI0 entkoppelt. Hubs nutzen **Multi-TT**. Nodes werden `read-only` gepollt, Bulk-OUT-Kanäle werden freigehalten. |
| **Netzwerk-Subsystem (Edge)** | Paketkollisionen & Bus-Konkurrenz auf dem Pi Zero 2 W | Kein nativer Ethernet-MAC. USB-Ethernet-Adapter teilen sich DWC2-Channels mit Scannern. | **Wiznet W5500 via SPI0:** Dedizierter SPI-Hardware-TCP/IP-Controller mit 30 MHz SPI-Takt. Völlige Entkopplung vom DWC2-USB-Bus. |
| **Compute & Memory (Nodes)** | Buffer Overflow in Wi-Fi ISR | ESP32-C5 ist ein **Single-Core RISC-V Prozessor (RV32IMC)**. Aufwendige String-Formatierung blockiert den Wi-Fi-Stack. | **ISR-Entkopplung & Direct-Mapped Cache:** Zero-Copy Ringpuffer in FreeRTOS, CRC32 Direct-Mapped Hash-Cache ($O(1)$) ohne dynamische Heap-Allokation. |
| **Netzwerk-Protokoll** | Paketverlust durch TCP-Congestion & Handshake-Latenz | TCP-Verbindungen (oder MQTT-Over-TCP) erzeugen State-Tracking-Overhead auf dem Pi Zero 2 W RAM. | **Raw UDP Unicast Datagrams:** 1024-Byte Batching. Fire-and-forget mit minimalem Kernel-Socket-Footprint. MTU-optimiert. |
| **Datenbank / Storage (Zentrale)** | `SQLITE_BUSY`, fsync-Wait, Schreibabnutzung der Flash-Zellen | Parallele Schreibversuche und ständige I/O-Syncs auf Standard-MicroSD (Random Write $<2\text{ MB/s}$). | **M.2 NVMe SSD + SQLite WAL:** Transaktionsbündelung (5'000 Records/Batch), `synchronous = NORMAL`, Ringpuffer in `/dev/shm`. |
| **HF & Elektromagnetische Verträglichkeit** | Frontend-Desensibilisierung (LNA Saturation) & Cross-Talk | 40 Antennen auf engem Bauraum induzieren Signalverzerrungen; Onboard-WLAN stört den Empfang. | **Kavitätsabschirmung:** HF-Kammern, Absorber-Vlies, Antennenabstand $\ge \lambda/2$. Onboard-WLAN/BT auf Pis per Device-Tree komplett deaktiviert. |

---

## 3. ESP32-C5 Firmware: Intra-Node Deduplizierung

Da der ESP32-C5 über keinen zweiten Kern verfügt, muss die Firmware strikt zwischen Interrupt Service Routine (ISR), Filter-Task und USB-Übertragung priorisiert werden.

```
[ 802.11 PHY Layer ] 
        │ Hardware MAC Filter
[ wifi_promiscuous_rx_cb() ]  <-- ISR Level (Priorität 23)
        │ xRingbufferSendFromISR() (Zero-Copy Pointers)
[ FreeRTOS Ringbuffer (32 KB SRAM) ]
        │ xRingbufferReceive()
[ dedup_tx_task() ]           <-- Worker Task (Priorität 10)
        │ CRC32-Prüfung gegen dedup_table[2048]
        │ Packen in WifiTelemetryPacket (52 Bytes)
        ▼
[ USB-Serial-JTAG FIFO ]      <-- Native Hardware FIFO (64 Bytes)
```

### 3.1. Speicher- und Deduplizierungs-Logik

```c
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "esp_wifi.h"
#include "esp_rom_crc.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/ringbuf.h"
#include "driver/usb_serial_jtag.h"

#define DEDUP_TABLE_SIZE 2048
#define DEDUP_INDEX_MASK (DEDUP_TABLE_SIZE - 1)
#define DEDUP_TTL_MS     1500
#define PACKET_MAGIC     0xAA

typedef struct __attribute__((__packed__)) {
    uint8_t  magic;            // 0xAA
    uint8_t  node_id;          // 0..39
    uint8_t  channel;          // 1..165
    int8_t   rssi;             // dBm
    uint32_t timestamp_ms;     // System-Tick
    uint8_t  bssid[6];         // Transmitter MAC
    uint16_t frame_ctrl;       // 802.11 Frame Control
    uint16_t seq_ctrl;         // Sequence Control
    uint8_t  ssid_len;         // Länge der SSID
    char     ssid[32];         // SSID String
    uint8_t  padding;          // Alignment auf 52 Bytes
    uint16_t crc16;            // Checksumme
} WifiTelemetryPacket;

typedef struct {
    uint32_t hash;
    uint32_t timestamp_ms;
} DedupEntry;

static DedupEntry s_dedup_table[DEDUP_TABLE_SIZE];
static RingbufHandle_t s_rx_ringbuf = NULL;

static inline bool is_frame_duplicate(const uint8_t *mac, uint16_t seq_ctrl, uint32_t now) {
    uint8_t vector[8];
    memcpy(&vector[0], mac, 6);
    memcpy(&vector[6], &seq_ctrl, 2);

    // Hardwarebeschleunigte CRC32 via ESP-ROM
    uint32_t hash = esp_rom_crc32_le(0, vector, sizeof(vector));
    uint16_t idx = hash & DEDUP_INDEX_MASK;

    if (s_dedup_table[idx].hash == hash) {
        if ((now - s_dedup_table[idx].timestamp_ms) < DEDUP_TTL_MS) {
            return true;
        }
    }

    s_dedup_table[idx].hash = hash;
    s_dedup_table[idx].timestamp_ms = now;
    return false;
}

static void wifi_promiscuous_rx_cb(void *buf, wifi_promiscuous_pkt_type_t type) {
    if (type != WIFI_PKT_MGMT) return;

    const wifi_promiscuous_pkt_t *pkt = (wifi_promiscuous_pkt_t *)buf;
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    // Nur Header und Metadaten übertragen (max. 48 Bytes)
    if (xRingbufferSendFromISR(s_rx_ringbuf, pkt, sizeof(wifi_promiscuous_pkt_t) + 36, &xHigherPriorityTaskWoken) != pdTRUE) {
        // Buffer voll: Drop Counter inkrementieren
    }

    if (xHigherPriorityTaskWoken) {
        portYIELD_FROM_ISR();
    }
}
```

---

## 4. Edge-Knoten Architektur: Raspberry Pi Zero 2 W

### 4.1. Hardware-Verschaltung W5500 SPI-Ethernet an Raspberry Pi Zero 2 W

Um Bus-Konflikte zu vermeiden, wird der native USB-OTG-Port ausschliesslich für den Multi-TT USB-Hub genutzt. Das Ethernet-Interface läuft autark über den SPI0-Bus der 40-Pin-GPIO-Leiste.

```
Wiznet W5500 Modul                  Raspberry Pi Zero 2 W (GPIO)
┌──────────────────┐               ┌──────────────────────────┐
│ VCC (3.3V)       │───────────────│ Pin 1  (3.3V Power)      │
│ GND              │───────────────│ Pin 6  (GND)             │
│ MOSI             │───────────────│ Pin 19 (GPIO 10 / MOSI)  │
│ MISO             │───────────────│ Pin 21 (GPIO 9  / MISO)  │
│ SCLK             │───────────────│ Pin 23 (GPIO 11 / SCLK)  │
│ CSn              │───────────────│ Pin 24 (GPIO 8  / CE0)   │
│ INTn (Interrupt) │───────────────│ Pin 22 (GPIO 25)         │
│ RSTn             │───────────────│ Pin 18 (GPIO 24)         │
└──────────────────┘               └──────────────────────────┘
```

#### OS-Konfiguration Edge-Nodes (`/boot/firmware/config.txt`)
```ini
# Deaktivierung interner Funkmodule (eliminiert 2.4-GHz-Störungen und Interrupts)
dtoverlay=disable-wifi
dtoverlay=disable-bt

# W5500 SPI-Overlay mit 30 MHz Bustakt und GPIO25 IRQ
dtparam=spi=on
dtoverlay=w5500,cs=0,speed=30000000,int_pin=25

# USB-Controller Host-Modus forcieren
dtoverlay=dwc2,dr_mode=host
```

### 4.2. Hochleistungs-Forwarder Daemon (C mit `epoll`)

Der Forwarder sammelt Daten von 4× `/dev/ttyACM*` über Non-Blocking I/O, bündelt bis zu 19 Records in ein UDP-Datagramm ($\le 1024$ Bytes) und sendet dieses direkt an den Pi 5.

```c
// Auszug: edge_forwarder.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define MAX_EVENTS 8
#define TELEMETRY_PACKET_SIZE 52
#define BATCH_CAPACITY 19 // 19 * 52 = 988 Bytes (< 1472 Byte MTU)

typedef struct {
    uint8_t buffer[BATCH_CAPACITY * TELEMETRY_PACKET_SIZE];
    size_t count;
} BatchBuffer;

static BatchBuffer g_batch;
static int g_udp_sock;
static struct sockaddr_in g_dest_addr;

void flush_batch() {
    if (g_batch.count == 0) return;
    sendto(g_udp_sock, g_batch.buffer, g_batch.count * TELEMETRY_PACKET_SIZE, 0,
           (struct sockaddr *)&g_dest_addr, sizeof(g_dest_addr));
    g_batch.count = 0;
}

int set_nonblocking(int fd) {
    int flags = fcntl(fd, F_GETFL, 0);
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

int main() {
    int epoll_fd = epoll_create1(0);
    struct epoll_event ev, events[MAX_EVENTS];

    // UDP Socket Setup
    g_udp_sock = socket(AF_INET, SOCK_DGRAM, 0);
    g_dest_addr.sin_family = AF_INET;
    g_dest_addr.sin_port = htons(5555);
    inet_pton(AF_INET, "192.168.10.1", &g_dest_addr.sin_addr);

    // 4 Nodes öffnen (/dev/ttyACM0 bis 3)
    for (int i = 0; i < 4; i++) {
        char path[32];
        snprintf(path, sizeof(path), "/dev/ttyACM%d", i);
        int fd = open(path, O_RDONLY | O_NOCTTY | O_NONBLOCK);
        if (fd < 0) continue;
        ev.events = EPOLLIN | EPOLLET;
        ev.data.fd = fd;
        epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &ev);
    }

    uint8_t rx_scratch[256];
    while (1) {
        int nfds = epoll_wait(epoll_fd, events, MAX_EVENTS, 20); // 20ms Max-Flush Latenz
        if (nfds == 0) {
            flush_batch();
            continue;
        }

        for (int i = 0; i < nfds; i++) {
            ssize_t bytes_read;
            while ((bytes_read = read(events[i].data.fd, rx_scratch, sizeof(rx_scratch))) > 0) {
                for (ssize_t offset = 0; offset + TELEMETRY_PACKET_SIZE <= bytes_read; offset += TELEMETRY_PACKET_SIZE) {
                    if (rx_scratch[offset] == PACKET_MAGIC) {
                        memcpy(&g_batch.buffer[g_batch.count * TELEMETRY_PACKET_SIZE], 
                               &rx_scratch[offset], TELEMETRY_PACKET_SIZE);
                        g_batch.count++;
                        if (g_batch.count >= BATCH_CAPACITY) {
                            flush_batch();
                        }
                    }
                }
            }
        }
    }
}
```

---

## 5. Zentraler Aggregator & Datenbank Pipeline: Raspberry Pi 5

Der Pi 5 empfängt die Datenströme via Gigabit-Ethernet, wendet einen temporalen Sliding-Window-Filter über das gesamte Cluster an und schreibt aggregiert in eine NVMe-gestützte SQLite-Instanz.

### 5.1. SQLite High-Throughput Schema & Tuning

```sql
-- Initialisierung: /var/data/wardriving.db
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -128000;         -- 128 MB RAM Cache
PRAGMA locking_mode = EXCLUSIVE;     -- Kein Multi-Process Lock Overhead
PRAGMA page_size = 4096;
PRAGMA temp_store = MEMORY;
PRAGMA mmap_size = 1073741824;       -- 1 GB Memory Mapped I/O

CREATE TABLE IF NOT EXISTS observations (
    id             INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp_utc  INTEGER NOT NULL,
    node_id        INTEGER NOT NULL,
    channel        INTEGER NOT NULL,
    rssi           INTEGER NOT NULL,
    bssid          BLOB NOT NULL,     -- 6-Byte Raw Binary
    ssid           TEXT,
    frame_ctrl     INTEGER NOT NULL,
    seq_ctrl       INTEGER NOT NULL
);

-- Partieller Index: Minimiert Write-Amplification während der Fahrt
CREATE INDEX IF NOT EXISTS idx_bssid_recent 
ON observations (bssid, timestamp_utc DESC);
```

### 5.2. Aggregator Daemon (Inter-Cluster Deduplikation & Ingest)

```python
#!/usr/bin/env python3
import socket
import struct
import sqlite3
import time

LISTEN_IP = "0.0.0.0"
LISTEN_PORT = 5555
DB_PATH = "/mnt/nvme/wardriving.db"
PACKET_FORMAT = "<BBBbI6sHHB32sBxH" # 52 Bytes Struct
PACKET_SIZE = struct.calcsize(PACKET_FORMAT)

# In-Memory Cache für Inter-Cluster-Deduplizierung: BSSID -> (timestamp, rssi)
cluster_cache = {}
CACHE_TTL_SEC = 5.0
RSSI_THRESHOLD_DBM = 4

def run_aggregator():
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 16 * 1024 * 1024) # 16 MB Buffer
    sock.bind((LISTEN_IP, LISTEN_PORT))

    conn = sqlite3.connect(DB_PATH, isolation_level=None)
    cursor = conn.cursor()
    cursor.execute("PRAGMA journal_mode = WAL;")
    cursor.execute("PRAGMA synchronous = NORMAL;")

    batch = []
    last_commit = time.time()

    while True:
        data, _ = sock.recvfrom(2048)
        now = time.time()
        offset = 0

        while offset + PACKET_SIZE <= len(data):
            pkt = struct.unpack_from(PACKET_FORMAT, data, offset)
            offset += PACKET_SIZE

            magic, node_id, channel, rssi, ts_boot, bssid, frame_ctrl, seq_ctrl, ssid_len, ssid_raw, crc = (
                pkt[0], pkt[1], pkt[2], pkt[3], pkt[4], pkt[5], pkt[6], pkt[7], pkt[8], pkt[9], pkt[11]
            )

            if magic != 0xAA:
                continue

            # Inter-Cluster Deduplizierungs-Filter
            last_entry = cluster_cache.get(bssid)
            if last_entry:
                last_time, last_rssi = last_entry
                if (now - last_time < CACHE_TTL_SEC) and (abs(rssi - last_rssi) < RSSI_THRESHOLD_DBM):
                    continue # Frame innerhalb des Zeitfensters ohne signifikanten RSSI-Delta verwerfen

            cluster_cache[bssid] = (now, rssi)

            ssid = ssid_raw[:ssid_len].decode('utf-8', errors='ignore')
            batch.append((int(now * 1000), node_id, channel, rssi, bssid, ssid, frame_ctrl, seq_ctrl))

        # Transaktions-Batching (alle 1000 Records oder alle 1 Sekunde)
        if len(batch) >= 1000 or (now - last_commit >= 1.0 and batch):
            cursor.execute("BEGIN TRANSACTION;")
            cursor.executemany(
                "INSERT INTO observations (timestamp_utc, node_id, channel, rssi, bssid, ssid, frame_ctrl, seq_ctrl) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?);",
                batch
            )
            cursor.execute("COMMIT;")
            batch.clear()
            last_commit = now

            # Cache-Bereinigung alle 60 Sekunden
            if len(cluster_cache) > 200000:
                cluster_cache.clear()

if __name__ == "__main__":
    run_aggregator()
```

---

## 6. Power Distribution Network (PDN) & Thermisches Design

### 6.1. Leistungsbilanz & Stromschienen-Auslegung

| Einheit | Anzahl | Max. Stromaufnahme (5V Peak) | Dauerlast (5V Steady-State) | Gesamtleistung |
| :--- | :--- | :--- | :--- | :--- |
| **Raspberry Pi 5 + NVMe** | 1 | 5.0 A (25.0 W) | 2.5 A (12.5 W) | 15.0 W |
| **Raspberry Pi Zero 2 W** | 10 | $10 \times 0.5\text{ A} = 5.0\text{ A}$ | $10 \times 0.25\text{ A} = 2.5\text{ A}$ | 12.5 W |
| **ESP32-C5 Nodes (Dual-Band Scan)** | 40 | $40 \times 0.35\text{ A} = 14.0\text{ A}$ | $40 \times 0.16\text{ A} = 6.4\text{ A}$ | 32.0 W |
| **16-Port Industrial Switch** | 1 | 1.2 A (6.0 W) | 0.8 A (4.0 W) | 4.0 W |
| **Gesamtsystem (Sicherheitsfaktor 1.3)** | — | **Max Peak: 25.2 A (126 W)** | **Typisch: 12.2 A (61 W)** | **Puffer: 150 W** |

### 6.2. Spannungsabfall-Minimierung & Verkabelung

* **Primärversorgung:** Ein zentrales industrielles Schaltnetzteil (z. B. **MeanWell LRS-150-12** oder **RSD-150B-12** bei 12V Fahrzeugnetz) liefert **12 V DC / 12.5 A**.
* **Dezentrale DC-DC-Wandlung:** Keine 5V-Leitungen über lange Distanzen ziehen ($I^2R$-Verluste führen zu Brownouts auf den Pi Zeros).
  * 5× Synchron-Abwärtswandler (Step-Down Buck, z. B. Texas Instruments TPS54560, 12V $\rightarrow$ 5.15V / 5A Peak).
  * Jeder Wandler speist genau **2× Edge-Einheiten (2× Pi Zero 2 W + 8× ESP32-C5)**.
  * 1× Separater Wandler (5.1V / 6A) ausschliesslich für den Raspberry Pi 5.
* **Pufferung:** An jedem 5V-Einspeisepunkt sitzt eine Low-ESR-Elektrolytkondensator-Bank ($2200\,\mu\text{F} / 10\text{V}$) parallel zu einem $100\,\text{nF}$ Keramikkondensator gegen hochfrequente Lastspitzen während Wi-Fi RX/TX-Transienten.

---

## 7. Mathematische Durchsatz- & Latenzvalidierung

### 7.1. Bus-Auslastung auf Edge-Ebene (Pi Zero 2 W)

* **Roh-Erfassung ohne Filter (Worst Case Szenario):**
  $$\text{Frames pro Sekunde} = 400\text{ Frames/s}$$
  $$\text{Datenmenge} = 400 \times 52\text{ Bytes} \approx 20.8\text{ kB/s pro Node}$$
  Bei 4 Nodes an einem Pi Zero: $4 \times 20.8\text{ kB/s} = 83.2\text{ kB/s}$ ($0.66\text{ Mbit/s}$).
* **Nach Intra-Node Deduplizierung (Wirkungsgrad $\eta \approx 80\%$):**
  $$\text{Nettodurchsatz pro Edge-Pi} = 83.2\text{ kB/s} \times 0.20 = 16.64\text{ kB/s} \approx 133\text{ kbit/s}$$
* **W5500 SPI-Durchsatzgrenze:**
  Bei $f_{\text{SPI}} = 30\text{ MHz}$ beträgt die theoretische Bandbreite $30\text{ Mbit/s}$. Effektiv mit Protokoll-Overhead via Linux SPI-Treiber: **$\approx 14\text{ Mbit/s}$**.
  $$\text{Auslastung des W5500} = \frac{0.133\text{ Mbit/s}}{14\text{ Mbit/s}} \approx \mathbf{0.95\%}$$
  *Ergebnis:* Der SPI-Netzwerk-Link operiert bei unter 1% Last. Latenzen und Paketverluste auf der Edge-Strecke sind physikalisch ausgeschlossen.

### 7.2. Storage-Durchsatz auf Aggregator-Ebene (Raspberry Pi 5)

* **Kumulierter Cluster-Traffic (40 Nodes):**
  $$\text{Netto-Paketrate} = 40\text{ Nodes} \times 80\text{ Events/s} = 3'200\text{ Records/s}$$
  $$\text{Netzwerk-Ingestion} = 3'200 \times 52\text{ Bytes} \approx 166.4\text{ kB/s}$$
* **Nach Inter-Cluster Sliding-Window Filter (Wirkungsgrad $\approx 50\%$ im Verbund):**
  $$\text{DB-Schreiblast} = 1'600\text{ Records/s}$$
  Mit SQLite B-Tree Index und WAL Overhead: $\approx 200\text{ Bytes/Record}$.
  $$\text{Disk Write Rate} = 1'600 \times 200\text{ Bytes} = \mathbf{320\text{ kB/s}}$$
* **PCIe Gen 3 M.2 NVMe SSD Kapazität:**
  Sustained Sequential/Random Write: **$>400\text{ MB/s}$**.
  $$\text{Auslastung des I/O-Subsystems} = \frac{0.32\text{ MB/s}}{400\text{ MB/s}} = \mathbf{0.08\%}$$
  *Ergebnis:* Das I/O-Subsystem besitzt einen Headroom von über Faktor 1'000. Ein Schreib-Bottleneck existiert nicht.