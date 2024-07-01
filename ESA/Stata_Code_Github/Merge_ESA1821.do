***********************************************************************************************
************************************************************************************************
** Eva Krowartz, Justin Möckl
** Collaborators: Olderbak
** Titel of project: Alc share of total consumption by consumption group and proportion of revenue by group and beverage type
** 29.01.2024: erstellt
** 20.06.2024: Mit neuen Datensatz laufen lassen

* Vorgefertigte Datensätze appenden
************************************************************************************************
use "...\esa21_alc.dta", clear
append using "...\esa18_alc.dta"


lab var altgr3 "Altersgruppen"

* gemergt Einkommensgrenzen neu ausrechnen
fre hne
sum hne_mean

*** Äquivalenzeinkommen
* Eine Variable für Einkommen nach Grenzen in einzelnen Wellen
gen hne_eq3_1821=hne_eq3_18 if intj==2018
replace hne_eq3_1821=hne_eq3_21 if intj==2021
label values hne_eq3_1821 einkommensgruppen

lab var hne_eq3_1821 "Einkommensgruppen (Terzil ESA) Nettoäquivalenzeinkommen"

list intj help_adultshh help_childhh help_child1418hh hne hne_mean if hne_mean<100
 
bysort hne_eq3_18: sum hne_mean // 1 bis 1380€ 2 bis 2253€ 3 ab 2266€
bysort hne_eq3_21: sum hne_mean // 1 bis 1587€ 2 bis 2529€ 3 ab 2616€
* Vergleich über Jahre
bysort hne_eq3_1821 intj: sum hne_mean 

* Eine Variable für Einkommen nach Grenzen in einzelnen Wellen
gen hne_eq4_1821=hne_eq4_18 if intj==2018
replace hne_eq4_1821=hne_eq4_21 if intj==2021
label values hne_eq4_1821 einkommensgruppen

lab var hne_eq4_1821 "Einkommensgruppen (Quartil EU-SILC) Nettoäquivalenzeinkommen"

tab hne hne_eq4_1821 , m
bysort hne_eq4_1821: sum hne_mean // 1 bis 1453€ 2 bis 2918€ 3 ab 2616€
bysort hne_eq4_18: sum hne_mean // 1 bis 1332€ 2 bis 2529€ 3 ab 2616€
bysort hne_eq4_21: sum hne_mean // 1 bis 1453€ 2 bis 2918€ 3 ab 2983€
* Vergleich über Jahre
bysort hne_eq4_1821 intj: sum hne_mean 

* Eine Variable für Einkommen nach Grenzen in einzelnen Wellen
gen hne_eq10_1821=hne_eq10_18 if intj==2018
replace hne_eq10_1821=hne_eq10_21 if intj==2021
label values hne_eq10_1821 einkommensgruppen

lab var hne_eq10_1821 "Einkommensgruppen (Dezil EU-SILC) Nettoäquivalenzeinkommen"

tab hne hne_eq10_1821 , m
bysort hne_eq10_1821: sum hne_mean // 1 bis 1587€ 2 bis 2709 3 ab 2447€
bysort hne_eq10_18: sum hne_mean // 1 bis 1453 2 bis 2367 3 ab 2447€
bysort hne_eq10_21: sum hne_mean // 1 bis 1587 2 bis 2709 3 ab 2733€
* Vergleich über Jahre
bysort hne_eq10_1821 intj: sum hne_mean 

*******************************************************************************
* Gruppen für Auswertung (18 Gruppen)

fre ges2 hne_eq4_1821 hne_eq3_1821 hne_eq10_1821 altgr3

egen group1 = group(ges2 hne_eq4_1821 altgr3), label
egen group2 = group(ges2 hne_eq3_1821 altgr3), label
egen group3 = group(ges2 hne_eq10_1821 altgr3), label

label var group1 "Gruppen: Einkommen nach Quartil EU-SILC"
label var group2 "Gruppen: Einkommen nach Terzil ESA"
label var group3 "Gruppen: Einkommen nach Dezil EU-SILC"

* Anzeige der Gruppen mit Beschriftungen
*tab group1 group2, m
*tab group1 group3, m
fre group1 group2 group3
*******************************************************************************
* Gruppen für Auswertung (18 Gruppen * 3 Trinkgruppen)

fre ges2 hne_eq4_1821 hne_eq3_1821 hne_eq10_1821 altgr3 trinkgruppe

egen tgroup1 = group(ges2 hne_eq4_1821 altgr3 trinkgruppe), label
egen tgroup2 = group(ges2 hne_eq3_1821 altgr3 trinkgruppe), label
egen tgroup3 = group(ges2 hne_eq10_1821 altgr3 trinkgruppe), label

label var tgroup1 "Gruppen nach Trinkgruppen: Einkommen nach Quartil EU-SILC"
label var tgroup2 "Gruppen nach Trinkgruppen: Einkommen nach Terzil ESA"
label var tgroup3 "Gruppen nach Trinkgruppen: Einkommen nach Dezil EU-SILC"

* Anzeige der Gruppen mit Beschriftungen
*tab tgroup1 tgroup2, m
fre tgroup1 tgroup2 tgroup3


* Anteil der Trinkgruppen am Konsum nur unter Complete Cases
gen alk_cc=1 if alk30gr>0 & alk30gr<. & bier30gr>=0 & bier30gr<. ///
& wein30gr>=0 & wein30gr<. & spir30gr>=0 & spir30gr<. & mish30gr>=0 & mish30gr<.

label var alk_cc "Complete Cases Alkohol/Getränke (in Gramm)"



* Insgesamt Alkoholmenge
bysort trinkgruppe ges: sum alk30gr 
bysort group1 ges: sum alk30gr 
* 9 Diverse mit Gesamtangabe, daher nicht in Analysen berücksichtigt

***** Trinkgruppen Dummys
* Risikoarm (<12/<24) 
recode trinkgruppe (1=1 "Risikoarm (<12/<24)") (2 3=0 "Riskant/Gefährlich/Hoch") ///
(.=.) (.a=.a "lebenslang abstinent") (.b=.b "letzte 12 Monate abstinent") ///
(.c=.c "letzte 30 Tage abstinent"), gen(riskarm)
tab riskarm trinkgruppe, m
label var riskarm "Risikoarmer Alkoholkonsum (<12/<24) (unter Konsumenten)" 

* Riskant (12-40/24-60)
recode trinkgruppe (2=1 "Riskant (12-40/24-60)") (1 3=0 "Risikoarm/Gefährlich/Hoch") ///
(.=.) (.a=.a "lebenslang abstinent") (.b=.b "letzte 12 Monate abstinent") ///
(.c=.c "letzte 30 Tage abstinent"), gen(risk)
tab risk trinkgruppe, m
label var risk "Riskanter Alkoholkonsum (12-40/24-60) (unter Konsumenten)" 

* Gefährlich/Hoch (>40/>60)
recode trinkgruppe (3=1 "Gefährlich/Hoch (>40/>60)") (1 2=0 "Risikoarm/Riskant") ///
(.=.) (.a=.a "lebenslang abstinent") (.b=.b "letzte 12 Monate abstinent") ///
(.c=.c "letzte 30 Tage abstinent"), gen(gef)
tab gef trinkgruppe, m
label var gef "Gefährlich/Hoher Alkoholkonsum (>40/>60) (unter Konsumenten)" 

* Alkohol insgesamt
*************** GEWICHTET nach Redressementgewichtung ****************************************************

* gewichtet (nach Redressementgewicht)
gen alk30gr_rw=alk30gr*rg_bundn if tgroup1!=. & alk_cc==1 
* Konsumierte Summe unter Trinkgruppen - gewichtet (nach Redressementgewicht)
egen alk30gr_sumrw=total(alk30gr*rg_bundn) if tgroup1!=. & alk_cc==1 
* Anteil der an dieser Summe
gen alk30gr_proprw=(alk30gr*rg_bundn)/alk30gr_sumrw if tgroup1!=. & alk_cc==1
* Summe über Trinkgruppen
bysort tgroup1: egen alk30gr_proprw_tg=sum(alk30gr_proprw) if tgroup1!=. & alk_cc==1 
bysort tgroup1: egen alk30gr_rw_tg=sum(alk30gr_rw) if tgroup1!=. & alk_cc==1 

label var alk30gr_rw "(Redressement)Gewichtet Alkohol pro Tag in Gramm ingesamt(letzte 30 Tage)"
label var alk30gr_sumrw "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm ingesamt (letzte 30 Tage)"
label var alk30gr_proprw "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm ingesamt (letzte 30 Tage)"
label var alk30gr_proprw_tg "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm pro Trinkgruppe (letzte 30 Tage)"
label var alk30gr_rw_tg "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm pro Trinkgruppe (letzte 30 Tage)"

* Bier insgesamt - gewichtet (nach Redressementgewicht)
* gewichtet (nach Redressementgewicht)
gen bier30gr_rw=bier30gr*rg_bundn if tgroup1!=. & alk_cc==1 
* Konsumierte Summe unter Trinkgruppen - gewichtet (nach Redressementgewicht)
egen bier30gr_sumrw=total(bier30gr*rg_bundn) if tgroup1!=. & alk_cc==1 
* Anteil der an dieser Summe
gen bier30gr_proprw=(bier30gr*rg_bundn)/bier30gr_sumrw if tgroup1!=. & alk_cc==1
* Summe über Trinkgruppen
bysort tgroup1: egen bier30gr_proprw_tg=sum(bier30gr_proprw) if tgroup1!=. & alk_cc==1
bysort tgroup1: egen bier30gr_rw_tg=sum(bier30gr_rw) if tgroup1!=. & alk_cc==1 

label var bier30gr_rw "(Redressement)Gewichtet Alkohol pro Tag in Gramm ingesamt Bier (letzte 30 Tage)"
label var bier30gr_sumrw "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm ingesamt Bier (letzte 30 Tage)"
label var bier30gr_proprw "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm ingesamt Bier (letzte 30 Tage)"
label var bier30gr_proprw_tg "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm pro Trinkgruppe Bier (letzte 30 Tage)"
label var bier30gr_rw_tg "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm pro Trinkgruppe Bier (letzte 30 Tage)"

* Wein insgesamt - gewichtet (nach Redressementgewicht)
* gewichtet (nach Redressementgewicht)
gen wein30gr_rw=wein30gr*rg_bundn if tgroup1!=. & alk_cc==1 
* Konsumierte Summe unter Trinkgruppen - gewichtet (nach Redressementgewicht)
egen wein30gr_sumrw=total(wein30gr*rg_bundn) if tgroup1!=. & alk_cc==1 
* Anteil der an dieser Summe
gen wein30gr_proprw=(wein30gr*rg_bundn)/wein30gr_sumrw if tgroup1!=. & alk_cc==1
* Summe über Trinkgruppen
bysort tgroup1: egen wein30gr_proprw_tg=sum(wein30gr_proprw) if tgroup1!=. & alk_cc==1
bysort tgroup1: egen wein30gr_rw_tg=sum(wein30gr_rw) if tgroup1!=. & alk_cc==1 

label var wein30gr_rw "(Redressement)Gewichtet Alkohol pro Tag in Gramm ingesamt Wein (letzte 30 Tage)"
label var wein30gr_sumrw "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm ingesamt Wein (letzte 30 Tage)"
label var wein30gr_proprw "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm ingesamt Wein (letzte 30 Tage)"
label var wein30gr_proprw_tg "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm pro Trinkgruppe Wein (letzte 30 Tage)"
label var wein30gr_rw_tg "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm pro Trinkgruppe Wein (letzte 30 Tage)"

* Spirituosen insgesamt - gewichtet (nach Redressementgewicht)
* gewichtet (nach Redressementgewicht)
gen spir30gr_rw=spir30gr*rg_bundn if tgroup1!=. & alk_cc==1 
* Konsumierte Summe unter Trinkgruppen - gewichtet (nach Redressementgewicht)
egen spir30gr_sumrw=total(spir30gr*rg_bundn) if tgroup1!=. & alk_cc==1 
* Anteil der an dieser Summe
gen spir30gr_proprw=(spir30gr*rg_bundn)/spir30gr_sumrw if tgroup1!=. & alk_cc==1
* Summe über Trinkgruppen
bysort tgroup1: egen spir30gr_proprw_tg=sum(spir30gr_proprw) if tgroup1!=. & alk_cc==1
bysort tgroup1: egen spir30gr_rw_tg=sum(spir30gr_rw) if tgroup1!=. & alk_cc==1 

label var spir30gr_rw "(Redressement)Gewichtet Alkohol pro Tag in Gramm ingesamt Spirituosen (letzte 30 Tage)"
label var spir30gr_sumrw "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm ingesamt Spirituosen (letzte 30 Tage)"
label var spir30gr_proprw "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm ingesamt Spirituosen (letzte 30 Tage)"
label var spir30gr_proprw_tg "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm pro Trinkgruppe Spirituosen (letzte 30 Tage)"
label var spir30gr_rw_tg "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm pro Trinkgruppe Spirituosen (letzte 30 Tage)"

* Mischgetränke insgesamt - gewichtet (nach Redressementgewicht)
* gewichtet (nach Redressementgewicht)
gen mish30gr_rw=mish30gr*rg_bundn if tgroup1!=. & alk_cc==1 
* Konsumierte Summe unter Trinkgruppen - gewichtet (nach Redressementgewicht)
egen mish30gr_sumrw=total(mish30gr*rg_bundn) if tgroup1!=. & alk_cc==1 
* Anteil der an dieser Summe
gen mish30gr_proprw=(mish30gr*rg_bundn)/mish30gr_sumrw if tgroup1!=. & alk_cc==1
* Summe über Trinkgruppen
bysort tgroup1: egen mish30gr_proprw_tg=sum(mish30gr_proprw) if tgroup1!=. & alk_cc==1
bysort tgroup1: egen mish30gr_rw_tg=sum(mish30gr_rw) if tgroup1!=. & alk_cc==1 

label var mish30gr_rw "(Redressement)Gewichtet Alkohol pro Tag in Gramm ingesamt Mischgetränke (letzte 30 Tage)"
label var mish30gr_sumrw "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm ingesamt Mischgetränke (letzte 30 Tage)"
label var mish30gr_proprw "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm ingesamt Mischgetränke (letzte 30 Tage)"
label var mish30gr_proprw_tg "(Redressement)Gewichteter Anteil an Alkohol pro Tag in Gramm pro Trinkgruppe Mischgetränke (letzte 30 Tage)"
label var mish30gr_rw_tg "(Redressement)Gewichtete Summe Alkohol pro Tag in Gramm pro Trinkgruppe Mischgetränke (letzte 30 Tage)"

