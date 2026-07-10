# BACKLOG.md — fl-airport-company

Projektspezifische offene Tasks und Todos.
Nie mitten in einer Session den Kontext wechseln — hier notieren, gesammelt abarbeiten.

Prio: `1` = hoch · `2` = mittel · `3` = niedrig

---

| # | Beschreibung | Prio | Entdeckt in |
| :--- | :--- | :--- | :--- |
| 1 | **TechView-Anreicherung: SQL/M-Code/DAX aus dem `.pbix` extrahieren.** Power BI Desktop läuft nicht auf macOS — Zugang über Windows-VM (Parallels/VMware/UTM), Windows 365 Cloud PC, oder kurz einen Windows-Rechner ausleihen. DAX-Measures sind auch über Power BI Web (app.powerbi.com, Pro-Trial) einsehbar/editierbar, M-Code + Native Query nicht. Konkret rausziehen: (1) **Rohdatenvolumen vor Filterung** — Zeilenzahl von `Flight_Data.flights` in PostgreSQL vor SQL-/Power-Query-Filterung (aktuell nur der gefilterte Endstand 1.264.229 bekannt); (2) **Exakter SQL-Quelltext** (Native Query, Rechtsklick auf letzten Power-Query-Schritt) — bisher nur die Absicht bekannt (EXTRACT+WHERE Zeitraum, WHERE LAX Origin/Dest, WHERE Ausschluss cancelled/diverted, ABS() für Verspätungswerte, CASE WHEN für Richtungs-Spalte); (3) **M-Code je Power-Query-Schritt** im Klartext, in der bekannten Reihenfolge (Datentypen → Umbenennung → 2400-Sonderfall ersetzen → Uhrzeit-Formatierung → Merge mit CSV für Airline-Klarnamen → Hilfsspalten `fl_direction`/`fl_direction_delay_status` → Datumstabelle); (4) **DAX-Measure-Formeln im Klartext** — größte Lücke, bisher nur Ergebniswerte (OTP 29,85 %, Delay Index 18,54, Ø-Verspätung 26,42 Min.) bekannt, nicht die Berechnungslogik dahinter, ideal per DAX Studio (kostenloses externes Tool) in einem Export; (5) **Datenmodell/Beziehungen** — wie hängen Fakt-Tabelle `flights`, Datumstabelle und Airline-Lookup zusammen (Kardinalität/Richtung). Ergebnis fließt in einen "Technical Approach"-Abschnitt in README.md + optional eigenes TechView-Kapitel in `slides.yaml`. | 2 | Session 2026-07-10 — Diskussion Power-BI-Web-Zugang für technische Tiefe |
