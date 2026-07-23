# Analyse der Unpünktlichkeit im Flugverkehr

# vom Flughafenbetreiber fLAirport 





#### Ablauf

* Power BI und SQL zusammen eingesetzt
* Flugverspätungen analysiert und visualisiert
* Eine Präsentation der Ergebnisse vorbereitet





#### Ziele

* Aktuellen Überblick der Lage
* Identifizierung von Häufungen
* Handlungsempfehlungen





#### Anforderungen und Bedingungen

* Betrachtet werden nur Flüge von oder nach LAX
* Informationen jeweils nach Abflug und Ankunft aufbereitet
* Zeitraum der Flugdaten 2015 bis 2017
* Gestrichene oder umgeleitete Flüge sollen vollständig außen vor bleiben
* Unpünktlich bedeutet mindestens 5 Minuten Abweichung von der geplanten Zeit
* Die Abweichung betrifft sowohl zu früh, als auch zu spät, da beides den Flugbetrieb beeinflusst.
* Betrifft die Ankunftszeiten in LA und die Abflugzeiten von LA



#### Work Pipe und Tech Stack





☐ **Daten sammeln >> SQL / CSV**



Verbinde dich mit den Datenquellen und lade die benötigten Daten für deine Analysen.



* PostgreSQL Datenbank für Flugdaten
* CSV Datei für Kürzel und Namen der Fluggesellschaften 



Für eine optimale Performance werden nach Möglichkeiten nur die, für die Analyse, notwendigen Daten herangezogen und zur Weiterverarbeitung in Power Bi importiert. 



Dazu wird mit Hilfe von angepassten SQL-Queries bereits beim Datenimport die Datenquelle selektiert.



* Zeitraum 2015 bis 2017 mit EXTRACT und WHERE
* Flughafen für Abflug oder Ankunft LA mit WHERE
* Keine gestrichenen oder umgeleiteten Flüge mit WHERE
* Absolute Werte für Verspätungen mit ABS
* Ankunft oder Abflug durch eine neue Spalte mit CASE WHEN THEN ELSE 







☐ **Daten bereinigen >> SQL / PowerQueryEditor (PQE) \& M**





* Anpassung von Daten-Typen
* Umbenennung von Abfragen, Angewendeten Schritten, Spalten
* Ersetzen von Werten, z.B. 2400
* Formatierung der Uhrzeiten mit M
* Zusammenführung der Fluggesellschaften mit Namen aus der CSV-Datei
* Ergänzung von neuen Hilfsspalten fl\_direction, fl\_direction\_delay\_status







* Ergänzung um eine Datumstabell für lückenlose zeitliche Darstellungen















☐ **Datenanalyse >> DAX**





##### **☑ Kennzahlen für den Double-Check**

* 1.264.229 Datensätze
* 377.347 pünktliche Flüge 
* 886.882 Flüge mit relevanter Verspätung
* 368.669 Flüge von LA mit Verspätung 
* 518.213 Flüge nach LA mit Verspätung
* 13 betroffene Fluggesellschaften
* Durchschnittliche Unpünktlichkeit in Minuten pro Flug 26,42 (arrival = 26,51 und departure = 26,30)



















#### 3A Übersicht der wichtigsten Kennzahlen



☐ Stelle eine Übersicht der **wichtigsten Kennzahlen** der Flüge und Unpünktlichkeit dar.



☐ Interessant für einen ersten Überblick sind die Anzahl der Flüge, 

☐ der Anteil der Airlines an den Flügen, der Anteil unpünktlicher Flüge oder 

☐ die durchschnittliche Unpünktlichkeit in Minuten pro Flug. 

☐ Wenn dir noch weitere, wichtige Kennzahlen einfallen, dann berechne auch diese und stelle sie dar.



☐ Welche drei Airlines haben die höchste durchschnittliche Unpünktlichkeit pro Flug? 

☐ Wie hoch ist der Anteil der unpünktlichen Flüge dieser Airlines?



☐ In welchen Zeiträumen sind die Flüge besonders unpünktlich? 

☐ Lassen sich bestimmte Zeitpunkte oder wiederkehrende Muster finden? 

☐ Untersuche neben den zeitlichen Ebenen Jahr, Quartal und Monat auch separat die Kalenderwoche, den Wochentag und die Stunde des Tages.



☐ Berechne die Kennzahlen mit Measures. Selbst wenn du sie in dieser Übersicht nicht verwendest, kannst du sie später nutzen und geeignet filtern.



☐ Überprüfe beim Erstellen der Measures deine Zwischenschritte in einer Tabelle. Achte darauf, auf welche Grundgesamtheit sich deine Berechnungen beziehen. Nutze Variablen, wenn es dir sinnvoll erscheint. Die Funktionen CALCULATE und FILTER ermöglichen sehr vielfältige Berechnungen.





☐Datenfelder mehrfach in Visuals nutzen. tabellarische Darstellung , prozentualen Anteil 



On-Time Performance (OTP). 



3b. Welche drei Airlines haben die höchste durchschnittliche Unpünktlichkeit pro Flug? Wie hoch ist der Anteil der unpünktlichen Flüge dieser Airlines?



Verwende einen Datenschnitt, um leicht verschiedene Zeiträume betrachten zu können.



☐ **Data Storytelling**: Bereite eine 15-minütige Präsentation deiner Ergebnisse nach den Grundsätzen des Data Storytelling vor. 

☐ Beachte dabei alle drei Aspekte: **Kontext**, **Narrativ** und **Visualisierung**.





Best Practices



////////////////////////////////

////////////////////////////////

0

☐ Extra Tabelle für Measures

☐ Extra Tabelle für fortlaufende Datumstabelle

☐ Extra Tabelle für vollständige Uhrzeittabelle





☐ Tech Stack and Work Pipline

* Datenquellen: PostgrSQL, CSV
* Tools: Power-BI Desktop App und Berichts-Setup, Power-BI Services und Dashboard
* Scripts: SQL >> Datensammlung, M >> Datenbereinigung, DAX >> Datenaufbereitung 







☐ Switch. Eine getrennte Betrachtung nach Abflug oder Ankunft soll wahlweise möglich sein.

Verwende Klarnamen für die Airlines, nicht nur die Codes.



☐ Datenschnitt. Verwende einen Datenschnitt, um leicht verschiedene Zeiträume betrachten zu können.



Handlungsempfehlungen ? 









Ablauf der Abschlussprüfung (AP)

////////////////////////////////

////////////////////////////////



☐ Überprüfung Mindestkriterien (Kompetenzraster) für das Zertifikat

☐ 15 Minuten Präsentation

☐ Elemente des Data Storytelling

☐ Best Practices für Visualisierungen











