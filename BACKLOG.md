# BACKLOG.md — fl-airport-company

Projektspezifische offene Tasks und Todos.
Nie mitten in einer Session den Kontext wechseln — hier notieren, gesammelt abarbeiten.

Prio: `1` = hoch · `2` = mittel · `3` = niedrig

---

| # | Beschreibung | Prio | Entdeckt in |
| :--- | :--- | :--- | :--- |
| 1 | **TechView-Anreicherung: SQL/M-Code/DAX aus dem `.pbix` extrahieren.** Power BI Desktop läuft nicht auf macOS — Zugang über Windows-VM (Parallels/VMware/UTM), Windows 365 Cloud PC, oder kurz einen Windows-Rechner ausleihen. Stand: (1) **Rohdatenvolumen vor Filterung** — Zeilenzahl von `Flight_Data.flights` in PostgreSQL vor SQL-/Power-Query-Filterung (aktuell nur der gefilterte Endstand 1.264.229 bekannt) — **weiterhin offen**; (2) ~~Exakter SQL-Quelltext~~ **erledigt 2026-07-21** — vollständige Native Query dokumentiert in `docs/m-code-refactoring.md` Abschnitt 1; (3) ~~M-Code je Power-Query-Schritt~~ **erledigt 2026-07-21** — alle 18 Schritte dokumentiert in `docs/m-code-refactoring.md` Abschnitt 2, inkl. Korrektur-Tabelle ggü. der bisherigen Annahme (`fl_direction` kommt aus SQL nicht M, kein "2400→23:59"-Sonderfall, echte Spaltennamen `fl_delay_status`/`delayed` statt vermutetem `fl_direction_delay_status`); (4) ~~DAX-Measure-Formeln im Klartext~~ **erledigt 2026-07-21** — vollständiger Measure-Export dokumentiert in `docs/dax-refactoring.md` (alle 24 Measures, inkl. Mapping zu sichtbaren Kennzahlen); (5) ~~Datenmodell/Beziehungen~~ **erledigt 2026-07-21** — Model-View-Screenshot (`public/img/fLAirport-tables.png`) zeigt das vollständige Star Schema: Faktentabelle `Report_Flights_Data` + `_Calendar` (Datum) + `_Time` (Uhrzeit) + `Origin_Unique_Carrieres` (Airline) + disconnected `_Measures`; dokumentiert in `report/etl-m-code.md` (Abschnitt Data Model). **TechView-Kapitel `technical-approach` in `slides.yaml` ist gefüllt** (4 Slides: SQL Native Query → Power Query M → Datenmodell → DAX, keine Platzhalter mehr). Offen bleibt nur noch (1) Rohdatenvolumen vor Filterung. | 2 | Session 2026-07-10 — Diskussion Power-BI-Web-Zugang für technische Tiefe |
