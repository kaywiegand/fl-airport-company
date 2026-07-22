# TechView — Bausteine-Kuration

Auswahl der technischen Bausteine (SQL · M · DAX · Datenmodell), die in die TechView-Slides
gehören. Nicht alles zeigen — sondern die Stellen, die *fachliches Urteilsvermögen* sichtbar
machen: saubere Datenabgrenzung, DRY-ETL, korrekte DAX-Muster, ein durchdachtes Datenmodell.

Quelle für alle Snippets: [`measures-dax.md`](../report/measures-dax.md) · [`etl-m-code.md`](../report/etl-m-code.md) (refactored).
Zielstruktur: Kapitel `technical-approach` in `public/md/slides.yaml` (aktuell Platzhalter
`tech-sql` / `tech-mcode` / `tech-dax`) + **eine neue Slide „Datenmodell"**.

**Prio-Legende:** ⭐ = Kern-Slide, unbedingt zeigen · ➕ = wertvoll, wenn Platz.

---

## Slide 1 — Datenmodell (NEU) ⭐

**Was zeigen:** Die drei Tabellen und ihre Beziehungen als kleines Schema.

| Tabelle | Rolle | Beziehung |
| :--- | :--- | :--- |
| `Report_Flights_Data` | Faktentabelle (1 Zeile = 1 Flug) | — |
| `Origin_Unique_Carrieres` | Airline-Lookup | `op_carrier_code` → `Code` (n:1) |
| `_Calendar` | Datumsdimension | `_Calendar[Date]` → `fl_date` (1:n) |

**Warum wichtig:** Zeigt Star-Schema-Denken. Die separate `_Calendar`-Dimension ist der Grund,
warum die Zeitreihen über alle Ebenen (Jahr → Quartal → Monat → Woche → Tag/Stunde) und die
„pro Tag"-Durchschnitte überhaupt funktionieren — das trägt die ganze „Analyse Zeiträume"-Sektion
der Präsentation. Genau der Baustein, den Kay explizit sehen wollte.

> Caveat: `_Calendar` ist bestätigt vorhanden (genutzt in `COUNTROWS(_Calendar)`); die exakte
> Kardinalität/Richtung der Beziehung ist noch nicht aus dem `.pbix` verifiziert (BACKLOG #1,
> Punkt 5). Als Standard-Datumsdimension dargestellt.

---

## Slide 2 — ETL: Datenabgrenzung in SQL ⭐

**Was zeigen:** Den `WHERE`-Block + `CASE`/`ABS` der Native Query (gekürzt).

```sql
WHERE EXTRACT(YEAR FROM fl_date) BETWEEN 2015 AND 2017
  AND (origin = 'LAX' OR dest = 'LAX')
  AND cancelled = FALSE AND diverted = FALSE
-- CASE WHEN dest='LAX' → 'arrival' / origin='LAX' → 'departure'  (fl_direction)
-- ABS(arr_delay), ABS(dep_delay)  → Verspätung vorzeichenlos
```

**Warum wichtig:** Die gesamte Datengrundlage der Analyse (Zeitraum, LAX-only, keine
cancelled/diverted) ist *an der Quelle* abgegrenzt und läuft gefaltet in PostgreSQL — nicht
clientseitig nachgefiltert. `ABS()` begründet direkt die Report-Definition „gilt für zu früh
UND zu spät". Verbindet Technik mit einer Fachaussage, die in der Präsentation vorkommt.

---

## Slide 3 — ETL: Bereinigung in Power Query ⭐

Zwei Bausteine, die Handwerk zeigen — nicht die ganze 18-Schritt-Kette.

**3a — Zeit-Parsing als wiederverwendbare Funktion** (statt 4× Copy-Paste):
```m
fnParseFlightTime = (raw) => …   // hhmm → time, inkl. 2400 → 00:00
Table.AddColumn(prev, "time_dep", each fnParseFlightTime([raw_dep]), type time)
```

**3b — ≥5-Minuten-Regel an genau einer Stelle:**
```m
fl_delay_status = if d >= 5 then [fl_direction] & " delay" else "on time"
delayed         = [fl_delay_status] <> "on time"   // abgeleitet, nicht wiederholt
```

**Warum wichtig:** ⭐ für 3b — `fl_delay_status` ist die Spalte, auf der praktisch jedes Measure
filtert; die Kernregel der ganzen Analyse (≥ 5 Min.) lebt hier an einer einzigen Stelle. ➕ für
3a — zeigt DRY/Funktionsdenken, aber eher „nice to show".

---

## Slide 4 — DAX: korrekte Muster ⭐

Drei Measures, die je eine Technik demonstrieren und die Kernaussagen der Präsentation stützen.

**4a — Durchschnitt richtig gerechnet** (Häufigkeit ≠ Schwere):
```dax
avg_delay_value_total = DIVIDE([sum_delays_total], [cnt_total_delays])   -- 26,42 Min.
```
Teilt durch die *verspäteten* Flüge, nicht durch alle — sonst zögen die `0`-Werte der pünktlichen
Flüge den Schnitt nach unten. Direkt an der „Indikator ist fragwürdig"-Erkenntnis.

**4b — DIVIDE + Filter, die Kernzahl 3,51 %:**
```dax
top3_avg_delay_value_in_pct = DIVIDE([top3_avg_delay_value_in_cnt], [cnt_total_delays])
-- Zähler: SUMX über FILTER(VALUES(carrier), [top3_avg_ranking] <= 3)
```
`RANKX` → `SUMX` über die Top-3-Menge → `DIVIDE`. Eine Rangdefinition speist Einfärbung *und*
Zahl. Das ist die 3,51-%-Zahl, um die sich die halbe Präsentation dreht.

**4c — Kombinationsindikator:**
```dax
delay_index = [delay_rate] * [avg_delay_value_total]   -- 18,54
```
Häufigkeit × Schwere — die Alternative, die die Analyse dem irreführenden Einzelindikator
empfiehlt.

**Warum wichtig:** Zeigt, dass durchgehend mit `DIVIDE` (division-sicher) und bewusstem
Filterkontext gearbeitet wurde — und dass die 3,51-%-Kernzahl aus nachvollziehbarem DAX kommt,
nicht aus einer Blackbox.

---

## Was bewusst NICHT in die TechView kommt

- Die vollständige 18-Schritt-M-Kette (gehört in `report/etl-m-code.md`, nicht auf eine Slide).
- Alle 24 Measures einzeln (Mapping-Tabelle in `report/measures-dax.md` reicht).
- Die Refactoring-Historie (IST vs. bereinigt) — TechView zeigt die *saubere* Lösung, die
  Begründung liegt in den Arbeitsdateien `docs/dax-refactoring.md` / `docs/m-code-refactoring.md`.

## Umsetzung

Diese vier Slides ersetzen die aktuellen Platzhalter im `technical-approach`-Kapitel von
`slides.yaml` (Slide 1 „Datenmodell" ist neu, Slides 2–4 füllen `tech-sql` / `tech-mcode` /
`tech-dax`). Danach `make portfolio` → TechView-HTML.
