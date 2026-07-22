# ETL — SQL Native Query & Power Query (M)

Dokumentation der vollständigen Datenaufbereitung für `Report_Flights_Data`, von der
PostgreSQL-Quelle bis zur finalen Power-BI-Tabelle. Quelle: M-Code-Export der Abfrage
`Report_Flights_Data` aus Power BI Desktop (Advanced Editor). Deckt BACKLOG.md #1,
Teilpunkte (2) und (3) ab ("Exakter SQL-Quelltext" und "M-Code je Power-Query-Schritt").

**Wichtige Korrektur gegenüber der bisherigen Annahme** (siehe Abschnitt "Abweichungen"
unten): `fl_direction` wird **nicht** in Power Query berechnet, sondern kommt bereits fertig
aus der SQL Native Query. Der vermutete "Sonderfall 2400"-Schritt existiert so nicht — ungültige
Uhrzeiten werden stillschweigend zu `null`, nicht auf 23:59 korrigiert (siehe Schritt 3–6).

---

## 1. Quelle — SQL Native Query

Einzige Datenquelle: `PostgreSQL.Database("training-db.stackfuel.com", "Flight_Data")`,
Tabelle `flights`, mit `EnableFolding=true` (die Query wird an PostgreSQL delegiert, nicht
clientseitig in Power Query ausgeführt).

```sql
SELECT

    fl_date,
    EXTRACT(WEEK FROM fl_date) AS fl_week,

    CASE
        WHEN dest LIKE 'LAX' THEN 'arrival'
        WHEN origin LIKE 'LAX' THEN 'departure'
        ELSE null
    END AS fl_direction,

    origin AS fl_origin,
    dest AS fl_dest,

    crs_dep_time AS raw_dep_crs,
    crs_arr_time AS raw_arr_crs,

    arr_time AS raw_arr,
    dep_time AS raw_dep,

    ABS(arr_delay) AS delay_arr,
    ABS(dep_delay) AS delay_dep,

    op_carrier

FROM flights

WHERE EXTRACT(YEAR FROM fl_date) >= 2015
  AND EXTRACT(YEAR FROM fl_date) <= 2017
  AND (origin = 'LAX' OR dest = 'LAX')
  AND cancelled = FALSE
  AND diverted = FALSE
```

**Was hier bereits passiert, bevor überhaupt ein Power-Query-Schritt läuft:**
- Zeitraum-Filter 2015–2017 (`EXTRACT(YEAR ...)`)
- LAX-Filter (Origin **oder** Destination)
- Ausschluss gestrichener (`cancelled`) und umgeleiteter (`diverted`) Flüge
- `fl_direction` ("arrival"/"departure") wird direkt per `CASE WHEN` aus `origin`/`dest` abgeleitet
- `ABS()` auf `arr_delay`/`dep_delay` — negative Werte (zu früh) werden bereits hier auf ihren
  Absolutbetrag gebracht, das begründet die im Report genannte Regel "gilt für zu früh UND zu spät"
- Alle Uhrzeiten (`crs_dep_time`, `crs_arr_time`, `arr_time`, `dep_time`) kommen als Rohwerte
  (`raw_*`), noch nicht als Zeitformat — das übernimmt Power Query in den Schritten 3–6

Noch offen (BACKLOG.md #1, Punkt 1): das **Rohdatenvolumen vor Filterung** (Zeilenzahl von
`flights` ohne die `WHERE`-Bedingungen) ist aus dieser Query nicht ablesbar — die Native Query
selektiert bereits gefiltert.

---

## 2. Power-Query-Schritte (M), in Reihenfolge

### Schritt 1 — `Quelle`
Die SQL Native Query von oben. Startpunkt der Pipeline.

### Schritt 2 — `#"mod data types"`
```m
Table.TransformColumnTypes(Quelle, {
    {"fl_date", type date}, {"fl_week", type text},
    {"raw_dep_crs", type text}, {"raw_dep", type text},
    {"raw_arr_crs", type text}, {"raw_arr", type text},
    {"delay_arr", Int64.Type}, {"delay_dep", Int64.Type}
})
```
Setzt Basistypen: Datum, die vier Roh-Uhrzeit-Spalten vorerst als Text (Zwischenschritt vor der
Zeit-Konvertierung), Verspätungswerte als Ganzzahl.

### Schritt 3–6 — Uhrzeit-Formatierung (vier fast identische Schritte)
`#"mod crs_dep time format"` → `#"mod dep time format"` → `#"mod crs_arr time format"` →
`#"mod arr time format"`, je einmal für `raw_dep_crs`, `raw_dep`, `raw_arr_crs`, `raw_arr`.

Gleiche Logik viermal wiederholt (Custom Column, nicht per Funktion parametrisiert):
```m
let
    _raw = [raw_dep_crs],
    _input = if _raw = null then "" else Text.Trim(Text.From(_raw)),
    _length = Text.Length(_input),

    // hhmm ohne führende Nullen (z.B. "5" = 00:05, "830" = 08:30) auf 6-stelliges
    // HHMMSS-Rohformat auffüllen, bevor es in HH:MM:SS gesplittet wird
    _normalized =
        if _length = 0 then null
        else if _length = 1 then "000" & _input & "00"
        else if _length = 2 then "00" & _input & "00"
        else if _length = 3 then "0" & _input & "00"
        else if _length = 4 then _input & "00"
        else _input,

    _asTime = try Time.FromText(
        Text.Range(_normalized, 0, 2) & ":" &
        Text.Range(_normalized, 2, 2) & ":" &
        Text.Range(_normalized, 4, 2)
    ) otherwise null
in
    _asTime
```
**Kein expliziter Sonderfall für "2400"** (die aus dem US-Flugdaten-Format bekannte
Mitternachts-Schreibweise): `"2400"` wird zu `"24:00:00"` normalisiert, `Time.FromText` schlägt
dabei fehl (`24:00:00` ist kein gültiger Zeitwert), das `try…otherwise null` fängt das ab —
das Ergebnis ist **`null`**, nicht `23:59`. Betrifft nur die vier `time_*`-Anzeigespalten, nicht
die Verspätungsberechnung selbst (die läuft über `delay_arr`/`delay_dep` aus der SQL-Query,
unabhängig von diesen Uhrzeit-Spalten) — kein bekannter Einfluss auf die Report-Kennzahlen.

### Schritt 7 — `#"change to type time"`
```m
Table.TransformColumnTypes(#"mod arr time format", {
    {"time_dep", type time}, {"time_arr_crs", type time},
    {"time_arr", type time}, {"time_dep_crs", type time}
})
```
Setzt die vier per `Time.FromText` erzeugten Werte explizit auf den Power-BI-Zeittyp.

### Schritt 8 — `#"merge carrier table data"`
```m
Table.NestedJoin(#"change to type time", {"op_carrier"},
    Origin_Unique_Carrieres, {"Code"}, "Origin_Unique_Carrieres", JoinKind.LeftOuter)
```
Left-Outer-Join gegen eine separate Lookup-Tabelle `Origin_Unique_Carrieres` auf
`op_carrier` (Code) = `Code`. Datenmodell-Beziehung: `Report_Flights_Data[op_carrier]` →
`Origin_Unique_Carrieres[Code]` (n:1) — bislang einzige bestätigte Lookup-Beziehung
(BACKLOG.md #1, Punkt 5 — Datumstabelle/`_Calendar`-Beziehung ist hier nicht sichtbar,
weiterhin offen).

### Schritt 9 — `#"select carrier column data"`
```m
Table.ExpandTableColumn(#"merge carrier table data", "Origin_Unique_Carrieres",
    {"Description"}, {"Origin_Unique_Carrieres.Description"})
```
Klappt aus der genesteten Join-Tabelle nur die Spalte `Description` (Airline-Klarname) aus.

### Schritt 10 — `#"rename carrier column"`
```m
Table.RenameColumns(#"select carrier column data", {
    {"Origin_Unique_Carrieres.Description", "op_carrier_name"},
    {"op_carrier", "op_carrier_code"}
})
```
`op_carrier` (Code, z.B. "AA") → `op_carrier_code`; der neue Klarname → `op_carrier_name`
(z.B. "American Airlines Inc.").

### Schritt 11 — `#"reorder columns"`
```m
Table.ReorderColumns(#"rename carrier column", {
    "fl_date", "fl_direction", "fl_origin", "fl_dest",
    "raw_dep_crs", "raw_arr_crs", "raw_arr", "raw_dep",
    "delay_arr", "delay_dep",
    "time_dep_crs", "time_dep", "time_arr_crs", "time_arr",
    "op_carrier_code", "op_carrier_name"
})
```
Rein kosmetisch — keine Logik, nur lesbare Spaltenreihenfolge für die Endtabelle.

### Schritt 12 — `#"add delay stauts"` *(Tippfehler im Original-Schrittnamen, "stauts" statt "status")*
```m
Table.AddColumn(#"reorder columns", "fl_delay_status", each
    let
        flType = [fl_direction],
        delay = if flType = "arrival" then [delay_arr] else [delay_dep]
    in
        if delay >= 5 then flType & " delay" else "on time"
)
```
**Die zentrale ≥5-Minuten-Regel der gesamten Analyse.** Wählt je nach `fl_direction` die
passende Verspätung (`delay_arr` bei Ankunft, `delay_dep` bei Abflug) und klassifiziert:
`"arrival delay"` / `"departure delay"` / `"on time"`. Genau diese Spalte treibt
`CONTAINSSTRING(fl_delay_status, "delay")` in fast jeder DAX-Measure (siehe
`docs/dax-refactoring.md`).

### Schritt 13 — `#"mod delay status to type text"`
```m
Table.TransformColumnTypes(#"add delay stauts", {{"fl_delay_status", type text}})
```
Erzwingt Text-Typ (`Table.AddColumn` liefert sonst `any`).

### Schritt 14 — `#"add delay values"`
```m
Table.AddColumn(#"mod delay status to type text", "fl_delay_value", each
    if [fl_delay_status] = "arrival delay" then [delay_arr]
    else if [fl_delay_status] = "departure delay" then [delay_dep]
    else 0
)
```
Die tatsächliche Verspätung in Minuten als **eine** Spalte (statt zwei getrennter
Arrival/Departure-Spalten) — 0 bei "on time". Das ist exakt die Spalte, auf der
`avg_delay_value_total` in DAX rechnet (mit dem dort dokumentierten Filter-Gotcha, siehe
`docs/dax-refactoring.md`, Abschnitt 3).

### Schritt 15 — `#"mod delay values to type int"`
```m
Table.TransformColumnTypes(#"add delay values", {{"fl_delay_value", Int64.Type}})
```

### Schritt 16 — `#"add Index"`
```m
Table.AddIndexColumn(#"mod delay values to type int", "_index", 0, 1, Int64.Type)
```
Fortlaufender Zeilenindex ab 0 — keine fachliche Logik, vermutlich technische Notwendigkeit
(z.B. für ein Visual, das einen eindeutigen Schlüssel braucht) oder Debugging-Hilfsspalte.

### Schritt 17 — `#"add delay flag"`
```m
Table.AddColumn(#"add Index", "delay", each
    let
        flType = [fl_direction],
        delay = if flType = "arrival" then [delay_arr] else [delay_dep]
    in
        if delay >= 5 then true else false
)
```
Boolesches Gegenstück zu `fl_delay_status` (Schritt 12) — gleiche ≥5-Minuten-Regel, aber als
`true`/`false` statt als Text. Vermutlich für Slicer/Filter-Visuals, die einen Boolean statt
Text erwarten.

### Schritt 18 — `#"Umbenannte Spalten"` *(finaler Output)*
```m
Table.RenameColumns(#"add delay flag", {{"delay", "delayed"}})
```
Letzter Schritt — benennt die Boolean-Spalte von Schritt 17 in `delayed` um. Das ist die
Tabelle, die als `Report_Flights_Data` im Datenmodell landet.

---

## 3. Abweichungen von der bisherigen Annahme (BACKLOG.md #1)

Die bisher in `slides.yaml` (`tech-mcode`-Slide) angenommene Schrittfolge war eine Vermutung
ohne `.pbix`-Zugriff. Mit dem echten M-Code ergeben sich diese Korrekturen:

| Bisherige Annahme | Tatsächlich |
| :--- | :--- |
| `fl_direction` wird in Power Query als Hilfsspalte ergänzt | Kommt bereits aus der SQL Native Query (`CASE WHEN`) |
| "Sonderfall 2400 ersetzen" — wird zu 23:59 korrigiert | Kein expliziter Sonderfall — ungültige Zeiten (inkl. 2400) werden still zu `null` (betrifft nur die Anzeige-Zeitspalten, nicht die Verspätungswerte) |
| Eine Hilfsspalte `fl_direction_delay_status` | Zwei getrennte Spalten: `fl_delay_status` (Text: "arrival delay"/"departure delay"/"on time") und `delay`/`delayed` (Boolean) |
| Datumstabelle wird in dieser Abfrage ergänzt | Nicht Teil dieser Query — `_Calendar` ist eine separate Tabelle (Beziehung noch nicht bestätigt) |

Weiterhin offen (BACKLOG.md #1): Rohdatenvolumen vor Filterung (Punkt 1), vollständiges
Datenmodell/Beziehungen inkl. `_Calendar` (Punkt 5, Teil davon jetzt bekannt: `op_carrier` →
`Origin_Unique_Carrieres[Code]`).

---

# Refactoring

Analyse des IST-Standes: gefundene Probleme, Begründung, korrigierte Lösung. Die bereinigte
Fassung ist portfoliofertig in `report/etl-m-code.md` dokumentiert; dieser Abschnitt hält fest, *warum*
refactored wurde.

## R1 — Vier identische Zeit-Parse-Schritte (≈90 Zeilen Copy-Paste)

**Gefunden:** Die Schritte 3–6 sind derselbe ~15-zeilige Parse-Block, viermal eingefügt, nur der
Quellspaltenname wechselt (`raw_dep_crs`, `raw_dep`, `raw_arr_crs`, `raw_arr`).

**Warum schlecht:** Ein Bugfix (z. B. der 2400-Fall aus R3) müsste an vier Stellen identisch
nachgezogen werden — genau die Art Duplikat, die auseinanderdriftet. Der Advanced Editor wird
unnötig lang und unübersichtlich.

**Lösung:** Eine wiederverwendbare Funktion, vier Ein-Zeilen-Aufrufe.
```m
// Query "fnParseFlightTime" (eigene Abfrage oder let-lokale Funktion)
(raw as any) as nullable time =>
let
    _input = if raw = null then "" else Text.Trim(Text.From(raw)),
    _norm  = Text.PadStart(_input, 4, "0") & "00",   // hhmm ohne führende Nullen → HHMMSS
    _time  = if Text.Length(_input) = 0 then null
             else if _input = "2400" then #time(0, 0, 0)   // Mitternacht, siehe R3
             else try #time(
                     Number.FromText(Text.Start(_norm, 2)),
                     Number.FromText(Text.Middle(_norm, 2, 2)),
                     0
                 ) otherwise null
in
    _time
```
Jeder der vier Schritte wird dann zu einer Zeile:
```m
Table.AddColumn(prev, "time_dep_crs", each fnParseFlightTime([raw_dep_crs]), type time)
```
`Text.PadStart` ersetzt die fünf `if _length = …`-Zweige; `#time(...)` mit Zahlen ist robuster
als `Time.FromText` auf zusammengesetzten Strings.

## R2 — `delayed` dupliziert die Delay-Logik von `fl_delay_status`

**Gefunden:** Schritt 12 (`fl_delay_status`) und Schritt 17 (`delayed`) implementieren beide
unabhängig „nimm `delay_arr` oder `delay_dep` je Richtung, prüfe ≥ 5".

**Warum schlecht:** Die ≥5-Minuten-Schwelle steht an zwei Stellen. Ändert man sie in einer,
driftet die andere still mit — und `delayed` und `fl_delay_status` würden sich widersprechen.

**Lösung:** `delayed` aus dem bereits klassifizierten Status ableiten:
```m
Table.AddColumn(prev, "delayed", each [fl_delay_status] <> "on time", type logical)
```
Die ≥5-Regel lebt damit an genau einer Stelle (Schritt 12).

## R3 — Mitternacht (`2400`) wird still zu `null`

**Gefunden:** `"2400"` (US-BTS-Schreibweise für Mitternacht) normalisiert zu `"24:00:00"`,
`Time.FromText` scheitert, `try … otherwise null` liefert `null`.

**Warum schlecht:** Ein gültiger Zeitpunkt (00:00) geht als fehlender Wert verloren. Heute ohne
Folge für die KPIs (die Verspätung kommt aus der SQL-Query, nicht aus diesen Anzeigespalten) —
aber eine stille Datenqualitätslücke, die zum Bug wird, sobald jemand ein Visual auf die
geplanten Uhrzeiten baut.

**Lösung:** `2400` explizit auf `00:00` abbilden (in R1 bereits in `fnParseFlightTime`
eingebaut: `else if _input = "2400" then #time(0,0,0)`).

## R4 — Ungenutzte Index-Spalte `_index`

**Gefunden:** Schritt 16 fügt eine fortlaufende Ganzzahl-Spalte `_index` hinzu, die downstream
nirgends referenziert wird.

**Warum schlecht:** Eine eindeutige, hochkardinale Ganzzahlspalte ist der Worst Case für die
VertiPaq-Kompression — sie bläht das Modell auf, ohne einen Zweck zu erfüllen.

**Lösung:** Schritt entfernen. Falls später ein eindeutiger Schlüssel gebraucht wird, gezielt
wieder hinzufügen.

## R5 — Kosmetik & schlankeres Modell

- **Tippfehler im Schrittnamen** `#"add delay stauts"` → `#"add delay status"`. Harmlos, aber
  in einem Portfolio-Artefakt vermeidbar.
- **Zwischenspalten aufräumen:** `raw_dep_crs`/`raw_arr`/… und `delay_arr`/`delay_dep` werden
  nach der Klassifikation (Schritte 12/14) nicht mehr gebraucht. Ein abschließendes
  `Table.RemoveColumns` schlankt die Faktentabelle und beschleunigt Refresh + Modellgröße.
- **Optional — Zeitformatierung nach SQL verlagern:** `make_time()`/`to_char()` in Postgres statt
  zeilenweisem M-Parsing wäre faltbar (die Arbeit liefe in der Datenbank). Nur relevant, falls die
  Refresh-Dauer je zum Problem wird — für einen statischen historischen Report nicht nötig.
