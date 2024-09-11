# SUMMARY

This project aims to estimate the revenue distribution of alcohol sales in Germany across various groups.

## ESA -\> to be added by Justin

In this code, data from two general population surveys (2018 and 2021) are analysed to provide estimates on alcohol use across various groupings.

Der Output ist einer Excel Tabelle dargestellt. Es wurden die bereits publizierten Variablen aus Rauschert et al. 2022 als Grundlage genommen und erweitert für die spezifische Fragestellung.

Alkoholkonsum (siehe Rauschert C, Möckl J, Seitz NN, Wilms N, Olderbak S, Kraus L: The use of psychoactive substances in Germany—findings from the Epidemiological Survey of Substance Abuse 2021. Dtsch Arztebl Int 2022; 119: 527–34. DOI: 10.3238/arztebl.m2022.0244) Die durchschnittliche Menge des Alkoholkonsums wurde anhand eines Frequenz-Menge-Index jeweils für Bier, Wein/Sekt, Spirituosen sowie alkoholhaltige Mixgetränke ermittelt. Dieser wurde aus Angaben zur Anzahl der Tage, an denen die jeweiligen Getränke konsumiert wurden, sowie der Anzahl der getrunkenen Einheiten an einem typischen Konsumtag gebildet. Zur Berechnung der Menge des Reinalkohols in Gramm wurden die Liter-Angaben der Getränke mittels getränkespezifischer Alkoholgehalte und der Anzahl der getrunkenen Einheiten verwendet. Die getränkespezifischen Alkoholgehalte (Bier: 4,8 Vol. %; Wein/Sekt: 11,0 Vol. %; Spirituosen: 33,0 Vol. %) entsprechen einer Alkoholmenge von 38,1 g, 87,3 g beziehungsweise 262,0 g Reinalkohol pro Liter (e12). Für alkoholhaltige Mixgetränke wurde 0,04 Liter Spirituosen als durchschnittlicher Alkoholgehalt eines Glases (0,3 bis 0,4 Liter) angenommen. Aus dem berechneten Reinalkohol in Gramm wurde eine individuelle, durchschnittliche Tagesmenge berechnet. Anhand empfohlener Tagesgrenzwerte für risikoarmen Alkoholkonsum (11) wurden fünf Kategorien gebildet:

1)  lebenslang abstinent
2)  abstinent in den letzten 12 Monaten
3)  abstinent in den letzten 30 Tagen
4)  risikoarmer Konsum (Männer ≤ 24 g, Frauen ≤ 12 g) und
5)  riskanter Konsum (Männer \> 24 g; Frauen \> 12 g).

Episodisches Rauschtrinken wurde mit einem offenen Antwortformat über die Anzahl der Tage mit fünf oder mehr konsumierten Gläsern Alkohol, egal ob Bier, Wein/Sekt, Spirituosen oder alkoholhaltige Mixgetränke (circa 14 g Reinalkohol pro Glas, das heißt mindestens 70 g Reinalkohol) erfasst. Update: Hier wurde das Episodische Rauschtrinken anhand der durchschnitllichen täglichen konsumierten Menge Alkohol geupdated (falls \>60gr).

Das kategorial erhobene Haushalts-Einkommen im ESA wurde mithile der gewichteten Mittelwerte der Angaben aus dem EVS 2018, differenziert nach Haushaltsgröße, metrisch umcodiert. Um zu kleinen Fallzahlen nicht zu viel Bedeutung beizumessen, wurden Angaben nur differenziert, wenn mehr als 5 Angaben zu der spezifischen Haushaltgröße vorhanden waren. Wenn das nicht der Fall war, wurden die Mittelwerte der Haushaltsgrößen zusammengelegt. Wenn es beispielsweise mehr als 10 Angaben für Ein-Personenhaushalte, mehr als 5 für 1,5-Personenhaushalte, aber nur 4 für Haushalte mit mehr als 1,5 Personen, dann wurde der Mittelwert für alle Ein-Personenhaushalte und für alle Haushalte größer oder gleich 1,5 Personen verwendet. Im Anschluss wurde das so ermittelte Einkommen mit der Haushaltsgröße zu einem Haushalts-Netto-Äquivalenzeinkommen umcodiert. Diese wurde anhand der Einkommensdezile aus der EU-SILC differenziert für die Jahre 2018 und 2021 in niedrig (1.-3. Dezil), mittel (4-6. Dezil) und hoch (7.-10. Dezil) eingeteilt.

## EVS -\> to be added by Anna

In this code, data from the EVS general population survey (2018) are analysed to provide estimates on alcohol spendings across various groupings (Einkommen x Geschlecht x Alter x Trinkgruppe(ESA) x Getränketyp).

**Outputfile:**

spendingsperdrink\_[DATE].csv und spendingsperdrink\_[DATE].rds

**Variablenbeschreibung Outputfile:**

avg_wert_pro_stdd_w: durchschnittliche Ausgaben pro Standarddrink. Ein Standarddrink enthält 12 Gramm Reinalkohol. Aufgrund zu geringer Fallzahl wurden für Mischgetränke keinen Ausgaben pro Einkommen x Geschlecht x Alter x Trinkgruppe-Stratum berechnet, stattdessen stellt der Wert den Durschnitt über alle Strata da.

Trinkgruppe: Definiert über Stratum-spezifische Perzentilgrenzen für Risikoarmes/Riskantes/Hochriskantes Trinken aus ESA.

n_haushalte: Anzahl der Haushalte im Einkommen x Geschlecht x Alter x Trinkgruppe x Getränketyp-Stratum (CAVE: nicht Personen, da Menge und Ausgaben nur auf Haushaltsebene vorliegen; Personen können nur über Geschlecht und Alter differenziert werden)

ci_low & ci_high: SE anhand von n_haushalte berechnet

**Probleme/offene Punkte bzgl. Berechnung:**

-   Alkoholische Getränke (Käufe im Ausland) abziehen? wenn ja, wie? Daten liegen nicht spezifisch für Getränketyp vor

-   Personen über 64 werden derzeit nicht berücksichtigt (25% des Gesamt-N), weil ESA Trinkgruppen nur bis 64 vorhanden

## -\> to be added by Jakob/Carolin

In this code, data from ESA and EVS are combined to split alcohol revenue into various groupings.
