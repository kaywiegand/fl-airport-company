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
- Nächster Schritt: `project-case story` — `public/md/portfolio.md` aus
  `report/report_extract_final.md` befüllen, danach Kernthese mit Kay abstimmen
