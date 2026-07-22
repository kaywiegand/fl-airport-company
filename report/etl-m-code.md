# ETL Pipeline — From PostgreSQL to the Reporting Table
**SQL NATIVE QUERY + POWER QUERY (M) FOR fLAIRPORT**

---

Die Faktentabelle `Report_Flights_Data` entsteht in zwei Etappen: eine gefaltete SQL Native
Query zieht und filtert die Rohdaten in PostgreSQL, danach bereinigt und ergänzt Power Query (M)
die Spalten. Diese Datei zeigt die bereinigte Pipeline — Zeit-Parsing als wiederverwendbare
Funktion, die ≥5-Minuten-Regel an genau einer Stelle.

## Inhalt

- [Source & Filtering (SQL)](#source--filtering-sql)
- [Type Setting](#type-setting)
- [Time Parsing (shared function)](#time-parsing-shared-function)
- [Carrier Enrichment](#carrier-enrichment)
- [Delay Classification](#delay-classification)
- [Final Shape](#final-shape)
- [Data Model](#data-model)

---

## Source & Filtering (SQL)

Einzige Quelle: PostgreSQL-Tabelle `flights`. Die Native Query läuft mit `EnableFolding=true` —
Filterung und erste Transformationen passieren in der Datenbank, nicht clientseitig.

```sql
SELECT
    fl_date,
    EXTRACT(WEEK FROM fl_date) AS fl_week,
    CASE
        WHEN dest   LIKE 'LAX' THEN 'arrival'
        WHEN origin LIKE 'LAX' THEN 'departure'
        ELSE null
    END AS fl_direction,
    origin AS fl_origin,  dest AS fl_dest,
    crs_dep_time AS raw_dep_crs,  crs_arr_time AS raw_arr_crs,
    arr_time AS raw_arr,          dep_time AS raw_dep,
    ABS(arr_delay) AS delay_arr,  ABS(dep_delay) AS delay_dep,
    op_carrier
FROM flights
WHERE EXTRACT(YEAR FROM fl_date) BETWEEN 2015 AND 2017
  AND (origin = 'LAX' OR dest = 'LAX')
  AND cancelled = FALSE
  AND diverted  = FALSE
```

Bereits hier passiert das Wesentliche der Datenabgrenzung: Zeitraum 2015–2017, nur LAX-Flüge
(Start **oder** Ziel), keine gestrichenen/umgeleiteten Flüge. `fl_direction` wird per `CASE`
abgeleitet, `ABS()` macht Verspätungen vorzeichenlos — das begründet die Report-Regel „gilt für
zu früh UND zu spät".

## Type Setting

Ein `Table.TransformColumnTypes`-Schritt setzt die Basistypen: `fl_date` als Datum,
Verspätungen als Ganzzahl, die vier Roh-Uhrzeiten vorerst als Text (Zwischenschritt vor dem
Parsing).

## Time Parsing (shared function)

Die vier Roh-Uhrzeiten (`hhmm` ohne führende Nullen, z. B. `830` = 08:30) werden über **eine**
Funktion in echte Zeitwerte gewandelt — statt vier kopierter Blöcke. Mitternacht (`2400`) wird
explizit auf `00:00` abgebildet.

```m
// Query: fnParseFlightTime
(raw as any) as nullable time =>
let
    _input = if raw = null then "" else Text.Trim(Text.From(raw)),
    _norm  = Text.PadStart(_input, 4, "0") & "00",
    _time  = if Text.Length(_input) = 0 then null
             else if _input = "2400" then #time(0, 0, 0)
             else try #time(
                     Number.FromText(Text.Start(_norm, 2)),
                     Number.FromText(Text.Middle(_norm, 2, 2)),
                     0
                 ) otherwise null
in
    _time
```

Aufruf je Spalte als Einzeiler:

```m
Table.AddColumn(prev, "time_dep_crs", each fnParseFlightTime([raw_dep_crs]), type time)
// … analog: time_dep, time_arr_crs, time_arr
```

## Carrier Enrichment

Left-Outer-Join gegen die Lookup-Tabelle `Origin_Unique_Carrieres`, um zum Airline-Code den
Klarnamen zu holen (z. B. `AA` → „American Airlines Inc.").

```m
Table.NestedJoin(prev, {"op_carrier"}, Origin_Unique_Carrieres, {"Code"},
                 "carrier", JoinKind.LeftOuter)
// expand "Description" → op_carrier_name;  rename op_carrier → op_carrier_code
```

## Delay Classification

Die zentrale ≥5-Minuten-Regel — **einmal** definiert. `fl_delay_status` wählt je Richtung die
passende Verspätung und klassifiziert; `fl_delay_value` hält die Minuten als eine Spalte; der
Boolean `delayed` leitet sich direkt vom Status ab (keine Wiederholung der Schwellen-Logik).

```m
// fl_delay_status
Table.AddColumn(prev, "fl_delay_status", each
    let d = if [fl_direction] = "arrival" then [delay_arr] else [delay_dep]
    in  if d >= 5 then [fl_direction] & " delay" else "on time", type text)

// fl_delay_value  (0 bei pünktlich → macht sum/avg in DAX sauber)
Table.AddColumn(prev, "fl_delay_value", each
    if [fl_delay_status] = "arrival delay"   then [delay_arr]
    else if [fl_delay_status] = "departure delay" then [delay_dep]
    else 0, Int64.Type)

// delayed  (Boolean, aus dem Status abgeleitet)
Table.AddColumn(prev, "delayed", each [fl_delay_status] <> "on time", type logical)
```

`fl_delay_status` ist die Spalte, auf der praktisch jedes DAX-Measure filtert
(`CONTAINSSTRING(…, "delay")`, siehe [`measures-dax.md`](measures-dax.md)).

## Final Shape

Zum Abschluss werden nicht mehr benötigte Zwischenspalten entfernt (`raw_*`, `delay_arr`,
`delay_dep`) — das schlankt die Faktentabelle und beschleunigt den Refresh.

```m
Table.RemoveColumns(prev, {"raw_dep_crs","raw_arr_crs","raw_arr","raw_dep","delay_arr","delay_dep"})
```

## Data Model

Star Schema mit einer Faktentabelle, drei Dimensionen und einer eigenen Measures-Tabelle.

| Tabelle | Rolle | Beziehung |
| :--- | :--- | :--- |
| `Report_Flights_Data` | Faktentabelle (1 Zeile = 1 Flug) | — |
| `Origin_Unique_Carrieres` | Airline-Lookup (Code → Klarname) | `[op_carrier_code]` → `[Code]` (n:1) |
| `_Calendar` | Datumsdimension (Jahr → Tag) | `[Date]` → `[fl_date]` (1:n) |
| `_Time` | Uhrzeit-Dimension (Stunde/Minute) | über `time_crs_union` → `[Time]` (n:1) |
| `_Measures` | disconnected Measures-Tabelle | — (keine Beziehung) |

Der entscheidende Design-Punkt sind die **zwei getrennten Zeit-Dimensionen**: `_Calendar` trägt
die Datumsebene (Jahr/Quartal/Monat/Woche/Tag + die „pro Tag"-Durchschnitte via
`COUNTROWS(_Calendar)`), `_Time` die Tagesuhrzeit (Stunde) für die stündliche Tagesansicht. Eine
eigene Dimension je Ebene — statt Datums-/Zeit-Berechnungen auf der Faktentabelle — ist
Power-BI-Standard für saubere Zeitintelligenz. `_Measures` bündelt alle Kennzahlen in einer
disconnected Tabelle (übliche Best Practice, hält Measures aus den Datentabellen heraus).
