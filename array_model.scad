// ============================================================================
// ARCH-WD-3D-RF-OPT-REV1.0 // PARAMETRISCHES 3D-ARRAY-MODELL
// Einheit: Millimeter [mm] (Skaliert aus cm-Vorgaben: Faktor 10)
// CAD-Target: OpenSCAD / Slicing-Export: STL / 3MF
// ============================================================================

$fn = 40;

// --- BETRIEBSMODI & SCHALTER ---
SHOW_ANTENNAS    = true;   // Visualisierung der HF-Strahler zur Kollisionsprüfung
SHOW_BASE_FRAME  = true;   // Tragstruktur / Trägerplatte
SHOW_MOUNT_HOLES = true;   // SMA-Bulkhead Durchbrüche & Choke-Kammern

// --- STRUKTURABMESSUNGEN ---
BASE_THICKNESS   = 5.0;    // Grundplattenstärke [mm]
PEDESTAL_OD      = 22.0;   // Aussendurchmesser der Montagesäulen [mm]
SMA_BORE_DIA     = 6.5;    // Durchgangsbohrung für SMA-Female Bulkhead (RG316) [mm]
SMA_HEX_DIA      = 9.0;    // Sechskant-Aussparung für Verdrehschutz [mm]
SMA_HEX_DEPTH    = 3.0;    // Tiefe der Sechskant-Aussparung [mm]
CHOKE_RECESS_DIA = 11.0;   // Aufnahmebohrung für Ferrithülse (Mantelwellensperre) [mm]
CHOKE_RECESS_LEN = 16.0;   // Tiefe der Ferrit-Aufnahme unterhalb Mount [mm]

// --- ANTENNEN-DUMMY PARAMETER ---
SMA_NUT_H        = 8.0;    // Höhe SMA-Verschraubung über Deckel [mm]
ANT_DIA          = 9.5;    // Durchschnittlicher Durchmesser Dipol-Radom [mm]
ANT_LEN_24       = 108.0;  // Physische Länge 2.4 GHz Dipol (ca. Lambda) [mm]
ANT_LEN_50       = 62.0;   // Physische Länge 5.0 GHz Dipol [mm]

// --- DATEN-MATRIX [ID, X_mm, Y_mm, Z_Tier_mm, Band_Type] ---
// Band_Type: 0 = 5GHz, 1 = 2.4GHz, 2 = BLE, 3 = Dynamic Probe
NODE_DATA = [
    [ 1,  40.0,  40.0, 130.0, 1],
    [14,  40.0, 110.0,   0.0, 0],
    [15,  40.0, 180.0,  65.0, 0],
    [ 2,  40.0, 250.0,   0.0, 1],
    [16, 105.0,  40.0,   0.0, 0],
    [17, 105.0, 110.0, 130.0, 0],
    [ 3, 105.0, 180.0,  65.0, 1],
    [18, 105.0, 250.0, 130.0, 0],
    [19, 170.0,  40.0,  65.0, 0],
    [ 4, 170.0, 110.0,   0.0, 1],
    [20, 170.0, 180.0,   0.0, 0],
    [21, 170.0, 250.0,  65.0, 0],
    [ 5, 235.0,  40.0, 130.0, 1],
    [22, 235.0, 110.0,  65.0, 0],
    [23, 235.0, 180.0, 130.0, 0],
    [ 6, 235.0, 250.0,   0.0, 1],
    [24, 300.0,  40.0,   0.0, 0],
    [ 7, 300.0, 110.0,  65.0, 1],
    [41, 300.0, 145.0, 130.0, 3], // Dynamic Center Probe
    [25, 300.0, 180.0,   0.0, 0],
    [26, 300.0, 250.0,  65.0, 0],
    [27, 365.0,  40.0, 130.0, 0],
    [28, 365.0, 110.0,   0.0, 0],
    [ 8, 365.0, 180.0, 130.0, 1],
    [29, 365.0, 250.0,   0.0, 0],
    [30, 430.0,  40.0,   0.0, 0],
    [ 9, 430.0, 110.0,   0.0, 1],
    [31, 430.0, 180.0,  65.0, 0],
    [32, 430.0, 250.0, 130.0, 0],
    [33, 495.0,  40.0,  65.0, 0],
    [10, 495.0, 110.0, 130.0, 1],
    [34, 495.0, 180.0,   0.0, 0],
    [35, 495.0, 250.0,  65.0, 0],
    [36, 560.0,  40.0, 130.0, 0],
    [11, 560.0, 110.0,  65.0, 1],
    [37, 560.0, 180.0, 130.0, 0],
    [38, 560.0, 250.0,   0.0, 0],
    [12, 625.0,  40.0,   0.0, 1],
    [13, 625.0, 110.0, 130.0, 1],
    [39, 625.0, 180.0,  65.0, 2],
    [40, 625.0, 250.0, 130.0, 1]
];

// --- FARBSCHEMATA (HF-BÄNDER) ---
function get_color(band) = 
    (band == 1) ? [1.00, 0.43, 0.00, 0.90] : // 2.4 GHz (Orange)
    (band == 0) ? [0.00, 0.57, 1.00, 0.90] : // 5.0 GHz (Blau)
    (band == 2) ? [0.70, 0.53, 1.00, 0.90] : // BLE (Violett)
                  [0.00, 0.90, 0.46, 0.90];  // Dynamic Probe (Grün)

function get_ant_len(band) = 
    (band == 1 || band == 2) ? ANT_LEN_24 : ANT_LEN_50;

// --- GEOMETRIE-MODULE ---

// Trägersäule für Z-Elevation inklusive internem HF-Kabel/Ferritkanal
module pedestal(x, y, z_height) {
    total_h = z_height + BASE_THICKNESS;
    translate([x, y, 0]) {
        difference() {
            // Vollmaterial-Stütze
            cylinder(d = PEDESTAL_OD, h = total_h);

            if (SHOW_MOUNT_HOLES) {
                // SMA Durchgangsbohrung
                translate([0, 0, -1])
                    cylinder(d = SMA_BORE_DIA, h = total_h + 2);
                
                // Obere Sechskant-Tasche (Verdrehschutz)
                translate([0, 0, total_h - SMA_HEX_DEPTH])
                    cylinder(d = SMA_HEX_DIA, h = SMA_HEX_DEPTH + 1, $fn=6);
                
                // Untere Aufnahme für Ferrit-Choke
                translate([0, 0, -1])
                    cylinder(d = CHOKE_RECESS_DIA, h = min(total_h - SMA_HEX_DEPTH - 2, CHOKE_RECESS_LEN + 1));
            }
        }
    }
}

// Grundplatte mit Randverstärkung und Montage-Grid
module base_plate() {
    difference() {
        hull() {
            for (pt = NODE_DATA) {
                translate([pt[1], pt[2], 0])
                    cylinder(d = PEDESTAL_OD + 10, h = BASE_THICKNESS);
            }
        }
        // Ausschnitt-Kanalisierungen zur Gewichts- und Materialreduktion (HF-Transparenz)
        if (SHOW_MOUNT_HOLES) {
            for (pt = NODE_DATA) {
                if (pt[3] == 0) {
                    translate([pt[1], pt[2], -1])
                        cylinder(d = SMA_BORE_DIA, h = BASE_THICKNESS + 2);
                    translate([pt[1], pt[2], BASE_THICKNESS - SMA_HEX_DEPTH])
                        cylinder(d = SMA_HEX_DIA, h = SMA_HEX_DEPTH + 1, $fn=6);
                }
            }
        }
    }
}

// Dummy für Koaxial-Antenne zur räumlichen Verifikation
module antenna_mockup(band) {
    // SMA-Verbinder Basis
    color([0.85, 0.75, 0.20]) // Messing-Gold
        cylinder(d = 8.0, h = SMA_NUT_H);
    
    // Antennenkörper (Knickelement / Gehäuse)
    color(get_color(band))
        translate([0, 0, SMA_NUT_H])
            cylinder(d = ANT_DIA, h = get_ant_len(band));
            
    // Oberer Abschluss-Radius
    color(get_color(band))
        translate([0, 0, SMA_NUT_H + get_ant_len(band)])
            sphere(d = ANT_DIA);
}

// --- GESAMTAUFBAU ---
module assembly() {
    // 1. Mechanische Struktur
    if (SHOW_BASE_FRAME) {
        color([0.22, 0.25, 0.30]) { // Dunkelgraues PETG
            base_plate();
            for (node = NODE_DATA) {
                if (node[3] > 0) {
                    pedestal(node[1], node[2], node[3]);
                }
            }
        }
    }

    // 2. Antennen (sofern aktiviert)
    if (SHOW_ANTENNAS) {
        for (node = NODE_DATA) {
            z_pos = node[3] + BASE_THICKNESS;
            translate([node[1], node[2], z_pos]) {
                antenna_mockup(node[4]);
            }
        }
    }
}

// Modell instanziieren
assembly();
