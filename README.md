<img width="1024" height="559" alt="image" src="https://github.com/user-attachments/assets/a943a67f-6c44-4e8a-9b73-de66056e34d9" />

# Technische Systemdokumentation: Multi-Node High-Density Wardriving Rig

**Dokument-ID:** ARCH-WD-41C5-M9N-REV1.0  
**Systemtyp:** Dezentrales, frequenzstarres HF-Sniffer-Cluster mit zweistufigem RS-485 Feldbus und Linux-Host  
**Revisionsstand:** 1.0 (Produktionsbereit)  

---

## 1. Systemübersicht & Architektur

### 1.1 Zielsetzung & Funktionsprinzip
Klassische Wardriving-Systeme verwenden Frequenz-Hopping auf ein oder zwei Funk-Interfaces. Dadurch entstehen signifikante Blindzeiten („Channel Dwell Time Misses“), insbesondere bei sich schnell bewegenden Fahrzeugen.  
Dieses System eliminiert Blindzeiten durch **vollständige räumliche Parallelisierung**:
* **41 dedizierte Worker-Nodes (Seeed XIAO ESP32-C5):** Jeder Sniffer operiert auf einem fest zugewiesenen Funkkanal (2.4 GHz CH 1–13, 5 GHz UNII-1/2/2e/3 sowie BLE). Es findet **kein** Kanalwechsel im Betrieb statt; die Latenz zur Erfassung von Beacons, Probe Requests und Association Frames sinkt auf die physische HF-Präsenzzeit.
* **Dual-Segment RS-485 Bus:** Aufgeteilt in zwei unabhängige differentielle Busstränge (Bus 1: 20 Nodes; Bus 2: 21 Nodes), betrieben über Auto-Direction Transceiver (MAX13488E) zur Vermeidung von Kollisionen und Latenzstau.
* **Master Controller (ESP32-WROOM-32E):** Deterministisches Polling beider Busse auf getrennten Hardware-UARTs über dedizierte FreeRTOS-Cores. Aggregation, CRC-Validierung, COBS-Framing und Streaming über High-Speed UART mit Hardware Flow Control.
* **Frontend Host (Raspberry Pi Zero 2 W):** Empfängt den COBS-Bytestrom via PL011-UART, korreliert Pakete synchron mit dem 10-Hz-GNSS-Stream des u-blox NEO-M9N/M10 (via I2C), filtert Duplikate per Bloom-Filter und schreibt transaktionssicher in eine SQLite-Datenbank (WAL-Modus) sowie WiGLE-CSV-Logdateien.

```
                           +-------------------------------------------------------------+
                           |                     12V Bordnetz / Batterie                 |
                           +-------------------------------------------------------------+
                                       |                                    |
                               [ 15A KFZ-Sicherung ]                        |
                                       |                                    |
                           [ Buck Converter 12V -> 5.2V ]                   |
                             (Mean Well 12A/15A Peak)                       |
                                       |                                    |
            +--------------------------+--------------------------+         |
            |                          |                          |         |
     [ Bank 1: 10 Nodes ]       [ Bank 2: 10 Nodes ]       [ Bank 3: 11 Nodes ] [ Bank 4: 10 Nodes ]
     [ PTC Polyfuse 2.0A]       [ PTC Polyfuse 2.0A]       [ PTC Polyfuse 2.0A] [ PTC Polyfuse 2.0A]
            |                          |                          |                 |
     (Nodes 01 - 10)            (Nodes 11 - 20)            (Nodes 21 - 31)   (Nodes 32 - 41)
            \                         /                          \                 /
             \                       /                            \               /
              +---------------------+                              +-------------+
                         |                                                |
                 [ Bus 1: RS-485 ]                                [ Bus 2: RS-485 ]
              (Nodes 01–20, A/B Diff.)                         (Nodes 21–41, A/B Diff.)
                         |                                                |
                         +-----------------------+------------------------+
                                                 |
                                     [ Master ESP32-WROOM-32E ]
                                     | Core 0: Poll UART1 (Bus 1) |
                                     | Core 1: Poll UART2 (Bus 2) |
                                     | COBS / CRC32 Ringbuffer    |
                                                 |
                                         [ UART 921'600 Baud ]
                                         [ RTS/CTS Flow Control]
                                                 |
                                                 v
                                     [ Raspberry Pi Zero 2 W ]
                                     | PL011 UART Ingest (/dev/ttyAMA0) |
                                     | I2C u-blox GNSS (10 Hz Fix)     |
                                     | In-Memory Bloom Filter          |
                                     | SQLite WAL & WiGLE CSV Storage  |
```

---

## 2. Vollständige Bauteilliste (Bill of Materials - BOM)

| Pos. | Komponente | Spezifikation / Details | Anzahl | Bezugsquelle / Referenz |
| :--- | :--- | :--- | :--- | :--- |
| **1.0** | **Recheneinheiten** | | | |
| 1.1 | Worker Nodes | Seeed Studio XIAO ESP32-C5 (Dual-Band 2.4/5 GHz RISC-V) | 41x | Seeed 102010624 |
| 1.2 | Master Controller | ESP32-WROOM-32E (Bare Module oder NodeMCU DevKit, 8MB Flash) | 1x | Espressif Systems |
| 1.3 | Frontend Host | Raspberry Pi Zero 2 W (Quad-Core Cortex-A53, 512MB RAM) | 1x | Raspberry Pi Foundation |
| 1.4 | GNSS Modul | u-blox NEO-M9N oder NEO-M10 (Breakout mit Qwiic/I2C & SMA) | 1x | SparkFun / Matek |
| 1.5 | RS-485 Transceiver | Maxim / ADI MAX13488EESA+ (SOIC-8, AutoDirection, 16 Mbps, 5V) | 43x | Analog Devices |
| **2.0** | **HF-Infrastruktur** | | | |
| 2.1 | HF-Pigtails | U.FL / IPEX-1 auf SMA-Female (Bulkhead mit O-Ring), RG316, 15 cm | 41x | Huber+Suhner / Taoglas |
| 2.2 | Dual-Band Antennen | 2.4 / 5.8 GHz Dipol Omnidirektional (2–3 dBi, Knickgelenk, SMA-Male) | 41x | z. B. Alfa Network AOA-2458 |
| 2.3 | GNSS-Antenne | Aktive Multiband (GPS L1, GLONASS G1, Galileo E1), 28 dB LNA, 3.3V | 1x | z. B. Taoglas AA.162 / Beitian |
| **3.0** | **Passive Bauelemente** | | | |
| 3.1 | Spannungsteiler R1 | $1.0\ \text{k}\Omega$, Metallschicht 0805, 1%, 0.125 W | 41x | Pegelanpassung 5V $\rightarrow$ 3.3V High-Side |
| 3.2 | Spannungsteiler R2 | $2.0\ \text{k}\Omega$, Metallschicht 0805, 1%, 0.125 W | 41x | Pegelanpassung 5V $\rightarrow$ 3.3V Low-Side |
| 3.3 | Bus-Terminierung | $120\ \Omega$, Metallschicht 0805/Axial, 1%, 0.25 W | 4x | An beiden Enden von Bus 1 & Bus 2 |
| 3.4 | Fail-Safe Biasing | $510\ \Omega$, Metallschicht 0805/Axial, 1%, 0.25 W | 4x | Pull-Up (A $\rightarrow$ 5V) & Pull-Down (B $\rightarrow$ GND) |
| 3.5 | IC-Abblockkondensator | $100\ \text{nF}$, Keramik X7R, 0805, 50V | 43x | Pin 8 ($V_{CC}$) aller MAX13488E |
| 3.6 | Node-Stützkondensator| $10\ \mu\text{F}$, Keramik X7R, 1206, 16V | 41x | Direkt an 5V/GND Pins jedes XIAO C5 |
| 3.7 | Stripe-Pufferelko | $1'000\ \mu\text{F}$, Aluminium-Elektrolyt Low-ESR, 16V (Pan. FR) | 4x | Stripe-Einspeisung Bank 1–4 |
| 3.8 | Überstromschutz | SMD/THT PTC Polyfuse 2.0 A (Hold: 2.0 A, Trip: 4.0 A, max. 16V) | 4x | Bourns MF-MSMF200 |
| **4.0** | **Stromversorgung** | | | |
| 4.1 | Hauptwandler | DC-DC Step-Down synchron, 9–36V $\rightarrow$ 5.2V DC / 15 A Peak | 1x | Mean Well RSD-60G-5 o. ä. |
| 4.2 | Kfz-Sicherung | ATO/ATC Inline-Sicherungshalter + 15 A Schmelzsicherung | 1x | Primärseite vor Step-Down |
| 4.3 | Filter-Induktivität | $10\ \mu\text{H}$ SMD-Leistungsdrossel (Sättigungsstrom $\ge 4\ \text{A}$) | 1x | Pi / Master LC-Filter |
| 4.4 | Filter-Kapazität | $470\ \mu\text{F}$ Low-ESR Elko, 16V | 1x | Pi / Master LC-Filter |
| **5.0** | **Mechanik & Verdrahtung**| | | |
| 5.1 | Trägerplatinen | FR4 Streifenraster / Lochraster $160 \times 100\ \text{mm}$ (Cu $35\ \mu\text{m}$) | 4x | 4 Cluster-Stripes (Bänke 1–4) |
| 5.2 | Hauptzuleitung Strom | Hochflexible Silikonlitze AWG 16 ($1.5\ \text{mm}^2$), rot/schwarz | 5 m | Sternverkabelung 5.2V / GND |
| 5.3 | Bus-Leitung | Cat.6A S/FTP Installationskabel (AWG 23/1 Paarverseilung) | 3 m | RS-485 Differenzpaare A/B |
| 5.4 | Signalleitungen | Silikonlitze AWG 24 / AWG 26, verdrillt | 5 m | UART / Flow-Control Verbindungen |
| 5.5 | Kühlelemente | Kupfer-Heatsinks $10 \times 10 \times 4\ \text{mm}$ inkl. 3M Wärmeleitband | 42x | 41x C5 RF-Shield, 1x Pi Zero 2W SiP |
| 5.6 | Speicherkarte | SanDisk Extreme / Endurance microSDXC 64 GB / 128 GB (A2) | 1x | Für Pi Zero 2 W |

---

## 3. Elektrische Verschaltung & Pegelanpassung

### 3.1 Worker Node Interface (XIAO ESP32-C5 an MAX13488E)
Der Transceiver MAX13488E arbeitet an $V_{CC} = 5.0\ \text{V}$, um die normgerechten RS-485 Differenzpegel ($V_{OD} \ge 1.5\ \text{V}$ über $54\ \Omega$) bereitzustellen. Der ESP32-C5 arbeitet intern auf 3.3V-Logik und ist **nicht 5V-tolerant**.

* **Senderichtung (C5 TX $\rightarrow$ MAX13488E DI):**
  * $V_{OH}$ des ESP32-C5 beträgt minimal $0.8 \cdot V_{DD} = 2.64\ \text{V}$.
  * Der MAX13488E spezifiziert $V_{IH,\min} = 2.0\ \text{V}$.
  * **Direktverbindung zulässig:** C5 TX (GPIO 1) wird direkt auf Pin 4 (DI) des MAX13488E geführt.
* **Empfangsrichtung (MAX13488E RO $\rightarrow$ C5 RX):**
  * $V_{OH}$ des MAX13488E liegt bei typisch $4.8\ \text{V}$ bis $5.0\ \text{V}$. Ein direkter Anschluss zerstört den ESP32-C5 Eingang.
  * **Spannungsteilerberechnung:**
    $$V_{RX} = V_{RO} \cdot \frac{R_2}{R_1 + R_2} = 5.0\ \text{V} \cdot \frac{2.0\ \text{k}\Omega}{1.0\ \text{k}\Omega + 2.0\ \text{k}\Omega} = 5.0\ \text{V} \cdot \frac{2}{3} \approx 3.33\ \text{V}$$
    Die Grenzfrequenz mit parasitärer Eingangskapazität ($C_{in} \approx 5\ \text{pF} + C_{Stray} \approx 5\ \text{pF} = 10\ \text{pF}$) beträgt:
    $$f_c = \frac{1}{2 \pi \cdot (R_1 \parallel R_2) \cdot C} = \frac{1}{2 \pi \cdot 667\ \Omega \cdot 10 \times 10^{-12}\ \text{F}} \approx 23.8\ \text{MHz}$$
    Dies garantiert unverzerrte Flanken selbst bei 2 bis 3 MBaud.
* **AutoDirection Steuerung:**
  * Der MAX13488E verfügt über eine interne Transmit-State-Machine: Die Pins $\overline{\text{RE}}$ und $\text{DE}$ entfallen bzw. werden intern geregelt. Das vereinfacht das Hardware-Design auf reines RX/TX ohne GPIO-Direction-Switching.

```
       +5.0V Bus
          |
         [+] Pin 8 (VCC) - MAX13488E
          |
         [===] C_dec = 100nF (X7R)
          |
         GND Pin 5 (GND)
          |
 ESP32-C5 |
+---------+         +-------------+                    RS-485 Differential Bus
|         |  TX     |             | Pin 6 (A) -------- A (Data +)
|  GPIO 1 +-------->+ Pin 4 (DI)  |
|         |         |  MAX13488E  | Pin 7 (B) -------- B (Data -)
|         |         |             |
|  GPIO 2 +<---+    |             |
+---------+    |    +------+------+
         RX    |           | Pin 1 (RO)
              [ ] R1       | (5V Logikpegel)
              [ ] 1.0k     |
               |           |
               +-----------+
               |
              [ ] R2
              [ ] 2.0k
               |
              GND
```

### 3.2 RS-485 Bus-Topologie, Terminierung & Biasing
Das System nutzt zwei physisch getrennte Busstränge. Eine Daisy-Chain-Linientopologie ist zwingend einzuhalten; Stichleitungen zu den Nodes dürfen maximal $5\ \text{cm}$ betragen.

* **Bus 1:** Nodes 01 bis 20 (Cluster-Stripes 1 und 2).
* **Bus 2:** Nodes 21 bis 41 (Cluster-Stripes 3 und 4).
* **Differenzielle Terminierung:** An den beiden äußersten Enden jedes Busses sitzt jeweils ein Abschlusswiderstand:
  $$R_T = 120\ \Omega \quad (1\%,\ 0.25\ \text{W})$$
* **Fail-Safe Biasing:** Verhindert Float-Zustände auf der differentiellen Leitung im Ruhemodus (Tristate, wenn kein Node treibt), sodass $V_A - V_B > +200\ \text{mV}$ bleibt:
  * Pull-Up von Leitung A auf $+5.0\ \text{V}$ via $R_{PU} = 510\ \Omega$ (nur am Master Gateway).
  * Pull-Down von Leitung B auf $\text{GND}$ via $R_{PD} = 510\ \Omega$ (nur am Master Gateway).
  * Ergibt im Idle-Zustand eine definierte Differenzspannung von ca. $260\ \text{mV}$.

```
                 Master Gateway                            Letzter Node (z.B. Node 20)
              +-------------------+                            +-------------------+
  +5.0V <-----+---[ 510 Ohm ]     |                            |                   |
              |        |          |                            |                   |
  Line A <----+--------+----------+=========[ Cat6A Ader ]=====+-------------------+
              |        |          |                            |        |          |
              |   [ 120 Ohm ]     |                            |   [ 120 Ohm ]     |
              |        |          |                            |        |          |
  Line B <----+--------+----------+=========[ Cat6A Ader ]=====+-------------------+
              |        |          |                            |                   |
    GND <-----+---[ 510 Ohm ]     |                            |                   |
              +-------------------+                            +-------------------+
```

### 3.3 Pinbelegung Master ESP32-WROOM-32E
Der Master fungiert als Dual-Port RS-485 Gateway und leitet verifizierte Pakete zum Raspberry Pi weiter.

| Pin / GPIO | Funktion | Peripherie / Gegenstelle | Signalpegel | Beschreibung |
| :--- | :--- | :--- | :--- | :--- |
| **GPIO 16** | UART1 RX | MAX13488E #1 RO (Bus 1) | 3.3V (via R1/R2) | RS-485 Empfang Bus 1 (Nodes 01–20) |
| **GPIO 17** | UART1 TX | MAX13488E #1 DI (Bus 1) | 3.3V | RS-485 Senden Bus 1 |
| **GPIO 21** | UART2 RX | MAX13488E #2 RO (Bus 2) | 3.3V (via R1/R2) | RS-485 Empfang Bus 2 (Nodes 21–41) |
| **GPIO 22** | UART2 TX | MAX13488E #2 DI (Bus 2) | 3.3V | RS-485 Senden Bus 2 |
| **GPIO 14** | UART0 TX | Pi Zero 2W RX (Pin 10 / GPIO 15)| 3.3V Direkt | COBS Stream Out (921'600 Baud) |
| **GPIO 15** | UART0 RX | Pi Zero 2W TX (Pin 8 / GPIO 14) | 3.3V Direkt | Host Command In |
| **GPIO 13** | UART0 RTS| Pi Zero 2W CTS (Pin 36 / GPIO 16)| 3.3V Direkt | Flow Control: Master sendet Stopp an Pi |
| **GPIO 12** | UART0 CTS| Pi Zero 2W RTS (Pin 11 / GPIO 17)| 3.3V Direkt | Flow Control: Pi signalisiert Pufferüberlauf |
| **GND** | Bezugspotenzial| Pi Zero 2W / MAX13488E / Bus | 0V | Gemeinsame Signalmasse |

### 3.4 Pinbelegung Raspberry Pi Zero 2 W
Der Pi Zero 2 W nutzt seinen vollwertigen Hardware-UART (PL011) auf der Stiftleiste für den Datenstrom sowie I2C für GNSS.

| Raspberry Pi Pin | BCM GPIO | Signal / Funktion | Zielkomponente | Modus / Konfiguration |
| :--- | :--- | :--- | :--- | :--- |
| **Pin 1 / 17** | 3V3 Power | VCC 3.3V | u-blox GNSS VCC | Max. 50 mA Stromaufnahme |
| **Pin 2 / 4** | 5V Power | VCC 5.0V | Buck-Converter (via LC) | Primäre Stromeinspeisung Host |
| **Pin 3** | GPIO 2 | I2C1 SDA | u-blox GNSS SDA | Interne $1.8\ \text{k}\Omega$ Pull-Ups aktiv |
| **Pin 5** | GPIO 3 | I2C1 SCL | u-blox GNSS SCL | $400\ \text{kHz}$ Fast-Mode I2C |
| **Pin 6 / 9 / 14**| GND | Signal GND | Systemmasse | Zentraler Stern-GND |
| **Pin 8** | GPIO 14 | UART0 TXD | Master GPIO 15 (RX) | PL011 Primärer Hardware-UART |
| **Pin 10** | GPIO 15 | UART0 RXD | Master GPIO 14 (TX) | PL011 (921'600 Baud) |
| **Pin 11** | GPIO 17 | UART0 RTS | Master GPIO 12 (CTS) | Hardware Flow Control RTS |
| **Pin 36** | GPIO 16 | UART0 CTS | Master GPIO 13 (RTS) | Hardware Flow Control CTS |

> **Wichtiger Hinweis zur Raspberry Pi UART-Konfiguration:**  
> Standardmäßig ist der Mini-UART an GPIO 14/15 gekoppelt. In `/boot/firmware/config.txt` muss Bluetooth deaktiviert oder auf den Mini-UART gelegt werden, um die voll pufferbare PL011-Hardware bereitzustellen:
> ```ini
> dtoverlay=disable-bt
> dtoverlay=uart0,ctsrts=1
> enable_uart=1
> ```

---

## 4. HF-Architektur & Kanalzuordnungsplan

Um Co-Channel-Interferenzen innerhalb des Gehäuses zu minimieren und eine nahtlose Erfassung aller weltweiten Funknetze zu garantieren, werden die 41 Nodes festen physikalischen Kanälen zugewiesen.

### 4.1 Kanalmatrix
* **2.4 GHz Band (13 Nodes):** Kanäle 1 bis 13 (DSSS/OFDM).
* **5 GHz UNII-1 & UNII-2A (8 Nodes):** Kanäle 36, 40, 44, 48 (Indoor) und 52, 56, 60, 64 (DFS).
* **5 GHz UNII-2C Extended (12 Nodes):** Kanäle 100, 104, 108, 112, 116, 120, 124, 128, 132, 136, 140, 144.
* **5 GHz UNII-3 (5 Nodes):** Kanäle 149, 153, 157, 161, 165.
* **Sonderaufgaben / BLE (3 Nodes):**
  * Node 39: Dedizierter Bluetooth Low Energy (BLE) Adv Sniffer (Kanal 37, 38, 39 Cyclic Fast-Hop).
  * Node 40: Redundanter 2.4 GHz Social-Kanal Sniffer (CH 1 / 6 / 11 Fast-Hop für Hidden SSID Tracking).
  * Node 41: UNII-4 / ISM Erweiterung (Kanal 169/173) bzw. dynamischer Probe-Request Monitor.

| Node ID | Band | Primärkanal | Frequenz ($f_c$) | Antennenpolarisation | Cluster Bank |
| :---: | :---: | :---: | :---: | :---: | :---: |
| **Node 01** | 2.4 GHz | CH 1 | $2412\ \text{MHz}$ | Vertikal | Bank 1 |
| **Node 02** | 2.4 GHz | CH 2 | $2417\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 1 |
| **Node 03** | 2.4 GHz | CH 3 | $2422\ \text{MHz}$ | Vertikal | Bank 1 |
| **Node 04** | 2.4 GHz | CH 4 | $2427\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 1 |
| **Node 05** | 2.4 GHz | CH 5 | $2432\ \text{MHz}$ | Vertikal | Bank 1 |
| **Node 06** | 2.4 GHz | CH 6 | $2437\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 1 |
| **Node 07** | 2.4 GHz | CH 7 | $2442\ \text{MHz}$ | Vertikal | Bank 1 |
| **Node 08** | 2.4 GHz | CH 8 | $2447\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 1 |
| **Node 09** | 2.4 GHz | CH 9 | $2452\ \text{MHz}$ | Vertikal | Bank 1 |
| **Node 10** | 2.4 GHz | CH 10 | $2457\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 1 |
| **Node 11** | 2.4 GHz | CH 11 | $2462\ \text{MHz}$ | Vertikal | Bank 2 |
| **Node 12** | 2.4 GHz | CH 12 | $2467\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 2 |
| **Node 13** | 2.4 GHz | CH 13 | $2472\ \text{MHz}$ | Vertikal | Bank 2 |
| **Node 14** | 5 GHz UNII-1 | CH 36 | $5180\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 2 |
| **Node 15** | 5 GHz UNII-1 | CH 40 | $5200\ \text{MHz}$ | Vertikal | Bank 2 |
| **Node 16** | 5 GHz UNII-1 | CH 44 | $5220\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 2 |
| **Node 17** | 5 GHz UNII-1 | CH 48 | $5240\ \text{MHz}$ | Vertikal | Bank 2 |
| **Node 18** | 5 GHz UNII-2A | CH 52 | $5260\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 2 |
| **Node 19** | 5 GHz UNII-2A | CH 56 | $5280\ \text{MHz}$ | Vertikal | Bank 2 |
| **Node 20** | 5 GHz UNII-2A | CH 60 | $5300\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 2 |
| **Node 21** | 5 GHz UNII-2A | CH 64 | $5320\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 22** | 5 GHz UNII-2C | CH 100 | $5500\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 3 |
| **Node 23** | 5 GHz UNII-2C | CH 104 | $5520\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 24** | 5 GHz UNII-2C | CH 108 | $5540\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 3 |
| **Node 25** | 5 GHz UNII-2C | CH 112 | $5560\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 26** | 5 GHz UNII-2C | CH 116 | $5580\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 3 |
| **Node 27** | 5 GHz UNII-2C | CH 120 | $5600\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 28** | 5 GHz UNII-2C | CH 124 | $5620\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 3 |
| **Node 29** | 5 GHz UNII-2C | CH 128 | $5640\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 30** | 5 GHz UNII-2C | CH 132 | $5660\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 3 |
| **Node 31** | 5 GHz UNII-2C | CH 136 | $5680\ \text{MHz}$ | Vertikal | Bank 3 |
| **Node 32** | 5 GHz UNII-2C | CH 140 | $5700\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 4 |
| **Node 33** | 5 GHz UNII-2C | CH 144 | $5720\ \text{MHz}$ | Vertikal | Bank 4 |
| **Node 34** | 5 GHz UNII-3 | CH 149 | $5745\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 4 |
| **Node 35** | 5 GHz UNII-3 | CH 153 | $5765\ \text{MHz}$ | Vertikal | Bank 4 |
| **Node 36** | 5 GHz UNII-3 | CH 157 | $5785\ \text{MHz}$ | Horizontal ($-45^\circ$) | Bank 4 |
| **Node 37** | 5 GHz UNII-3 | CH 161 | $5805\ \text{MHz}$ | Vertikal | Bank 4 |
| **Node 38** | 5 GHz UNII-3 | CH 165 | $5825\ \text{MHz}$ | Horizontal ($+45^\circ$) | Bank 4 |
| **Node 39** | 2.4 GHz ISM | BLE Adv | $2402/26/80\ \text{MHz}$ | Vertikal | Bank 4 |
| **Node 40** | 2.4 GHz ISM | Redundant 1/6/11 | Tri-Channel Hop | Horizontal ($-45^\circ$) | Bank 4 |
| **Node 41** | Dynamic UNII | CH 169/Probe | $5845\ \text{MHz}$ | Vertikal | Bank 4 |

### 4.2 HF-Montage und Antennendiversität
* **Räumliche Entkopplung:** Antennenanschlüsse im Gehäusepanel in einem versetzten Raster (Staggered Grid) anordnen. Mindestabstand $d \ge \lambda/4$ bei $2.4\ \text{GHz}$ ($d \ge 3.1\ \text{cm}$). Empfohlen: $5\ \text{cm}$ Lochabstand.
* **Polarisationsdiversität:** Benachbarte Antennen sind alternierend vertikal ($90^\circ$), nach links gekippt ($+45^\circ$) und nach rechts gekippt ($-45^\circ$) zu montieren. Dies verhindert Empfangsauslöschungen bei unvollständiger Polarisationsanpassung des Zielsenders und dämpft Nahfeldkopplungen zwischen den Empfängern um bis zu $15\ \text{dB}$.
* **Kabeldämpfung:** RG316 Pigtails weisen bei $5.8\ \text{GHz}$ eine Dämpfung von ca. $1.5\ \text{dB/m}$ auf. Bei $15\ \text{cm}$ Kabellänge beträgt der Leitungsverlust lediglich $\approx 0.22\ \text{dB}$, was vernachlässigbar ist.

---

## 5. Stromversorgungs- & Schutzkonzept

### 5.1 Leistungsbilanz & Dimensionierung
Der Strombedarf teilt sich auf 41 Worker Nodes, 43 RS-485 Transceiver, das Master Gateway und den Raspberry Pi Host auf:

* **ESP32-C5 Nodes (41x):**
  * RX-Dauerstrom (Promiscuous Mode, Dual-Band aktiv): ca. $85\ \text{mA}$ pro Node.
  * Transiente Peaks bei Verarbeitungsspitzen: bis zu $180\ \text{mA}$.
  * $I_{\text{Nodes, nom}} = 41 \times 0.085\ \text{A} = 3.485\ \text{A}$
  * $I_{\text{Nodes, peak}} = 41 \times 0.180\ \text{A} = 7.38\ \text{A}$
* **RS-485 Transceiver MAX13488E (43x):**
  * Ruhestrom / Empfang: ca. $4.5\ \text{mA}$ pro IC.
  * Sendestrom (treibend auf $54\ \Omega$ Last während Response): ca. $40\ \text{mA}$ (maximal 2 Nodes senden zeitgleich).
  * $I_{\text{RS485}} \approx (41 \times 0.0045\ \text{A}) + (2 \times 0.040\ \text{A}) \approx 0.265\ \text{A}$
* **Master ESP32-WROOM-32E (1x):**
  * Beide Kerne unter Last (240 MHz), kein Wi-Fi aktiv: ca. $80\ \text{mA}$.
* **Raspberry Pi Zero 2 W + u-blox M9N (1x):**
  * Pi Zero 2 W unter 4-Core CPU-Last: ca. $550\ \text{mA}$.
  * u-blox NEO-M9N (10 Hz Tracking, aktive Antenne mit LNA): ca. $65\ \text{mA}$.
  * $I_{\text{Host}} \approx 0.615\ \text{A}$

$$\sum I_{\text{Nominal}} \approx 3.49\ \text{A} + 0.27\ \text{A} + 0.08\ \text{A} + 0.62\ \text{A} \approx 4.46\ \text{A} \quad (\approx 23.2\ \text{W} \text{ bei } 5.2\ \text{V})$$
$$\sum I_{\text{Peak}} \approx 7.38\ \text{A} + 0.35\ \text{A} + 0.15\ \text{A} + 1.20\ \text{A} \approx 9.08\ \text{A} \quad (\approx 47.2\ \text{W} \text{ bei } 5.2\ \text{V})$$

**Sicherheitsmarge:** Der eingesetzte DC-DC Wandler (12 A Dauer / 15 A Peak) wird zu maximal 37% im Nennbetrieb und zu 60% im Peak ausgelastet. Dies garantiert hohe Lebensdauer und thermische Stabilität im geschlossenen Gehäuse.

### 5.2 Verteilertopologie & Entstörung
Zur Vermeidung von Ground-Bounces und Spannungsabfällen über lange Leiterbahnen wird eine streng sternförmige Einspeisung implementiert.

1. **Primärseite (12V Kfz / Akku):**
   * Kfz-Flachsicherung 15 A träge direkt am Stromeingang.
   * Überspannungsschutzdiode (TVS SMBJ15CA) parallel zum Eingang gegen Spannungsspitzen der Kfz-Lichtmaschine (Load Dump bis 40V).
2. **Sekundärseite (5.2V Hauptschiene):**
   * Ausgangsspannung auf **$5.20\ \text{V}$** kalibriert, um Leitungsabfälle unter Last zu kompensieren.
   * Sternverteiler aus 4 separaten Strängen via AWG 16 Silikonleitung ($1.5\ \text{mm}^2$) zu den 4 Platinen-Stripes.
3. **Platinen-Absicherung (Bank 1 bis 4):**
   * Jede Bank verfügt über eine eigene Polyfuse PTC ($I_{\text{Hold}} = 2.0\ \text{A}$, $I_{\text{Trip}} = 4.0\ \text{A}$).
   * Direkt hinter der Polyfuse puffert ein $1'000\ \mu\text{F}$ Low-ESR Aluminium-Elko transiente Stromspitzen.
4. **Pi- und Master-Entstörung (LC-Filter):**
   * Die digitale HF der 41 Nodes erzeugt erhebliche Ripple auf der 5V-Schiene.
   * Pi Zero 2W und Master ESP32 werden über ein LC-Filter gespeist:
     * Drossel $L = 10\ \mu\text{H}$ (min. 3 A Sättigungsstrom).
     * Elko $C = 470\ \mu\text{F}$ Low-ESR + $100\ \text{nF}$ Keramik.
     * Grenzfrequenz: $f_0 = \frac{1}{2 \pi \sqrt{10\ \mu\text{H} \cdot 470\ \mu\text{F}}} \approx 2.32\ \text{kHz}$. Schaltnetzteilrauschen ($> 100\ \text{kHz}$) wird um $> 60\ \text{dB}$ bedämpft.

---

## 6. Kommunikationsprotokolle & Datenstrukturen

### 6.1 RS-485 Polling-Protokoll (Master $\leftrightarrow$ Worker Nodes)
Um Buskollisionen auszuschließen, arbeiten beide RS-485 Busse im strikten Master-Polling-Verfahren (Half-Duplex Master-Command / Slave-Response).  
* **Baudrate:** $2'000'000\ \text{Baud}$ (2 Mbps), 8N1. (Übertragungszeit pro Byte: $5\ \mu\text{s}$).

#### Master Poll Request Frame (4 Bytes)
Der Master adressiert zyklisch Node 1 bis 20 auf Bus 1 und zeitgleich Node 21 bis 41 auf Bus 2.

```
+---------------+---------------+---------------+---------------+
| Sync (0xAA)   | Node ID (1-41)| Cmd (0x01)    | CRC-8         |
+---------------+---------------+---------------+---------------+
  Byte 0          Byte 1          Byte 2          Byte 3
```
* `Sync`: Fester Präfix `0xAA`.
* `Node ID`: Zieladresse ($1 \dots 41$).
* `Cmd`: `0x01` = Poll Data Request; `0x02` = Reset/Clear Buffer; `0x03` = Channel Reconfig.
* `CRC-8`: Polynom $x^8 + x^2 + x^1 + 1$ (`0x07`).

#### Slave Metadata Response Frame (43 Bytes)
Hat der adressierte Node ein neues Paket erfasst, antwortet er unmittelbar:

```
+--------+--------+--------+------------------+--------+--------+--------+-------+
| Sync   | NodeID | PktType| BSSID (MAC)      | RSSI   | Ch     | Auth   | SSID  |
| 0x55   | (1-41) | (1 B)  | (6 Bytes)        | (int8) | (uint8)| (uint8)| Length|
+--------+--------+--------+------------------+--------+--------+--------+-------+
  0        1        2        3 - 8              9        10       11       12     
  
+------------------------------------+-----------+---------------+
| SSID Payload                       | Sequence  | CRC-16-CCITT  |
| (Feste 24 Bytes, 0x00 gepadded)    | Counter   | (2 Bytes)     |
+------------------------------------+-----------+---------------+
  13 - 36                              37 - 40     41 - 42
```

* **Gesamtlänge:** Exakt 43 Bytes fix.
* Wenn der Node **keine neuen Daten** im Ringpuffer hat, sendet er ein Single-Byte Response: `0x00` (No Data).
* **Timing-Analyse (Worst Case bei Volllast):**
  * Poll Request: 4 Bytes $\rightarrow 20\ \mu\text{s}$.
  * Bus Turnaround Time (MAX13488E Auto-Direction): $< 2\ \mu\text{s}$.
  * Slave Antwort: 43 Bytes $\rightarrow 215\ \mu\text{s}$.
  * Zykluszeit pro Node: $\approx 250\ \mu\text{s}$.
  * Kompletter Sweep über 20 Nodes auf Bus 1: $20 \times 250\ \mu\text{s} = 5.0\ \text{ms}$.
  * **Ergebnis:** Jeder Funkkanal wird **200 Mal pro Sekunde ($200\ \text{Hz}$ Polling-Frequenz)** abgefragt!

### 6.2 Master-zu-Host High-Speed UART Protokoll (COBS + CRC32)
Die vom Master aggregierten Daten werden über einen einheitlichen Stream an den Raspberry Pi übertragen.

* **Schnittstelle:** UART mit RTS/CTS, Baudrate $921'600\ \text{Baud}$ (Durchsatz: ca. $92\ \text{kB/s}$).
* **Framing:** Consistent Overhead Byte Stuffing (COBS). Dadurch fungiert das Byte `0x00` als exklusiver Frame-Delimiter, ohne dass Escape-Sequenzen variable Längen erzwingen.
* **Master Outgoing Payload:**

```
+------------+---------------------------------------------------+------------+
| 0x00       | COBS-Encodete Payload                             | 0x00       |
| (Delimiter)| [ Master-Timestamp (4B) | Slave-Frame (43B) | CRC32 ] | (Delimiter)|
+------------+---------------------------------------------------+------------+
```

Der Raspberry Pi liest Byteströme bis zum nächsten `0x00`, dekodiert in-place und prüft das angehängte CRC32-Feld. Fehlerhafte Übertragungen werden verworfen.

---

## 7. Firmware-Architektur (Worker & Master)

### 7.1 Worker Node Firmware (ESP32-C5)
Kompiliert mit ESP-IDF v5.3+ (RISC-V Toolchain).

```c
// worker_sniffer.c - Pseudo-Code Logik für C5
#include "esp_wifi.h"
#include "driver/uart.h"

#define NODE_ID 14                 // Fest im Flash hinterlegt (z. B. CH 36)
#define TARGET_CHANNEL 36
#define TARGET_SECOND_CHANNEL WIFI_SECOND_CHAN_NONE

typedef struct __attribute__((packed)) {
    uint8_t sync;
    uint8_t node_id;
    uint8_t pkt_type;
    uint8_t bssid[6];
    int8_t  rssi;
    uint8_t channel;
    uint8_t authmode;
    uint8_t ssid_len;
    uint8_t ssid[24];
    uint32_t seq_num;
    uint16_t crc16;
} frame_payload_t;

// Lock-Free Ringbuffer für gefilterte Pakete
ringbuf_t *packet_buffer;

void wifi_promiscuous_rx_cb(void *buf, wifi_promiscuous_pkt_type_t type) {
    const wifi_promiscuous_pkt_t *pkt = (wifi_promiscuous_pkt_t *)buf;
    const uint8_t *payload = pkt->payload;
    
    // Nur Management Frames (Beacons, Probe Resp/Req) auswerten
    uint16_t frame_ctrl = payload[0] | (payload[1] << 8);
    uint8_t sub_type = (frame_ctrl >> 4) & 0x0F;
    
    if ((frame_ctrl & 0x0C) == 0x00) { // Type: Management
        frame_payload_t item;
        item.sync = 0x55;
        item.node_id = NODE_ID;
        item.rssi = pkt->rx_ctrl.rssi;
        item.channel = TARGET_CHANNEL;
        
        // BSSID Extraktion (Addr3 bei Beacon/Probe Resp)
        memcpy(item.bssid, &payload[16], 6);
        
        // SSID Parsing aus Tagged Parameters (Tag 0)
        parse_ssid_ie(&payload[24], pkt->rx_ctrl.sig_len - 24, item.ssid, &item.ssid_len);
        
        item.crc16 = calculate_crc16(&item, sizeof(item) - 2);
        ringbuf_push_overwrite(packet_buffer, &item);
    }
}

void rs485_poll_task(void *pvParameters) {
    uint8_t rx_buf[4];
    while (1) {
        // Blockierendes Lesen auf Master-Sync (0xAA, NODE_ID, 0x01, CRC)
        int len = uart_read_bytes(UART_NUM_1, rx_buf, 4, portMAX_DELAY);
        if (len == 4 && rx_buf[0] == 0xAA && rx_buf[1] == NODE_ID) {
            if (verify_crc8(rx_buf, 3, rx_buf[3])) {
                frame_payload_t out_frame;
                if (ringbuf_pop(packet_buffer, &out_frame)) {
                    uart_write_bytes(UART_NUM_1, &out_frame, sizeof(out_frame));
                } else {
                    uint8_t no_data = 0x00;
                    uart_write_bytes(UART_NUM_1, &no_data, 1);
                }
            }
        }
    }
}
```

### 7.2 Master Controller Firmware (ESP32-WROOM-32E)
Verteilt das Polling streng auf die beiden CPU-Kerne von FreeRTOS.

* **Core 0 (Task `poll_bus1`):**
  * Exklusiver Zugriff auf UART1 (GPIO 16/17, MAX13488E #1).
  * Iteriert `for(node = 1; node <= 20; node++)`.
  * Schreibt empfangene Payloads in eine thread-sichere FreeRTOS Stream-Queue (`xQueueStreamOut`).
* **Core 1 (Task `poll_bus2`):**
  * Exklusiver Zugriff auf UART2 (GPIO 21/22, MAX13488E #2).
  * Iteriert `for(node = 21; node <= 41; node++)`.
  * Schreibt empfangene Payloads in dieselbe Stream-Queue.
* **DMA/Interrupt UART-Streamer (Task `stream_host` auf Core 0):**
  * Liest kontinuierlich aus `xQueueStreamOut`.
  * Berechnet CRC32 der Metadaten.
  * Führt In-Place COBS-Codierung durch.
  * Sendet Frame via UART0 (921'600 Baud) mit aktiviertem CTS-Monitoring. Ist CTS High (Pi meldet Busy), puffert der Master bis zu $64\ \text{kB}$ im internen SRAM.

---

## 8. Frontend Host Daemon & Datenbank (Raspberry Pi Zero 2 W)

### 8.1 Ingest Pipeline Architektur
Auf dem Raspberry Pi läuft ein systemd-Service in Python 3 / C-Extension oder optimiertem Go/Rust.

```
       [ /dev/ttyAMA0 ] (921'600 Baud)           [ /dev/i2c-1 ] (NEO-M9N)
               |                                         |
        [ UART-Worker ]                           [ GNSS-Poller ]
         (COBS Decode)                             (10 Hz UBX-NAV-PVT)
               |                                         |
        [ Check CRC32 ]                                  |
               |                                         |
               +-------------------+---------------------+
                                   |
                         [ Atomic Sync Point ]
                      (Match Package mit Lat/Lon)
                                   |
                        [ Bloom-Filter Check ]
                     (BSSID + Encryption Type)
                                   |
                  +----------------+----------------+
                  | (Neu)                           | (Bereits gesehen)
                  v                                 v
        [ SQLite WAL Queue ]                 [ RSSI Peak Update ]
        (Transaktionaler Bulk)                      |
                  |                                 +--> Verwerfen / Skip
                  v
        [ wigle_log.csv ]
```

### 8.2 GNSS Konfiguration (u-blox UBX)
Das Modul wird über I2C mit einer festen Taktrate von **10 Hz** betrieben. Standardmäßig liefert u-blox über I2C ASCII-NMEA-Sentences. Um CPU-Overhead auf dem Pi Zero 2 W zu eliminieren, wird NMEA deaktiviert und rein binäres **UBX-NAV-PVT** gepollt:
* Sende `UBX-CFG-PRT` um NMEA auf I2C zu deaktivieren.
* Sende `UBX-CFG-RATE` mit `measRate = 100` ($100\ \text{ms} \rightarrow 10\ \text{Hz}$).
* Bei $10\ \text{Hz}$ Fixrate hat das Fahrzeug bei $50\ \text{km/h}$ ($13.8\ \text{m/s}$) eine Geodaten-Präzision von $1.38\ \text{m}$ Wegstrecke pro GNSS-Sample.

### 8.3 In-Memory Bloom Filter zur Deduplizierung
Um Flash-Schreibzyklen zu minimieren und die SQLite-Schreiblast um bis zu 95% zu reduzieren, wird ein Bloom-Filter im LPDDR2-RAM gehalten.
* **Parameter:** $n = 500'000$ einzigartige BSSIDs, Falsch-Positiv-Rate $p = 0.1\%$ ($0.001$).
* **Speicherbedarf:**
  $$m = -\frac{n \cdot \ln(p)}{(\ln 2)^2} = -\frac{500000 \cdot (-6.9077)}{0.48045} \approx 7'188'650\ \text{Bits} \approx 877\ \text{kB}$$
  Mit weniger als **1 MB RAM-Verbrauch** filtert der Pi redundante Beacons vollständig im Arbeitsspeicher ab. Nur Netze mit neuen Eigenschaften (SSID-Wechsel, anderer Kanal, stärkere Signalstärke $\Delta \text{RSSI} > 6\ \text{dB}$) passieren den Filter.

### 8.4 SQLite WAL Datenbankschema
Die Speicherung erfolgt in SQLite mit Write-Ahead-Logging (WAL) für maximale Schreibdurchsätze ohne Locks.

```sql
-- Initialisierung der Datenbank
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA temp_store = MEMORY;
PRAGMA cache_size = -32000; -- 32 MB Cache

CREATE TABLE IF NOT EXISTS networks (
    bssid TEXT PRIMARY KEY,
    ssid TEXT,
    capabilities TEXT,
    frequency INTEGER,
    channel INTEGER,
    first_seen INTEGER,
    last_seen INTEGER,
    best_rssi INTEGER,
    best_lat REAL,
    best_lon REAL,
    best_altitude REAL,
    accuracy REAL
) WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS observations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    bssid TEXT,
    timestamp INTEGER,
    rssi INTEGER,
    lat REAL,
    lon REAL,
    alt REAL,
    channel INTEGER,
    FOREIGN KEY(bssid) REFERENCES networks(bssid)
);

CREATE INDEX IF NOT EXISTS idx_obs_bssid ON observations(bssid);
```

### 8.5 WiGLE CSV Generator
Der Ingest-Daemon schreibt konform zum WiGLE CSV Format Release 2:

```csv
WigleWifi-1.4,appRelease=1.0,model=MultiNodeRig,release=1.0,device=ESP32C5Cluster,display=None,board=Cluster,brand=Custom
MAC,SSID,AuthMode,FirstSeen,Channel,RSSI,CurrentLatitude,CurrentLongitude,AltitudeMeters,AccuracyMeters,Type
00:11:22:33:44:55,MyHomeAP,[WPA2-PSK-CCMP][ESS],2026-09-24 12:00:00,36,-64,52.520008,13.404954,45.2,2.1,WIFI
```

---

## 9. Montageanleitung, Verdrahtung & Inbetriebnahmeprotokoll

### 9.1 Mechanische Struktur (Die 4 Cluster-Stripes)
* Die 41 Nodes werden auf 4 Streifenrasterplatinen aufgeteilt:
  * Stripe 1: Nodes 01 bis 10 (Bus 1)
  * Stripe 2: Nodes 11 bis 20 (Bus 1)
  * Stripe 3: Nodes 21 bis 31 (Bus 2)
  * Stripe 4: Nodes 32 bis 41 (Bus 2)
* Jeder Seeed XIAO C5 wird mit 2-poligen Stiftleisten gesockelt montiert, um im Defektfall austauschbar zu bleiben.
* Die SOIC-8 Transceiver (MAX13488E) sitzen jeweils direkt neben dem Node auf SMD-Adapterplatinen oder sind direkt auf der Streifenrasterbahn verdrahtet.
* **Wärmeableitung:** Auf jedes HF-Shield des ESP32-C5 wird ein $10 \times 10\ \text{mm}$ Kupferkühlkörper mit wärmeleitendem Klebeband (3M 8810) geklebt.

### 9.2 Schritt-für-Schritt Inbetriebnahmeprotokoll (Checkliste)

#### Phase 1: Kaltprüfung & Passive Validierung (Ohne Betriebsspannung)
1. **Durchgangstest Stromschienen:** Prüfe mit dem Multimeter im Widerstandsmodus den Widerstand zwischen $+5.2\ \text{V}$ und $\text{GND}$ an jedem Stripe. Der Widerstand muss im Megaohm-Bereich liegen (Kondensatoraufladung beobachten). Ein Wert unter $100\ \Omega$ deutet auf Lötbrücken hin.
2. **Bus-Terminierung messen:**
   * Multimeter an Bus 1: Messe den differentiellen Widerstand zwischen Leitung A und Leitung B.
   * **Sollwert:** Exakt $60\ \Omega$ ($\pm 2\ \Omega$). (Zwei $120\ \Omega$ Widerstände parallel).
   * Multimeter an Bus 2: Gleiche Messung; Sollwert ebenfalls $60\ \Omega$.
3. **Fail-Safe Biasing messen:**
   * Widerstand von Leitung A gegen $+5\ \text{V}$: Sollwert $\approx 510\ \Omega$.
   * Widerstand von Leitung B gegen $\text{GND}$: Sollwert $\approx 510\ \Omega$.

#### Phase 2: Leistungsprüfung (Rauchtest)
1. Alle 41 Nodes und den Master aus ihren Sockeln entfernen! Nur die Transceiver (MAX13488E) verbleiben bestückt.
2. Kfz-Spannungsversorgung (12V) an Step-Down Wandler anlegen.
3. Ausgangsspannung des Wandlers mit Potentiometer exakt auf **$5.20\ \text{V}$** kalibrieren.
4. Spannung an Sockel-Pin 5V und GND aller 41 XIAO-Plätze prüfen.
5. Spannung am Ausgang des LC-Filters für Master und Pi Zero 2W prüfen ($5.18\ \text{V}$ bis $5.20\ \text{V}$).

#### Phase 3: Pegelwandler-Verifikation
1. Einen MAX13488E mit Test-Befehl treiben (RO geht auf High).
2. Spannung an Pin RX des XIAO-Sockels messen: **Darf keinesfalls über 3.35V liegen!** (Soll: $3.33\ \text{V}$).

#### Phase 4: Bestückung & Bus-Kommunikationstest
1. Ausschalten, Master-Modul und Node 01 einsetzen.
2. Master-Firmware via USB flashen. Oszilloskop an Bus 1 Leitung A/B anschließen.
3. Master sendet Poll-Telegramme für Node 01. Prüfe die Flankensteilheit auf dem Oszilloskop:
   * Keine übermäßigen Ringing-Effekte (Überschwinger $< 0.5\ \text{V}$).
   * Differenzspannung $V_A - V_B$ muss zwischen $+2.0\ \text{V}$ und $-2.0\ \text{V}$ schwingen.
4. Node 01 antwortet.
5. Nach erfolgreichem Test sukzessive alle Nodes 02 bis 41 sockeln.

---

## 10. Fehlerdiagnose-Matrix (Troubleshooting)

| Symptom | Mögliche Ursache | Messtechnischer Nachweis | Korrekturmaßnahme |
| :--- | :--- | :--- | :--- |
| **Node antwortet nicht auf Polling (Timeout)** | Falsche Node-ID in Firmware einkompiliert | Master meldet Frame Drop auf spezifischer ID | Firmware via USB neu flashen, `NODE_ID` abgleichen. |
| | Kalte Lötstelle am R1/R2 Pegelteiler | Oszilloskop an C5 RX: Signalpegel bleibt 0V | Lötstellen an R1 ($1\ \text{k}\Omega$) und R2 ($2\ \text{k}\Omega$) nachlöten. |
| | Bus A/B vertauscht | $V_A - V_B$ ist im Ruhezustand negativ ($< -200\ \text{mV}$) | Pins 6 und 7 am Transceiver kreuzen. |
| **Hohe Frame-Error-Rate (CRC-Fehler)** | Fehlende oder falsche Bus-Terminierung | Signal an A/B zeigt starke Reflexionen / Überschwinger | $120\ \Omega$ Widerstände an den physischen Busenden prüfen. |
| | GND-Versatz zwischen Stripes | DC-Spannung zwischen GND Stripe 1 und Stripe 4 $> 50\ \text{mV}$ | Stern-Masseverbindung (AWG 16) verstärken. |
| **XIAO C5 stürzt sporadisch ab (Brownout)** | Stromspitze beim Starten der Radio-Transceiver | Einbruch der 5V-Schiene unter $4.5\ \text{V}$ im Oszilloskop sichtbar | $10\ \mu\text{F}$ Keramikkondensator direkt an die Pins des C5 nachlöten. |
| | PTC Polyfuse löst aus | Polyfuse wird fühlbar heiß ($> 70^\circ\text{C}$), Spannung bricht ein | Stripe auf Kurzschluss prüfen; ggf. Polyfuse auf 2.5 A erhöhen. |
| **Kein GNSS-Fix am Raspberry Pi** | I2C-Adresse falsch konfiguriert | `i2cdetect -y 1` zeigt keine Adresse `0x42` | Verkabelung SDA/SCL prüfen, Pull-Ups auf 3.3V verifizieren. |
| | Aktive Antenne erhält keine Phantomspeisung | Keine 3.3V am Innenleiter der SMA-Buchse messbar | Lötjumper für Antennenspeisung auf GNSS-Breakout schließen. |
| **Pi Zero 2W verliert Pakete (Buffer Overflow)** | Master überrennt Pi; Flow-Control inaktiv | Pin CTS bleibt dauerhaft LOW; Master sendet trotz Volllast weiter | GPIO 16/17 Pinbelegung prüfen; RTS/CTS in `/boot/firmware/config.txt` validieren. |
