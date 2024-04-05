# SUMMARY

This project aims to estimate the revenue distribution of alcohol sales in Germany across various groups.

## ESA -\> to be added by Justin

In this code, data from two general population surveys (2018 and 2021) are analysed to provide estimates on alcohol use across various groupings.

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
