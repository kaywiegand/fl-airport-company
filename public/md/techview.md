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
*Der vollständige Weg von den Bedingungen bis zu den Handlungsempfehlungen*

1. Einstieg
2. Kennzahlen
3. Analyse Verspätungen
4. Insights
5. Analyse Zeiträume
6. Insights
7. Empfehlungen
8. Ergänzungen


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

## Datenerhebung — SQL Native Query
*Gefiltert an der Quelle, nicht clientseitig nachgezogen*


## Datenbereinigung — Power Query (M)
*Zeit-Parsing als Funktion, die ≥5-Minuten-Regel an genau einer Stelle*


## Datenmodell — Star Schema
*Eine Faktentabelle, zwei Zeit-Dimensionen, Airline-Lookup und eine Measures-Tabelle*

* **Aufbau**
  - Report_Flights_Data: Faktentabelle (1 Zeile = 1 Flug)
  - _Calendar: Datumsebene (Jahr → Quartal → Monat → Woche → Tag)
  - _Time: Tagesuhrzeit (Stunde) für die Tagesansicht
  - Origin_Unique_Carrieres: Airline-Code → Klarname
  - _Measures: eigene Tabelle für alle Kennzahlen

## Datenanalyse — DAX Measures
*DIVIDE-sicher, Filterkontext bewusst genutzt*



---

### Kennzahlen

## Kennzahlen im Überblick
*Konsolidierte Sicht — Detail-Charts siehe StoryView*

* **1.264.229** — Flüge 2015–2017
* **70 %** — unpünktlich (≥ 5 Min.)
* **368.669 / 518.213** — Abflug- / Ankunftsverspätungen
* **13** — betroffene Fluggesellschaften
* **29,85 %** — On-Time Performance
* **18,54** — Delay Index
* **26,42 Min.** — Ø Verspätung pro Flug


---

### Analyse Verspätungen

## Ø-Verspätung je Airline
*13 Fluggesellschaften, Top-3-Anteil an der Gesamtverspätung*



---

### Analyse Zeiträume

## Aggregierte Betrachtung
*Jahre, Quartale, Monate, Tage*


## Wochenansicht der Verspätungen
*Anzahl und Summe nach Wochentag, mit On-Time Performance*


## Tagesansicht der Verspätungen
*Verlauf nach Uhrzeit (0–23 Uhr)*



---

### Insights

## Erkenntnisse Zeitebenen
*Erkenntnisse aus den langfristigen und kurzfristigen Mustern im Überblick*

