***********************************************************************************************
************************************************************************************************
** Eva Krowartz, Justin Möckl
** Collaborators: Olderbak, Rauschert
** Titel of project: Auswertung für Paper 
* Alc share of total consumption by consumption group and proportion of consumption by group and beverage type
** 29.01.2024: erstellt
** 20.06.2024: Mit neuen Datensatz laufen lassen
** 26.06.2024: Jetzt anstatt Quartile Dezile (grouo3 instead of group1)
** Dezile EU-SILC
************************************************************************************************
************************************************************************************************

set more off, perm 
set scrollbufsize 100000
set linesize 140
set scheme s1mono, permanently

*Set Directory
cd "G:\50-Projekte\483-Bund ESA\_Publ\2024_Alc share of total consumption\Analysis"


* Datensatz laden
use ".\esa1821_alc.dta", clear

* Check Bedarfsgewichte
graph box gewicht_hne, over(intj) yscale(range(1 (1) 10))
bysort intj: sum gewicht_hne


* ssc install estout, replace // Muss installiert sein für die Schleife
* Gewichtung da ab 2018 hier Querschnittgewichtung
svyset stadt_bl [pw=rg_bundn], strata(intj)

***** Gesamtstichprobe *************
* Variablen (Dummy)
local v "vx210_3 binge01_2"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/18 {	

******************** Nach Gruppe *****************
di "capture estpost svy, subpop(if group3==`a'): tab intj `var', obs percent row format(%9.1f) ci"
		capture estpost svy, subpop(if group3==`a'): tab intj `var', obs percent row format(%9.1f) ci
		
		* Prävalenz
		mat def p = e(row) 
		* untere KI
		mat def lo = e(lb)
		* obere KI
		mat def up = e(ub)
		* Stichprobengröße
		mat def n = e(obs)
		
		* Prävalenz nur für Ausprägung 1
		
		* Matrizen zusammenfügen
		mat def `var'_`a' = p[1,4..6] \ lo[1,4..6] \ up[1,4..6] \ n[1,4..6] \ n[1,7..9] 
		
		mat rownames `var'_`a' = "Prev" "KI_low" "KI_up" "n prev" "n total"
		
		* Save in Excel
		putexcel set "Alkohol_Gesamtbevölkerung", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		local z = (`a'-1)*12 + 1
		putexcel A`z' = "Bund `a': `: var label `var'' `: label (group3) `a''", bold
	
		local z = (`a'-1)*12 + 2
		putexcel A`z' = "estpost svy, subpop(if group3==`a'): tab intj `var', obs percent row format(%9.1f) ci"

		local z = (`a'-1)*12 + 3 
		putexcel A`z' = matrix(`var'_`a'), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		local z = (`a'-1)*12 + 9 
		putexcel B`z':Q`z', nformat(number)
		
		local z = (`a'-1)*12 + 10 
		putexcel B`z':Q`z', nformat(number)
		}
}


***** Gesamtstichprobe *************
* Variablen (metrisch)
local v "alk30gr"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/18 {	

******************** Nach Gruppe *****************
di "capture svy, subpop(if group3==`a'): mean `var', over(intj)"
		capture svy, subpop(if group3==`a'): mean `var', over(intj)
		
		* Speicher komplett r(table)
		mat def mean=r(table)
			* Prävalenz
		mat def p = mean[1,1...]
		* untere KI
		mat def lo = mean[5,1...]
		* obere KI
		mat def up = mean[6,1...]
		* Stichprobengröße
		mat def n = e(_N)
		
		* Für Total
		
		
        di "capture svy, subpop(if group3==`a'): mean `var'"
		capture svy, subpop(if group3==`a'): mean `var'
		
		* Speicher komplett r(table)
		mat def meanT=r(table)
			* Prävalenz
		mat def pT = meanT[1,1...]
		* untere KI
		mat def loT = meanT[5,1...]
		* obere KI
		mat def upT = meanT[6,1...]
		* Stichprobengröße
		mat def nT = e(_N)
		
		* Matrizen zusammenfügen
		mat def `var'_`a' = (p[1,1...], pT[1,1...]) \ ///
							(lo[1,1...], loT[1,1...]) \ ///
							(up[1,1...], upT[1,1...]) \ ///
							(n[1,1...], nT[1,1...]) 
							 
		mat rownames `var'_`a' = "Mean `a'" "KI_low `a'" "KI_up `a'" "n `a'" 
		mat colnames `var'_`a' = "2018" "2021" "Total"
		
		* Save in Excel
		putexcel set "Alkohol_Gesamtbevölkerung", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		local z = (`a'-1)*12 + 1
		putexcel A`z' = "Bund (letzte 12 Monate) `a': `: var label `var'' `: label (group3) `a''", bold
	
		local z = (`a'-1)*12 + 2
		putexcel A`z' = "capture svy, subpop(if group3==`a'): mean `var', over(intj)"

		local z = (`a'-1)*12 + 3 
		putexcel A`z' = matrix(`var'_`a'), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		local z = (`a'-1)*12 + 9 
		putexcel B`z':Q`z', nformat(number)
		
		local z = (`a'-1)*12 + 10 
		putexcel B`z':Q`z', nformat(number)
		}
}
	

***** Konsumenten *************
* Variablen (Dummy)
local v "binge01_2 riskarm risk gef"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/18 {	

******************** Nach Gruppe *****************
di "capture estpost svy, subpop(if group3==`a' & vx210_3==1): tab intj `var', obs percent row format(%9.1f) ci"
		capture estpost svy, subpop(if group3==`a' & vx210_3==1): tab intj `var', obs percent row format(%9.1f) ci
		
		* Prävalenz
		mat def p = e(row) 
		* untere KI
		mat def lo = e(lb)
		* obere KI
		mat def up = e(ub)
		* Stichprobengröße
		mat def n = e(obs)
		
		* Prävalenz nur für Ausprägung 1
		
		* Matrizen zusammenfügen
		mat def `var'_`a' = p[1,4..6] \ lo[1,4..6] \ up[1,4..6] \ n[1,4..6] \ n[1,7..9] 
		
		mat rownames `var'_`a' = "Prev" "KI_low" "KI_up" "n prev" "n total"
		
		* Save in Excel
		putexcel set "Alkohol_Konsumenten", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		local z = (`a'-1)*12 + 1
		putexcel A`z' = "Bund Konsumenten (letzte 12 Monate) `a': `: var label `var'' `: label (group3) `a''", bold
	
		local z = (`a'-1)*12 + 2
		putexcel A`z' = "estpost svy, subpop(if group3==`a' & vx210_3==1): tab intj `var', obs percent row format(%9.1f) ci"

		local z = (`a'-1)*12 + 3 
		putexcel A`z' = matrix(`var'_`a'), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		local z = (`a'-1)*12 + 9 
		putexcel B`z':Q`z', nformat(number)
		
		local z = (`a'-1)*12 + 10 
		putexcel B`z':Q`z', nformat(number)
		}
}

***** Konsumenten *************
* Variablen (metrisch)
local v "alk30gr"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/18 {	

******************** Nach Gruppe *****************
di "capture svy, subpop(if group3==`a' & vx210_3==1): mean `var', over(intj)"
		capture svy, subpop(if group3==`a' & vx210_3==1): mean `var', over(intj)
		
		* Speicher komplett r(table)
		mat def mean=r(table)
			* Prävalenz
		mat def p = mean[1,1...]
		* untere KI
		mat def lo = mean[5,1...]
		* obere KI
		mat def up = mean[6,1...]
		* Stichprobengröße
		mat def n = e(_N)
		
		* Für Total
		
		
        di "capture svy, subpop(if group3==`a' & vx210_3==1): mean `var'"
		capture svy, subpop(if group3==`a' & vx210_3==1): mean `var'
		
		* Speicher komplett r(table)
		mat def meanT=r(table)
			* Prävalenz
		mat def pT = meanT[1,1...]
		* untere KI
		mat def loT = meanT[5,1...]
		* obere KI
		mat def upT = meanT[6,1...]
		* Stichprobengröße
		mat def nT = e(_N)
		
		* Matrizen zusammenfügen
		mat def `var'_`a' = (p[1,1...], pT[1,1...]) \ ///
							(lo[1,1...], loT[1,1...]) \ ///
							(up[1,1...], upT[1,1...]) \ ///
							(n[1,1...], nT[1,1...]) 
							 
		mat rownames `var'_`a' = "Mean `a'" "KI_low `a'" "KI_up `a'" "n `a'" 
		mat colnames `var'_`a' = "2018" "2021" "Total"
		
		* Save in Excel
		putexcel set "Alkohol_Konsumenten", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		local z = (`a'-1)*12 + 1
		putexcel A`z' = "Bund Konsumenten (letzte 12 Monate) `a': `: var label `var'' `: label (group3) `a''", bold
	
		local z = (`a'-1)*12 + 2
		putexcel A`z' = "capture svy, subpop(if group3==`a' & vx210_3==1): mean `var', over(intj)"

		local z = (`a'-1)*12 + 3 
		putexcel A`z' = matrix(`var'_`a'), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		local z = (`a'-1)*12 + 9 
		putexcel B`z':Q`z', nformat(number)
		
		local z = (`a'-1)*12 + 10 
		putexcel B`z':Q`z', nformat(number)
		}
}
		

***** Trinkgruppen (Gewichtet mit Gewichtung (Redressment) *************
* Variablen (Anteile pro Gruppe)
local v "alk30gr_proprw_tg bier30gr_proprw_tg wein30gr_proprw_tg spir30gr_proprw_tg mish30gr_proprw_tg"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/54 {	

******************** Nach Gruppe *****************
di "sum `var' if tgroup3==`a' & vx210_3==1"
		sum `var' if tgroup3==`a' & vx210_3==1
		
		* Anteil der Gruppe
		mat def p`a' = r(mean)*100
		* Stichprobengröße
		mat def n`a' = r(N)
}		
		* Prävalenz nur für Ausprägung 1
		
		* Matrizen zusammenfügen
		mat def `var'_pr = (p1, n1 \ ///
							p2, n2 \ ///
						   p3, n3 \ ///
						   p4, n4 \ ///
						   p5, n5 \ ///
						   p6, n6 \ ///
						   p7, n7 \ ///
						   p8, n8 \ ///
						   p9, n9 \ ///
						   p10, n10 \ ///
						   p11, n11 \ ///
						   p12, n12 \ ///
						   p13, n13 \ ///
						   p14, n14 \ ///
						   p15, n15 \ ///
						   p16, n16\ ///
						   p17, n17\ ///
						   p18, n18\ ///
						   p19, n19\ ///
						   p20, n20\ ///
						   p21, n21\ ///
						   p22, n22\ ///
						   p23, n23\ ///
						   p24, n24\ ///
						   p25, n25\ ///
						   p26, n26\ ///
						   p27, n27\ ///
						   p28, n28\ ///
						   p29, n29\ ///
						   p30, n30\ ///
						   p31, n31\ ///
						   p32, n32\ ///
						   p33, n33\ ///
						   p34, n34\ ///
						   p35, n35\ ///
						   p36, n36\ ///
						   p37, n37\ ///
						   p38, n38\ ///
						   p39, n39\ ///
						   p40, n40\ ///
						   p41, n41\ ///
						   p42, n42\ ///
						   p43, n43\ ///
						   p44, n44\ ///
						   p45, n45\ ///
						   p46, n46\ ///
						   p47, n47\ ///
						   p48, n48\ ///
						   p49, n49\ ///
						   p50, n50\ ///
						   p51, n51\ ///
						   p52, n52\ ///
						   p53, n53\ ///
						   p54, n54)


		mat colnames `var'_pr = "Anteil" "Stichprobengröße"
		mat rownames `var'_pr = "1FN34Ra" "2FN34R" "3FN34G" ///
          "4FN59Ra" "5FN59R" "6FN59G" "7FN60Ra" "8FN60R" ///
          "9FN60G" "10FM34Ra" "11FM34R" "12FM34G" "13FM59Ra" ///
          "14FM59R" "15FM59G" "16FM60Ra" "17FM60R" "18FM60G" ///
          "19FH34Ra" "20FH34R" "21FH34G" "22FH59Ra" "23FH59R" ///
          "24FH59G" "25FH60Ra" "26FH60R" "27FH60G" "28MN34Ra" ///
          "29MN34R" "30MN34G" "31MN59Ra" "32MN59R" "33MN59G" ///
          "34MN60Ra""35MN60R" "36MN60G" "37MM34Ra" "38MM34R" ///
          "39MM34G" "40MM59Ra" "41MM59R" "42MM59G" "43MM60Ra" ///
          "44MM60R" "45MM60G" "46MH34Ra" "47MH34R" "48MH34G" ///
          "49MH59Ra" "50MH59R" "51MH59G" "52MH60Ra" "53MH60R" ///
          "54MH60G" 

		
		* Save in Excel
		putexcel set "Alkohol_Trinkgruppen", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		putexcel A1 = "Bund Konsumenten (letzte 12 Monate) Anteil Trinkgruppen an Gesamtkonsum: `: var label `var''", bold
	
		putexcel A2 = "sum `var' if tgroup3==`a' & vx210_3==1"
 
		putexcel A3 = matrix(`var'_pr), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		putexcel C4:C57, nformat(number)
		}

***** Trinkgruppen (Gewichtet mit Gewichtung (Redressment) *************
* Variablen (Summe der Alkoholika)
local v "alk30gr_rw_tg bier30gr_rw_tg wein30gr_rw_tg spir30gr_rw_tg mish30gr_rw_tg"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/54 {	

******************** Nach Gruppe *****************
di "sum `var' if tgroup3==`a' & vx210_3==1"
		sum `var' if tgroup3==`a' & vx210_3==1
		
		* Anteil der Gruppe
		mat def p`a' = r(mean)
		* Stichprobengröße
		mat def n`a' = r(N)
}		
		* Prävalenz nur für Ausprägung 1
		
		* Matrizen zusammenfügen
		mat def `var'_pr = (p1, n1 \ ///
							p2, n2 \ ///
						   p3, n3 \ ///
						   p4, n4 \ ///
						   p5, n5 \ ///
						   p6, n6 \ ///
						   p7, n7 \ ///
						   p8, n8 \ ///
						   p9, n9 \ ///
						   p10, n10 \ ///
						   p11, n11 \ ///
						   p12, n12 \ ///
						   p13, n13 \ ///
						   p14, n14 \ ///
						   p15, n15 \ ///
						   p16, n16\ ///
						   p17, n17\ ///
						   p18, n18\ ///
						   p19, n19\ ///
						   p20, n20\ ///
						   p21, n21\ ///
						   p22, n22\ ///
						   p23, n23\ ///
						   p24, n24\ ///
						   p25, n25\ ///
						   p26, n26\ ///
						   p27, n27\ ///
						   p28, n28\ ///
						   p29, n29\ ///
						   p30, n30\ ///
						   p31, n31\ ///
						   p32, n32\ ///
						   p33, n33\ ///
						   p34, n34\ ///
						   p35, n35\ ///
						   p36, n36\ ///
						   p37, n37\ ///
						   p38, n38\ ///
						   p39, n39\ ///
						   p40, n40\ ///
						   p41, n41\ ///
						   p42, n42\ ///
						   p43, n43\ ///
						   p44, n44\ ///
						   p45, n45\ ///
						   p46, n46\ ///
						   p47, n47\ ///
						   p48, n48\ ///
						   p49, n49\ ///
						   p50, n50\ ///
						   p51, n51\ ///
						   p52, n52\ ///
						   p53, n53\ ///
						   p54, n54)


		mat colnames `var'_pr = "Anteil" "Stichprobengröße"
		mat rownames `var'_pr = "1FN34Ra" "2FN34R" "3FN34G" ///
          "4FN59Ra" "5FN59R" "6FN59G" "7FN60Ra" "8FN60R" ///
          "9FN60G" "10FM34Ra" "11FM34R" "12FM34G" "13FM59Ra" ///
          "14FM59R" "15FM59G" "16FM60Ra" "17FM60R" "18FM60G" ///
          "19FH34Ra" "20FH34R" "21FH34G" "22FH59Ra" "23FH59R" ///
          "24FH59G" "25FH60Ra" "26FH60R" "27FH60G" "28MN34Ra" ///
          "29MN34R" "30MN34G" "31MN59Ra" "32MN59R" "33MN59G" ///
          "34MN60Ra""35MN60R" "36MN60G" "37MM34Ra" "38MM34R" ///
          "39MM34G" "40MM59Ra" "41MM59R" "42MM59G" "43MM60Ra" ///
          "44MM60R" "45MM60G" "46MH34Ra" "47MH34R" "48MH34G" ///
          "49MH59Ra" "50MH59R" "51MH59G" "52MH60Ra" "53MH60R" ///
          "54MH60G" 

		
		* Save in Excel
		putexcel set "Alkohol_Trinkgruppen", sheet(`var') modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		putexcel A1 = "Bund Konsumenten (letzte 12 Monate) Anteil Trinkgruppen an Gesamtkonsum: `: var label `var''", bold
	
		putexcel A2 = "sum `var' if tgroup3==`a' & vx210_3==1"
 
		putexcel A3 = matrix(`var'_pr), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		putexcel C4:C57, nformat(number)
		}

		
**** Redresssementgewichtung (siehe oben)
* Variablen (Dummy)
local v "binge01_2"
local vcount : word count `v'

forvalues n = 1/`vcount' {

		local var: word `n' of `v'
		
	* Schleife pro Gruppe
forvalues a= 1/54 {	

******************** Nach Gruppe *****************
di "capture estpost svy, subpop(if tgroup3==`a' & vx210_3==1 & alk_cc==1): tab intj `var', obs percent row format(%9.1f) ci"
		capture estpost svy, subpop(if tgroup3==`a' & vx210_3==1 & alk_cc==1): tab intj `var', obs percent row format(%9.1f) ci
		
		* Prävalenz
		mat def p = e(row) 
		* untere KI
		mat def lo = e(lb)
		* obere KI
		mat def up = e(ub)
		* Stichprobengröße
		mat def n = e(obs)
		
		* Prävalenz nur für Ausprägung 1
		
		* Matrizen zusammenfügen
		mat def `var'_`a' = p[1,4..6] \ lo[1,4..6] \ up[1,4..6] \ n[1,4..6] \ n[1,7..9] 
		
		mat rownames `var'_`a' = "Prev" "KI_low" "KI_up" "n prev" "n total"
		
		* Save in Excel
		putexcel set "Alkohol_Trinkgruppen", sheet(`var'_rg) modify
		
		* Freie Zelle auswählen, Label als Titel (see https://www.statalist.org/forums/forum/general-stata-discussion/general/706869-show-label-value)
		local z = (`a'-1)*12 + 1
		putexcel A`z' = "Bund Konsumenten (letzte 12 Monate) `a': `: var label `var'' `: label (tgroup3) `a''", bold
	
		local z = (`a'-1)*12 + 2
		putexcel A`z' = "estpost svy, subpop(if tgroup3==`a' & vx210_3==1 & alk_cc==1): tab intj `var', obs percent row format(%9.1f) ci"

		local z = (`a'-1)*12 + 3 
		putexcel A`z' = matrix(`var'_`a'), names nformat("0.0")
		
		* ns als Zahlen formatieren, ohne Dezimalstelle
		local z = (`a'-1)*12 + 9 
		putexcel B`z':Q`z', nformat(number)
		
		local z = (`a'-1)*12 + 10 
		putexcel B`z':Q`z', nformat(number)
				
		* p-Wert als Zahlen formatieren, mit drei Dezimalstellen
		local z = (`a'-1)*12 + 11
		putexcel B`z':Q`z', nformat("0.000")
		}
}
		
