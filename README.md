# SUMMARY

This project aims to estimate the revenue distribution of alcohol sales in Germany across various groups.

## ESA -\> to be added by Justin

In this code, data from two general population surveys (2018 and 2021) are analysed to provide estimates on alcohol use across various groupings.
Der Output ist einer Excel Tabelle dargestellt. Es wurden die bereits publizierten Variablen aus Rauschert et al. 2022 als Grundlage genommen und erweitert für die spezifische Fragestellung.

Alkoholkonsum (siehe Rauschert C, Möckl J, Seitz NN, Wilms N, Olderbak S, Kraus L: The use of psychoactive substances in Germany—findings from the Epidemiological Survey of Substance Abuse 2021. Dtsch Arztebl Int 2022; 119: 527–34. DOI: 10.3238/arztebl.m2022.0244)
Die durchschnittliche Menge des Alkoholkonsums wurde anhand eines Frequenz-Menge-Index jeweils für Bier, Wein/Sekt, Spirituosen sowie alkoholhaltige Mixgetränke ermittelt. Dieser wurde aus Angaben zur Anzahl der Tage, an denen die jeweiligen Getränke konsumiert wurden, sowie der Anzahl der getrunkenen Einheiten an einem typischen Konsumtag gebildet. Zur Berechnung der Menge des Reinalkohols in Gramm wurden die Liter-Angaben der Getränke mittels getränkespezifischer Alkoholgehalte
und der Anzahl der getrunkenen Einheiten verwendet. Die getränkespezifischen Alkoholgehalte (Bier: 4,8 Vol. %; Wein/Sekt: 11,0 Vol. %; Spirituosen: 33,0 Vol. %) entsprechen einer Alkoholmenge von 38,1 g, 87,3 g beziehungsweise 262,0 g Reinalkohol pro Liter (e12). Für alkoholhaltige Mixgetränke wurde 0,04 Liter Spirituosen als durchschnittlicher Alkoholgehalt eines Glases (0,3 bis 0,4 Liter) angenommen. Aus dem berechneten Reinalkohol in Gramm wurde eine individuelle, durchschnittliche Tagesmenge berechnet. Anhand empfohlener Tagesgrenzwerte für risikoarmen Alkoholkonsum (11) wurden fünf Kategorien gebildet:

1) lebenslang abstinent
2) abstinent in den letzten 12 Monaten
3) abstinent in den letzten 30 Tagen
4) risikoarmer Konsum (Männer ≤ 24 g, Frauen ≤ 12 g) und
5) riskanter Konsum (Männer > 24 g; Frauen > 12 g).
   
Episodisches Rauschtrinken wurde mit einem offenen Antwortformat über die Anzahl der Tage mit fünf oder mehr konsumierten Gläsern Alkohol, egal ob Bier, Wein/Sekt, Spirituosen oder alkoholhaltige Mixgetränke
(circa 14 g Reinalkohol pro Glas, das heißt mindestens 70 g Reinalkohol) erfasst. Update: Hier wurde das Episodische Rauschtrinken geupdated anhand der durchschnitllichen täglichen konsumierten Menge Alkohol, falls diese größer aös 60 gr beträgt.

Das kategorial erhobene Haushalts-Einkommen wurde mithile der gewichteten Mittelwerte der Angaben aus dem EVS 2018 differenziert nach Gewichtung der Haushaltsgröße für das Netto-Äquivalenzeinkommen metrisch umcodiert. Um zu kleinen Fallzahlen nicht zu viel Bedeutung beizumessen, wurden nur Angaben von mind. 5 Personen pro Zelle benutzt und ansonsten die Mittelwerte zu einer Haushaltsgröße zusammengefügt. Wenn beispielsweise nur 5 Angaben im EVS zum Einkommen in Haushalten mit mehr als einer Person gab, dann wurde der Mittelwert nicht nach Haushhaltsgröße differnziert. Wenn es >10 Angaben für Ein-Personenhaushalte, >5 für 1,5 Personenhaushalte, aber nur 4 für >1,5 Personenhaushalte gab, dann wurde der Mittelwert für >1,5 Haushalte verwendet. Im Anschluss wurde das so ermittelte Einkommen mit der Haushaltsgröße zu einem Haushalts-Netto-Äquivalenzeinkommen umcodiert. 

Für diese und weitere Berechnungen sind die Stata Codes zusammen mit einer Variablenliste hochgeladen worden, da sich die Benennung im Stata Code zur Excel Liste unterscheidet.



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
