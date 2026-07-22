# DAX Measures — On-Time Performance & Delay Metrics
**MEASURE LAYER OF THE fLAIRPORT POWER BI MODEL**

---

Die Kennzahlen des Reports liegen als DAX-Measures auf der Faktentabelle
`Report_Flights_Data`. Alle Quoten nutzen `DIVIDE()` (Division-durch-0-sicher), alle
abgeleiteten Werte bauen auf wenige Basis-Bausteine auf — eine Single Source of Truth statt
paralleler Formeln. Diese Datei zeigt die bereinigte Measure-Struktur; Format-Angaben in
Klammern (`#,0`, `0.00 %`).

## Inhalt

- [Base Counts](#base-counts)
- [On-Time & Delay Ratios](#on-time--delay-ratios)
- [Delay Severity](#delay-severity)
- [Year-over-Year Trend](#year-over-year-trend)
- [Airline Ranking & Top-3 Share](#airline-ranking--top-3-share)
- [Per-Day Averages](#per-day-averages)
- [Measure → KPI Mapping](#measure--kpi-mapping)

---

## Base Counts

Reine Zähler — die Bausteine, auf denen jede Quote und jeder Durchschnitt aufsetzt. Das
Textfeld `fl_delay_status` (in der ETL gesetzt, siehe [`etl-m-code.md`](etl-m-code.md)) trägt die
≥5-Minuten-Klassifikation; die Measures filtern nur noch darauf.

```dax
cnt_total          = COUNTROWS('Report_Flights_Data')

cnt_total_delays   = CALCULATE(COUNTROWS('Report_Flights_Data'),
                         CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay"))

cnt_total_ontimes  = CALCULATE(COUNTROWS('Report_Flights_Data'),
                         'Report_Flights_Data'[fl_delay_status] = "on time")

cnt_delayed_arrival   = CALCULATE(COUNTROWS('Report_Flights_Data'),
                            CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "arrival delay"))

cnt_delayed_departure = CALCULATE(COUNTROWS('Report_Flights_Data'),
                            CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "departure delay"))

cnt_op_carrier     = DISTINCTCOUNT('Report_Flights_Data'[op_carrier_code])

sum_delays_total   = SUM('Report_Flights_Data'[fl_delay_value])
```

Einheitlich aufgebaute Zähler (kein `COALESCE`-Sonderfall), sprechende Namen. `sum_delays_total`
summiert die Verspätungsminuten — pünktliche Flüge tragen `0` bei und verfälschen die Summe daher
nicht. Ergebnisse u. a.: `cnt_total` = 1.264.229 · `cnt_total_delays` = 886.882 · `cnt_op_carrier` = 13.

## On-Time & Delay Ratios

Je Konzept genau ein Measure. Beide sind das Spiegelbild voneinander (Summe = 100 %).

```dax
otp_rate    = DIVIDE([cnt_total_ontimes], [cnt_total])   -- (0.00 %)  → 29,85 %
delay_rate  = DIVIDE([cnt_total_delays],  [cnt_total])   -- (0.00 %)  → 70 %
```

`DIVIDE()` statt `/` liefert bei leerem Nenner sauber `BLANK()` statt eines Fehlers — die
On-Time Performance ist die zentrale Business-Kennzahl des Reports.

## Delay Severity

Trennung von *Häufigkeit* (Quote oben) und *Schwere* (Dauer). Der Durchschnitt teilt bewusst
die Verspätungssumme durch die Zahl der **verspäteten** Flüge — nicht durch alle, sonst würden
die `0`-Werte der pünktlichen Flüge den Schnitt nach unten ziehen.

```dax
avg_delay_value_total = DIVIDE([sum_delays_total], [cnt_total_delays])   -- → 26,42 Min.

delay_index = [delay_rate] * [avg_delay_value_total]                     -- → 18,54
```

`delay_index` kombiniert Häufigkeit × Schwere zu einer Kennzahl — genau die Art
Kombinationsindikator, den die Analyse dem irreführenden „Ø-Verspätung pro Flug" als Alternative
empfiehlt.

## Year-over-Year Trend

Vergleich erstes vs. letztes Betrachtungsjahr über `VAR`-Blöcke.

```dax
kpi_delay_total_trend_diff =
    VAR cnt_first = CALCULATE([cnt_total_delays], YEAR('Report_Flights_Data'[fl_date]) = 2015)
    VAR cnt_last  = CALCULATE([cnt_total_delays], YEAR('Report_Flights_Data'[fl_date]) = 2017)
    RETURN cnt_last - cnt_first                              -- (#,0)     → 22.135

kpi_delay_total_trend_pct =
    VAR cnt_first = CALCULATE([cnt_total_delays], YEAR('Report_Flights_Data'[fl_date]) = 2015)
    VAR cnt_last  = CALCULATE([cnt_total_delays], YEAR('Report_Flights_Data'[fl_date]) = 2017)
    RETURN DIVIDE(cnt_last - cnt_first, cnt_last)            -- (0.00 %)  → 7,17 %
```

> Hinweis: Die Jahre `2015`/`2017` sind bewusst fest verdrahtet (fixer 3-Jahres-Report). Bei einer
> Datenerweiterung wären `YEAR(MIN(...))` / `YEAR(MAX(...))` über die Kalendertabelle vorzuziehen.

## Airline Ranking & Top-3 Share

Kern der zentralen Erkenntnis: die drei Airlines mit der höchsten Ø-Verspätung tragen nur einen
Bruchteil zur Gesamtverspätung bei. Entscheidend ist, dass **Einfärbung und Anteilszahl dieselbe
Rangdefinition teilen** — `top3_avg_ranking` ist die einzige „Wer ist Top 3?"-Quelle.

```dax
top3_avg_ranking =
    RANKX(ALLSELECTED('Report_Flights_Data'[op_carrier_name]),
          [avg_delay_value_total], , DESC, Dense)

top3_avg_ranking_highlights =                     -- Conditional-Formatting-Farbe je Balken
    IF([top3_avg_ranking] <= 3, "#E3BE60", "#A0A0A0")

top3_avg_delay_value_in_cnt =                     -- Delays der Top-3-Airlines
    SUMX(
        FILTER(VALUES('Report_Flights_Data'[op_carrier_name]), [top3_avg_ranking] <= 3),
        [cnt_total_delays]
    )                                             -- (#,0)    → 31.092

top3_avg_delay_value_in_pct =                     -- deren Anteil an ALLEN Delays
    DIVIDE([top3_avg_delay_value_in_cnt], [cnt_total_delays])   -- (0.00 %) → 3,51 %
```

`RANKX` rankt die Airlines nach Ø-Verspätung, `SUMX` über die gefilterte Top-3-Menge summiert
deren Delays, `DIVIDE` setzt sie ins Verhältnis — Ergebnis 3,51 %, die Kernzahl der Präsentation.

## Per-Day Averages

Bezug auf die separate Kalendertabelle `_Calendar` — `COUNTROWS(_Calendar)` liefert die Zahl der
Kalendertage im Filterkontext und macht so „pro Tag"-Durchschnitte möglich.

```dax
avg_delays_cnt_per_day = DIVIDE([cnt_total_delays], COUNTROWS(_Calendar))   -- → 809
```

## Measure → KPI Mapping

| Measure | Ergebnis | Slide |
| :--- | :--- | :--- |
| `cnt_total` · `otp_rate` · `delay_rate` | 1.264.229 · 29,85 % · 70 % | Kennzahlen |
| `cnt_delayed_departure` · `cnt_delayed_arrival` | 368.669 · 518.213 | Verspätungen nach Richtung |
| `cnt_op_carrier` · `delay_index` | 13 · 18,54 | Kennzahlen im Detail |
| `kpi_delay_total_trend_diff` · `_pct` | 22.135 · 7,17 % | Kennzahlen im Detail |
| `avg_delays_cnt_per_day` · `avg_delay_value_total` | 809 · 26,42 Min. | Verspätung pro Tag/Flug |
| `top3_avg_delay_value_in_pct` | 3,51 % | Ø-Verspätung je Airline / Insight |
