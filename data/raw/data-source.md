# Data Source — PostgreSQL `flights` + Carrier Lookup
**DATENHERKUNFT & DATENWÖRTERBUCH FÜR fLAIRPORT**

---

Die Rohdaten stammen aus einer PostgreSQL-Trainingsdatenbank (StackFuel-Umgebung, Zugang nicht
öffentlich) plus einer beiliegenden CSV. Diese Datei dokumentiert Quelle, relevante Spalten und
den vorgegebenen Datenscope — sanitisiert, ohne Zugangsdaten. Die eigentliche Extraktion (SQL
Native Query) ist in [`../../report/etl-m-code.md`](../../report/etl-m-code.md) beschrieben.

## Inhalt

- [Source Systems](#source-systems)
- [Table `flights` — relevant columns](#table-flights--relevant-columns)
- [Lookup `UNIQUE_CARRIERS.csv`](#lookup-unique_carrierscsv)
- [Assignment Scope](#assignment-scope)

---

## Source Systems

| Quelle | System | Inhalt |
| :--- | :--- | :--- |
| Datenbank `Flight_Data`, Tabelle `flights` | PostgreSQL | Flugbewegungen (Fakten) |
| `UNIQUE_CARRIERS.csv` | CSV (beiliegend) | Airline-Code → Klarname |

Der Datensatz ist groß — die Aufgabe verlangt ausdrücklich, Abfragen präzise einzuschränken
(nur benötigte Spalten, nur relevante Zeilen). Das geschieht direkt in der SQL Native Query beim
Import (Query Folding), nicht erst in Power Query.

## Table `flights` — relevant columns

Nur die für die Analyse genutzten Spalten (das vollständige Datenwörterbuch der Aufgabe umfasst
mehr Felder, u. a. `flight_id`, `op_carrier_fl_num`, `cancellation_code`, `carrier_delay`).

| Spalte | Bedeutung | Verwendung |
| :--- | :--- | :--- |
| `fl_date` | Flugdatum | Zeitraum-Filter + Basis für `_Calendar` (Zeitreihen) |
| `op_carrier` | Kennung der Fluglinie | Join auf Carrier-Lookup |
| `origin` / `dest` | Start- / Zielflughafen | LAX-Filter + Richtungsableitung (`fl_direction`) |
| `crs_dep_time` / `crs_arr_time` | geplante Ab-/Ankunftszeit | Roh-Uhrzeiten (in ETL zu `time` geparst) |
| `dep_time` / `arr_time` | tatsächliche Ab-/Ankunftszeit | Roh-Uhrzeiten |
| `dep_delay` / `arr_delay` | Verspätung in Minuten (±) | `ABS()` → vorzeichenlose Verspätung |
| `cancelled` / `diverted` | gestrichen / umgeleitet (bool) | Ausschluss-Filter |

## Lookup `UNIQUE_CARRIERS.csv`

Die Datenbank führt nur Kurzcodes; die CSV liefert die Klarnamen.

| Spalte | Bedeutung |
| :--- | :--- |
| `Code` | Airline-Kurzcode (Join-Schlüssel = `flights.op_carrier`) |
| `Description` | Vollständiger Name (z. B. „American Airlines Inc.") |

## Assignment Scope

Von der Aufgabenstellung vorgegebene Filterbedingungen (1:1 in der SQL `WHERE`-Klausel umgesetzt):

- **Zeitraum:** Flüge der Jahre **2015–2017**
- **Flughafen:** nur Flüge, die in **LAX** starten *oder* landen (`origin = 'LAX' OR dest = 'LAX'`)
- **Ausschluss:** gestrichene und umgeleitete Flüge bleiben vollständig außen vor
- **Unpünktlich:** ≥ 5 Minuten Abweichung von der geplanten Zeit; bei Ankünften zählt die
  Ankunfts-, bei Abflügen die Abflugzeit (getrennte Betrachtung nach Richtung)

> Zugangsdaten zur Trainingsdatenbank stehen bewusst nicht hier und nicht im Repo (siehe
> `.gitignore` / `Abschlussprojekt-Infos.md`).
