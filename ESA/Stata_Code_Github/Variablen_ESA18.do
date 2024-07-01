***********************************************************************************************
************************************************************************************************
** Eva Krowartz, Justin Möckl
** Collaborators: Olderbak
** Titel of project: Alc share of total consumption by consumption group and proportion of revenue by group and beverage type
** 25.01.2024: erstellt
** 19.06.2024: Neu erstellt mit Einkommensgruppen anhand EVS 2018

* Querschnittsdaten appenden, um Nettoäquivalenzeinkommen berechnen zu können
************************************************************************************************

* 2018 aufbereiten und auf nötige Variablen reduzieren wie 2021

* Nur Bundebene 
********* Benötigte Variablen:
* Da wir sehr viele Gruppen benötigen, bitte ESA 2018 und ESA 2021 zusammen als 
* eine Stichprobe auswerten. 
* Was wir brauchen ist die Verteilung der Trinkgruppen in %
 
* Kategorie 1 (Frauen: > 0 - 12 GPD, Männer: > 0-24 Gramm pro Tag (GPT), 
* Kategorie 2 (Frauen: >12-40 GPT, Männer: >24-60 GPT),
* Kategorie 3 (Frauen: >40 GPT, Männer: >60 GPT)
* Heavy Episodic Drinking (HED): mind 1x pro Monat
 
* für alkoholischen Getränke: Bier, Wein, Spirituosen (für alkoholhaltige
* Mixgetränke 0,04 Liter Spirituosen als durchschnittlicher Alkoholgehalt verwenden)
 
* nach 
* •	Geschlecht (2), 
* •	Altersgruppe (3), 18-34, 35-59, 60+   und
* •	Einkommen (3); hier bitte Terzile der Gesamtstichprobe nehmen und uns die Grenzen mitteilen

* Variablen im Datensatz
************* Soziodemographie
* Geschlecht 
fre ges
* Alter Kategorial und metrisch 
fre altq
sum alter
* Einkommen
fre hne
* Kategoriale Variable: für Dezile zumindest der Gruppen siehe help pctile 
sum hne, d

************* Trinkvariablen
* Trinkgruppen
* Wann leztes Mal konsumiert
fre vx210

* Alkohol in Gramm nach Getränkeart für Kategorien
* Entweder 30 Tage oder 12 Monate Angabe, manche PAPI Leute haben beide angegeben
* In diesen Fällen wurde der höhere Wert genommen
* Alkohol in Gramm in den letzten 30 Tagen 
sum alk30gr bier30gr wein30gr spir30gr mish30gr
* Alkohol in Gramm in den letzten 12 Monaten 
sum alk12gr bier12gr wein12gr spir12gr mish12gr
* Alkohol in Gramm in den letzten 30 Tagen oder in den letzten 12 Monaten
sum alkgr biergr weingr spirgr mishgr


************************************************************************************************
*** Definition der Variablen
************************************************************************************************

**** Variablen vorbereiten ******
**** Geschlecht
* Dummy Männlich
gen male=1 if ges==1
replace male=0 if ges==2
lab var male "Männlich Dummy (ohne divers)"
tab ges male,m
 
* Dummy Weiblich
gen female=1 if ges==2
replace female=0 if ges==1
lab var female "Weiblich Dummy (ohne divers)"
tab ges female,m
 
tab male female, m
 
* Dummy Alle
gen all=1 if ges!=.
lab var all "m|w Dummy"
tab ges all,m

* Geschlecht ohne Divers für Analyse 
recode ges (1 = 1 "Männer") (2 = 0 "Frauen") (3 = .), gen(ges2)
lab var ges2 "Geschlecht binär"


******************************************************************************************
*** Riskanter Konsum 30D 
******************************************************************************************
**** Neu Justin 25.01.2024: alkkon erweitern anhand alk30gr (Complete Cases unter Getränkearten)
* Kontrollieren anhand alkkons und krit30n
* Keine Ausbesserung durch einzelne Getränkesorten, weil Compelte Cases bzgl Getränke
gen trinkgruppe=.

replace trinkgruppe=.a if alkkons==0
replace trinkgruppe=.b if alkkons==1
replace trinkgruppe=.c if alkkons==2
replace trinkgruppe=1 if alk30gr>0 & alk30gr<12 & female==1
replace trinkgruppe=1 if alk30gr>0 & alk30gr<24 & male==1
replace trinkgruppe=2 if alk30gr>=12 & alk30gr<=40 & female==1
replace trinkgruppe=2 if alk30gr>=24 & alk30gr<=60 & male==1
replace trinkgruppe=3 if alk30gr>40 & alk30gr<. & female==1
replace trinkgruppe=3 if alk30gr>60 & alk30gr<. & male==1

label def trinkgruppe .a "lebenslang abstinent" .b "letzte 12 Monate abstinent" .c "letzte 30 Tage abstinent" ///
					  1 "Risikoarm (<12/<24)" 2 "Riskant (12-40/24-60)" ///
					  3 "Gefährlich/Hoch (>40/>60)" 
label val trinkgruppe trinkgruppe

bysort trinkgruppe ges: sum alk*gr *30gr

tab trinkgruppe alkkons, m
tab trinkgruppe alk30kat, m
tab trinkgruppe krit30n, m 
*list ges alk*gr *30gr if alk30kat!=. & trinkgruppe==.


* Bei Getränkesorten einzelne Kategorien auf Null setzen, falls Alkohol getrunken
* aber nicht diese Kategorie, bzw. Tage==0

* Bier bier30
sum bier30 bier30gr
replace bier30gr=0 if bier30==0
sum bier30 bier30gr

* Wein wein30
sum wein30 wein30gr
replace wein30gr=0 if wein30==0
sum wein30 wein30gr

* Spirituosen spir30
sum spir30 spir30gr
replace spir30gr=0 if spir30==0
sum spir30 spir30gr

* Mischgetränke mish30
sum mish30 mish30gr
replace mish30gr=0 if mish30==0
sum mish30 mish30gr


******************************************************************************** 
* Alkohol letzte 30 Tage
recode vx210 (0 1 2 = 0 "nein") (3 = 1 "ja"), gen(vx210_2)

label var vx210_2 "Alkohol letzte 30 Tage"
tab vx210 vx210_2, m

******************************************************************************** 
* Alkohol letzte 12 Monate
recode vx210 (0 1 = 0 "nein") (2 3 = 1 "ja"), gen(vx210_3)

label var vx210_3 "Alkohol letzte 12 Monate"
tab vx210 vx210_3, m

********************************************************************************
* binge01 nur auf Grundlage von f65
* Heavy Episodic Drinking mndest einmal in letzten 30 Tagen (binge_01)

fre binge01
tab binge01 vx210, m

* binge01_2=1 falls mehr als 60g Alkohol pro Tag (alk30gr>60)
gen binge01_2=binge01
replace binge01_2=1 if (alk30gr>60 & alk30gr<.)  // 7 changes

lab var binge01_2 "Binge Drinking Letzte 30 Tage (korrigiert mit alk30gr)"
lab def binge01_2 1 "ja" 0 "nein"
lab val binge01 binge01_2 binge01_2 

bysort ges: tab trinkgruppe binge01_2, m 
bysort ges: tab f67 binge01_2, m 

* Binge in den letzten 12 Monaten
fre binge12
recode binge12 (0=0 "nein") (1/365=1 "ja"), g(binge12_01)
lab var binge12_01 "12-Monats Prävalenz Binge Drinking (korrigiert mit alk*gr)"
fre binge12_01
* in den letzten 30 Tagen, heißt automatisch auch letzte 12 Monate
replace binge12_01=1 if binge01==1
* Durchschnittlich mehr als 60gr pro Tag ist auch Binge
replace binge12_01=1 if (alkgr>60 & alkgr<.) | (alk30gr>60 & alk30gr<.)

tab binge12_01 binge01, m
bysort binge12_01: sum alkgr alk30gr
* Verteilung der Trinkgruppen in % nach Alter 
* Neugruppierung der Altersgruppen (18-34, 35-59, 60+) 

gen altgr3 = .

replace altgr3 = 1 if alter >= 18 & alter <= 34
replace altgr3 = 2 if alter >= 35 & alter <= 59
replace altgr3 = 3 if alter >= 60 & alter < .

* Benenne die Altersgruppen
label define agegroups 1 "18-34 Jahre" 2 "35-59 Jahre" 3 "Über 60 Jahre"
label values altgr3 agegroups

tab altgr3

* Neugruppierung der Haushaltseinkommen Gruppen 
fre hne

* Verbessern mit s10_*
fre s10_* if s10>=.

* hne verbessern anahnd s10_* - auch hier nicht verbessert (wie 2021 ausbessern)
***********************************
* s10_1 im Rahmen der Erstellung des Äquivalenzeinkommens ausbessern
* s10_2 - vergleichbare Kategorien 
replace hne=1 if s10_2==1
replace hne=2 if s10_2==2
replace hne=3 if s10_2==3
replace hne=4 if s10_2==4
replace hne=5 if s10_2==5

* s10_3 - vergleichbare Kategorien 
replace hne=6 if s10_3==1
replace hne=7 if s10_3==2
replace hne=8 if s10_3==3
replace hne=9 if s10_3==4
replace hne=10 if s10_3==5

* s10_4 - vergleichbare Kategorien
replace hne=11 if s10_4==1
replace hne=12 if s10_4==2
replace hne=13 if s10_4==3

* Bis 33% und zwischen 33% und 66% 

gen hne3_18 = .

replace hne3_18 = 1 if hne == 1 | hne == 2 | hne == 3 | hne == 4 | hne == 5 | hne == 6 | hne == 7 | hne == 8
replace hne3_18 = 2 if hne==9 | hne == 10 | hne == 11 
replace hne3_18 = 3 if hne == 12 | hne == 13

* Bennene die Einkommensgruppen
label define einkommensgruppen 1 "Niedriges Einkommen" 2 "Mittleres Einkommen" 3 "Hohes Einkommen" 
label values hne3_18 einkommensgruppen

label var hne3_18 "Haushaltsnetto-Einkommensgruppen"

tab hne3_18

*egen tercile=xtile(hne), n(3) 
*fre tercile // höchste Einkommensklasse nur 19%, daher Höchste Einkommensklasse ab 3000

* Eigentlich nötig Nettoäquivalenzeinkommen
* Berechnung Nettoäquivalenzeinkommen, siehe "Analysen zur Einkommensarmut und -verteilung auf Basis des Mikrozensus"
* Zur Ermittlung des Medians der Äquivalenzeinkommen wird zunächst jeder Person eine Äquivalenzklasse zugewiesen. Diese erhält
* man, indem man die Ober- und Untergrenze der Klasse, in der das jeweilige Haus-
* haltsnettoeinkommen liegt, durch die Summe der Bedarfsgewichte aller Haushaltsmitglieder
* teilt. Das Äquivalenzeinkommen liegt zwischen den so ermittelten Grenzen. 
* Gewichtung nach Haushaltsgröße: 1 für erstes Mitglied, 0,5 für jedes weitere Mitglied über 14, 0,3 für jedes Kind unter 14 


* Gewichte ermitteln, anhand f13 und f14
gen gewicht_hne= 1 if f13==1 // f14 umcodiert auf Missing für Personen im Ein Personen Haushalt

* Cut Off bei 20 Personen pro Haushalt in 2018
* Weitere Personen über 14 +0.5 (-1 da man den Befragten noch abziehen muss)
gen help_adultshh_1=(f13-f14)-1

******* Annahme: ***********************
* wenn -1, sich selber vergessen, daher 0 Erwachsene
list alter f13 f14 help_adultshh if help_adultshh_1<0
replace help_adultshh_1=0 if help_adultshh_1==-1

* Only Adults if f14==.
replace help_adultshh_1=0 if f13==1
* Weitere Personen unter 14 +0.3
* f14 Anzahl Kinder unter 18
gen help_child18hh=f14
* Anzahl unter 14-Jährige, assuming every other child except the first 5 is over 14
* Kind 1
gen help_childage1_14=1 if f14_2_1<14
* Kind 2
gen help_childage2_14=1 if f14_2_2<14
* Kind 3
gen help_childage3_14=1 if f14_2_3<14
* Kind 4
gen help_childage4_14=1 if f14_2_4<14
* Kind 5
gen help_childage5_14=1 if f14_2_5<14

* Generate children under 14
* Missings werden bei rowtotal() zu Null
egen help_child14hh=rowtotal(help_childage1_14 help_childage2_14 help_childage3_14 help_childage4_14 help_childage5_14)

* Generate children over 14
* If age not clear then conservatively over 14
gen help_child1418hh=help_child18hh-help_child14hh

* In bereits erstellter Variable wurden alle Kinder als unter 14 gezählt,
* daher jetzt die Kinder zwischen 14 und 18 wieder addieren
gen help_adultshh=help_adultshh_1+help_child1418hh if help_child1418hh<. // 1248 changes

tab help_adultshh help_adultshh_1, m
tab help_adultshh help_child14hh, m

* Alle mehr als Ein-Personenhaushalte mit gewichteter Haushaltsgröße erhöhen (1+ da Befragter vorher abgezogen)
replace gewicht_hne=1+0.5*help_adultshh+0.3*help_child14hh if gewicht_hne!=1
sum gewicht_hne

* Jeweils die Grenzen gewichten für Äquivalenzklassen
fre hne

* Gewichteten Mittelwert aus EVS2018 nach Haushaltsgröße (gewicht_hne) nehmen 
* Für Werte siehe G:\50-Projekte\483-Bund ESA\_Publ\2024_Alc share of total consumption\Analysis\EVS_2018
* Check Haushaltsgröße pro Einkommensklasse
tab gewicht_hne hne, m

* Gewichteter Mittelwert - wenn n in Zelle >5 
gen hne_mean=.
replace hne_mean=248 if hne==1  // unter 500, Es gibt nur 4 Personen in einem Hasuhalt größer 1, daher keine Differenzierung
replace hne_mean=654/gewicht_hne if hne==2 // 500- unter 750, Es gibt nur 4 Personen in einem Hasuhalt größer 1, daher keine Differenzierung
replace hne_mean=870/gewicht_hne if hne==3 & gewicht_hne==1 // 750- unter 1000 & 1 Personen Haushalt
replace hne_mean=879/gewicht_hne if hne==3 & gewicht_hne>1 & gewicht_hne<. // 750- unter 1000 & mehr als 1 Personen Haushalt
replace hne_mean=1122/gewicht_hne if hne==4 & gewicht_hne==1 // 1000- unter 1250 & 1 Personen Haushalt
replace hne_mean=1167/gewicht_hne if hne==4 & gewicht_hne>1 // 1000- unter 1250 & mehr als 1 Personen Haushalt
replace hne_mean=1375/gewicht_hne if hne==5 & gewicht_hne==1 // 1250- unter 1500 & 1 Personen Haushalt
replace hne_mean=1379/gewicht_hne if hne==5 & gewicht_hne>1 & gewicht_hne<=1.5 // 1250- unter 1500 & 1-2 Personen Haushalt
replace hne_mean=1365/gewicht_hne if hne==5 & gewicht_hne>1.5 & gewicht_hne<. // 1250- unter 1500 & >2 Personen Haushalt
replace hne_mean=1624/gewicht_hne if hne==6 & gewicht_hne==1 // 1500- unter 1750
replace hne_mean=1623/gewicht_hne if hne==6 & gewicht_hne>1 & gewicht_hne<=1.5 // 1500- unter 1750 & 1-2 Personen Haushalt
replace hne_mean=1619/gewicht_hne if hne==6 & gewicht_hne>1.5 & gewicht_hne<. // 1500- unter 1750 & >2 Personen Haushalt
replace hne_mean=1872/gewicht_hne if hne==7 & gewicht_hne==1 // 1750- unter 2000
replace hne_mean=1866/gewicht_hne if hne==7 & gewicht_hne>1 & gewicht_hne<=1.5 // 1750- unter 2000
replace hne_mean=1860/gewicht_hne if hne==7 & gewicht_hne>1.5 & gewicht_hne<=2 // 1750- unter 2000
replace hne_mean=1946/gewicht_hne if hne==7 & gewicht_hne>2 & gewicht_hne<. // 1750- unter 2000
replace hne_mean=2123/gewicht_hne if hne==8 & gewicht_hne==1 // 2000- unter 2250
replace hne_mean=2122/gewicht_hne if hne==8 & gewicht_hne>1 & gewicht_hne<=1.5  // 2000- unter 2250
replace hne_mean=2131/gewicht_hne if hne==8 & gewicht_hne>1.5 & gewicht_hne<=2  // 2000- unter 2250
replace hne_mean=2132/gewicht_hne if hne==8 & gewicht_hne>2 & gewicht_hne<. // 2000- unter 2250
replace hne_mean=2367/gewicht_hne if hne==9 & gewicht_hne==1 // 2250- unter 2500
replace hne_mean=2380/gewicht_hne if hne==9 & gewicht_hne>1 & gewicht_hne<=1.5 // 2250- unter 2500
replace hne_mean=2363/gewicht_hne if hne==9 & gewicht_hne>1.5 & gewicht_hne<=2 // 2250- unter 2500
replace hne_mean=2379/gewicht_hne if hne==9 & gewicht_hne>2 & gewicht_hne<. // 2250- unter 2500
replace hne_mean=2733/gewicht_hne if hne==10 & gewicht_hne==1 // 2500- unter 3000
replace hne_mean=2772/gewicht_hne if hne==10 & gewicht_hne>1 & gewicht_hne<=1.5  // 2500- unter 3000
replace hne_mean=2759/gewicht_hne if hne==10 & gewicht_hne>1.5 & gewicht_hne<=2 // 2500- unter 3000
replace hne_mean=2765/gewicht_hne if hne==10 & gewicht_hne>2 & gewicht_hne<. // 2500- unter 3000
replace hne_mean=3435/gewicht_hne if hne==11 & gewicht_hne==1 // 3000- unter 4000
replace hne_mean=3497/gewicht_hne if hne==11 & gewicht_hne>1 & gewicht_hne<=1.5  // 3000- unter 4000
replace hne_mean=3506/gewicht_hne if hne==11 & gewicht_hne>1.5 & gewicht_hne<=2 // 3000- unter 4000
replace hne_mean=3546/gewicht_hne if hne==11 & gewicht_hne>2 & gewicht_hne<. // 3000- unter 4000
replace hne_mean=4422/gewicht_hne if hne==12 & gewicht_hne==1 // 4000- unter 5000
replace hne_mean=4475/gewicht_hne if hne==12 & gewicht_hne>1 & gewicht_hne<=1.5  // 4000- unter 5000
replace hne_mean=4505/gewicht_hne if hne==12 & gewicht_hne>1.5 & gewicht_hne<=2 // 4000- unter 5000
replace hne_mean=4505/gewicht_hne if hne==12 & gewicht_hne>2 & gewicht_hne<. // 4000- unter 5000
replace hne_mean=7305/gewicht_hne if hne==13 & gewicht_hne==1 // über 5000
replace hne_mean=7355/gewicht_hne if hne==13 & gewicht_hne>1 & gewicht_hne<=1.5  // über 5000
replace hne_mean=7548/gewicht_hne if hne==13 & gewicht_hne>1.5 & gewicht_hne<=2 // über 5000
replace hne_mean=7586/gewicht_hne if hne==13 & gewicht_hne>2 & gewicht_hne<. // über 5000

* Ausbessern wenn Missing für hne_mean anhand s10_1
* s10_1 - nicht vergleichbare Kategorien
* Weniger als 1500 
replace hne_mean=861/gewicht_hne if s10_1==1 & gewicht_hne==1 & hne_mean==.
replace hne_mean=860/gewicht_hne if s10_1==1 & gewicht_hne>1 & gewicht_hne<=1.5 & hne_mean==.
replace hne_mean=1264/gewicht_hne if s10_1==1 & gewicht_hne>1.5 & gewicht_hne<. & hne_mean==.
* 1500-3000 
replace hne_mean=2144/gewicht_hne if s10_1==2 & gewicht_hne==1 & hne_mean==.
replace hne_mean=2153/gewicht_hne if s10_1==2 & gewicht_hne>1 & gewicht_hne<=1.5 & hne_mean==.
replace hne_mean=2152/gewicht_hne if s10_1==2 & gewicht_hne>1.5 & gewicht_hne<2.0 & hne_mean==.
replace hne_mean=2163/gewicht_hne if s10_1==2 & gewicht_hne>2.0 & gewicht_hne<. & hne_mean==.
* >3000 
replace hne_mean=5054/gewicht_hne if s10_1==3 & gewicht_hne==1 & hne_mean==.  
replace hne_mean=5109/gewicht_hne if s10_1==3 & gewicht_hne>1 & gewicht_hne<=1.5 & hne_mean==.
replace hne_mean=5186/gewicht_hne if s10_1==3 & gewicht_hne>1.5 & gewicht_hne<2.0 & hne_mean==.
replace hne_mean=5212/gewicht_hne if s10_1==3 & gewicht_hne>2.0 & gewicht_hne<. & hne_mean==.

label var hne_mean "Netto-Äquivalenzeinkommen (Mean EVS 2018)"

egen hne_eq3_18=xtile(hne_mean), n(3) 
label values hne_eq3_18 einkommensgruppen

tab hne_eq3_18 hne3_18, m
list hne hne_eq f13 f14 if hne3_18==3 & hne_eq3_18==1 // Haushaltsgröße auf unter 20 beschränkt
tab hne hne_eq3_18, m  
bysort hne_eq3_18: sum hne_mean // Grenzen Äquivalenzeinkommen: 1 bis 1380€ 2 bis 2253€ 3 ab 2266€
tab hne hne3_18, m // Grenzen Hauhshaltseinkommen: 1 bis 2000€ 2 bis unter 4000€ 3 ab 4000€

***** EXTERNE Threasholds anhand EU-SILC
* 2018 1. Quartil 1355 2. Quartil 1893 3 Quartil 2572 4. Quartil >2572
* /max bis höchsten Wert (exkl. Missings!)
recode hne_mean (0/1355 = 1 "Niedriges Einkommen (1. Quartil)") ///
(1355/2572 = 2 "Mittleres Einkommen (2. + 3. Quartil)") ///
(2572/max = 3 "Hohes Einkommen (4. Quartil)"), gen(hne_eq4_18)

tab hne hne_eq4_18, m
tab hne_eq4_18 hne3_18, m
tab hne_eq4_18 hne_eq3_18, m

***** EXTERNE Threasholds anhand EU-SILC
* 2018 1.-3. Dezil 1462 4.-7. Dezil 2406 8. - 10. Dezil >2406
* /max bis höchsten Wert (exkl. Missings!)
recode hne_mean (0/1462 = 1 "Niedriges Einkommen (1.-3. Dezil)") ///
(1462/2406 = 2 "Mittleres Einkommen (4.-7. Dezil)") ///
(2406/max = 3 "Hohes Einkommen (8.-10. Dezil)"), gen(hne_eq10_18)

tab hne hne_eq10_18, m
tab hne_eq10_18 hne3_18, m
tab hne_eq10_18 hne_eq3_18, m

*******************************************************************************
* Gruppen für Auswertung (18 Gruppen)

fre ges2 hne_eq3_18 hne_eq4_18 hne_eq10_18 altgr3

egen group1_18 = group(ges2 hne_eq4_18 altgr3)
egen group2_18 = group(ges2 hne_eq3_18 altgr3)
egen group3_18 = group(ges2 hne_eq10_18 altgr3)

* Beschriftungen für jede Gruppe
label define group_labels 1 "Frau, Niedriges Einkommen, 18-34 Jahre" ///
2 "Frau, Niedriges Einkommen, 35-59 Jahre" ///
3 "Frau, Niedriges Einkommen, über 60 Jahre" ///
4 "Frau, Mittleres Einkommen, 18-34 Jahre" ///
5 "Frau, Mittleres Einkommen, 35-59 Jahre" ///
6 "Frau, Mittleres Einkommen, über 60 Jahre" ///
7 "Frau, Hohes Einkommen, 18-34 Jahre" ///
8 "Frau, Hohes Einkommen, 35-59 Jahre" ///
9 "Frau, Hohes Einkommen, über 60 Jahre" ///
10 "Männer, Niedriges Einkommen, 18-34 Jahre" ///
11 "Männer, Niedriges Einkommen, 35-59 Jahre" ///
12 "Männer, Niedriges Einkommen, über 60 Jahre" ///
13 "Männer, Mittleres Einkommen, 18-34 Jahre" ///
14 "Männer, Mittleres Einkommen, 35-59 Jahre" ///
15 "Männer, Mittleres Einkommen, über 60 Jahre" ///
16 "Männer, Hohes Einkommen, 18-34 Jahre" ///
17 "Männer, Hohes Einkommen, 35-59 Jahre" ///
18 "Männer, Hohes Einkommen, über 60 Jahre" 

* Beschriftung der Gruppenvariable
label values group1_18 group2_18 group3_18 group_labels

label var group1_18 "Gruppen: Einkommen nach hne_eq4_18"
label var group2_18 "Gruppen: Einkommen nach hne_eq3_18"
label var group3_18 "Gruppen: Einkommen nach hne_eq10_18"

* Anzeige der Gruppen mit Beschriftungen
tab group1_18 group2_18, m
tab group1_18 group3_18, m
fre group1_18 group2_18 group3_18

* Reduzieren auf nötigte Variablen
* drop dsm related variables
keep intj dg_bund rg_bundn stadt_bl int_art ges* alt* help* gewicht_hne hne* *gr trinkgruppe vx2* bier* wein* spir* mish* binge*

save "...\esa18_alc.dta", replace
