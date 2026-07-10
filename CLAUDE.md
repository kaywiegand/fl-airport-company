# CLAUDE.md — fl-airport-company

> Projektspezifische Anweisungen für Claude Code.
> Ergänzt die globale CLAUDE.md aus dem Workspace-Root.

---

## Projekt

| Feld | Inhalt |
| :--- | :--- |
| Slug | `fl-airport-company` |
| Typ | DA / BI-Export (Power BI) |
| Stack | Power BI · SQL (PostgreSQL) |
| Status | 🔄 in Aufbereitung |

---

## Besonderheit gegenüber anderen Portfolio-Projekten

Kein Notebook-/`src/`-Projekt — die Analyse wurde vollständig in **Power BI** durchgeführt
(SQL-Query gegen eine PostgreSQL-Trainingsdatenbank + Power Query/DAX). Entsprechend abweichende
Struktur:

- **Kein `notebooks/`, kein `src/[paket]/`** — die "Notebooks"-Sections in README/`project-case`
  entfallen bzw. werden zu "Power BI Report".
- **`report/`** enthält das Original-Artefakt: `Report-flAirport_v09.pbix` (Power BI Datei) +
  `Report-flAirport_v09.pdf` (Export) + `report_extract_final.md` (OCR-Extrakt des PDFs — Quelle
  für alle Findings/Zahlen in README und `public/md/portfolio.md`).
- **`public/img/page-NN.png`** — alle 21 PDF-Seiten als PNG exportiert (`pdftoppm -png -r 150`).
  Kuration/Auswahl der Slide-relevanten Seiten passiert im `project-case slides`-Dialog.
- **ML-Pflicht bei `project-case check` entfällt** (kein `notebooks/06_*`, kein `data/models/`) →
  Kategorie 5 ist `n.a.`.

## Sicherheit — wichtig

`Abschlussprojekt-Infos.md` (Aufgabenstellung) ist per `.gitignore` **bewusst nicht** im Repo —
sie enthält Klartext-Zugangsdaten zu einer StackFuel-Trainingsdatenbank. Der sachliche
Aufgabenkontext (Szenario, Fragestellungen, Datenquelle) steht stattdessen sanitiert (ohne
Credentials) in README.md und `public/md/portfolio.md`. Diese Datei nie ungeprüft committen.

---

## Session-Einstieg

1. PROCESS_LOG.md lesen — aktueller Stand und letzte Session
2. ROADMAP.md lesen — offene Phasen
3. Globale CLAUDE.md aus dem Workspace-Root gilt weiterhin
