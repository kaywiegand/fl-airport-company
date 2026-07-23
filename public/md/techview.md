# fLAirport

**Projekt:** fLAirport
**Beschreibung:** Technischer Deep-Dive: SQL · Power Query · DAX
**Autor:** Kay Wiegand
**Zielgruppe:** Tech Lead · Data Peers
**Dauer:** 10 Minuten
**Zeitraum:** 2015–2017
**GitHub:** [kaywiegand/fl-airport-company](https://github.com/kaywiegand/fl-airport-company)

---


---

### Projektrahmen

# fLAirport

**Analyse unpünktlicher Flüge | Los Angeles International Airport**
**Power BI - Business Intelligence Analytics & Reporting | 2015–2017**

* **1.264.229** — Flüge 2015–2017 (LAX)
* **70 %** — unpünktlich (≥ 5 Min.)
* **29,85 %** — On-Time Performance
* **26,42 Min.** — Ø Verspätung pro Flug

## Inhaltsübersicht
*Der technische Weg von der Datenerhebung bis zur fertigen Kennzahl*

1. Einstieg
2. Technischer Ansatz
3. Kennzahlen
4. Analyse Verspätungen


---

### Einstieg

## Analyse-Szenario
*Diskussionsgrundlage für den Flughafenbetreiber fLAirport*

> Routinemäßige Analyse der Verspätungen

## Analyse Bedingungen
*In Abstimmung mit der Führungsebene wurden folgende Anforderungen an den Bericht herausgearbeitet*

* **Betrachtungsraum**
  - Nur Flüge von oder nach LAX
  - Zeitraum 2015–2017
  - Keine gestrichenen oder umgeleiteten Flüge
* **Anforderungen**
  - Übersicht Kennzahlen
  - Top 3 der unpünktlichen Airlines mit Unpünktlichkeitsrate
  - Zeiträume mit gehäuft starker Unpünktlichkeit
  - Informationen getrennt nach Abflug und Ankunft
* **Definition Unpünktlichkeit**
  - ≥ 5 Minuten Abweichung von der geplanten Zeit
  - Gilt für zu früh UND zu spät


---

### Technischer Ansatz

## Technischer Ansatz
*Vier technische Arbeitsschritte bis zur vollständigen Analyse*


## Datenerhebung — SQL Native Query
*Gefiltert an der Quelle, nicht clientseitig nachgezogen*


## Datenbereinigung — Power Query (M)
*Zeit-Parsing als Funktion, die ≥5-Minuten-Regel an genau einer Stelle*


## Datenmodell — Star Schema
*Eine Faktentabelle, zwei Zeit-Dimensionen, Airline-Lookup und eine Measures-Tabelle*


## Datenanalyse — DAX Measures
*DIVIDE-sicher, Filterkontext bewusst genutzt*



---

### Kennzahlen

## Kennzahlen im Überblick
*Konsolidierte Sicht, Detail-Charts siehe StoryView*

* **1.264.229** — Flüge 2015–2017
* **368.669** — Abflug-Verspätungen
* **518.213** — Ankunfts-Verspätungen
* **13** — betroffene Fluggesellschaften


---

### Analyse Verspätungen

## Ø-Verspätung je Airline
*13 Fluggesellschaften, Top-3-Anteil an der Gesamtverspätung*



---

### Abschluss

## fLAirport
*['Analyse unpünktlicher Flüge | Los Angeles International Airport', 'Power BI - Business Intelligence Analytics & Reporting | 2015–2017']*

> Vom Rohdatenimport bis zur Kennzahl
