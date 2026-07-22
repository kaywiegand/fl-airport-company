# DAX Measures — fLAirport Power BI Report

Strukturierter Export aller im Power-BI-Datenmodell definierten Measures (Tabelle
`Report_Flights_Data`, TableID 6864). Quelle: Measure-Export aus Power BI Desktop
(Roh-Tabelle mit ID/Expression/FormatString etc.). Deckt BACKLOG.md #1, Teilpunkt (4)
("DAX-Measure-Formeln im Klartext") ab.

**Format-Notation:** `#,0` = ganzzahlig mit Tausendertrennzeichen · `0.00\ %` = Prozent mit
2 Nachkommastellen · leer = kein explizites Format (übernimmt Kontext-Formatierung).

---

## 1. Basiskennzahlen (Zähler)

Reine `COUNTROWS`/`SUM`-Measures — die Grundlage, auf der alle Raten und Quoten aufbauen.

### `cnt_total`
Gesamtanzahl Flüge im gefilterten Datensatz.
```dax
COUNTROWS('Report_Flights_Data')
```
Format: `#,0` · **Ergebnis: 1.264.229** (Kennzahlen-Slide, kpi-1)

### `cnt_total_delays`
Anzahl aller verspäteten Flüge (Ankunft ODER Abflug, `fl_delay_status` enthält "delay").
```dax
COALESCE(
    CALCULATE(
        COUNTROWS('Report_Flights_Data'),
        CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay")
    ),
    0
)
```
Format: `#,0` · **Ergebnis: 886.882** (kpi-1, airline-delays)

### `cnt_total_ontimes`
Anzahl pünktlicher Flüge (`fl_delay_status = "on time"`).
```dax
CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    'Report_Flights_Data'[fl_delay_status] = "on time"
)
```
Format: `#,0.0` · **Ergebnis: 377.347** (kpi-1)

### `cnt_delayed_arrival`
Anzahl Ankunftsverspätungen (`fl_delay_status` enthält "arrival delay").
```dax
CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "arrival delay")
)
```
Format: `#,0` · **Ergebnis: 518.213** (kpi-2)

### `cnt_delayed_departure`
Anzahl Abflugverspätungen (`fl_delay_status` enthält "departure delay").
```dax
CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "departure delay")
)
```
Format: `#,0` · **Ergebnis: 368.669** (kpi-2)

### `cnt_op_carrier`
Anzahl unterschiedlicher Fluggesellschaften im gefilterten Datensatz.
```dax
COUNTROWS(DISTINCT(Report_Flights_Data[op_carrier_code]))
```
Format: `0` · **Ergebnis: 13** (kpi-3)

### `sum_delays_total`
Summe aller Verspätungsminuten (Rohsumme, Basis für `avg_delay_value_total`).
```dax
SUM('Report_Flights_Data'[fl_delay_value])
```
Format: `0` — kein eigenes KPI, nur Zwischenschritt.

### `cnt_total_delays_fixed`
Wie `cnt_total_delays`, aber mit `FILTER(ALL(...))` statt `CALCULATE` direkt — cross-filter-
kontext-unabhängig (ignoriert aktive Slicer/Filter). Basis für `pct_shares_total_delays`.
```dax
CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    FILTER(
        ALL('Report_Flights_Data'),
        CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay")
    )
)
```
Format: `0`

---

## 2. Raten & Quoten

### `otp_rate` — On-Time Performance
```dax
DIVIDE([cnt_total_ontimes], [cnt_total])
```
Format: `0.00\ %` · **Ergebnis: 29,85 %** (kpi-3, das offizielle OTP-KPI der Präsentation)

### `pct_total_ontimes`
Gleiche Formel wie `otp_rate`, nur mit explizitem 0-Fallback und gröberer Rundung (2
Nachkommastellen statt 2) — für den Pünktlichkeits-Split auf kpi-1 (rundet auf 30 %).
```dax
DIVIDE([cnt_total_ontimes], [cnt_total], 0)
```
Format: `0.00\ %`

### `pct_total_delays`
Gegenstück zu `pct_total_ontimes` — Anteil verspäteter Flüge, gerundet auf 70 % (kpi-1).
```dax
DIVIDE([cnt_total_delays], [cnt_total], 0)
```
Format: `0.000\ %`

### `delay_rate`
Faktisch identisch zu `pct_total_delays` (ohne `DIVIDE`-Fallback) — zweite, redundante
Definition derselben Quote. Basis für `delay_index`.
```dax
[cnt_total_delays]/[cnt_total]
```
Format: `0.00\ %` · **Ergebnis: 70 %**

### `pct_shares_total_delays`
Verspätungsanteil auf Basis von `cnt_total_delays_fixed` (kontextunabhängig), skaliert ×100
— eine dritte Variante derselben Grundfrage, vermutlich für eine spezifische Visual-Anforderung
(z. B. Kartenwert ohne %-Formatierung).
```dax
VAR delay_count = CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay")
)
RETURN
DIVIDE(delay_count, [cnt_total_delays_fixed]) * 100
```
Format: kein Format

---

## 3. Verspätungsschwere (Dauer)

### `avg_delay_value_total` — Ø Verspätung pro Flug
**Wichtiger Gotcha, dokumentiert im Original-Kommentar der Messung:** ein einfacher
`AVERAGE()` über alle Zeilen wäre falsch, weil pünktliche Flüge mit `fl_delay_value = 0`
den Durchschnitt nach unten verzerren würden. Die Messung filtert deshalb explizit auf
Zeilen mit `delay`-Status, bevor sie mittelt.
```dax
CALCULATE(
    AVERAGE('Report_Flights_Data'[fl_delay_value]),
    FILTER(
        'Report_Flights_Data',
        CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay")
    )
)
```
> Original-Kommentar im Measure:
> "OK: `[sum_delays_total] / [cnt_total_delays]` — FALSCH: `AVERAGE(fl_delay_value)`, weil
> auch die pünktlichen mit delay_value 0 mitgezählt werden."

Format: kein Format · **Ergebnis: 26,42 Min.** (kpi-3, kpi-4, zentrale Kennzahl der gesamten
"Indikator ist fragwürdig"-Erkenntnis)

### `avg_delays_cnt_per_day`
```dax
DIVIDE([cnt_total_delays], COUNTROWS(_Calendar))
```
Format: kein Format · **Ergebnis: 809** (kpi-4, Ø Verspätungen pro Tag)

### `avg_flights_cnt_per_day`
```dax
DIVIDE([cnt_total], COUNTROWS(_Calendar))
```
Format: kein Format — kein eigenes KPI in der Präsentation, aber verfügbar.

### `avg_ontime_cnt_per_day`
```dax
DIVIDE([cnt_total_ontimes], COUNTROWS(_Calendar))
```
Format: kein Format — kein eigenes KPI in der Präsentation, aber verfügbar.

### `delay_index`
Kombinationskennzahl aus Häufigkeit (`delay_rate`) und Schwere (`avg_delay_value_total`) —
genau die Art Indikator, die die Empfehlung "Indikator verbessern" fordert.
```dax
[delay_rate] * [avg_delay_value_total]
```
Format: kein Format · **Ergebnis: 18,54** (kpi-3, Delay Index)

---

## 4. Zeitlicher Vergleich (2015 → 2017)

### `kpi_delay_total_trend_diff`
Absolute Differenz der Verspätungsanzahl zwischen 2017 und 2015.
```dax
VAR cnt15 = CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay"),
    YEAR('Report_Flights_Data'[fl_date]) = 2015
)
VAR cnt17 = CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay"),
    YEAR('Report_Flights_Data'[fl_date]) = 2017
)
RETURN cnt17 - cnt15
```
Format: `#,0` · **Ergebnis: 22.135** (kpi-3, "Steigerung Anzahl Verspätungen")

### `kpi_delay_total_trend_pct`
Prozentuale Steigerung derselben Differenz, relativ zu 2017.
```dax
VAR cnt15 = CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay"),
    YEAR('Report_Flights_Data'[fl_date]) = 2015
)
VAR cnt17 = CALCULATE(
    COUNTROWS('Report_Flights_Data'),
    CONTAINSSTRING('Report_Flights_Data'[fl_delay_status], "delay"),
    YEAR('Report_Flights_Data'[fl_date]) = 2017
)
RETURN DIVIDE((cnt17 - cnt15), cnt17)
```
Format: `0.00\ %` · **Ergebnis: 7,17 %** (kpi-3)

---

## 5. Airline-Ranking & Top-3-Anteil

Die Measure-Gruppe hinter der zentralen Erkenntnis der Präsentation ("Indikator ist
fragwürdig") — Ranking nach Ø-Verspätung und der auffällig kleine Anteil der Top-3-Airlines
an der Gesamtverspätung.

### `top3_avg_ranking`
Rang jeder Airline nach `avg_delay_value_total`, absteigend, dichte Rangfolge (keine
Ranglücken bei Gleichständen). Treibt die farbliche Hervorhebung im Ranking-Chart.
```dax
RANKX(
    ALLSELECTED(Report_Flights_Data[op_carrier_name]),
    CALCULATE([avg_delay_value_total]),
    ,
    DESC,
    Dense
)
```
Format: `0`

### `top3_avg_ranking_highlights`
Conditional-Formatting-Measure — liefert direkt die Hex-Farbe für den Ranking-Chart
(Gold für Top 3, Grau für den Rest). Genau die Gold/Grau-Einfärbung auf `airline-delays.jpg`.
```dax
VAR CurrentRank = [top3_avg_ranking]
RETURN
    IF(CurrentRank <= 3, "#E3BE60", "#A0A0A0")
```
Format: kein Format (Rückgabetyp String/Hex, nicht Zahl)

### `top3_avg_delay_value_in_cnt`
Absolute Anzahl Verspätungen, die auf die Top-3-Airlines (nach Ø-Verspätung) entfallen —
die zentrale "31.092"-Zahl aus dem Ranking-Chart.
```dax
VAR TopNTable =
    TOPN(
        3,
        VALUES('Report_Flights_Data'[op_carrier_name]),
        [avg_delay_value_total],
        DESC
    )
RETURN
SUMX(TopNTable, [cnt_total_delays])
```
Format: `#,0` · **Ergebnis: 31.092** (airline-delays)

### `top3_avg_delay_value_in_pct`
Anteil dieser 31.092 an der Gesamtverspätung — **die Kernzahl der ganzen Erkenntnis** (3,51 %).
```dax
VAR topN_table =
    TOPN(
        3,
        VALUES('Report_Flights_Data'[op_carrier_name]),
        [avg_delay_value_total],
        DESC
    )
VAR top3_delay_count = SUMX(topN_table, [cnt_total_delays])
RETURN DIVIDE(top3_delay_count, [cnt_total_delays])
```
Format: `0.00\ %` · **Ergebnis: 3,51 %** (airline-delays, Insight-Slide "Erkenntnisse aus der
Betrachtung")

---

## Mapping: Measure → sichtbare Kennzahl in der Präsentation

| Measure | Ergebnis | Slide (StoryView) |
| :--- | :--- | :--- |
| `cnt_total` | 1.264.229 | Kennzahlen — Gesamtüberblick |
| `cnt_total_ontimes` / `pct_total_ontimes` | 377.347 / 30 % | Kennzahlen — Gesamtüberblick |
| `cnt_total_delays` / `pct_total_delays` | 886.882 / 70 % | Kennzahlen — Gesamtüberblick |
| `cnt_delayed_departure` | 368.669 | Kennzahlen — Verspätungen nach Richtung |
| `cnt_delayed_arrival` | 518.213 | Kennzahlen — Verspätungen nach Richtung |
| `cnt_op_carrier` | 13 | Kennzahlen im Detail |
| `otp_rate` | 29,85 % | Kennzahlen im Detail |
| `delay_index` | 18,54 | Kennzahlen im Detail |
| `kpi_delay_total_trend_diff` / `_pct` | 22.135 / 7,17 % | Kennzahlen im Detail |
| `avg_delays_cnt_per_day` | 809 | Verspätung pro Tag und Flug |
| `avg_delay_value_total` | 26,42 Min. | Verspätung pro Tag und Flug |
| `top3_avg_ranking` / `top3_avg_ranking_highlights` | Rang + Gold/Grau-Farbe | Ø-Verspätung je Airline |
| `top3_avg_delay_value_in_cnt` | 31.092 | Ø-Verspätung je Airline |
| `top3_avg_delay_value_in_pct` | 3,51 % | Ø-Verspätung je Airline / Insight "Erkenntnisse aus der Betrachtung" |

---

## Für TechView — Vorschlag Kürzung

Für die `tech-dax`-Slide (TechView, aktuell Platzhalter in `slides.yaml`) eignen sich
exemplarisch diese vier als DAX-Codebeispiele, weil sie unterschiedliche Techniken zeigen und
die Kernaussage der Präsentation direkt stützen:

1. **`avg_delay_value_total`** — zeigt den dokumentierten Korrektur-Gotcha (naives `AVERAGE()`
   wäre falsch), passt inhaltlich zur "Indikator ist fragwürdig"-Erkenntnis.
2. **`top3_avg_delay_value_in_pct`** — die 3,51-%-Kernzahl, zeigt `TOPN`+`SUMX`+`DIVIDE`-Muster.
3. **`delay_index`** — einfachste Formel, zeigt die Kombination aus Häufigkeit und Schwere.
4. **`kpi_delay_total_trend_pct`** — zeigt `VAR`-Nutzung für einen Jahresvergleich.

Noch nicht in dieser Übersicht (weiterhin offen, siehe BACKLOG.md #1): SQL-Quelltext (Native
Query), M-Code je Power-Query-Schritt, Datenmodell/Beziehungen.

---

# Refactoring

Analyse des IST-Standes: gefundene Probleme, Begründung, korrigierte Lösung. Die bereinigte
Fassung ist portfoliofertig in `report/measures-dax.md` dokumentiert; dieser Abschnitt hält fest, *warum*
refactored wurde.

## R1 — Drei Measures für dieselbe Delay-Quote

**Gefunden:** `pct_total_delays`, `delay_rate` und (teilweise) `pct_shares_total_delays`
berechnen alle den Anteil verspäteter Flüge. `pct_total_ontimes` und `otp_rate` sind ebenfalls
formelgleich.

**Warum schlecht:** Fünf Measures für zwei Konzepte (Delay-Anteil, On-Time-Anteil). Ändert sich
die Basislogik (z. B. die ≥5-Minuten-Schwelle in der ETL, oder der Nenner), muss man daran denken,
alle Varianten konsistent nachzuziehen — sonst driften Kennzahlen, die eigentlich identisch sein
sollten, unbemerkt auseinander. Klassische Single-Source-of-Truth-Verletzung.

**Lösung:** Je Konzept genau ein Measure behalten, Duplikate entfernen.
- `otp_rate` behalten → `pct_total_ontimes` löschen.
- `delay_rate` behalten (mit Fix aus R2) → `pct_total_delays` löschen.
- `pct_shares_total_delays` ist *nicht* dasselbe (Anteil der aktuellen Auswahl an ALLEN Delays,
  Filterkontext bewusst via `ALL()` entfernt) — bleibt, wird aber umbenannt und nutzt bestehende
  Bausteine wieder (siehe R5).

## R2 — `delay_rate` nutzt rohe Division statt `DIVIDE()`

**Gefunden:**
```dax
delay_rate = [cnt_total_delays] / [cnt_total]
```
**Warum schlecht:** Jede andere Quote im Modell nutzt `DIVIDE(...)` mit eingebautem
Division-durch-0-Schutz. Die rohe `/`-Variante wirft in einem Filterkontext mit leerem Nenner
einen Fehler (`Infinity`/Error) statt eines sauberen `BLANK()`. Inkonsistent und die einzige
echte Fehlerquelle in der Measure-Sammlung.

**Lösung:**
```dax
delay_rate = DIVIDE([cnt_total_delays], [cnt_total])
```

## R3 — `avg_delay_value_total` unnötig komplex (die eigene Notiz kennt die bessere Lösung)

**Gefunden:**
```dax
avg_delay_value_total =
CALCULATE(
    AVERAGE('Report_Flights_Data'[fl_delay_value]),
    FILTER('Report_Flights_Data', CONTAINSSTRING([fl_delay_status], "delay"))
)
```
Der Measure-Kommentar hält selbst fest: *„OK: `[sum_delays_total] / [cnt_total_delays]`."*

**Warum schlecht:** `FILTER` über die ganze Tabelle + `CALCULATE(AVERAGE)` ist teurer und
schlechter faltbar als eine simple Division zweier bereits vorhandener Measures. Der Autor kannte
die einfachere Form (im Kommentar), hat sie aber nicht eingesetzt. Der Filter ist zudem gar nicht
nötig: pünktliche Flüge haben in der ETL `fl_delay_value = 0` (M-Schritt 14), tragen also nichts
zur Summe bei.

**Lösung:** Die vom Autor selbst notierte „OK"-Form verwenden — nutzt zugleich das sonst tote
`sum_delays_total`:
```dax
avg_delay_value_total = DIVIDE([sum_delays_total], [cnt_total_delays])
```
Ergebnis identisch (26,42 Min.), einfacher, faltbarer, ohne Tabellen-`FILTER`.

## R4 — „Top 3" ist zweimal unterschiedlich definiert

**Gefunden:** `top3_avg_ranking_highlights` färbt Airlines über `RANKX(..., Dense) <= 3` gold.
`top3_avg_delay_value_in_cnt` / `_in_pct` (die 3,51-%-Kernzahl) bestimmen die Top 3 dagegen über
`TOPN(3, ...)`.

**Warum schlecht:** Zwei verschiedene Definitionen desselben „Top 3". Bei einem exakten
Gleichstand zweier Airlines auf `avg_delay_value_total` kann `Dense`-Rang vier Airlines als
„Rang ≤ 3" gold einfärben, während die KPI-Zahl weiterhin exakt drei aufsummiert — Chart und Zahl
widersprechen sich. Bei stetigen Durchschnitten unwahrscheinlich, aber es ist eine latente
Inkonsistenz zwischen dem, was hervorgehoben wird, und dem, was die Zahl misst.

**Lösung:** Eine einzige „Wer ist Top 3?"-Quelle. Zähl-Measure aus demselben `top3_avg_ranking`
ableiten, das auch die Einfärbung nutzt:
```dax
top3_avg_delay_value_in_cnt =
SUMX(
    FILTER(VALUES('Report_Flights_Data'[op_carrier_name]), [top3_avg_ranking] <= 3),
    [cnt_total_delays]
)

top3_avg_delay_value_in_pct =
DIVIDE([top3_avg_delay_value_in_cnt], [cnt_total_delays])
```
Chart-Einfärbung und Anteilszahl teilen sich jetzt garantiert dieselbe Rangdefinition.

## R5 — Umbenennungen & wiederverwendete Bausteine

**Gefunden:** `pct_shares_total_delays` rechnet den Zähler mit einem eigenen `CALCULATE`
neu (statt `[cnt_total_delays]` zu nutzen) und multipliziert mit `100` statt Prozentformat.
`cnt_total_delays_fixed` heißt nach seiner Implementierung (`ALL()`), nicht nach seiner Bedeutung.

**Warum schlecht:** Doppelte Logik + Name beschreibt das *Wie*, nicht das *Was* → schlechter lesbar.

**Lösung:** Bausteine wiederverwenden, sprechend benennen, Prozentformat statt `×100`:
```dax
cnt_delays_grand_total =        -- vormals cnt_total_delays_fixed
CALCULATE([cnt_total_delays], ALL('Report_Flights_Data'))

pct_delays_share =              -- vormals pct_shares_total_delays
DIVIDE([cnt_total_delays], [cnt_delays_grand_total])   -- Format: 0.00 %
```

## R6 — Uneinheitliches `COALESCE` und tote Measures

- **`COALESCE(..., 0)`** nur auf `cnt_total_delays`, nicht auf den Geschwister-Zählern
  (`cnt_total_ontimes`, `cnt_delayed_arrival/departure`). Entweder überall oder nirgends —
  `COUNTROWS` liefert `BLANK()` (kein Error), und `DIVIDE` fängt Blank ohnehin ab. **Lösung:**
  `COALESCE` entfernen, damit alle Basiszähler gleich aufgebaut sind.
- **Tote Measures:** `avg_flights_cnt_per_day` und `avg_ontime_cnt_per_day` speisen kein
  sichtbares KPI. **Lösung:** entweder bewusst als Reserve behalten oder entfernen —
  `sum_delays_total` hingegen wird durch R3 vom „toten" zum genutzten Baustein.
- **Hartkodierte Jahre** in `kpi_delay_total_trend_*` (`= 2015` / `= 2017`). Für einen fixen
  3-Jahres-Report vertretbar, aber bei Datenerweiterung vergleicht das Measure still die falschen
  Jahre. **Lösung:** über `_Calendar` dynamisch (`YEAR(MIN(...))` / `YEAR(MAX(...))`) oder
  mindestens als Kommentar dokumentieren.
