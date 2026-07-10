# Portfolio Summary — fLAirport — Analyse unpünktlicher Flüge
<!-- Interface-Datei: Wird von /project-case story befüllt.
     Einzige Zahlenquelle für /project-case report und /project-case slides.
     KEINE Inhalte aus Notebooks kopieren — nur kuratierte Kernaussagen.
-->

---

## Project

```
name:       fLAirport — Analyse unpünktlicher Flüge
slug:       fl-airport-company
type:       DA
stage:      Phase 3 — Story (Portfolio-Aufbereitung)
target:     On-Time Performance (OTP) je Airline/Zeitraum — kein ML-Target
stack:      Power BI · SQL (PostgreSQL) · DAX
period:     2015–2017
rows:       1.264.229 Flüge (LAX, gefiltert: keine gestrichenen/umgeleiteten Flüge)
notebooks:  0 (Power-BI-Report statt Notebooks — siehe report/Report-flAirport_v09.pbix)
findings:   6
dashboard:
```

---

## Storyline

```
thesis:     Die durchschnittliche Verspätung pro Flug ist als alleiniger KPI irreführend —
            Airlines mit extremen Ø-Werten haben oft nur wenige Flüge und kaum Einfluss auf
            die Gesamtzahl der Verspätungen. Entscheidend für operative Planung sind
            stattdessen die klar wiederkehrenden saisonalen und wochentäglichen Muster.
hook:       Die drei Airlines mit der höchsten Ø-Verspätung pro Flug stehen für nur 3,51 % aller
            Verspätungen an LAX.
proof:      Kennzahlen-Übersicht → Airline-Ranking (Ø-Verspätung vs. Anteil Gesamtverspätung)
            → zeitliche Musteranalyse über 6 Ebenen (Jahr, Quartal, Monat, Woche, Wochentag,
            Stunde)
so_what:    Kapazitäts- und Prozessplanung sollte sich an saisonalen/Wochen-/Tages-Mustern
            orientieren, nicht an Airline-Durchschnittswerten — die sind ein "fragwürdiger
            Indikator" (O-Ton Report).
```

---

## Problem

```
kpi_name:   On-Time Performance (OTP)
kpi_ist:    29,85 %
kpi_soll:   — (Auftrag verlangt Transparenz + Muster-Identifikation, kein Zielwert vorgegeben)
kpi_gap:    —
problem_statement: |
  fLAirport braucht für sein größtes Drehkreuz LAX eine abteilungsübergreifende
  Diskussionsgrundlage zur Pünktlichkeit — 70 % aller Flüge weichen ≥ 5 Minuten von der Planzeit
  ab. Offen ist, welche Airlines und welche Zeiträume die Unpünktlichkeit treiben, um interne
  Prozesse gezielt darauf abzustimmen.
```

---

## Key Findings

### F1 — Kennzahlen-Überblick
```
finding:   70 % aller LAX-Flüge sind unpünktlich (≥ 5 Min., zu früh oder zu spät); OTP 29,85 %,
           Ø-Verspätung 26,42 Min./Flug (Ankunft 26,51 / Abflug 26,30)
number:    886.882 von 1.264.229 Flügen (70 %)
source:    report/report_extract_final.md (Seite 3, 5, 6)
```

### F2 — Airline-Indikator-Verzerrung
```
finding:   Die drei Airlines mit der höchsten Ø-Verspätung pro Flug (Envoy Air, Frontier
           Airlines, JetBlue Airways) tragen nur zu einem kleinen Bruchteil zur
           Gesamtverspätung bei — der Indikator ignoriert die Flughäufigkeit
number:    3,51 % Anteil an allen Verspätungen
source:    report/report_extract_final.md (Seite 7–9)
```

### F3 — Saisonales Muster
```
finding:   Deutlicher Anstieg der Verspätungen in Q2, Peak in Q3, niedrigster Wert in Q1 —
           Feiertage/Urlaubszeiten lassen sich in den Daten klar ablesen
number:    Q1 = Minimum, Q3 = Peak
source:    report/report_extract_final.md (Seite 10–11, 14)
```

### F4 — Wochentagsmuster
```
finding:   Samstag hat die deutlich geringste Anzahl/Summe an Verspätungen; Freitag, Sonntag
           und Montag steigen wieder deutlich an
number:    Samstag = wöchentliches Minimum
source:    report/report_extract_final.md (Seite 12, 14)
```

### F5 — Tagesmuster
```
finding:   Verspätungen häufen sich morgens (6–9 Uhr) und am späten Nachmittag — passend zum
           typischen Arbeitszeit-Rhythmus im Flugbetrieb
number:    Peak 6–9 Uhr
source:    report/report_extract_final.md (Seite 13–14)
```

### F6 — Richtungssplit
```
finding:   Verspätungen verteilen sich auf 368.669 Abflüge und 518.213 Ankünfte (zusammen
           886.882) — Ankunftsverspätungen überwiegen leicht
number:    368.669 (Abflug) / 518.213 (Ankunft)
source:    interne Kennzahlen-Verifikation (Power-BI-Measures, Double-Check-Notizen)
```

---

## Model Results
<!-- Entfällt — Typ DA, kein ML-Modell. Analyse erfolgt vollständig über Power BI/DAX Measures. -->

---

## Figures
<!-- Aus report/Report-flAirport_v09.pdf exportiert (pdftoppm, 21 Seiten) → public/img/page-NN.png.
     Vorläufige thematische Zuordnung — finale Auswahl/Umbenennung passiert im slides-Dialog. -->

```yaml
overview:
  - page-03.png   # Gesamtanzahl Flüge, pünktlich/verspätet Split
  - page-04.png   # Verspätungen Abflug/Ankunft/Gesamt
  - page-05.png   # OTP, Delay Index, betroffene Airlines
  - page-06.png   # Verspätungen pro Tag, Verspätung pro Flug in Minuten

airlines:
  - page-07.png   # Top-3-Airlines nach Ø-Verspätung, Anteil an Auswahl
  - page-08.png   # Erkenntnisse Airline-Betrachtung
  - page-09.png   # Wichtige Erkenntnis: Indikator fragwürdig
  - page-19.png   # Ranking nach Anzahl der Verspätungen
  - page-20.png   # Delay Index Airlines
  - page-21.png   # Delay Rate Airlines

temporal:
  - page-10.png   # Aggregierte Betrachtung Jahre/Quartale/Monate/Tage
  - page-11.png   # Kontinuierliche Betrachtung Jahre/Quartale/Monate/Tage
  - page-12.png   # Wochenansicht der Verspätungen
  - page-13.png   # Tagesansicht nach Uhrzeit
  - page-14.png   # Erkenntnisse Zeitebenen

recommendations:
  - page-15.png   # Handlungsempfehlungen
```

---

## Recommendations

```
r1:
  title:  Operative Planung optimieren
  detail: Saisonale Häufungen sowie Wochen-/Tages-Muster verstärkt in die Kapazitätsplanung
          einbeziehen, um Spitzenwerten gezielt vorzubeugen.

r2:
  title:  Research fortführen
  detail: Extreme Einzelausreißer in Anzahl und Summe der Verspätungen mit den Fachabteilungen
          klären, um Ursachen zu identifizieren und Wiederholungen zu vermeiden.

r3:
  title:  Indikator verbessern
  detail: Ø-Verspätung pro Flug allein zeigt nur die Schwere, nicht die Häufigkeit oder den
          Gesamteinfluss. Sinnvollere Kombination: OTP & Summe, Anzahl & Summe, Delay-Index.
```

---

## Status

```
generated_by:   /project-case story + slides + report
generated_at:   2026-07-10
summary_version: 2
portfolio_check: ⚠️ partial — Phase 3–5 abgeschlossen, Phase 6 (Public Launch: Commit+Push) offen
report_html:    ✅ generated
slides_html:    ✅ generated (3 Views: Overview 8 · StoryView 29 · TechView 12 Slides)
dashboard:      ❌ not deployed — kein Dashboard geplant, statischer Report (siehe ROADMAP.md)
```
