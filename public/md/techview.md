# fLAirport — Analyse unpünktlicher Flüge

**Projekt:** fLAirport — Analyse unpünktlicher Flüge
**Beschreibung:** Technischer Deep-Dive: SQL · Power Query · DAX
**Autor:** Kay Wiegand
**Zielgruppe:** Tech Lead · Data Peers
**Dauer:** 10 Minuten
**Zeitraum:** 2015–2017
**GitHub:** [kaywiegand/fl-airport-company](https://github.com/kaywiegand/fl-airport-company)

---


---

### Projektrahmen

## Auftrag & Bedingungen
*Rahmen der Analyse*

* **Betrachtungsraum**
  - Nur Flüge von oder nach LAX (geplante An-/Abflugzeiten)
  - Zeitraum 2015–2017
  - Gestrichene oder umgeleitete Flüge ausgeschlossen
* **Definition Unpünktlichkeit**
  - ≥ 5 Minuten Abweichung von der geplanten Zeit
  - Gilt für zu früh UND zu spät
  - Getrennte Betrachtung nach Abflug/Ankunft möglich


---

### Technischer Ansatz

## Datenerhebung — SQL
*PostgreSQL-Quelle, gefiltert beim Import*

* **Bekannte Filterlogik (Absicht — Native Query folgt)**
  - EXTRACT + WHERE — Eingrenzung auf Zeitraum 2015–2017
  - WHERE — LAX als Origin oder Destination
  - WHERE — Ausschluss gestrichener/umgeleiteter Flüge
  - ABS() — Absolutwerte für Verspätungen
  - CASE WHEN…THEN…ELSE — neue Spalte für Abflug-/Ankunft-Richtung
> 🔧 Platzhalter — exakter SQL-Quelltext (Native Query) folgt aus Power BI Desktop. Siehe BACKLOG.md #1.

## Datenbereinigung — Power Query (M)
*Bekannte Schritt-Reihenfolge, Code folgt*

> 🔧 Platzhalter — vollständiger M-Code je Schritt folgt aus Power BI Desktop (Advanced Editor). Siehe BACKLOG.md #1.

## Datenanalyse — DAX Measures
*Bekannte Kennzahlen, Formeln folgen*

* **29,85 %** — On-Time Performance (Measure)
* **18,54** — Delay Index (Measure)
* **26,42 Min.** — Ø Verspätung/Flug (Measure)
* **3,51 %** — Top-3-Airline-Anteil (Measure + Filter)
> 🔧 Platzhalter — vollständige DAX-Formeln folgen, idealerweise per DAX Studio Export (alle Measures in einem Durchgang). Siehe BACKLOG.md #1.


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

### Airlines

## Ranking nach Ø-Verspätung


## Anteil der Top-3 an der Gesamtverspätung


## Erkenntnisse: Indikator verzerrt
*Konsolidiert aus StoryView*

* **Beobachtungen**
  - Top-3 nach Ø-Verspätung tragen nur 3,51 % zur Gesamtverspätung bei
  - 2016–2017 (ohne Envoy Air/US Airways): Einfluss deutlicher, Top-3-Anteil 22,31 %
  - Getrennte Ankunfts-/Abflug-Betrachtung: Anteile variieren deutlich
> Ø-Verspätung/Flug ignoriert die Flughäufigkeit — Airlines mit wenigen Flügen und Extremwerten verzerren den Indikator, ohne relevanten Einfluss auf die Gesamtzahl zu haben.


---

### Zeitliche Muster

## Anzahl Verspätungen — aggregiert


## Wochenansicht — Anzahl mit OTP


## Tagesansicht — Anzahl nach Uhrzeit


## Erkenntnisse Zeitebenen

* **Langfristig — Jahre, Quartale, Monate**
  - Über die Jahre insgesamt steigende Verspätungen
  - Saisonale Muster: Anstieg in Q2, Spitzenwerte in Q3, niedrigster Wert in Q1
  - Feiertage und Urlaubszeiten lassen sich deutlich ablesen
* **Kurzfristig — Wochentage, Tagesstunden**
  - Tagesansicht zeigt starke OTP-Schwankungen — Unbeständigkeit im operativen Ablauf
  - Samstag: deutlich geringste Anzahl und Summe an Verspätungen
  - Freitag, Sonntag und Montag: Werte steigen wieder deutlich an
  - Peaks am Morgen (6–7 und 8–9 Uhr) und am späten Nachmittag
