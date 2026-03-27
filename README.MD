# 🚀 Vettori Cosmici (Cosmic Vectors)

**VC*.BAS** è un simulatore grafico-fisico scritto originariamente nel **1991** per QuickBASIC 4.5 e aggiornato nel **2008** per **QB64**. Il programma calcola e visualizza i vettori di velocità istantanea a cui è sottoposto un osservatore sulla Terra, sommandoli per ricavare la velocità risultante rispetto alla Radiazione Cosmica di Fondo (CMBR).


## 📜 Evoluzione del Codice (1991 vs 2008)

Il repository include la versione originale del **1991** (`VC.BAS`) e il porting moderno del **2008** (`VC_QB64.BAS`). Le differenze principali documentano il passaggio tecnologico tra due ere:

* **Risoluzione Video:** Passaggio dal formato standard VGA 640x480 (fissato a `SCREEN 12`) alla risoluzione dinamica basata sul desktop dell'utente tramite le funzioni `_DesktopHeight` e `_NewImage` di QB64.
* **Precisione Matematica:** La versione originale operava principalmente in precisione singola, mentre la versione 2008 introduce la doppia precisione (`DEFDBL`) e l'uso di costanti astronomiche aggiornate secondo gli standard IAU.
* **Funzioni Native:** Nella versione del 1991 è presente un'implementazione manuale della funzione `Atan2`, necessaria in QuickBASIC 4.5 per la corretta gestione dei quadranti trigonometrici, ora sostituita dalla funzione nativa in QB64.
* **Rappresentazione Grafica:** La versione moderna introduce il supporto ai colori a 32-bit (`_RGB`) e una scala dinamica migliorata per la visualizzazione dei corpi celesti e dei pianeti interni.

## 🌌 Cosa misura il programma?
Il software calcola la velocità totale sommando quattro componenti vettoriali fondamentali:

1.  **Rotazione Terrestre:** Velocità basata sulla latitudine dell'osservatore ($\approx 0.46$ km/s all'equatore).
2.  **Rivoluzione Orbitale:** Il moto della Terra attorno al Sole ($\approx 29.78$ km/s).
3.  **Moto Solare (Apex):** Il movimento del Sistema Solare all'interno della Via Lattea verso la costellazione di Ercole ($\approx 217$ km/s).
4.  **Deriva verso il Grande Attrattore:** Il moto della nostra Galassia verso l'anomalia gravitazionale del Superammasso dell'Idra-Centauro ($\approx 610$ km/s).

## 🛠️ Caratteristiche Tecniche
* **Precisione Astronomica:** Calcolo del Giorno Giuliano e del Tempo Siderale Locale per orientare correttamente i vettori in base all'ora e alla posizione geografica.
* **Conversioni di Coordinate:** Implementa algoritmi per passare da coordinate Eclittiche, Galattiche ed Equatoriali (J2000) tramite matrici di rotazione e trigonometria sferica.
* **Grafica Scalabile:** Il programma permette di inserire un intervallo temporale (da 1 secondo a 1 settimana) per visualizzare lo spostamento teorico nello spazio.
* **Riferimenti Reali:** Visualizza in scala (proporzionale o ingrandita per visibilità) la Terra, la Luna, il Sole e i pianeti interni (Mercurio, Venere, Marte) lungo l'asse equatoriale.



## 📊 Legenda Colori Vettori
* **Verde (Tratteggiato):** Rotazione Terrestre (visualizzata con scala 50x per renderla visibile).
* **Ciano:** Orbita Terrestre.
* **Rosso:** Moto nella Via Lattea (Apex Solare).
* **Magenta:** Grande Attrattore.
* **Giallo:** Vettore Risultante (il moto totale dell'osservatore nello spazio).

## ⚙️ Requisiti
* Compatibile con **QB64** (tutte le versioni) e **QB64pe**.
* Adattamento automatico alla risoluzione desktop del monitor.

---
*Sviluppato da Marco da Venezia (1991 - rev. 2008)*

