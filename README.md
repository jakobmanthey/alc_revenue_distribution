# SUMMARY

This project aims to estimate the revenue distribution of alcohol sales in Germany across various groups.

## ESA -\> to be added by Justin

In this code, data from two general population surveys (2018 and 2021) are analysed to provide estimates on alcohol use across various groupings.

Daten aus zwei Erhebungswellen des ESA 2018 und 2021 wurden zusammen analysiert.

Einkommen:

Anhand folgender Fragen wurde das monatliche Netto-Haushaltseinkommen im ESA erhoben. 

„Wie hoch ist das monatliche Netto-Einkommen Ihres Haushalts insgesamt?
Gemeint ist dabei die Summe, die sich aus Lohn, Gehalt, Einkommen aus selbständiger Tätigkeit, Rente oder Pension ergibt. Rechnen Sie bitte auch die Einkünfte aus öffentlichen Beihilfen, Einkommen aus Vermietung, Verpachtung, Wohngeld, Kindergeld und sonstige Einkünfte hinzu und ziehen Sie dann Steuern und Sozialversicherungsbeiträge ab.“:
1 „bis unter 500 Euro“
2 „500 bis unter 750 Euro“
3 „750 bis unter 1.000 Euro“
4 „1.000 bis unter 1.250 Euro“
5 „1.250 bis unter 1.500 Euro“
6 „1.500 bis unter 1.750 Euro“
7 „1.750 bis unter 2.000 Euro“
8 „2.000 bis unter 2.250 Euro“
9 „2.250 bis unter 2.500 Euro“
10 „2.500 bis unter 3.000 Euro“
11 „3.000 bis unter 4.000 Euro“
12 „4.000 bis unter 5.000 Euro“
13 „5.000 Euro und mehr“
 
Im CATI Interview (ESA kann sowohl via CATI, CAWI oder PAPI beantwortet werden) konnte man sich in gröbere Kategorien einordnen, falls keine Einordnung in den oben genannten Kategorien vorgenommen wurde (das betrifft 115 Befragte):
1  „bis unter 1.500 Euro“ 
2  „1.500 bis unter 3.000 Euro“ 
3 „3.000 Euro und mehr“

Um diese kategorialen Auspärgungen metrisch darstellen zu können, wurden die gewichteten Mittelwerte des Einkommens des EVS 2018 pro Kategorie benutzt. Um den Einfluss der Haushaltsgröße zu berücksichtigen wurden die Mittelwerte zusätzlich Bedarfsgewicht des Äquivalenzeinkommens, also nach Haushaltsgröße, dargestellt. Da nicht alle Haushaltsgrößen in den Einkommensklassen vorhanden waren bzw. manche nur sehr sprälich bestezt waren, wurden die Mittelwerte der Einkommensklassen nur differneziert als Schätzung genutzt, wenn die Zelle mindestens eine Stichprobengröße von 5 aufwies. War dies nicht der Fall, dann wurde für diese Fälle der Mittelwert zusammen mit der jeweilig nedrigeren Haushaltsgröße berücksichtigt. So konnte für jede Einkommensklasse des ESA ein entsprechender Mittelwert abhängig von der Haushaltsgröße genutzt werden. Zusammen mit dem Bedarfsgewicht, bsierend auf der Haushaltsgröße, wurde daraus ein Nettoäquivalenzeinkommen berechnet.

FÜr die Kategorisierung des Nettoäquivalenzeinkommens in niedrig, mittel und hoch wurden die Grenzwerte der Einkommensverteilung von EU-SILC im Jahr 2018 und 2021 verwendet. Da keine Verteilung in Terzilen öffentlich zugänglich ist, wurden Quartile genutzt. Es wurden jeweils das untere Quartil als niedrieges Einkommen, das zweite und das dritte Quartil als mittleres Einkommen und das vierte Quartil als hohes Einkommen definiert. 
2018 lagen die oberen Grenzwerte bei 1355€, 1893€ und 2572€.
2021 lagen diese bei 1475€, 2079€ und 2924€. 

Alkoholkonsum
Im ESA wurden Angaben zum mindestens einmaligen Konsums von Alkohol in den letzten 12 Monaten sowie
die durchschnittliche Menge des Alkoholkonsums und des episodischen Rauschtrinkens in den letzten 30 Tagen erhoben.

Die durchschnittliche Menge des Alkoholkonsums wurde anhand eines
Frequenz-Menge-Index jeweils für Bier, Wein/Sekt, Spirituosen sowie al-
koholhaltige Mixgetränke ermittelt. Dieser wurde aus Angaben zur Anzahl
der Tage, an denen die jeweiligen Getränke konsumiert wurden, sowie der
Anzahl der getrunkenen Einheiten an einem typischen Konsumtag gebil-
det. Zur Berechnung der Menge des Reinalkohols in Gramm wurden die
Liter-Angaben der Getränke mittels getränkespezifischer Alkoholgehalte
und der Anzahl der getrunkenen Einheiten verwendet. Die getränkespezifi-
schen Alkoholgehalte (Bier: 4,8 Vol. %; Wein/Sekt: 11,0 Vol. %; Spirituo-
sen: 33,0 Vol. %) entsprechen einer Alkoholmenge von 38,1 g, 87,3 g be-
ziehungsweise 262,0 g Reinalkohol pro Liter. Für alkoholhaltige
Mixgetränke wurde 0,04 Liter Spirituosen als durchschnittlicher Alkohol-
gehalt eines Glases (0,3 bis 0,4 Liter) angenommen. Aus dem berechneten
Reinalkohol in Gramm wurde eine individuelle, durchschnittliche Tages-
menge berechnet. Anhand empfohlener Tagesgrenzwerte für risikoarmen
Alkoholkonsum wurden drei Kategorien gebildet:
1) risikoarmer Konsum (Männer ≤ 24 g, Frauen ≤ 12 g)
2) riskanter Konsum (Männer > 24 g & <= 60 g ; Frauen > 12 g & <= 40 g)und
3) Hoch-Konsum (Männer > 60 g ; Frauen > 40 g).
Für die Analysen wurden Personen mit fehlenden Werten bei einzelnen Getränkearten ausgeschlossen. 

Im Anschluss wurde der Anteil jedes Individuums an der Gesamtmenge berechnet und pro Gruppe summiert. 
Die Poststratifikationsgewichte wurden hierbei, wie bei den Prävalenzschätzungen berücksichtigt.
   
Episodisches Rauschtrinken wurde mit einem offenen Antwortformat
über die Anzahl der Tage mit fünf oder mehr konsumierten Gläsern Alko-
hol, egal ob Bier, Wein/Sekt, Spirituosen oder alkoholhaltige Mixgetränke
(circa 14 g Reinalkohol pro Glas, das heißt mindestens 70 g Reinalkohol)
erfasst sowie anhand der durchschnittlichen Tagesmenge (> 60g).


**Variablenbeschreibung:**
Blatt Trinkgruppen	
Gruppe	Gruppe nach Soziodemographischen und alkoholbezogenen Variablen
Geschlecht	Geschlecht (binär)
Einkommen	Pro Kopf Netto-Äquivalenzeinkommen pro Jahr (siehe Tabelle für Grenzwerte)
Alter	Alter
Konsumstatus	Alkoholkonsum in den letzten 30 Tagen
Alkoholgr	Alkohol in Gramm in den letzten 30 Tagen
Biergr	Alkohol in Gramm Bier in den letzten 30 Tagen
Weingr	Alkohol in Gramm Wein/Sekt in den letzten 30 Tagen
Spirituosengr	Alkohol in Gramm Spirituosen in den letzten 30 Tagen
Mischgetränkegr	Alkohol in Gramm Mischgetränken in den letzten 30 Tagen
Alkohol 	Anteil am gesamten Alkoholkonsum (letzte 30 Tage)
Bier 	Anteil am gesamten Bierkonsum (letzte 30 Tage)
Wein	Anteil am gesamten Konsum von Wein/Sekt (letzte 30 Tage)
Spirituosen	Anteil am gesamten Konsum von Spirituosen (letzte 30 Tage)
Mischgetränke	Anteil am gesamten Konsum von Mischgetränken (letzte 30 Tage)
n_Alkohol	Stichprobengröße für Anteile an Alkohol und einzelne Alkoholika
Binge30	Prävalenz: mindestens einmal mehr als 5 Getränke pro Trinkgelegenheit (letzte 30 Tage)
Binge30_low	Untere Grenze des Konfidenzintervalls
Binge30_up	Obere Grenze des Konfidenzintervalls
n_Binge30	Valide Fälle für Binge30

	
Blatt Soziodemographische Gruppen	
Geschlecht	Geschlecht (binär)
Einkommen	Pro Kopf Netto-Äquivalenzeinkommen pro Jahr (siehe Tabelle für Grenzwerte)
Alter	Alter
n	Stichprobengröße
Alk12	Prävalenz Alkoholkonsum (letzte 12 Monate)
Alk12_low	Untere Grenze des Konfidenzintervalls
Alk12_up	Obere Grenze des Konfidenzintervalls
Risikoarm	Risikoarmer Alkoholkonsum (<12/<24) (unter Konsumenten)
Risikoarm_low	Untere Grenze des Konfidenzintervalls
Risikoarm_up	Obere Grenze des Konfidenzintervalls
Riskant	Riskanter Alkoholkonsum (12-40/24-60) (unter Konsumenten) 
Riskant_low	Untere Grenze des Konfidenzintervalls
Riskant_up	Obere Grenze des Konfidenzintervalls
Hoch	Gefährlich/Hoher Alkoholkonsum (>40/>60) (unter Konsumenten)
Hoch_low	Untere Grenze des Konfidenzintervalls
Hoch_up	Obere Grenze des Konfidenzintervalls
Alkoholgr_kon	Alkohol in Gramm in den letzten 30 Tagen (unter Konsumenten) 
Alkoholgr_kon_low	Untere Grenze des Konfidenzintervalls
Alkoholgr_kon_up	Obere Grenze des Konfidenzintervalls
n_Alkoholgr	Valide Fälle Alkoholgr
Alkoholgr	Alkohol in Gramm in den letzten 30 Tagen 
Alkoholgr_low	Untere Grenze des Konfidenzintervalls
Alkoholgr_up	Obere Grenze des Konfidenzintervalls
n_Binge30	Valide Fälle Binge30
Binge30	Prävalenz: mindestens einmal mehr als 5 Getränke pro Trinkgelegenheit (letzte 30 Tage)
Binge30_low	Untere Grenze des Konfidenzintervalls
Binge30_up	Obere Grenze des Konfidenzintervalls


**Probleme/offene Punkte bzgl. Berechnung:**

- Keine Terzile von EUROSTAT veröffentlicht. Bisher Quartile für Unterscheidung hergenommen. 1. Unterstes Quartil 2. zweites und drittes Quartil 3. Oberstes Quartil. Ändern?

## EVS -\> to be added by Anna

In this code, data from a general population survey (2018) are analysed to provide estimates on alcohol spendings across various groupings (Einkommen x Geschlecht x Alter x Trinkgruppe(ESA)).

**Outputfile:**

spendingsperdrink.csv und spendingsperdrink.rds

**Labelling:**

Geschlecht: 1= männlich, 2=weiblich\
Einkommensgruppe: 1=niedrig, 2=mittel, 3=hoch\
Trinkgruppe: 1=risikoarm, 2=risikant, 3=hoch

**Variablenbeschreibung:**

avg_wert_pro_stdd_w: durchschnittliche Ausgaben pro Standarddrink in Euro (Standarddrink: 0,33l Bier, 0,125l Wein, 0,04l Spirituose)

**Probleme/offene Punkte bzgl. Berechnung:**

-   mitgelieferte Hochrechnungsfaktoren nicht berücksichtigt

-   Alkoholische Getränke (Käufe im Ausland) abziehen? wenn ja, wie? Daten liegen nicht spezifisch für Getränketyp vor

-   Personen über 64 werden derzeit nicht berücksichtigt (25% des Gesamt-N), weil ESA Trinkgruppen nur bis 64 vorhanden

-   Einkommensgruppen basieren auf empirischen Terzilen des Nettoäquivalenzeinkommens berechnet mit Angaben im Datensatz (ungewichtet), liegt höher als die offiziellen Angaben des Statistischen Bundesamtes und ESA

-   zu simple Berechnung der Standarddrinks?: Bier Menge in l / 0.33, Wein Menge in l / 0.125, Spirituosen Menge in l / 0.04 (keine Unterschiedung in Alkoholgehalt innerhalb der Gruppen, z.B. für Wermut, Portwein, Mischbier etc.)

## -\> to be added by Jakob/Carolin

In this code, data from ESA and EVS are combined to split alcohol revenue into various groupings.
