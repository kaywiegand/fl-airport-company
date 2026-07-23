# PROCESS_LOG.md — fl-airport-company

Verlauf + Entscheidungen. Pointer auf Files — kein Inhalt kopieren.
Metriken, Findings, Outputs gehören in `docs/report-extract.md` / `public/md/` — nicht hier.

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
- `project-case story`: `public/md/portfolio.md` aus `docs/report-extract.md` befüllt,
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
- Committet + gepusht nach `git@github.com:kaywiegand/fl-airport-company.git` (2 Commits:
  Fundament+Visuals, dann Story+Slides+Report)
- Overview-Storyline-Lücke gefunden + behoben: Cover/Inhalt fehlten in allen 3 Views,
  Airline-Ranking- und Zeitmuster-Chart fehlten in Overview (nur Text-Pointe ohne Beleg-Chart) —
  ergänzt, damit jeder Proof-Schritt der These mindestens einen Chart hat
- README auf Portfolio-Standard gebracht (zh-tram-flow-Struktur als Referenz): Where-to-start-
  Tabelle, Reports & Artifacts (Links zu Hub/Overview/StoryView/TechView — fehlten komplett,
  obwohl die Pipeline schon fertig gebaut war), Tech-Stack-Tabelle, Table of Contents, Author-
  Section ergänzt
- Nächster Schritt: GitHub Pages manuell in den Repo-Settings aktivieren (kein `gh`-CLI hier
  verfügbar für automatisches Setup), danach `docs/PROJECTS.md`-Status auf `✅ portfolio-ready`

---

## 2026-07-23 — TechView Deep-Dive fertiggestellt, StoryView-Review, GitHub Pages

- StoryView komplett final poliert (mehrere Feedback-Runden: Agenda-Zentrierung, Code-Block-
  Layouts, Insight-Box-Abstände, Closing-Split) — Details siehe `wgnd-skills`-Commits
  `4e27dd7`/`962146a` (globale Slide-Bausteine, nicht projektspezifisch)
- TechView-Kapitel "Technischer Ansatz" inhaltlich fertiggestellt: neue Intro-Slide
  (h_timeline, 4 Arbeitsschritte Gathering→Cleaning→Preparing→Analysis), SQL/M/DAX-Code-Slides
  von Fließtext-Caption auf Bullet-Listen umgestellt (`public/md/slides.yaml` `tech-sql`/
  `tech-mcode`/`tech-dax`)
- Kennzahlen-Slide (TechView + Overview, identisches Layout): von 3 auf 2 Rows umgebaut
  (4 KPIs / 2 Rings + 2 Werte), DAX-Measure-Herkunft der 8 Werte gegen
  [`report/measures-dax.md`](report/measures-dax.md) geprüft (alle 8 sind Measures, keine
  Rohwerte) und als Fußnote auf der TechView-Slide ergänzt
- Ø-Verspätung-je-Airline-Slide (TechView): Business-Caption durch Measure-Zuordnung ersetzt
  (`avg_delay_value_total` + 4 `top3_avg_*`-Measures), Legitimität der DAX-Nutzung anhand des
  Chart-Bildes Element für Element verifiziert
- TechView-Kapitel "Analyse Zeiträume"/"Insights" (4 Detail-Slides) aus TechView entfernt —
  war Redundanz zu StoryView ohne technischen Mehrwert; neue TechView-exklusive Closing-Slide
  ergänzt (Fazit: Reproduzierbarkeit/Flexibilität durch sauber getrennte SQL→M→Modell→DAX-Kette)
- Overview: fehlende Agenda-Slide ergänzt (war in keinem View-Pfad vorhanden)
- Diverse Nav/Agenda-Konsistenz-Fixes: veraltete Kapitel-Einträge in TechView-Agenda entfernt,
  doppelter "Insights"-Nav-Tick in Overview per `nav_tick_by_view` unterdrückt (Kapitel liegen
  dort direkt hintereinander, in StoryView nicht — dort bleiben beide "Insights" sinnvoll)
- Hub `view_order` von `[overview, storyview, techview]` auf `[overview, techview, storyview]`
  korrigiert — Ausreißer ggü. den anderen 3 Portfolio-Projekten, die die Reihenfolge schon
  richtig hatten; Konvention jetzt in `wgnd-skills/project-case/build-pipeline.md` fixiert
- Hub-Karten zeigen jetzt Slide-Anzahl statt einer geschätzten Dauer mit Uhr-Icon (`wgnd-skills`,
  betrifft alle 4 Portfolio-Projekte, jeweils neu gebaut)
- **Sicherheitsfund:** `docs/initial-project-brief.md` (neu von Kay angelegt) enthielt
  Klartext-DB-Zugangsdaten (Server/User/Passwort) — sofort zu `.gitignore` hinzugefügt, nie
  committed. `docs/initial-todos-checks.md` (kein sensibler Inhalt) normal committed
- README-Audit gegen `project-case`-Pflicht-Sections-Checkliste: Key-Visual-PNG entfernt
  (Anti-Pattern + stale Bild), Slide-Zahlen korrigiert (StoryView 24, TechView 12), Approach-
  Abschnitt aktualisiert (`_Calendar`-Beziehung ist geklärt, nur Rohdatenvolumen bleibt offen)
- GitHub Pages Workflow ergänzt (`.github/workflows/pages.yml`, 1:1 von `zh-tram-flow`
  übernommen) — deployt `public/` bei jedem Push auf `main`. Falls der erste Actions-Run mit
  einem Pages-Fehler abbricht: einmalig in den Repo-Settings unter "Pages" die Source auf
  "GitHub Actions" stellen (nur nötig, falls Pages noch nie aktiviert war)
- Committet (2 Commits: TechView-Content + README/Pages) und gepusht. `docs/PROJECTS.md`
  aktualisiert: BACKLOG #1 ist bis auf das Rohdatenvolumen vor Filterung erledigt — nächster
  Schritt wäre `/project-case check` für eine formale Portfolio-Ready-Bewertung
