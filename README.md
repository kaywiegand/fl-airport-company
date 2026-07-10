# fLAirport — Analyse unpünktlicher Flüge

![Status](https://img.shields.io/badge/status-in%20Aufbereitung-yellow)

> Power-BI-Case: Unpünktlichkeit am Los Angeles International Airport (LAX), 2015–2017 —
> 1.264.229 Flüge, 13 Fluggesellschaften, aufbereitet für Führungskräfte-Reporting.

---

## TL;DR

- **1.264.229** Flüge von/nach LAX (2015–2017) analysiert — **70 %** davon unpünktlich
  (≥ 5 Min. Abweichung, zu früh oder zu spät)
- **On-Time Performance: 29,85 %** · **Ø Verspätung: 26,42 Min./Flug** · **Delay Index: 18,54**
- Die drei Airlines mit der höchsten *durchschnittlichen* Verspätung pro Flug
  (Envoy Air, Frontier Airlines, JetBlue Airways) stehen nur für **3,51 %** aller Verspätungen —
  zentrales Finding: der Indikator "Ø-Verspätung pro Flug" ist für Priorisierung ungeeignet
- Klare saisonale (Q2-Anstieg, Q3-Peak) und wöchentliche Muster (Samstag = Minimum, Freitag/
  Montag = Anstieg) sowie Tagesmuster (Peaks morgens 6–9 Uhr und am späten Nachmittag)

---

## Project Overview

Der Flughafenbetreiber fLAirport möchte für sein größtes Drehkreuz, den Los Angeles
International Airport, einen abteilungsübergreifenden Bericht zur Flugpünktlichkeit — als
gemeinsame Diskussionsgrundlage für Führungskräfte. Die Analyse deckt Übersichtskennzahlen, die
unpünktlichsten Airlines und zeitliche Muster ab, getrennt nach Abflug und Ankunft.

Umgesetzt als **Power BI Business Intelligence Case** (StackFuel Abschlussprojekt):
SQL-Query gegen eine PostgreSQL-Datenbank → Power Query/DAX-Aufbereitung → interaktiver Report
→ 15-minütige Management-Präsentation.

| Schritt | Werkzeug | Artefakt |
| :--- | :--- | :--- |
| Daten sammeln | SQL (PostgreSQL) | Filter: 2015–2017, LAX, keine gestrichenen/umgeleiteten Flüge |
| Daten bereinigen | Power Query | Zeitformat `hhmm`, Sonderfall `2400`, Airline-Klarnamen via CSV |
| Analyse | DAX Measures | Kennzahlen, Top-3-Airlines, zeitliche Ebenen (Jahr–Stunde) |
| Storytelling | Power BI Report | [`report/Report-flAirport_v09.pdf`](report/Report-flAirport_v09.pdf) |

---

## Problem Statement

Wie pünktlich ist der Flugverkehr an LAX, welche Airlines stechen negativ hervor, und lassen
sich wiederkehrende Zeiträume mit gehäufter Unpünktlichkeit identifizieren — um interne Prozesse
gezielt darauf abstimmen zu können?

| KPI | Ist | Ziel | Gap |
| :--- | :--- | :--- | :--- |
| On-Time Performance | 29,85 % | höher, saisonal geglättet | — |
| Ø Verspätung/Flug | 26,42 Min. | reduzieren, v. a. in Peak-Zeiträumen | — |

Ein Flug gilt als unpünktlich ab 5 Minuten Abweichung von der geplanten Zeit — in beide
Richtungen (zu früh wie zu spät). Betrachtet werden ausschließlich Flüge von oder nach LAX,
gestrichene und umgeleitete Flüge sind ausgeschlossen.

---

## Dataset

**Quellen:**
- PostgreSQL-Datenbank `Flight_Data`, Tabelle `flights` (StackFuel-Trainingsumgebung, Zugang
  nicht öffentlich — Query-Logik siehe Power-BI-Datei)
- [`data/UNIQUE_CARRIERS.csv`](data/UNIQUE_CARRIERS.csv) — Zuordnung Airline-Code → Klarname

**Zeitraum:** 2015–2017 · **Umfang:** 1.264.229 Flüge (nach Filterung) · **13** Fluggesellschaften

**Known Issues:**
- Uhrzeiten im Format `hhmm` ohne führende Nullen, Sonderwert `2400` (behandelt als 23:59)
- Nur Flüge mit LAX als Origin oder Destination — bei Ankünften zählt nur Ankunfts-, bei
  Abflügen nur Abflugunpünktlichkeit

---

## Approach

Kein Notebook-/Code-Workflow — die komplette Analyse liegt im Power-BI-Report:

- **Report:** [`report/Report-flAirport_v09.pbix`](report/Report-flAirport_v09.pbix) (Power BI
  Desktop) · [`report/Report-flAirport_v09.pdf`](report/Report-flAirport_v09.pdf) (Export, 21
  Seiten) · [`report/report_extract_final.md`](report/report_extract_final.md) (Text-Extrakt)
- **Kennzahlen-Übersicht:** Gesamtflüge, Pünktlichkeitsanteil, OTP, Delay Index
- **Airline-Ranking:** Top 3 nach Ø-Verspätung pro Flug + deren Anteil an allen Verspätungen
- **Zeitliche Analyse:** Jahr, Quartal, Monat, Kalenderwoche, Wochentag, Tagesstunde — jeweils
  nach Anzahl *und* Summe der Verspätungen

---

## Results

**Findings:**
1. 70 % aller Flüge sind unpünktlich (≥ 5 Min.), OTP liegt bei 29,85 % — davon 368.669
   Abflug-Verspätungen und 518.213 Ankunfts-Verspätungen (886.882 gesamt)
2. Die drei Airlines mit der höchsten Ø-Verspätung pro Flug tragen nur 3,51 % zur
   Gesamtverspätung bei — der Indikator ist wegen geringer Flugzahlen einzelner Airlines verzerrt
3. Saisonal: Anstieg in Q2, Peak in Q3, niedrigster Wert in Q1
4. Wochentag: Samstag = deutliches Minimum, Freitag/Sonntag/Montag = Anstieg
5. Tageszeit: Peaks morgens (6–9 Uhr) und am späten Nachmittag

**Recommendations:**
- **Operative Planung optimieren** — saisonale und Wochen-/Tages-Muster in die
  Kapazitätsplanung einbeziehen, Peaks gezielt abfedern
- **Research fortführen** — einzelne extreme Ausreißer-Zeiträume mit den Fachabteilungen klären
- **Indikator verbessern** — Ø-Verspätung/Flug allein ist kein verlässlicher Priorisierungs-
  Indikator; Kombination aus OTP, Anzahl und Summe der Verspätungen (Delay Index) sinnvoller

Details: [`report/report_extract_final.md`](report/report_extract_final.md)

---

## Setup

Kein Python-Setup nötig — Report öffnen mit [Power BI Desktop](https://powerbi.microsoft.com/desktop/):

```
open report/Report-flAirport_v09.pbix
```

PDF-Export und Text-Extrakt liegen zusätzlich unter `report/` für den schnellen Überblick ohne
Power BI Installation.
