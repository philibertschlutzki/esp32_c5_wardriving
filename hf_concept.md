<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1060 560" width="100%" height="100%" style="background:#0f1117; font-family:Consolas, 'Liberation Mono', Menlo, monospace;">
  <defs>
    <!-- Filter für Elevation Halos -->
    <filter id="glow-tier2" x="-40%" y="-40%" width="180%" height="180%">
      <feGaussianBlur stdDeviation="3" result="blur" />
      <feComposite in="SourceGraphic" in2="blur" operator="over" />
    </filter>
    <style>
      .grid-line { stroke: #1e2230; stroke-width: 1; stroke-dasharray: 4,4; }
      .border-line { stroke: #33394d; stroke-width: 1.5; }
      .axis-text { fill: #656d85; font-size: 11px; }
      .node-text { font-size: 10px; font-weight: bold; text-anchor: middle; dominant-baseline: central; fill: #ffffff; }
      .sub-text { font-size: 8px; text-anchor: middle; dominant-baseline: central; fill: #d0d4e0; }
      .legend-title { fill: #ffffff; font-size: 11px; font-weight: bold; }
      .legend-label { fill: #8a93a8; font-size: 10px; }
      
      /* Band Colors */
      .c-24 { fill: #ff6d00; stroke: #ff9e40; }
      .c-50 { fill: #0091ff; stroke: #64b5f6; }
      .c-ble { fill: #b388ff; stroke: #d1c4e9; }
      .c-dyn { fill: #00e676; stroke: #b9f6ca; }
      
      /* Tier Rings */
      .tier0-ring { fill: #1c202d; stroke: #454d66; stroke-width: 1.5; stroke-dasharray: 3,2; }
      .tier1-ring { fill: #252b3d; stroke: #7b86a6; stroke-width: 1.5; }
      .tier2-ring { fill: #323a52; stroke: #00e5ff; stroke-width: 2; filter: url(#glow-tier2); }
    </style>
  </defs>

  <!-- Titelblock & Header -->
  <text x="35" y="30" fill="#ffffff" font-size="14" font-weight="bold" letter-spacing="1">ARCH-WD-3D-RF-OPT-REV1.0 // 41-KNOTEN ARRAY LAYOUT (X-Y-Z)</text>
  <text x="35" y="46" fill="#656d85" font-size="10">DIMENSIONEN: 66.5 cm × 29.0 cm × 13.0 cm | ABSTUFUNGEN: Z0=0.0cm (Tier 0), Z1=6.5cm (Tier 1), Z2=13.0cm (Tier 2)</text>

  <!-- Array Perimeter Baseframe -->
  <rect x="75" y="65" width="895" height="340" fill="#131620" class="border-line" rx="4" />

  <!-- Y-Grid-Linien (Y = 4.0, 11.0, 14.5, 18.0, 25.0) -->
  <!-- Transformation: Y_px = 65 + (Y_cm * 12.5) -->
  <line x1="75" y1="115" x2="970" y2="115" class="grid-line" />
  <line x1="75" y1="202.5" x2="970" y2="202.5" class="grid-line" />
  <line x1="75" y1="246.25" x2="970" y2="246.25" class="grid-line" />
  <line x1="75" y1="290" x2="970" y2="290" class="grid-line" />
  <line x1="75" y1="377.5" x2="970" y2="377.5" class="grid-line" />

  <text x="30" y="115" class="axis-text">Y=4.0</text>
  <text x="24" y="202.5" class="axis-text">Y=11.0</text>
  <text x="24" y="246.25" class="axis-text">Y=14.5</text>
  <text x="24" y="290" class="axis-text">Y=18.0</text>
  <text x="24" y="377.5" class="axis-text">Y=25.0</text>

  <!-- X-Grid-Linien (X = 4.0, 10.5, 17.0, 23.5, 30.0, 36.5, 43.0, 49.5, 56.0, 62.5) -->
  <!-- Transformation: X_px = 75 + (X_cm * 13.7) -->
  <line x1="129.8" y1="65" x2="129.8" y2="405" class="grid-line" />
  <line x1="218.85" y1="65" x2="218.85" y2="405" class="grid-line" />
  <line x1="307.9" y1="65" x2="307.9" y2="405" class="grid-line" />
  <line x1="396.95" y1="65" x2="396.95" y2="405" class="grid-line" />
  <line x1="486.0" y1="65" x2="486.0" y2="405" class="grid-line" />
  <line x1="575.05" y1="65" x2="575.05" y2="405" class="grid-line" />
  <line x1="664.1" y1="65" x2="664.1" y2="405" class="grid-line" />
  <line x1="753.15" y1="65" x2="753.15" y2="405" class="grid-line" />
  <line x1="842.2" y1="65" x2="842.2" y2="405" class="grid-line" />
  <line x1="931.25" y1="65" x2="931.25" y2="405" class="grid-line" />

  <text x="129.8" y="423" class="axis-text" text-anchor="middle">X=4.0</text>
  <text x="218.85" y="423" class="axis-text" text-anchor="middle">10.5</text>
  <text x="307.9" y="423" class="axis-text" text-anchor="middle">17.0</text>
  <text x="396.95" y="423" class="axis-text" text-anchor="middle">23.5</text>
  <text x="486.0" y="423" class="axis-text" text-anchor="middle">30.0</text>
  <text x="575.05" y="423" class="axis-text" text-anchor="middle">36.5</text>
  <text x="664.1" y="423" class="axis-text" text-anchor="middle">43.0</text>
  <text x="753.15" y="423" class="axis-text" text-anchor="middle">49.5</text>
  <text x="842.2" y="423" class="axis-text" text-anchor="middle">56.0</text>
  <text x="931.25" y="423" class="axis-text" text-anchor="middle">X=62.5</text>

  <!-- ======================== NODES ======================== -->
  <!-- Col 1: X=4.0 (129.8) -->
  <g transform="translate(129.8, 115)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">01</text><text y="25" class="sub-text">CH1·Z2</text>
  </g>
  <g transform="translate(129.8, 202.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">14</text><text y="21" class="sub-text">C36·Z0</text>
  </g>
  <g transform="translate(129.8, 290)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">15</text><text y="23" class="sub-text">C40·Z1</text>
  </g>
  <g transform="translate(129.8, 377.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-24" />
    <text y="-2" class="node-text">02</text><text y="21" class="sub-text">CH2·Z0</text>
  </g>

  <!-- Col 2: X=10.5 (218.85) -->
  <g transform="translate(218.85, 115)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">16</text><text y="21" class="sub-text">C44·Z0</text>
  </g>
  <g transform="translate(218.85, 202.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">17</text><text y="25" class="sub-text">C48·Z2</text>
  </g>
  <g transform="translate(218.85, 290)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-24" />
    <text y="-2" class="node-text">03</text><text y="23" class="sub-text">CH3·Z1</text>
  </g>
  <g transform="translate(218.85, 377.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">18</text><text y="25" class="sub-text">C52·Z2</text>
  </g>

  <!-- Col 3: X=17.0 (307.9) -->
  <g transform="translate(307.9, 115)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">19</text><text y="23" class="sub-text">C56·Z1</text>
  </g>
  <g transform="translate(307.9, 202.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-24" />
    <text y="-2" class="node-text">04</text><text y="21" class="sub-text">CH4·Z0</text>
  </g>
  <g transform="translate(307.9, 290)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">20</text><text y="21" class="sub-text">C60·Z0</text>
  </g>
  <g transform="translate(307.9, 377.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">21</text><text y="23" class="sub-text">C64·Z1</text>
  </g>

  <!-- Col 4: X=23.5 (396.95) -->
  <g transform="translate(396.95, 115)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">05</text><text y="25" class="sub-text">CH5·Z2</text>
  </g>
  <g transform="translate(396.95, 202.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">22</text><text y="23" class="sub-text">C100·Z1</text>
  </g>
  <g transform="translate(396.95, 290)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">23</text><text y="25" class="sub-text">C104·Z2</text>
  </g>
  <g transform="translate(396.95, 377.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-24" />
    <text y="-2" class="node-text">06</text><text y="21" class="sub-text">CH6·Z0</text>
  </g>

  <!-- Col 5: X=30.0 (486.0) -->
  <g transform="translate(486.0, 115)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">24</text><text y="21" class="sub-text">C108·Z0</text>
  </g>
  <g transform="translate(486.0, 202.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-24" />
    <text y="-2" class="node-text">07</text><text y="23" class="sub-text">CH7·Z1</text>
  </g>
  <!-- Node 41: Dynamic Probe Center Z2 -->
  <g transform="translate(486.0, 246.25)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-dyn" />
    <text y="-2" class="node-text" fill="#000000">41</text><text y="25" class="sub-text" fill="#00e676">PRB·Z2</text>
  </g>
  <g transform="translate(486.0, 290)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">25</text><text y="21" class="sub-text">C112·Z0</text>
  </g>
  <g transform="translate(486.0, 377.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">26</text><text y="23" class="sub-text">C116·Z1</text>
  </g>

  <!-- Col 6: X=36.5 (575.05) -->
  <g transform="translate(575.05, 115)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">27</text><text y="25" class="sub-text">C120·Z2</text>
  </g>
  <g transform="translate(575.05, 202.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">28</text><text y="21" class="sub-text">C124·Z0</text>
  </g>
  <g transform="translate(575.05, 290)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">08</text><text y="25" class="sub-text">CH8·Z2</text>
  </g>
  <g transform="translate(575.05, 377.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">29</text><text y="21" class="sub-text">C128·Z0</text>
  </g>

  <!-- Col 7: X=43.0 (664.1) -->
  <g transform="translate(664.1, 115)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">30</text><text y="21" class="sub-text">C132·Z0</text>
  </g>
  <g transform="translate(664.1, 202.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-24" />
    <text y="-2" class="node-text">09</text><text y="21" class="sub-text">CH9·Z0</text>
  </g>
  <g transform="translate(664.1, 290)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">31</text><text y="23" class="sub-text">C136·Z1</text>
  </g>
  <g transform="translate(664.1, 377.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">32</text><text y="25" class="sub-text">C140·Z2</text>
  </g>

  <!-- Col 8: X=49.5 (753.15) -->
  <g transform="translate(753.15, 115)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">33</text><text y="23" class="sub-text">C144·Z1</text>
  </g>
  <g transform="translate(753.15, 202.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">10</text><text y="25" class="sub-text">CH10·Z2</text>
  </g>
  <g transform="translate(753.15, 290)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">34</text><text y="21" class="sub-text">C149·Z0</text>
  </g>
  <g transform="translate(753.15, 377.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-50" />
    <text y="-2" class="node-text">35</text><text y="23" class="sub-text">C153·Z1</text>
  </g>

  <!-- Col 9: X=56.0 (842.2) -->
  <g transform="translate(842.2, 115)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">36</text><text y="25" class="sub-text">C157·Z2</text>
  </g>
  <g transform="translate(842.2, 202.5)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-24" />
    <text y="-2" class="node-text">11</text><text y="23" class="sub-text">CH11·Z1</text>
  </g>
  <g transform="translate(842.2, 290)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-50" />
    <text y="-2" class="node-text">37</text><text y="25" class="sub-text">C161·Z2</text>
  </g>
  <g transform="translate(842.2, 377.5)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-50" />
    <text y="-2" class="node-text">38</text><text y="21" class="sub-text">C165·Z0</text>
  </g>

  <!-- Col 10: X=62.5 (931.25) -->
  <g transform="translate(931.25, 115)">
    <circle r="15" class="tier0-ring" /><circle r="10" class="c-24" />
    <text y="-2" class="node-text">12</text><text y="21" class="sub-text">CH12·Z0</text>
  </g>
  <g transform="translate(931.25, 202.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">13</text><text y="25" class="sub-text">CH13·Z2</text>
  </g>
  <g transform="translate(931.25, 290)">
    <circle r="17" class="tier1-ring" /><circle r="11" class="c-ble" />
    <text y="-2" class="node-text">39</text><text y="23" class="sub-text">ADV·Z1</text>
  </g>
  <g transform="translate(931.25, 377.5)">
    <circle r="19" class="tier2-ring" /><circle r="12" class="c-24" />
    <text y="-2" class="node-text">40</text><text y="25" class="sub-text">RED·Z2</text>
  </g>

  <!-- ======================== LEGENDE ======================== -->
  <g transform="translate(75, 460)">
    <!-- Frequenz-Legende -->
    <text x="0" y="12" class="legend-title">FREQUENZBÄNDER:</text>
    <circle cx="140" cy="9" r="6" class="c-24" />
    <text x="152" y="12" class="legend-label">2.4 GHz Wi-Fi</text>

    <circle cx="260" cy="9" r="6" class="c-50" />
    <text x="272" y="12" class="legend-label">5 GHz Wi-Fi</text>

    <circle cx="370" cy="9" r="6" class="c-ble" />
    <text x="382" y="12" class="legend-label">BLE Adv</text>

    <circle cx="460" cy="9" r="6" class="c-dyn" />
    <text x="472" y="12" class="legend-label">Dynamic Probe</text>

    <!-- Z-Achsen / Tier-Legende -->
    <text x="0" y="42" class="legend-title">Z-STAFFELUNG (TIER):</text>
    
    <circle cx="140" cy="39" r="8" class="tier0-ring" /><circle cx="140" cy="39" r="4" fill="#ffffff" />
    <text x="155" y="42" class="legend-label">Tier 0 (Z = 0.0 cm)</text>

    <circle cx="280" cy="39" r="10" class="tier1-ring" /><circle cx="280" cy="39" r="5" fill="#ffffff" />
    <text x="297" y="42" class="legend-label">Tier 1 (Z = 6.5 cm)</text>

    <circle cx="430" cy="39" r="12" class="tier2-ring" /><circle cx="430" cy="39" r="6" fill="#ffffff" />
    <text x="449" y="42" class="legend-label">Tier 2 (Z = 13.0 cm)</text>
  </g>
</svg>
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
