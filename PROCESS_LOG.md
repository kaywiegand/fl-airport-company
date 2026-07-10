# PROCESS_LOG.md — fl-airport-company

Verlauf + Entscheidungen. Pointer auf Files — kein Inhalt kopieren.
Metriken, Findings, Outputs gehören in `report/report_extract_final.md` / `public/md/` — nicht hier.

---

## 2026-07-10 — Migration in eigenes Repo + Portfolio-Aufbereitung gestartet

- Projekt bestand nur als Unterordner im Workspace-Repo (kein eigenes Git, kein Fundament) —
  jetzt eigenständiges Repo, Remote `git@github.com:kaywiegand/fl-airport-company.git` gesetzt
- Fundament-Files angelegt: CLAUDE.md · README.md · ROADMAP.md · BACKLOG.md · PROCESS_LOG.md
  (manuell, nicht per `/project-init` — Ordner hatte bereits Inhalt, Data-Typ des Skills setzt
  Notebook-/`src/`-Struktur voraus, die hier nicht passt — Projekt ist BI-Export, kein
  Notebook-Projekt)
- Sicherheitsentscheidung: `Abschlussprojekt-Infos.md` enthält Klartext-DB-Credentials → per
  `.gitignore` aus dem Repo ausgeschlossen, sachlicher Kontext stattdessen sanitiert in README.md
- `Todo-and-Focus-Check.md` (persönliche Arbeitscheckliste, Datei-Rechte 600) ebenfalls per
  `.gitignore` ausgeschlossen — enthielt aber verlässliche Kennzahlen (u.a. sauberer Split
  368.669 Abflug- / 518.213 Ankunfts-Verspätungen), die als Datenquelle für README/portfolio.md
  übernommen wurden und die verrauschte OCR-Extraktion an der Stelle korrigieren
- Visuals-Export: alle 21 PDF-Seiten aus `report/Report-flAirport_v09.pdf` als PNG nach
  `public/img/page-01.png` … `page-21.png` (`pdftoppm -png -r 150`)
- `project-case story`: `public/md/portfolio.md` aus `report/report_extract_final.md` befüllt,
  Kernthese mit Kay abgestimmt ("Ø-Verspätung pro Flug ist als alleiniger KPI irreführend")
- `project-case slides`: `public/md/slides.yaml` im Kapitel-für-Kapitel-Dialog erstellt — 8
  Kapitel, 34 Slide-Einträge, 3 Views (Overview 8 · StoryView 29 · TechView 12 Slides).
  StoryView bildet den kompletten PDF-Report 1:1 ab (inkl. Anhang, Mehrfach-Diagramm-Seiten
  in Einzelbilder zerschnitten: `page-07/-10/-11/-12/-13/-18-*.png` via PIL-Crop). TechView ist
  bewusst konsolidiert (12 statt 29 Slides) plus neues Kapitel "Technischer Ansatz" mit
  SQL/M-Code/DAX-Platzhaltern (siehe BACKLOG #1) — Anhang ist nicht Teil von TechView
- `project-case report`: `make portfolio` (Makefile mit `SKILL_SCRIPTS`-Variable, `uv run --with
  pyyaml` für die 3 Scripts die PyYAML brauchen — kein eigenes `pyproject.toml`, da BI-Export ohne
  Python-Paket) — Hub (`index.html`) + 3 View-HTMLs generiert, im Browser verifiziert (Preview,
  keine Konsolenfehler), kleiner Fix: doppelter Zeitraum in Hub-Subtitle behoben
- Nächster Schritt: Kay-Review der generierten Artefakte, dann Commit + Push nach
  `git@github.com:kaywiegand/fl-airport-company.git`, danach `docs/PROJECTS.md`-Status update
