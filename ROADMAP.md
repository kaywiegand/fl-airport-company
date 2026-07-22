# ROADMAP — fl-airport-company

> Ausgangslage → Phasen → Ziel

---

## Ausgangslage

StackFuel-Abschlussprojekt (Business Intelligence Specialist — Analytics & Reporting with Power
BI) ist fachlich abgeschlossen: Power-BI-Report fertig analysiert, exportiert als `.pbix` + PDF.
Bisher nur Rohmaterial ohne eigenes Repo, ohne Fundament, ohne öffentliche Aufbereitung.

---

## Phasen

- [x] Phase 1 — Fundament: eigenes Git-Repo, CLAUDE.md/README/BACKLOG/PROCESS_LOG, `.gitignore`
      für sensible Aufgaben-Infos
- [x] Phase 2 — Visuals-Export: PDF-Seiten als PNG nach `public/img/`
- [x] Phase 3 — Story: `public/md/portfolio.md` aus `docs/report-extract.md` befüllt
      (`project-case story`)
- [x] Phase 4 — Slides: `public/md/slides.yaml` im Dialog erstellt (`project-case slides`) —
      3 Views (Overview/StoryView/TechView), TechView mit SQL/M/DAX-Platzhaltern (BACKLOG #1)
- [x] Phase 5 — Report: `public/index.html` + Views mechanisch generiert (`make portfolio`),
      im Browser verifiziert (Hub, StoryView-Chart, TechView-Platzhalter)
- [ ] Phase 6 — Public Launch: Commit + Push nach GitHub, `docs/PROJECTS.md`-Status auf
      `✅ portfolio-ready`
- [ ] Phase 7 — TechView-Anreicherung: SQL/M-Code/DAX aus Power BI Desktop nachziehen
      (BACKLOG #1, sobald Windows-Zugang verfügbar)

---

## Ziel

Eigenständiges, öffentliches Portfolio-Case-Repo analog zu den Notebook-Projekten — README als
Einstieg, `public/index.html` als Hub mit den Kern-Erkenntnissen aus dem Power-BI-Report, ohne
sensible Zugangsdaten im Git-Verlauf.
