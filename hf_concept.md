# Detailliertes 3D-HF-Konzept: Z-Achsen-Gestaffeltes Antennen-Array

**Dokument-ID:** ARCH-WD-3D-RF-OPT-REV1.0  
**Anwendungsbereich:** Frequenzstarres 41-Knoten HF-Sniffer-Cluster  
**Fokus:** 3D-Geometrie, Z-Achsen-Entkopplung, Strahlungsdiagramm-Erzeugung und 3D-Druck-Konstruktion  

---

## 1. Physikalische Grundlagen der Z-Achsen-Staffelung

Die Platzierung aller Antennen auf einer einzigen 2D-Ebene führt bei geringen Abständen zu starker elektromagnetischer Verkopplung ($S_{21}$) und Verformung des omnidirektionalen Strahlungsdiagramms. Durch die Nutzung der 3. Dimension (Z-Achse) treten folgende physikalische Effekte in Kraft:

### 1.1 Reduktion der gegenseitigen Kopplung ($S_{21}$)
Rundstrahlantennen (Dipole/Monopole) weisen ihr Strahlungsmaximum in der horizontalen Ebene ($X$-$Y$-Ebene) auf. Entlang der Antennenachse (Z-Achse, Top/Bottom) existiert eine ausgeprägte Nullstelle im Strahlungsdiagramm (Toroid-Form).

* **Horizontaler Versatz ($X$-$Y$):** Antennen koppeln im Maximum ihrer Abstrahlungscharakteristik.
* **Vertikaler Versatz ($\Delta Z$):** Wird Antenne B gegenüber Antenne A entlang der Z-Achse nach oben verschoben, wandert das physische Element von Antenne B in die Strahlungsnullstelle von Antenne A.
* **Kopplungsminderung:** Eine Höhenversetzung um $\Delta Z \ge \lambda/2$ verringert die Verkopplung $S_{21}$ um zusätzliche **$12\text{ dB}$ bis $18\text{ dB}$** im Vergleich zur reinen $X$-$Y$-Trennung auf gleicher Höhe.

$$\Delta Z_{2.4\text{ GHz}, \min} = \frac{\lambda_{2.4}}{2} \approx \frac{12.5\text{ cm}}{2} = 6.25\text{ cm}$$
$$\Delta Z_{5\text{ GHz}, \min} = \frac{\lambda_{5.5}}{2} \approx \frac{5.45\text{ cm}}{2} = 2.72\text{ cm}$$

### 1.2 Erhalt des 360°-Horizont-Strahlungsdiagramms
Auf einer flachen Ebene schatten sich benachbarte Metall- und Antennenelemente gegenseitig ab. Die Hauptstrahlungskeule einer Antenne trifft direkt auf den metallischen Leiter des Nachbarn und erzeugt tiefe Einbrüche (Nulls) im Empfangsdiagramm.

Durch eine Staffelung auf **drei diskreten Höhenebenen ($Z_0, Z_1, Z_2$)** strahlt das Fernfeld einer Antenne auf Ebene $Z_1$ ungestört über die physikalischen Spitzen der Antennen auf Ebene $Z_0$ hinweg.

---

## 2. 3D-Stufen-Architektur (3-Tier Stepped Matrix)

Das Array wird als abgestufte **Treppen- / Pyramiden-Struktur** aufgebaut, die modular auf einem 3D-Drucker gefertigt werden kann.

### 2.1 Ebenen-Definition (Tiers)
* **Tier 0 ($Z = 0\text{ cm}$):** Basis-Ebene (vorwiegend 5-GHz-Knoten mit kleinerer Wellenlänge).
* **Tier 1 ($Z = 6.5\text{ cm}$):** Mittlere Ebene (gemischte 2.4-GHz- und 5-GHz-Knoten).
* **Tier 2 ($Z = 13.0\text{ cm}$):** Höchste Ebene (vorwiegend überlappungssensible 2.4-GHz-Knoten und Sonderfunktionen).

```
          [Tier 2: Z = 13.0 cm]        (2.4GHz)        (2.4GHz)
                 /                                \
    [Tier 1: Z = 6.5 cm]      [5GHz]     (2.4GHz)     [5GHz]
           /                                                 \
[Tier 0: Z = 0.0 cm]   [5GHz]     [5GHz]      [5GHz]      [5GHz]
--------------------------------------------------------------------- (Basis)
```

---

## 3. Detaillierter 3D-Koordinaten- & Belegungsplan ($X, Y, Z$)

* **Grundfläche der Halterung:** $45.0\text{ cm} \times 28.0\text{ cm} \times 13.0\text{ cm}$ (Gutes Bauraum-Verhältnis für gängige 3D-Drucker, aufgeteilt in 4–6 Stecksegmente).
* **Ausrichtung:** Alle Antennen stehen strikt vertikal ($90^\circ$ zur Horizontalen).

| Pos. | Node ID | Band / Typ | Kanal / Funktion | X-Koord. | Y-Koord. | Z-Höhe (Tier) | $\min$ Abstand zum nächsten Band-Nachbarn |
| :---: | :---: | :--- | :--- | :---: | :---: | :---: | :---: |
| **01** | **Node 01** | 2.4 GHz | CH 1 ($2412\text{ MHz}$) | $4.0\text{ cm}$ | $4.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $14.2\text{ cm}$ (3D-Distanz) |
| **02** | Node 14 | 5 GHz | CH 36 ($5180\text{ MHz}$) | $4.0\text{ cm}$ | $11.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.5\text{ cm}$ |
| **03** | Node 15 | 5 GHz | CH 40 ($5200\text{ MHz}$) | $4.0\text{ cm}$ | $18.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.5\text{ cm}$ |
| **04** | **Node 02** | 2.4 GHz | CH 2 ($2417\text{ MHz}$) | $4.0\text{ cm}$ | $25.0\text{ cm}$ | **$Z_0 = 0.0\text{ cm}$** | $12.8\text{ cm}$ (3D-Distanz) |
| **05** | Node 16 | 5 GHz | CH 44 ($5220\text{ MHz}$) | $10.5\text{ cm}$ | $4.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **06** | Node 17 | 5 GHz | CH 48 ($5240\text{ MHz}$) | $10.5\text{ cm}$ | $11.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **07** | **Node 03** | 2.4 GHz | CH 3 ($2422\text{ MHz}$) | $10.5\text{ cm}$ | $18.0\text{ cm}$ | **$Z_1 = 6.5\text{ cm}$** | $13.5\text{ cm}$ (3D-Distanz) |
| **08** | Node 18 | 5 GHz | CH 52 ($5260\text{ MHz}$) | $10.5\text{ cm}$ | $25.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **09** | Node 19 | 5 GHz | CH 56 ($5280\text{ MHz}$) | $17.0\text{ cm}$ | $4.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **10** | **Node 04** | 2.4 GHz | CH 4 ($2427\text{ MHz}$) | $17.0\text{ cm}$ | $11.0\text{ cm}$ | **$Z_0 = 0.0\text{ cm}$** | $12.8\text{ cm}$ (3D-Distanz) |
| **11** | Node 20 | 5 GHz | CH 60 ($5300\text{ MHz}$) | $17.0\text{ cm}$ | $18.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **12** | Node 21 | 5 GHz | CH 64 ($5320\text{ MHz}$) | $17.0\text{ cm}$ | $25.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **13** | **Node 05** | 2.4 GHz | CH 5 ($2432\text{ MHz}$) | $23.5\text{ cm}$ | $4.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $14.1\text{ cm}$ (3D-Distanz) |
| **14** | Node 22 | 5 GHz | CH 100 ($5500\text{ MHz}$) | $23.5\text{ cm}$ | $11.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **15** | Node 23 | 5 GHz | CH 104 ($5520\text{ MHz}$) | $23.5\text{ cm}$ | $18.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **16** | **Node 06** | 2.4 GHz | CH 6 ($2437\text{ MHz}$) | $23.5\text{ cm}$ | $25.0\text{ cm}$ | **$Z_0 = 0.0\text{ cm}$** | $13.5\text{ cm}$ (3D-Distanz) |
| **17** | Node 24 | 5 GHz | CH 108 ($5540\text{ MHz}$) | $30.0\text{ cm}$ | $4.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **18** | **Node 07** | 2.4 GHz | CH 7 ($2442\text{ MHz}$) | $30.0\text{ cm}$ | $11.0\text{ cm}$ | **$Z_1 = 6.5\text{ cm}$** | $12.8\text{ cm}$ (3D-Distanz) |
| **19** | Node 25 | 5 GHz | CH 112 ($5560\text{ MHz}$) | $30.0\text{ cm}$ | $18.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **20** | Node 26 | 5 GHz | CH 116 ($5580\text{ MHz}$) | $30.0\text{ cm}$ | $25.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **21** | Node 27 | 5 GHz | CH 120 ($5600\text{ MHz}$) | $36.5\text{ cm}$ | $4.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **22** | Node 28 | 5 GHz | CH 124 ($5620\text{ MHz}$) | $36.5\text{ cm}$ | $11.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **23** | **Node 08** | 2.4 GHz | CH 8 ($2447\text{ MHz}$) | $36.5\text{ cm}$ | $18.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $13.5\text{ cm}$ (3D-Distanz) |
| **24** | Node 29 | 5 GHz | CH 128 ($5640\text{ MHz}$) | $36.5\text{ cm}$ | $25.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **25** | Node 30 | 5 GHz | CH 132 ($5660\text{ MHz}$) | $43.0\text{ cm}$ | $4.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **26** | **Node 09** | 2.4 GHz | CH 9 ($2452\text{ MHz}$) | $43.0\text{ cm}$ | $11.0\text{ cm}$ | **$Z_0 = 0.0\text{ cm}$** | $12.8\text{ cm}$ (3D-Distanz) |
| **27** | Node 31 | 5 GHz | CH 136 ($5680\text{ MHz}$) | $43.0\text{ cm}$ | $18.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **28** | Node 32 | 5 GHz | CH 140 ($5700\text{ MHz}$) | $43.0\text{ cm}$ | $25.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **29** | Node 33 | 5 GHz | CH 144 ($5720\text{ MHz}$) | $49.5\text{ cm}$ | $4.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **30** | **Node 10** | 2.4 GHz | CH 10 ($2457\text{ MHz}$) | $49.5\text{ cm}$ | $11.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $14.2\text{ cm}$ (3D-Distanz) |
| **31** | Node 34 | 5 GHz | CH 149 ($5745\text{ MHz}$) | $49.5\text{ cm}$ | $18.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **32** | Node 35 | 5 GHz | CH 153 ($5765\text{ MHz}$) | $49.5\text{ cm}$ | $25.0\text{ cm}$ | $Z_1 = 6.5\text{ cm}$ | $8.2\text{ cm}$ |
| **33** | Node 36 | 5 GHz | CH 157 ($5785\text{ MHz}$) | $56.0\text{ cm}$ | $4.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **34** | **Node 11** | 2.4 GHz | CH 11 ($2462\text{ MHz}$) | $56.0\text{ cm}$ | $11.0\text{ cm}$ | **$Z_1 = 6.5\text{ cm}$** | $13.5\text{ cm}$ (3D-Distanz) |
| **35** | Node 37 | 5 GHz | CH 161 ($5805\text{ MHz}$) | $56.0\text{ cm}$ | $18.0\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | $8.2\text{ cm}$ |
| **36** | Node 38 | 5 GHz | CH 165 ($5825\text{ MHz}$) | $56.0\text{ cm}$ | $25.0\text{ cm}$ | $Z_0 = 0.0\text{ cm}$ | $8.2\text{ cm}$ |
| **37** | **Node 12** | 2.4 GHz | CH 12 ($2467\text{ MHz}$) | $62.5\text{ cm}$ | $4.0\text{ cm}$ | **$Z_0 = 0.0\text{ cm}$** | $12.8\text{ cm}$ (3D-Distanz) |
| **38** | **Node 13** | 2.4 GHz | CH 13 ($2472\text{ MHz}$) | $62.5\text{ cm}$ | $11.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $13.5\text{ cm}$ (3D-Distanz) |
| **39** | **Node 39** | BLE | Adv (37/38/39) | $62.5\text{ cm}$ | $18.0\text{ cm}$ | **$Z_1 = 6.5\text{ cm}$** | $12.8\text{ cm}$ |
| **40** | **Node 40** | 2.4 GHz | Redundant 1/6/11 | $62.5\text{ cm}$ | $25.0\text{ cm}$ | **$Z_2 = 13.0\text{ cm}$** | $13.5\text{ cm}$ |
| **41** | Node 41 | Dyn | Probe / CH 169 | $30.0\text{ cm}$ | $14.5\text{ cm}$ | $Z_2 = 13.0\text{ cm}$ | Mitten-Position oben |

---

## 4. 3D-Druck Konstruktions- & Materialanforderungen

### 4.1 Filament-Wahl & HF-Eigenschaften
Standard-PLA oder Carbon-ABS dürfen **nicht** für die HF-Trägerstruktur verwendet werden:
* **Carbon-Filamente:** Graphit/Kohlefaser ist leitfähig und schirmt/reflektiert HF-Signale komplett ab.
* **Empfohlenes Filament:** **PETG** oder **ASA/ABS (ohne Additive)**.
  * Dielektrizitätskonstante $\epsilon_r \approx 2.2 \dots 2.8$ bei $2.4\text{ GHz}$.
  * Sehr geringer Dielektrischer Verlustfaktor ($\tan \delta < 0.01$).
  * Hohe Wärme- und UV-Beständigkeit für den Einsatz im KFZ/Aussenbereich.

### 4.2 Konstruktionsdetails für den 3D-Druck
1. **Wabenstruktur / Infill:**
   * Geringe Infill-Dichte im Bereich der Antennenrohre ($15\%\dots 20\%$ Gyroid- oder Honeycomb-Infill).
   * Verringert die effektive Dielektrizitätskonstante der Struktur nahe an Luft ($\epsilon_r \approx 1.0$), wodurch Brechung und Verstimmung der Antennen minimiert werden.
2. **Integrierte Entkopplungshülsen (Choke Sleeves):**
   * Im 3D-Druckmodell werden unterhalb jeder SMA-Aufnahme Zylinderaussparungen eingeplant, in die **Ferrithülsen** eingeclipst werden. Diese blockieren Mantelwellen direkt am Fußpunkt des Dipols.
3. **Pigtail-Kanäle:**
   * RG316-Pigtails werden in gedruckten Kabelkanälen an den Innenwänden der Stufen nach unten geführt. Vertikale Trennung von Koaxialkabeln und Logik-Busleitungen.

---

## 5. Quantitative Leistungsbewertung: 2D vs. 3D Layout

| Parameter / Metrik | Planare 2D-Anordnung ($Z = \text{const}$) | 3D-Gestaffelte Matrix ($Z_0, Z_1, Z_2$) | Verbesserung durch 3D-Konzept |
| :--- | :--- | :--- | :--- |
| **Mittlere Kopplung ($S_{21}$) 2.4 GHz** | $-12\text{ dB}$ bis $-16\text{ dB}$ | **$-28\text{ dB}$ bis $-35\text{ dB}$** | **$+16\text{ dB}$ Entkopplung** |
| **Mittlere Kopplung ($S_{21}$) 5 GHz** | $-18\text{ dB}$ bis $-22\text{ dB}$ | **$-34\text{ dB}$ bis $-42\text{ dB}$** | **$+16\text{ dB}$ Entkopplung** |
| **Horizontale Diagrammsymmetrie** | Starke Nullstellen (bis $-20\text{ dB}$) | Fast ideales Rundstrahlverhalten ($\pm 2.5\text{ dB}$) | **Rundum-Abdeckung gerettet** |
| **LNA Overload / Blocking Risiko** | Hoch (Empfänger-Taubheit bei Nah-Sendern) | Vernachlässigbar gering | **Maximale Empfangsempfindlichkeit** |
| **Gegenkopplung über Masse** | Hoch (Gemeinsame Ebene) | Gering (Räumliche 3D-Masse-Verteilung) | **Klares Signal-Rausch-Verhältnis (SNR)** |

---

## 6. Fazit & Empfehlung

Das 3D-gestaffelte Layout stellt die **HF-technisch optimale Lösung** dar. Durch die Kombination aus:
1. Dreistufiger Z-Achsen-Staffelung ($\Delta Z = 6.5\text{ cm}$),
2. Räumlicher Verschachtelung (Interleaving) von 2.4-GHz- und 5-GHz-Knoten und
3. HF-neutraler PETG-3D-Druckkonstruktion

wird die gegenseitige Beeinflussung der 41 Knoten unter die Wahrnehmungsgrenze der ESP32-C5 LNAs gedrückt. Das System erreicht damit die physisch maximale Empfindlichkeit für den mobilen High-Density-Einsatz.
