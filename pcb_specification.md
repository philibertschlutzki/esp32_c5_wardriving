### 1. Schaltplan-Design & Topologie (EDA: KiCad / Altium)

#### Hierarchische Struktur

* **Master-Sheet:** DC-Spannungseinspeisung (z. B. XT30/Terminal Block für 5 V), Bulk-Kapazitäten ($2\times 470\ \mu\text{F}$ Low-ESR Polymer), primärer TVS-Schutz (CDSOT23-SM712), erster $120\ \Omega$-Abschlusswiderstand und Host-UART-Anbindung.
* **Sub-Sheet (Node-Kanal):** Erstellung eines parametrisierten Sub-Sheets für die 41 bzw. 42 Slaves zur fehlerfreien Vervielfältigung im Layout.

#### Verschaltung pro Node-Kanal

```
       +5V ------------+------------------------+
                       |                        |
                    [22µF]                   [100nF]
                    (0805)                   (0603)
                       |                        |
                       v                        v
            +---------------------+   +---------------------+
            | XIAO C5 / ESP32-C5  |   |    MAX13488EESA+    |
            |                     |   | Pin 8 (VCC)         |
            |                TXD1 |-->| Pin 4 (DI)          |
            |                     |   |                     |
            |                     |   | Pin 1 (RO)          |
            |                     |   +----------|----------+
            |                     |              | (5V CMOS)
            |                     |              v
            |                     |   +---------------------+
            |                     |   | 74LVC1G34 (Level-Sh)|
            |                     |   | VCC: 3.3V, Pin 2 (A)|
            |                RXD1 |<--| Pin 4 (Y) (3.3V)    |
            +---------------------+   +---------------------+
                       |                        |
                      GND                      GND

```

* **RX-Pegelwandlung:** Pin 1 ($RO$) des MAX13488E auf Eingang $A$ des 74LVC1G34W5-7 führen. Ausgang $Y$ direkt auf $RXD$ des ESP32-C5 routen. Der IC wird mit der $3.3\ \text{V}$-Rail des ESP32 versorgt.
* **TX-Pfad:** Pin $TXD$ des ESP32-C5 direkt auf Pin 4 ($DI$) des MAX13488E führen ($V_{\text{IH, min}} = 2.0\ \text{V}$).
* **Kondensator-Platzierung im Schema:**
* Der 100-nF-Kondensator liegt zwingend direkt zwischen Pin 8 ($V_{\text{CC}}$) und Pin 5 ($GND$) des MAX13488E.
* Die Parallelschaltung aus $22\ \mu\text{F}$ und $100\ \text{nF}$ liegt unmittelbar an den 5V/GND-Versorgungspins des ESP32-Moduls.



---

### 2. Lagenaufbau & Impedanzkontrolle (4-Layer Standard)

Für gängige Fertigungsprozesse (z. B. JLC2313, 1.6 mm Gesamtdicke, $1\ \text{oz} / 35\ \mu\text{m}$ Kupfer):

| Layer | Typ | Funktion | Spezifikation |
| --- | --- | --- | --- |
| **Layer 1 (Top)** | Signal | RS-485 Diff-Pairs, UART-Traces, Bauteilpads | Mikrostreifenleitung gegen L2 |
| **Layer 2 (Inner 1)** | Plane | Durchgehende Massefläche (Solid Ground) | Keine Signalrouten, lückenlos |
| **Layer 3 (Inner 2)** | Plane / Power | 5V-Hochstrombus & lokale 3.3V-Rails | Breite Polygone/Kupfergüsse |
| **Layer 4 (Bottom)** | Signal | Hilfsroutings, Masseverbindungen | Geschlossenes GND-Pouring |

#### Differentieller Wellenwiderstand RS-485 ($Z_{\text{diff}} = 120\ \Omega$)

* **Referenz:** L1 gegen L2 (Prepreg 2116/7628, Dielektrizitätskonstante $\epsilon_r \approx 4.2\text{--}4.5$, Dielektrikumsdicke $H \approx 0.1\text{--}0.2\ \text{mm}$).
* **Trace-Geometrie (Richtwerte, abhängig vom Fertiger-Stackup):**
* Leiterbahnbreite: $W \approx 0.15\text{--}0.20\ \text{mm}$
* Leiterbahnabstand: $S \approx 0.25\text{--}0.30\ \text{mm}$
* Toleranz: $\pm 10\%$ Target-Impedanz.



---

### 3. Layout- & Routing-Vorgaben

#### RS-485 Busführung (Daisy-Chain)

1. **Streng linearer Bus:** Die Leitungen $A$ und $B$ müssen sequenziell von Node 1 bis Node 42 durchverbunden werden. Stichleitungen (Stubs) zu den Pins 6 und 7 der Transceiver dürfen eine Länge von maximal $5\ \text{mm}$ aufweisen.
2. **Terminierung:** An den beiden extremen Endpunkten des physischen Busses (Node 1 und Node 42 bzw. Master) wird je ein $120\ \Omega$-Widerstand (0805) direkt zwischen $A$ und $B$ platziert. Dazwischenliegende Nodes bleiben unterminiert.
3. **TVS-Platzierung:** Der CDSOT23-SM712 muss unmittelbar an der Eingangs- bzw. Ausgangs-Steckverbindung liegen. Die Leitungen $A$ und $B$ werden zuerst auf die Pads des TVS-Bausteins und von dort auf die Transceiver geführt.

#### HF- und Power-Integrität

* **Antennen-Freizonen:** Unter den Antennenbereichen der ESP32-C5 Module müssen sämtliche Kupferlagen (L1–L4) ausgespart werden (Antenna Keepout Zone gemäss Espressif Hardware Design Guidelines). Das Antennensegment muss bündig über den Platinenrand ragen.
* **Strombelastbarkeit 5V-Bus:**
* Maximaler Summen-Transientenstrom: $I_{\text{Peak}} \approx 42 \times 400\ \text{mA} \approx 16.8\ \text{A}$.
* Auslegung auf L3 als Polygon mit einer Mindestbreite von $12\text{--}15\ \text{mm}$ (bei $35\ \mu\text{m}$ Kupfer) oder Verteilung auf Top- und Bottom-Kupferflächen mit Stitching-Vias.
* Zulässiger Spannungsabfall über die gesamte Buslänge: $\Delta V \le 0.25\ \text{V}$.


* **Entkopplung:** Vias von den Kondensator-Pads zur GND-Plane (L2) müssen direkt am Pad mit möglichst geringer Zuleitungsinduktivität platziert werden (Via-in-Pad oder Adjacent-Via mit doppeltem Via-Übergang).

---

### 4. Fertigungsdateien & PCBA-Übergabe

#### Gerber- und Bohrdaten

* Export nach **RS-274X** oder **Gerber X2** mit metrischem Format (4:4) sowie getrennten NC-Drill-Dateien für durchkontaktierte (PTH) und nicht durchkontaktierte (NPTH) Bohrungen.

#### Stückliste (BOM) für SMT-Fertiger

Die BOM muss im CSV-/XLSX-Format mit eindeutigen Zuordnungen formatiert werden:

| Designator | Value | Package | LCSC / Part Number | Typ |
| --- | --- | --- | --- | --- |
| U1–U43 | MAX13488EESA+ | SOIC-8 | C71317 (oder ADI Originallink) | Transceiver |
| U44–U86 | 74LVC1G34W5-7 | SOT-23-5 | Diodes Inc. / Nexperia | Level Shifter |
| C1–C43 | 100nF, 25V, X7R | 0603 | Basic Part (z.B. C14663) | Entkopplung |
| C44–C85 | 22µF, 10V, X5R | 0805 | Extended Part | Pufferung |
| C86, C87 | 470µF, 10V | Radial SMD 6.3x8 | Low-ESR Polymer | Bulk-Puffer |
| R1, R2 | 120R, 1%, 1/4W | 0805 | Basic Part | Abschluss |
| D1, D2 | CDSOT23-SM712 | SOT-23 | Bourns | TVS-Diode |

#### Centroid / CPL-Datei (Pick & Place)

* Erzeugung der Spalten: `Designator`, `Val`, `Package`, `Mid X`, `Mid Y`, `Rotation`, `Layer`.
* **Prüfung:** Nullpunkt-Referenzierung und Drehwinkel (Rotation $0^\circ, 90^\circ, 180^\circ, 270^\circ$) für ICs (Pin 1) und Dioden in der 3D-Vorschau des Fertiger-Portals verifizieren.
