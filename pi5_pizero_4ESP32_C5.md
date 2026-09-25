# Technisches Systemkonzept v2.1: 41-Kanal ESP32-C5 Dual-Band Sniffer-Array
## Modulare 2-Einheiten-Architektur (RF-Pod & Compute-Unit) mit AliExpress-BOM

---

## 1. Physische Split-Architektur (Unit A vs. Unit B)

Um Hochfrequenzverluste (Dämpfung auf 5 GHz) zu minimieren und gleichzeitig das Rechnersystem vor Witterung, Vibration und thermischen Extremen zu schützen, wird das Gesamtsystem in zwei räumlich getrennte Baugruppen aufgeteilt:

```
┌────────────────────────────────────────────────────────────────────────┐
│                   UNIT A: RF- & SENSOR-POD (Exterieur)                 │
│                 (Dachgepäckträger, Gehäuse oder Dachbox)               │
│                                                                        │
│  [ 41× Dual-Band Antennen (2.4 / 5.8 GHz) ]                            │
│         │                                                              │
│         │ 41× U.FL-auf-SMA Pigtails (RG-178 / RG-316, ≤ 15 cm)         │
│         ▼                                                              │
│  [ 41× ESP32-C5 Node Boards ]                                          │
│  (Montiert auf Trägerplatten, passive Kühlung / Alukern)               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    │ 41× USB-Verbindungsleitungen
                                    │ (Länge: 2.0 m bis max. 3.0 m)
                                    │ Geschirmt, AWG 24 (VBUS/GND) / AWG 28 (Data)
                                    │ Gebündelt in Gewebeschlauch / Wellrohr
                                    │
┌───────────────────────────────────▼────────────────────────────────────┐
│               UNIT B: COMPUTE-, HUB- & POWER-UNIT (Interieur)          │
│                 (Fahrzeug-Innenraum oder Kofferraum)                   │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ 4× Industrial Multi-TT USB-Hubs (10-Port / 16-Port Metallchassis)│  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │ 4× USB 2.0 High-Speed Uplinks    │
│                                     ▼                                  │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Host-SBC: Raspberry Pi 5 (8 GB)                                  │  │
│  │  ├─ RP1 I/O Controller (xHCI Bus 1 & Bus 3)                      │  │
│  │  ├─ M.2 PCIe HAT+ mit 1 TB NVMe SSD (WAL-Pufferung)              │  │
│  │  └─ Active Cooler (Dauerlast-Kühlung)                            │  │
│  └──────────────────────────────────┬───────────────────────────────┘  │
│                                     │ UART / GPIO 18 (PPS)             │
│  [ u-blox NEO-M9N GNSS-Empfänger ] ─┘                                  │
│                                                                        │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │ Power Distribution Network (PDN)                                 │  │
│  │  ├─ Kfz-Eingangsfilter (ISO 7637-2 TVS + Verpolschutz)           │  │
│  │  ├─ 2× Buck-Konverter 12V -> 5.15V (Hubs / Nodes)                │  │
│  │  └─ 1× Buck-Konverter 12V -> 5.10V (Raspberry Pi 5)              │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────────┘
```

### 1.1. Begründung der Schnittstellentrennung
* **HF-Dämpfungsminimierung:** Koaxialkabel (z. B. RG-178 oder RG-316) besitzen bei $5.8\text{ GHz}$ eine Dämpfung von ca. $2.5\text{ bis }3.0\text{ dB/m}$. Bei $3\text{ Metern}$ Koaxialkabel gingen über $75\%$ der Empfangsenergie ($>7\text{ dB}$) vor dem Empfänger verloren. Durch die Platzierung der 41 ESP32-C5 direkt an den Antennenfüßen in Unit A beträgt die HF-Leitungslänge maximal $15\text{ cm}$ (Dämpfung $<0.4\text{ dB}$).
* **Digitale Übertragungsrobustheit:** Das digitalisierte Signal wird als robuster USB-Bytestrom über symmetrische Differenzleitungen ($D+/D-$) verlustfrei über Distanzen von mehreren Metern in den Innenraum übertragen.

---

## 2. Physikalische & Signaltechnische Limits der USB-Leitungen

### 2.1. Signalintegrität & Signallaufzeit ($t_{\text{prop}}$)
Der USB-Serial-JTAG-Controller des ESP32-C5 arbeitet nach dem **USB 2.0 Full-Speed** Standard mit $12\text{ Mbit/s}$ ($\text{Bitdauer } T_{\text{bit}} \approx 83.33\text{ ns}$).

1. **Laufzeitgrenze des Standards:** 
   USB 2.0 spezifiziert für Full-Speed Kabel eine maximale einfache Signallaufzeit von:
   $$t_{\text{prop, max}} = 26\text{ ns}$$
   Bei gängigen Dielektrika von USB-Kabeln (Polyethylen/PVC, Verkürzungsfaktor NVP $\approx 0.66$ bis $0.69$, entspricht ca. $5.0\text{ ns/m}$) ergibt sich die theoretische Obergrenze von:
   $$L_{\text{theor}} = \frac{26\text{ ns}}{5.2\text{ ns/m}} \approx 5.0\text{ Meter}$$
2. **Kabelreflektionen und Flankensteilheit:**
   Die Slew-Rate-Treiber im ESP32-C5 sind für Lastkapazitäten bis standardmäßig $C_L \approx 200\text{ bis }300\text{ pF}$ ausgelegt. Bei Leitungslängen über $3.0\text{ m}$ steigt die Kabelkapazität (typisch $50\text{ pF/m}$) zusammen mit Steckverbindungen auf $>180\text{ pF}$, was zu Flankenverrundungen führt.

### 2.2. Ohmscher Spannungsabfall auf $V_{\text{BUS}}$
Jeder ESP32-C5 nimmt bei voller Wi-Fi Promiscuous RX-Aktivität im Peak bis zu $I_{\text{peak}} = 350\text{ mA}$ auf. Die Versorgungsspannung wird von den Hubs in Unit B über das USB-Kabel zu den Nodes in Unit A geführt.

Der Schleifenwiderstand (Hin- und Rückleiter $V_{\text{BUS}} + \text{GND}$) beträgt bei Kabellänge $L$:
$$R_{\text{loop}} = 2 \times L \times R'_{\text{Leiter}}$$

| Aderquerschnitt ($V_{\text{BUS}}$/GND) | $R'_{\text{Leiter}}$ ($\Omega/\text{m}$) | $R_{\text{loop}}$ bei $2.0\text{ m}$ | $R_{\text{loop}}$ bei $3.0\text{ m}$ | $R_{\text{loop}}$ bei $5.0\text{ m}$ | $\Delta V$ ($350\text{ mA}$) bei $3.0\text{ m}$ |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **AWG 28** (Billigkabel) | $0.213\ \Omega/\text{m}$ | $0.85\ \Omega$ | $1.28\ \Omega$ | $2.13\ \Omega$ | **$0.448\text{ V}$** (Kritisch!) |
| **AWG 24** (Standard Industrie) | $0.084\ \Omega/\text{m}$ | $0.34\ \Omega$ | $0.50\ \Omega$ | $0.84\ \Omega$ | **$0.176\text{ V}$** (Stabil) |
| **AWG 22** (Hochwertig) | $0.053\ \Omega/\text{m}$ | $0.21\ \Omega$ | $0.32\ \Omega$ | $0.53\ \Omega$ | **$0.111\text{ V}$** (Optimal) |

* **Toleranzgrenze am ESP32-C5 Node:** Der integrierte LDO benötigt typischerweise mindestens $3.6\text{ V}$ Eingangsspannung, um saubere $3.3\text{ V}$ bereitzustellen. Speist der Hub $5.15\text{ V}$ ein, bleiben bei AWG 28 und $3.0\text{ m}$ unter Einberechnung von Übergangswiderständen an zwei USB-Steckern ($2 \times 0.1\ \Omega \implies \Delta V_{\text{Stecker}} \approx 0.07\text{ V}$) noch ca. $4.63\text{ V}$ übrig. Bei Billigkabeln mit $5.0\text{ m}$ bricht die Spannung im Transienten-Peak unter $4.3\text{ V}$ ein, was Brownout-Resets des RISC-V Kerns auslösen kann.

### 2.3. Bündel-Übersprechen (Crosstalk) im 41-Kabelstrang
Werden 41 USB-Leitungen parallel in einem engen Kabelbaum über mehrere Meter geführt, induzieren die $12\text{ MHz}$-Signalflanken kapazitives und induktives Übersprechen in benachbarte Adernpaare.
* Ungeschirmte Leitungen führen bei 41 parallelen Strömen zu Framing-Errors und USB-Reset-Events.
* **Voraussetzung:** Jede der 41 USB-Leitungen muss zwingend **doppelt geschirmt** sein (Geflechtschirm + Alufolie, STP - Shielded Twisted Pair).

### 2.4. Verbindliche Längenvorgabe
* **Absolute Obergrenze:** **$3.0\text{ Meter}$** (nur mit spezifizierten AWG 24/28 STP-Kabeln).
* **Empfohlene Nennlänge:** **$2.0\text{ bis }2.5\text{ Meter}$**. Dies reicht in gängigen Kfz-Konfigurationen aus, um vom Dach/Heckbereich sauber in den Kofferraum oder die Reserveradmulde zu gelangen, und garantiert minimale Signal-Latenzen sowie uneingeschränkte Spannungsstabilität.

---

## 3. Vollständige Stückliste (BOM) via AliExpress

Die Stückliste enthält alle zum Bau des Gesamtsystems benötigten Baugruppen, spezifiziert mit den auf AliExpress üblichen Suchbegriffen, Spezifikationen und geschätzten Preisen.

### 3.1. Unit A: RF- & Sensor-Array (Dach-/Außenbereich)

| Pos | Komponente / Artikel | Spezifikation & Suchbegriff (AliExpress) | Menge | Stk.-Preis ($) | Ges.-Preis ($) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **A1** | **ESP32-C5 Entwicklungsboard** | `ESP32-C5 Development Board RISC-V Dual-Band WiFi 6 2.4G 5G Type-C` (WROOM-1 Modul mit U.FL/IPEX Buchse) | 43 *(inkl. 2x Ersatz)* | $5.20 | $223.60 |
| **A2** | **Dual-Band Wi-Fi 6 Antennen** | `Dual Band 2.4G 5.8G Omni Antenna 3dBi 5dBi SMA Male for Router Drone` | 43 *(inkl. 2x Ersatz)* | $0.95 | $40.85 |
| **A3** | **HF-Pigtails (U.FL auf SMA)** | `IPEX MHF1 / U.FL to SMA Female Bulkhead RG178 Cable 10cm / 15cm` | 45 | $0.55 | $24.75 |
| **A4** | **Wasserdichtes Gehäuse Unit A** | `IP65 / IP67 Waterproof Plastic Enclosure ABS Junction Box 380x260x120mm` | 1 | $24.00 | $24.00 |
| **A5** | **Aluminium-Montageplatte** | `Perforated Aluminum Plate Sheet 2mm thickness 350x240mm` (Kühlkörper & Träger) | 2 | $8.50 | $17.00 |
| **A6** | **Wärmeleitpads** | `Thermal Conductive Silicone Pad 100x100x1.5mm 6.0 W/mK` | 4 | $2.20 | $8.80 |
| **A7** | **Kabeldurchführung (Mehrfach)** | `Multi-hole Cable Gland M32 / M40 Split Cable Entry Plate` (für 41 Kabel) | 2 | $7.50 | $15.00 |
| — | **Zwischensumme Unit A** | — | — | — | **$354.00** |

---

### 3.2. Verbindungs-Kabelbaum (Unit A nach Unit B)

| Pos | Komponente / Artikel | Spezifikation & Suchbegriff (AliExpress) | Menge | Stk.-Preis ($) | Ges.-Preis ($) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **C1** | **Industrie-USB-Kabel (2.5 m)** | `USB 2.0 A Male to Type-C Male Cable 2.5m Shielded 24AWG Power 28AWG Data Braided` | 43 | $2.40 | $103.20 |
| **C2** | **Gewebeschlauch (Bündelung)** | `Braided Cable Sleeving 40mm - 50mm PET Expandable Wire Loom 5M` | 1 | $8.00 | $8.00 |
| **C3** | **Schrumpfschlauch-Set** | `Heat Shrink Tubing Kit 2:1 Large Diameter 40mm / 50mm with Glue` | 1 | $6.50 | $6.50 |
| — | **Zwischensumme Verkabelung** | — | — | — | **$117.70** |

---

### 3.3. Unit B: Compute-, Hub- & Storage-Einheit (Innenraum)

| Pos | Komponente / Artikel | Spezifikation & Suchbegriff (AliExpress) | Menge | Stk.-Preis ($) | Ges.-Preis ($) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **B1** | **Raspberry Pi 5 (8 GB)** | `Raspberry Pi 5 8GB RAM BCM2712 Quad Core Cortex-A76 2.4GHz` | 1 | $88.00 | $88.00 |
| **B2** | **Pi 5 Active Cooler** | `Original Raspberry Pi 5 Active Cooler Heatsink PWM Fan` | 1 | $5.50 | $5.50 |
| **B3** | **M.2 NVMe PCIe HAT+** | `Raspberry Pi 5 M.2 NVMe HAT+ PCIe 2.0 / 3.0 M-Key 2280 Shield Board` | 1 | $8.50 | $8.50 |
| **B4** | **1 TB NVMe SSD M.2 2280** | `NVMe M.2 SSD 1TB PCIe 3.0x4 2280 (KingSpec / Netac / Fanxiang) >2000MB/s` | 1 | $54.00 | $54.00 |
| **B5** | **10-Port Multi-TT USB-Hubs** | `10 Port USB 2.0 Industrial Hub Metal Case Multi-TT GL852G / FE1.1s DC 5V/12V` | 3 | $28.00 | $84.00 |
| **B6** | **16-Port Multi-TT USB-Hub** | `16 Port USB 2.0 Industrial Metal Hub Multi-TT with Mounting Brackets` | 1 | $38.00 | $38.00 |
| **B7** | **Kurze USB-Host-Kabel (0.3 m)** | `USB 2.0 A Male to A Male Cable 30cm Short Shielded` (Hub zu Pi 5) | 4 | $1.10 | $4.40 |
| **B8** | **u-blox NEO-M9N GNSS Modul** | `NEO-M9N GNSS GPS Module Multi-Constellation 10Hz Dual Antenna Interface SMA` | 1 | $28.00 | $28.00 |
| **B9** | **Aktive GNSS-Dachantenne** | `Active GPS GLONASS Galileo High Gain 28dB Patch Antenna Magnetic SMA 3M` | 1 | $6.50 | $6.50 |
| **B10**| **Gehäuse Unit B (Metall/ABS)** | `Aluminum Extruded Enclosure Box / Industrial Instrument Case 250x190x80mm` | 1 | $19.00 | $19.00 |
| — | **Zwischensumme Unit B** | — | — | — | **$336.90** |

---

### 3.4. Power Distribution Network (PDN) & Automotive-Bordnetz

| Pos | Komponente / Artikel | Spezifikation & Suchbegriff (AliExpress) | Menge | Stk.-Preis ($) | Ges.-Preis ($) |
| :---: | :--- | :--- | :---: | :---: | :---: |
| **P1** | **Automotive TVS & EMI Filter** | `12V 24V Car Audio Power Filter Anti-Interference Surge Protector Board` | 1 | $9.50 | $9.50 |
| **P2** | **KFZ Sicherungshalter + Sicherung** | `In-line Waterproof Standard Blade Fuse Holder 12AWG with 20A Fuse` | 2 | $2.00 | $4.00 |
| **P3** | **Hochleistungs-Buck (Wandler 1)** | `DC-DC 12V 24V to 5V 10A 50W Step Down Buck Converter Waterproof Module` (Hub 1 & 2) | 1 | $8.50 | $8.50 |
| **P4** | **Hochleistungs-Buck (Wandler 2)** | `DC-DC 12V 24V to 5V 10A 50W Step Down Buck Converter Waterproof Module` (Hub 3 & 4) | 1 | $8.50 | $8.50 |
| **P5** | **Präzisions-Buck (Wandler 3)** | `DC-DC Step Down Converter 12V to 5.1V 5A (TPS40057 / XL4015 Heatsink)` (Pi 5) | 1 | $5.80 | $5.80 |
| **P6** | **Schottky-Sperrdioden (10A)** | `10SQ050 / 10SQ045 10A 45V Schottky Barrier Rectifier Diodes` (Rückspeiseschutz) | 1 Pack (10 Stk) | $2.50 | $2.50 |
| **P7** | **Stromverteilerblock** | `12-Way Terminal Busbar Block 100A with Cover for 12V Automotive` | 1 | $7.20 | $7.20 |
| — | **Zwischensumme PDN** | — | — | — | **$46.00** |

---

### 3.5. Gesamtkosten-Übersicht

$$\begin{aligned}
\text{Unit A (Sensor-Pod)} &: \$354.00 \\
\text{Kabelstrang (41-fach)} &: \$117.70 \\
\text{Unit B (Compute & Hubs)} &: \$336.90 \\
\text{Power Distribution Network} &: \$46.00 \\
\hline
\mathbf{\text{Gesamtsystem}} &: \mathbf{\$854.60}
\end{aligned}$$

---

## 4. Detailliertes Power Distribution Network (PDN)

Um Masseschleifen, Brownouts und thermische Überlastungen im Kfz-Betrieb auszuschliessen, wird das Bordnetz über drei galvanisch parallele Buck-Pfade entkoppelt.

```
 [ Kfz-Bordnetz: 12V/24V Batterie (9V .. 32V) ]
                        │
                        ▼
       [ 20A Kfz-Schmelzsicherung (In-Line) ]
                        │
                        ▼
       ┌───────────────────────────────────────────────┐
       │ Automotive Filterstufe (ISO 7637-2 / SM5S24A) │
       │  - P-Kanal MOSFET Verpolschutz (RDS_on < 4mΩ) │
       │  - TVS-Diode 24V (Load-Dump-Clamping bis 40V) │
       │  - PI-Filter: 10µH Induktivität + 2× 1000µF   │
       └───────────────────────┬───────────────────────┘
                               │
            Gefilterte 12V-Schiene (Hauptverteiler)
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
 ┌──────────────┐       ┌──────────────┐       ┌──────────────┐
 │ Buck-Modul 1 │       │ Buck-Modul 2 │       │ Buck-Modul 3 │
 │ 12V -> 5.15V │       │ 12V -> 5.15V │       │ 12V -> 5.10V │
 │ (10 A Peak)  │       │ (10 A Peak)  │       │ (5 A Peak)   │
 └──────┬───────┘       └──────┬───────┘       └──────┬───────┘
        │                      │                      │
        │ 10SQ045              │ 10SQ045              │ Direkteinspeisung
        │ Diode                │ Diode                │ Pin 2 & 4 (GND: 6)
        ▼                      ▼                      ▼
 ┌──────────────┐       ┌──────────────┐       ┌──────────────┐
 │ Hub 1 & 2    │       │ Hub 3 & 4    │       │ Raspberry    │
 │ (21 Nodes)   │       │ (20 Nodes)   │       │ Pi 5 + NVMe  │
 └──────┬───────┘       └──────┬───────┘       └──────┬───────┘
        │                      │                      │
        └──────────────┬───────┴──────────────────────┘
                       │
             Gemeinsamer GND-Sternpunkt
          (Zentraler Bolzen am Gehäuse B)
```

### 4.1. Hardware-Schutz gegen VBUS-Backpowering
Da die aktiven Industrie-Hubs mit $5.15\text{ V}$ und der Raspberry Pi 5 mit $5.10\text{ V}$ versorgt werden, würde über die $V_{\text{BUS}}$-Leitungen der vier Uplink-Kabel ein parasitärer Ausgleichsstrom fliessen:
$$\Delta V = 5.15\text{ V} - 5.10\text{ V} = 0.05\text{ V}$$
* **Pflichtmaßnahme:** Bei den vier kurzen USB-Kabeln zwischen Pi 5 und den Hubs (Pos. B7) wird **die $5\text{ V}$ $V_{\text{BUS}}$-Ader physisch unterbrochen** (Kabel anritzen und roten Draht kappen oder Isolierband auf Pin 1 des USB-A Steckers kleben). 
* Die Signaladern ($D+$, $D-$) und die **Masse-Ader (GND)** bleiben zwingend verbunden, um das Bezugspotential der Differenztreiber zu garantieren.

---

## 5. Hub-Topologie & xHCI-Controller-Mapping am Pi 5

Der Raspberry Pi 5 führt seine vier USB-Ports über den PCIe-gebundenen I/O-Controller **RP1**. Im RP1 arbeiten zwei voneinander unabhängige xHCI-Host-Controller.

```
                   [ BCM2712 SoC ]
                          │  PCIe 2.0 ×4
                          ▼
            [ RP1 I/O Controller ASIC ]
           ┌──────────────┴──────────────┐
           ▼                             ▼
   [ xHCI Controller 0 ]         [ xHCI Controller 1 ]
   (Root Hub: Bus 1)             (Root Hub: Bus 3)
     ├── Port 0 (USB 3.0)          ├── Port 1 (USB 3.0)
     └── Port 2 (USB 2.0)          └── Port 3 (USB 2.0)
           │                             │
     ┌─────┴─────┐                 ┌─────┴─────┐
     ▼           ▼                 ▼           ▼
   Hub 1       Hub 2             Hub 3       Hub 4
  (10 Ports)  (10 Ports)        (10 Ports)  (16 Ports)
  10 Nodes    10 Nodes          10 Nodes    11 Nodes
```

### 5.1. Mathematische Verifikation der xHCI-Ressourcen

Jeder xHCI-Controller im RP1 allokiert eine `Device Context Base Address Array` (DCBAA) mit maximal 64 Device-Slots (`MaxSlotsEn = 64`):

1. **Controller 0 (Bus 1):**
   * Verbundene Hubs: Hub 1 (1 Tier) + Hub 2 (1 Tier) = $2\text{ Slots}$
   * Verbundene Endgeräte: $10 + 10 = 20\text{ ESP32-C5 Nodes}$
   * Gesamt-Slots auf Controller 0: $2 + 20 = \mathbf{22\text{ Slots}} \le 64$ (**$34.4\%$ Auslastung**)
2. **Controller 1 (Bus 3):**
   * Verbundene Hubs: Hub 3 (1 Tier) + Hub 4 (Kaskadierter 16-Port = 2 Tiers) = $3\text{ Slots}$
   * Verbundene Endgeräte: $10 + 11 = 21\text{ ESP32-C5 Nodes}$
   * Gesamt-Slots auf Controller 1: $3 + 21 = \mathbf{24\text{ Slots}} \le 64$ (**$37.5\%$ Auslastung**)

* **Ergebnis:** Kein Controller überschreitet das Limit. Es verbleibt ein Headroom von $>60\%$. Ein Scheitern der USB-Enumeration durch Slot-Erschöpfung ist mathematisch ausgeschlossen.

---

## 6. Software- & Host-Konfiguration

### 6.1. Boot-Konfiguration (`/boot/firmware/config.txt`)
Die Begrenzung der USB-Stromaufnahme bei GPIO-Speisung muss aufgehoben und der PCIe-Bus für die NVMe SSD auf PCIe Gen 3 beschleunigt werden:

```ini
# PCIe Gen 3 fuer NVMe SSD aktivieren
dtparam=pcie=1
dtparam=pcie_gen=3

# USB-Strombegrenzung des Pi 5 aufheben (erzwingt 1.6A Gesamtbudget an den Ports)
usb_max_current_enable=1

# Hardware-UART fuer u-blox NEO-M9N GNSS Modul
enable_uart=1
dtoverlay=uart0

# PPS-Signal von GNSS Modul auf GPIO 18 mappen
dtoverlay=pps-gpio,gpiopin=18
```

### 6.2. Udev-Topologie-Regeln (`/etc/udev/rules.d/99-esp32-nodes.rules`)

Eindeutiges Mapping jedes physischen USB-Ports auf einen deterministischen Gerätenamen basierend auf dem RP1 Controller-Buspfad:

```udev
# =========================================================================
# RP1 Controller 0 (Bus 1)
# =========================================================================
# Hub 1 an Pi 5 Port 0 (Pfad 1-1.*) -> Nodes 00 bis 09
SUBSYSTEM=="tty", KERNELS=="1-1.1:1.0", SYMLINK+="esp_node_00", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.2:1.0", SYMLINK+="esp_node_01", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.3:1.0", SYMLINK+="esp_node_02", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.4:1.0", SYMLINK+="esp_node_03", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.5:1.0", SYMLINK+="esp_node_04", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.6:1.0", SYMLINK+="esp_node_05", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.7:1.0", SYMLINK+="esp_node_06", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.8:1.0", SYMLINK+="esp_node_07", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.9:1.0", SYMLINK+="esp_node_08", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-1.10:1.0", SYMLINK+="esp_node_09", MODE="0666"

# Hub 2 an Pi 5 Port 2 (Pfad 1-2.*) -> Nodes 10 bis 19
SUBSYSTEM=="tty", KERNELS=="1-2.1:1.0", SYMLINK+="esp_node_10", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.2:1.0", SYMLINK+="esp_node_11", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.3:1.0", SYMLINK+="esp_node_12", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.4:1.0", SYMLINK+="esp_node_13", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.5:1.0", SYMLINK+="esp_node_14", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.6:1.0", SYMLINK+="esp_node_15", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.7:1.0", SYMLINK+="esp_node_16", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.8:1.0", SYMLINK+="esp_node_17", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.9:1.0", SYMLINK+="esp_node_18", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="1-2.10:1.0", SYMLINK+="esp_node_19", MODE="0666"

# =========================================================================
# RP1 Controller 1 (Bus 3)
# =========================================================================
# Hub 3 an Pi 5 Port 1 (Pfad 3-1.*) -> Nodes 20 bis 29
SUBSYSTEM=="tty", KERNELS=="3-1.1:1.0", SYMLINK+="esp_node_20", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.2:1.0", SYMLINK+="esp_node_21", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.3:1.0", SYMLINK+="esp_node_22", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.4:1.0", SYMLINK+="esp_node_23", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.5:1.0", SYMLINK+="esp_node_24", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.6:1.0", SYMLINK+="esp_node_25", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.7:1.0", SYMLINK+="esp_node_26", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.8:1.0", SYMLINK+="esp_node_27", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.9:1.0", SYMLINK+="esp_node_28", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-1.10:1.0", SYMLINK+="esp_node_29", MODE="0666"

# Hub 4 an Pi 5 Port 3 (Pfad 3-2.*) -> Nodes 30 bis 40
SUBSYSTEM=="tty", KERNELS=="3-2.1:1.0", SYMLINK+="esp_node_30", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.2:1.0", SYMLINK+="esp_node_31", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.3:1.0", SYMLINK+="esp_node_32", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.4:1.0", SYMLINK+="esp_node_33", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.5:1.0", SYMLINK+="esp_node_34", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.6:1.0", SYMLINK+="esp_node_35", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.7:1.0", SYMLINK+="esp_node_36", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.8:1.0", SYMLINK+="esp_node_37", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.9:1.0", SYMLINK+="esp_node_38", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.10:1.0", SYMLINK+="esp_node_39", MODE="0666"
SUBSYSTEM=="tty", KERNELS=="3-2.11:1.0", SYMLINK+="esp_node_40", MODE="0666"
```

### 6.3. Systemd Service Unit (`/etc/systemd/system/wardriving-aggregator.service`)

```ini
[Unit]
Description=41-Channel Wardriving Stream Aggregator Core
After=network.target local-fs.target
RequiresMountsFor=/mnt/nvme

[Service]
Type=simple
User=root
WorkingDirectory=/opt/wardriving
ExecStart=/opt/wardriving/aggregator_core
Restart=always
RestartSec=3
LimitNOFILE=65536
CPUSchedulingPolicy=rr
CPUSchedulingPriority=80

[Install]
WantedBy=multi-user.target
```

---

## 7. Zusammenfassung der Leitungsdimensionierung

1. **Maximal zulässige Länge der USB-Kabel:** **$3.0\text{ Meter}$**. Längere passive Leitungen verletzen das Laufzeitbudget ($t_{\text{prop}} \le 26\text{ ns}$) und führen zu Instabilitäten durch Spannungsabfall auf $V_{\text{BUS}}$.
2. **Empfohlene Länge:** **$2.0\text{ bis }2.5\text{ Meter}$**. Dies minimiert die Kabelbaumdicke und das kapazitive Übersprechen im 41-Kanal-Bündel.
3. **Kabel-Spezifikation:** Es müssen zwingend Kabel mit **AWG 24 für Power** ($V_{\text{BUS}}$/GND) und **AWG 28 verdrillt für Daten** ($D+$/$D-$) mit Aluminiumfolie und Geflechtschirmung eingesetzt werden.
