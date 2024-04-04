## To-Do:
# - Hochrechnungsfaktoren brauchen wir nicht?
# - Alkoholische Getränke (Käufe im Ausland) abziehen? wenn ja, wie? nicht spezifisch für Getränketype
# - Wie umgehen mit Haushalten mit Durchschnittsalter > 64? derzeit werden diese nicht berücksichtigt (25%)
# - Wie umgehen mit Geschlecht bei Haushalten mit mehreren Personen?


### =====================================================================================================================================
### Berechnung der durchschnittlichen Ausgaben für eine Alkoholeinheit nach Getränketyp, Einkommensgruppe, Altersgruppe und Trinkgruppe
### =====================================================================================================================================

# ==================================================================================================================================================================
# 0) ESSENTIALS
# ______________________________________________________________________________________________________________________
# clean workspace
rm(list=ls())

packages <- c("tidyverse", "readxl") 

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Load packages
invisible(lapply(packages, library, character.only = TRUE))

# ==================================================================================================================================================================
## 1) LOAD DATA
# ______________________________________________________________________________________________________________________
#EVS
evs_path <- file.path("EVS/Data", "evs_ngt2018_slr.csv")
evs_raw <- read.csv(evs_path, header = TRUE, sep = ";", dec = ",", stringsAsFactors = FALSE)
#ESA
esa_path <- file.path("ESA", "ESA_Alc_Share_240221.xlsx")
esa_trinkgruppen_raw <- readxl::read_excel(esa_path, sheet = "Trinkgruppen")
esa_socgruppen_raw <- readxl::read_excel(esa_path, sheet = "Soziodemographische Gruppen")

# ==================================================================================================================================================================
## 2) DATA PREPARATION
# ______________________________________________________________________________________________________________________

# 2.1) ESA

#hier aufbereiten: Risikoarm, Riskant, Hoch (Socgruppen)

esa_perctrinkgruppen <- esa_socgruppen_raw %>%
  select("Geschlecht", "Alter", "Einkommen", "Risikoarm", "Riskant", "Hoch")

# =======================================================================================================================
# 2.2) EVS

# =======================================================================================================================
# Filtern und Umbenennen der relevanten Variablen
evs <- evs_raw %>%
  rename(ID = "EF3", #HaushaltsID
         N_Haushaltsmitglieder = "EF7", #Anzahl Personen im Haushalt, Wie Personen <18 Jahren identifizieren und exkludieren?
         Stellung_pers1 = "EF8u1", #Stellung im Haushalt Person 1 = Haupteinkommensbezieher
         sex_pers1 = "EF8u2", #Geschlecht Person 1
         yob_pers1 = "EF8u3", #Alter Person 1
         Stellung_pers2 = "EF9u1", #Stellung im Haushalt Person 2
         sex_pers2 = "EF9u2", #Geschlecht Person 2
         yob_pers2 = "EF9u3", #Alter Person 2
         Stellung_pers3 = "EF10u1", #Stellung im Haushalt Person 3
         sex_pers3 = "EF10u2", #Geschlecht Person 3
         yob_pers3 = "EF10u3", #Alter Person 3
         Stellung_pers4 = "EF11u1",
         sex_pers4 = "EF11u2",
         yob_pers4 = "EF11u3",
         Stellung_pers5 = "EF12u1",
         sex_pers5 = "EF12u2",
         yob_pers5 = "EF12u3",
         Stellung_pers6 = "EF13u1",
         sex_pers6 = "EF13u2",
         yob_pers6 = "EF13u3",
         Stellung_pers7 = "EF14u1",
         sex_pers7 = "EF14u2",
         yob_pers7 = "EF14u3",
         Stellung_pers8 = "EF15u1",
         sex_pers8 = "EF15u2",
         yob_pers8 = "EF15u3",
         n_kinder_u1 = "EF22", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt unter 1 Jahr
         n_kinder_1_3 = "EF23", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 1 bis unter 3
         n_kinder_3_6 = "EF24", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 3 bis unter 6
         n_kinder_6_12 = "EF25", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 6 bis unter 12
         n_kinder_12_18 = "EF26", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 12 bis unter 18
         haushaltsnettoeinkommen_quartal = "EF30", #Haushaltsnettoeinkommen aus der Quartalsrechnung ( + / - Vorzeichen)
         bier_untergärig_wert = "EF284u2", #ausgegebener Betrag für untergäriges Bier
         bier_untergärig_menge = "EF284u1", #Menge des gekauften untergärigen Biers
         bier_anderes_wert = "EF285u2", #ausgegebener Betrag für anderes Bier (altbier, kölsch, weizen, ...)
         bier_anderes_menge = "EF285u1", #Menge des gekauften anderen Biers
         bier_misch_wert = "EF287u2", #ausgegebener Betrag für Biermischgetränke, z.B. mit Cola
         bier_misch_menge = "EF287u1", #Menge des gekauften Biermischgetränks
         bier_ohneBez_wert = "EF288u2", #ausgegebener Betrag für Bier ohne nähere Bezeichnung
         bier_ohneBez_menge = "EF288u1", #Menge des gekauften Biers ohne nähere Bezeichnung
         mischgetraenke_wert = "EF272u2", #ausgegebener Betrag für Erfrischungsmixgetränke mit Alkoholgehalt unter 6%, z. B. Alkopops
         mischgetraenke_menge = "EF272u1", #Menge des gekauften Erfrischungsmixgetränks
         wein_rot_wert = "EF273u2", #ausgegebener Betrag für Rotwein
         wein_rot_menge = "EF273u1", #Menge des gekauften Rotweins
         wein_weiss_wert = "EF274u2", #ausgegebener Betrag für Weißwein
         wein_weiss_menge = "EF274u1", #Menge des gekauften Weißweins
         wein_rose_wert = "EF275u2", #ausgegebener Betrag für Roséwein
         wein_rose_menge = "EF275u1", #Menge des gekauften Roséweins
         wein_schaum_wert = "EF276u2", #ausgegebener Betrag für Schaumwein
         wein_schaum_menge = "EF276u1", #Menge des gekauften Schaumweins
         wein_apfel_wert = "EF277u2", #ausgegebener Betrag für Apfelwein
         wein_apfel_menge = "EF277u1", #Menge des gekauften Apfelweins
         wein_frucht_wert = "EF278u2", #ausgegebener Betrag für Fruchtwein
         wein_frucht_menge = "EF278u1", #Menge des gekauften Fruchtweins
         wein_wermut_wert = "EF279u2", #ausgegebener Betrag für Wermut
         wein_wermut_menge = "EF279u1", #Menge des gekauften Wermuts
         wein_sherry_wert = "EF280u2", #ausgegebener Betrag für Sherry
         wein_sherry_menge = "EF280u1", #Menge des gekauften Sherrys
         wein_portwein_wert = "EF281u2", #ausgegebener Betrag für Portwein
         wein_portwein_menge = "EF281u1", #Menge des gekauften Portweins
         wein_anderes_wert = "EF282u2", #ausgegebener Betrag für andere weinhaltige Getränke
         wein_anderes_menge = "EF282u1", #Menge der gekauften anderen weinhaltigen Getränke
         wein_ohneBez_wert = "EF283u2", #ausgegebener Betrag für Wein ohne nähere Bezeichnung
         wein_ohneBez_menge = "EF283u1", #Menge des gekauften Weins ohne nähere Bezeichnung
         sprit_likör_wert = "EF268u2", #ausgegebener Betrag für Likör
         sprit_likör_menge = "EF268u1", #Menge des gekauften Likörs
         sprit_whisky_wert = "EF269u2", #ausgegebener Betrag für Whisky
         sprit_whisky_menge = "EF269u1", #Menge des gekauften Whiskys
         sprit_branntwein_wert = "EF270u2", #ausgegebener Betrag für Branntwein
         sprit_branntwein_menge = "EF270u1", #Menge des gekauften Branntweins
         sprit_anderes_wert = "EF271u2", #ausgegebener Betrag für andere Spirituosen  (z.B. Rum, Wodka, Korn, ...) mehr als 6% Alkohol
         sprit_anderes_menge = "EF271u1") %>% #Menge der gekauften anderen Spirituosen 
  select(ID, N_Haushaltsmitglieder, Stellung_pers1, sex_pers1, yob_pers1, Stellung_pers2, yob_pers2, sex_pers2, Stellung_pers3, yob_pers3, sex_pers3, Stellung_pers4,
         yob_pers4, sex_pers4, Stellung_pers5, yob_pers5, sex_pers5, Stellung_pers6, yob_pers6, sex_pers6, Stellung_pers7, yob_pers7, sex_pers7, Stellung_pers8, yob_pers8, sex_pers8, n_kinder_u1, n_kinder_1_3,
         n_kinder_3_6, n_kinder_6_12, n_kinder_12_18, haushaltsnettoeinkommen_quartal, bier_untergärig_wert, bier_untergärig_menge, bier_anderes_wert,
         bier_anderes_menge, bier_misch_wert, bier_misch_menge, bier_ohneBez_wert, bier_ohneBez_menge, mischgetraenke_wert, mischgetraenke_menge,
         wein_rot_wert, wein_rot_menge, wein_weiss_wert, wein_weiss_menge, wein_rose_wert, wein_rose_menge, wein_schaum_wert, wein_schaum_menge,
         wein_apfel_wert, wein_apfel_menge, wein_frucht_wert, wein_frucht_menge, wein_wermut_wert, wein_wermut_menge, wein_sherry_wert,
         wein_sherry_menge, wein_portwein_wert, wein_portwein_menge, wein_anderes_wert, wein_anderes_menge, wein_ohneBez_wert, wein_ohneBez_menge,
         sprit_likör_wert, sprit_likör_menge, sprit_whisky_wert, sprit_whisky_menge, sprit_branntwein_wert, sprit_branntwein_menge, sprit_anderes_wert,
         sprit_anderes_menge)
 
# all wein, bier, sprit columns characters. convert to numeric
evs[, grep("wein|bier|sprit", names(evs))] <- sapply(evs[, grep("wein|bier|sprit", names(evs))], as.numeric)

# =======================================================================================================================         

# number of adults in the household
evs$N_Haushaltsmitglieder_adult <- evs$N_Haushaltsmitglieder - evs$n_kinder_u1 - evs$n_kinder_1_3 - evs$n_kinder_3_6 - evs$n_kinder_6_12 - evs$n_kinder_12_18

# =======================================================================================================================
## Äquivalenzeinkommen
# Bedarfsgewichtungsfaktor pro Haushalt berechnen
# nach neue OECD-Skala: ersten erwachsenen Person im Haushalt: Bedarfsgewicht 1 zugeordnet,
# für weiteren Haushaltsmitglieder: 0,5 für weitere Personen im Alter von 14 und mehr Jahren
# und 0,3 für jedes Kind im Alter von unter 14 Jahren)

berechne_gewichtungsfaktor <- function(row) {
  gewichtung <- 1 # Faktor für Hauptverdiener (pers1)
  
  # iterate over other household members (pers2-pers8)
  for (i in 2:8) {
    pers <- paste0('yob_pers', i)
#    print(pers)
    yob <- row[[pers]]
#    print(yob)
    if (is.na(yob)) {
      gewichtung <- gewichtung + 0 # Wenn Geburtsjahr fehlt, addiere 0 zur Gewichtung
    } else {
      if (yob <= 2004) {
        gewichtung <- gewichtung + 0.5 # Für Personen <= 2004
      } else {
        gewichtung <- gewichtung + 0.3 # Für Personen > 2004
      }
    }
  }
  
  return(gewichtung)
}

evs$gewichtungsfaktor <- apply(evs, 1, berechne_gewichtungsfaktor)


# check: show gewichtungsfaktor for rows with N_Haushaltsmitglieder = 2 -> looks good
evs[evs$N_Haushaltsmitglieder == 2, c("N_Haushaltsmitglieder", "gewichtungsfaktor", "yob_pers1", "yob_pers2")]

#calculate equivalized household income
evs$haushaltsnettoeinkommen_month <- evs$haushaltsnettoeinkommen_quartal/3
evs$netequincome <- evs$haushaltsnettoeinkommen_month / evs$gewichtungsfaktor

summary(evs$haushaltsnettoeinkommen_month) #median 3496.7
summary(evs$netequincome) #median 2354
#laut statistischem bundesamt liegt das mediane äquivalenzeinkommen bei 22713/12 = 1892 euro, dh niedriger als hier
#evtl. weil hochrechnugnsfaktoren nciht berücksichtigt?

# =======================================================================================================================
#summarize bier, wein, sprit
evs$Bier_Wert <- evs$bier_untergärig_wert + evs$bier_anderes_wert + evs$bier_misch_wert + evs$bier_ohneBez_wert
evs$Bier_Menge <- evs$bier_untergärig_menge + evs$bier_anderes_menge + evs$bier_misch_menge + evs$bier_ohneBez_menge
evs$Wein_Wert <- evs$wein_rot_wert + evs$wein_weiss_wert + evs$wein_rose_wert + evs$wein_schaum_wert + evs$wein_apfel_wert + evs$wein_frucht_wert + evs$wein_wermut_wert + evs$wein_sherry_wert + evs$wein_portwein_wert + evs$wein_anderes_wert + evs$wein_ohneBez_wert
evs$Wein_Menge <- evs$wein_rot_menge + evs$wein_weiss_menge + evs$wein_rose_menge + evs$wein_schaum_menge + evs$wein_apfel_menge + evs$wein_frucht_menge + evs$wein_wermut_menge + evs$wein_sherry_menge + evs$wein_portwein_menge + evs$wein_anderes_menge + evs$wein_ohneBez_menge
evs$Sprit_Wert <- evs$sprit_likör_wert + evs$sprit_whisky_wert + evs$sprit_branntwein_wert + evs$sprit_anderes_wert
evs$Sprit_Menge <- evs$sprit_likör_menge + evs$sprit_whisky_menge + evs$sprit_branntwein_menge + evs$sprit_anderes_menge
# =======================================================================================================================


# ==================================================================================================================================================================
## 3) Berechnungen
# ______________________________________________________________________________________________________________________

## gekaufte Mengen und Ausgaben (Wert) nach Anzahl der Haushaltsmitglieder gewichten
zu_gewichtende_spalten <- c("Bier_Wert", "Wein_Wert", "Sprit_Wert", "Bier_Menge", "Wein_Menge", "Sprit_Menge")
# Teilt ausgewählte Spalten durch Anzahl der erwachsenen Haushaltsmitglieder und speichert Ergebnisse in neuen Spalten (w=weighted)
evs <- evs %>%
  mutate(across(all_of(zu_gewichtende_spalten), list(~ . / N_Haushaltsmitglieder_adult), .names = "{.col}_w"))


## gekaufte Mengen in l in Standarddrinks (stdd=standarddrinks) umrechnen (0,33l Bier, 0,125l Wein, 0,04l Spirituosen), um Getränketypen bzgl. Alkoholgehalt vergleichbar zu machen
evs$bier_menge_stdd_w = evs$Bier_Menge_w / 0.33
evs$wein_menge_stdd_w = evs$Wein_Menge_w / 0.125
evs$sprit_menge_stdd_w = evs$Sprit_Menge_w / 0.04


## Ausgaben (Wert) pro Standarddrink (jeweils nach Getränketyp) berechnen, indem Ausgaben durch die Menge in Standarddrinks geteilt werden
# um auszuschließen, dass durch 0 geteilt wird (inf), wird gecheckt, ob Divisor == 0, falls ja, wird Ergebnis direkt auf 0 gesetzt
evs$Bier_Wert_pro_stdd_w <- with(evs, ifelse(bier_menge_stdd_w != 0, Bier_Wert_w / bier_menge_stdd_w, 0))
evs$Wein_Wert_pro_stdd_w <- with(evs, ifelse(wein_menge_stdd_w != 0, Wein_Wert_w / wein_menge_stdd_w, 0))
evs$Sprit_Wert_pro_stdd_w <- with(evs, ifelse(sprit_menge_stdd_w != 0, Sprit_Wert_w / sprit_menge_stdd_w, 0))

## Gesamtmenge an Standarddrinks pro Haushalt (dient als proxy für die Trinkgruppen)
evs$gesamtmenge_stdd_w = with(evs, bier_menge_stdd_w + wein_menge_stdd_w + sprit_menge_stdd_w)
#plausi check: plot histogram of gesamtmenge_stdd_w
hist(evs$gesamtmenge_stdd_w, breaks = 30, xlim = c(0, 400))


## Terzile für Nettohaushaltseinkommen -> Bilden der Einkommensgruppen
# Einkommensgruppe: 1 = 1. Terzil, 2 = 2. Terzil, 3 = 3. Terzil des Nettohaushaltseinkommens
terzile_einkommen_grenzen <- quantile(evs$netequincome, c(0, 1/3, 2/3, 1)) #Terzile finden
evs$einkommensgruppe <- cut(evs$netequincome, #neue Spalte mit Einkommensgruppen bilden
                                     breaks = terzile_einkommen_grenzen,
                                     labels = c(1, 2, 3), include.lowest = TRUE)

#------------------------------------------------------------
#plausi checks
ggplot(evs[evs$Wein_Wert_pro_stdd_w>0, ], aes(x =  einkommensgruppe, y = Wein_Wert_pro_stdd_w)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 5)) #higher income -> higher spending per stddrink

summary(evs[evs$Wein_Wert_pro_stdd_w>0, ]$Wein_Wert_pro_stdd_w) #median spending of 0.5€ per stddrink -> too low?


ggplot(evs[evs$Bier_Wert_pro_stdd_w>0, ], aes(x =  einkommensgruppe, y = Bier_Wert_pro_stdd_w)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 2)) #higher income -> higher spending per stddrink

summary(evs[evs$Bier_Wert_pro_stdd_w>0, ]$Bier_Wert_pro_stdd_w) #median spending of 0.5€ per stddrink -> too low?

#show rows that have Bier_Wert_pro_stdd_w < 0.2 but not 0
evs[evs$Bier_Wert_pro_stdd_w < 0.2 & evs$Bier_Wert_pro_stdd_w != 0, c("N_Haushaltsmitglieder_adult", "Bier_Wert", "Bier_Menge", "Bier_Wert_pro_stdd_w", "Bier_Wert_w", "Bier_Menge_w", "bier_menge_stdd_w")]

#calculation looks good
#------------------------------------------------------------

# ==================================================================================================================================================================
#tranform data to long format (one row per person, values to "sex" and "yob")
evs_long <- evs %>%
  pivot_longer(cols = grep("sex_pers|yob_pers", names(evs)), names_to = c(".value", "person"), values_to = c("sex", "yob"), names_pattern = "(sex|yob)_pers(\\d)")

calculate_age <- function(year_of_birth) {
  current_year <- 2018  # year of evs data collection
  age <- current_year - year_of_birth
  return(age)
}


#add age to evs_long
evs_long$age <- calculate_age(evs_long$yob)

#include only adults between age 18 and 64
evs_adultsbis64 <- evs_long %>%
  filter(age >= 18 & age <= 64) 


evs_adultsbis64 <- evs_adultsbis64 %>%
  mutate(altersgruppe = case_when(
    age >= 18 & age <= 34 ~ "18-34",
    age >= 35 & age <= 59 ~ "35-59",
    age >= 60 & age <= 64 ~ "60-64",
    TRUE ~ NA_character_ #Fallback falls keine der Bedingungen zutrifft
  ))

table(evs_adultsbis64$altersgruppe, useNA = "ifany")
prop.table(table(evs_adultsbis64$altersgruppe, useNA = "ifany"))

## TRINKGRUPPEN bilden

## = Perzentile für Gesamtmengen an Standarddrinks (proxy für Trinkgruppen) berechnen
## Notiz: Perzentilgrenzen variieren je nach Geschlecht, Alter und Einkommen. Geschlecht wird aufgrund der Haushaltebene hier ausgeklammert (wessen Geschlecht?)
## Perzentilgrenzen erhalten wir NACHTRÄGLICH durch Schätzungen des Epidemiologische Suchtsurvey (ESA)
## als Ersatz werden hier vorläufig fiktive Perzentilgrenzen generiert


## Generieren von fiktiven Perzentilen pro EinkommensgruppexAltersgruppe (identifier)

# Identifier für alle Kombinationen von Einkommen und Alter bilden
evs_adultsbis64$identifier <- paste(evs_adultsbis64$einkommensgruppe, evs_adultsbis64$altersgruppe, evs_adultsbis64$sex, sep = "_")

#adapt esa_perctrinkgruppen to evs_adultsbis64
esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  mutate(Einkommen_new = factor(Einkommen, levels = c("Niedriges Einkommen", "Mittleres Einkommen", "Hohes Einkommen")),
         Sex_new = factor(Geschlecht, levels = c("Male", "Female")),
         Alter_new = factor(Alter, levels = c("18-34 Jahre", "35-59 Jahre", "60-64 Jahre")))

esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  mutate(Einkommen_new = factor(Einkommen, levels = c("Niedriges Einkommen", "Mittleres Einkommen", "Hohes Einkommen"), labels = c(1, 2, 3)),
         Sex_new = factor(Geschlecht, levels = c("Male", "Female"), labels = c(1, 2)),
         Alter_new = factor(sub(" Jahre", "", Alter), levels = c("18-34", "35-59", "60-64")))
#divide by 100 to get decimal values
esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  mutate(across(c(Risikoarm, Riskant, Hoch), ~ . / 100))


esa_perctrinkgruppen$identifier <- paste(esa_perctrinkgruppen$Einkommen_new, esa_perctrinkgruppen$Alter_new, esa_perctrinkgruppen$Sex_new, sep = "_")

## -------dieser Teil ist später durch ESA Schätzungen zu ersetzen-------
# Erstellt Liste von eindeutigen Identifiern (Kombination von Einkommens- und Altersgruppe)
# um anschließend mittels sapply() für jedes Element Perzentilgrenzen zu generieren
#identifiers <- unique(evs$identifier)


# Funktion zur Generierung von Zufallswerten für untere (perc1) und obere (perc2) Perzentilgrenze
#generate_random_perc <- function() {
#  perc1 <- runif(1, min = 0.1, max = 0.9)
#  perc2 <- runif(1, min = perc1, max = 0.9)  # Stellt sicher, dass perc2 größer als perc1 ist
#  c(perc1 = perc1, perc2 = perc2)
#}

# Wendet Funktion 'generate_random_perc' auf jeden identifier an
# Ergebnis ist Liste von Vektoren mit zufällig generierten Perzentilgrenzen für jede Einkommens- und Altersgruppen-Kombination
#random_perc <- sapply(identifiers, function(id) generate_random_perc())

# Erstellt DataFrame mit identifiers und den zugehörigen zufällig generierten Perzentilgrenzen
# t() transponiert den Vektor 'random_perc', sodass jede Zeile die Perzentilgrenzen für eine spezifische Kombination repräsentiert
#pertentiles_by_strata <- data.frame(identifier = identifiers, t(random_perc), row.names = NULL)

## ----------ENDE Ersatz ESA Daten--------------
selected_esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  select(identifier, Risikoarm, Riskant, Hoch)

# Fusioniert 'pertentiles_by_strata' mit 'evs_bis64' basierend auf der Spalte 'identifier'
evs_bis64_strata <- merge(selected_esa_perctrinkgruppen, evs_adultsbis64, by = c("identifier"), all.x = TRUE)

# Zunächst wird nach identifier gruppiert um so nach strata die Werte der entspechenden 
# Perzentile zu errechnen. Für jeden Haushalt wird dann die Gesamtmenge mit den 
# jeweiligen Grenzwerten verglichen und eine Gruppeneinteilung (Trinkgruppen) vorgenommen

evs_bis64_strata_trinkgruppe <- evs_bis64_strata %>%
  filter(gesamtmenge_stdd_w > 0) %>% #nur Haushalte mit gekauften Getränken
  group_by(identifier) %>%
  mutate(Risikoarm_p = quantile(gesamtmenge_stdd_w, Risikoarm),
         Riskant_p = quantile(gesamtmenge_stdd_w, (Risikoarm+Riskant))) %>%
#         Hoch_p = quantile(gesamtmenge_stdd_w, Hoch)) 
  ungroup() %>%
  # weist jeder Zeile in 'evs_bis64_strata' eine Trinkgruppe zu basierend auf den berechneten Perzentilen
  mutate(trinkgruppe = case_when(
    gesamtmenge_stdd_w <= Risikoarm_p ~ 1, 
    gesamtmenge_stdd_w <= Riskant_p ~ 2,
    gesamtmenge_stdd_w > Riskant_p ~ 3,
    TRUE ~ NA)) #fallback falls keine der Bedingungen zutrifft

#Trink- und Altersgruppe von numerisch in Faktor umwandeln (Einkommensgruppe ist bereits ein Faktor)
#evs_bis64_strata_trinkgruppe <- evs_bis64_strata_trinkgruppe %>%
#  mutate(altersgruppe = as.factor(altersgruppe),
#         trinkgruppe = as.factor(trinkgruppe))

## Fallzahlen pro Trinkgruppe, Einkommensgruppe und Altersgruppe ausgeben lassen

# Fallzahl pro Trinkgruppe
N_trinkgruppe <- as.data.frame(table(evs_bis64_strata_trinkgruppe$trinkgruppe))
colnames(N_trinkgruppe) <- c("Gruppe", "N")

# Fallzahl pro Altersgruppe
N_altersgruppe <- as.data.frame(table(evs_bis64_strata_trinkgruppe$altersgruppe))
colnames(N_altersgruppe) <- c("Gruppe", "N")

# Fallzahl pro Sex
N_sex <- as.data.frame(table(evs_bis64_strata_trinkgruppe$sex))
colnames(N_sex) <- c("Gruppe", "N")

# Fallzahl pro Einkommensgruppe
N_einkommensgruppe <- as.data.frame(table(evs_bis64_strata_trinkgruppe$einkommensgruppe))
colnames(N_einkommensgruppe) <- c("Gruppe", "N")

# Fallzahl pro Stratum (TrinkgruppexEinkommensgruppexAltersgruppe)
N_stratum_df <- evs_bis64_strata_trinkgruppe  %>%
  group_by(trinkgruppe, altersgruppe, sex, einkommensgruppe) %>%
  summarize(N_stratum = n())

## Ausgaben pro Standarddrink mit Konfidenzintervallen (pro Getränketyp x Einkommensgruppe x Altersgruppe x Trinkgruppe - Stratum)

# Funktionen um Konfidenzintervall des means zu berechnen
# untere Grenze
mean_ci_low <- function(x, conf = 0.95) { 
  se <- sd(x) / sqrt(length(x)) 
  alpha <- 1 - conf 
  mean(x) + se * qnorm(alpha / 2) 
} 

# obere Grenze
mean_ci_high <- function(x, conf = 0.95) { 
  se <- sd(x) / sqrt(length(x)) 
  alpha <- 1 - conf 
  mean(x) + se * qnorm(1-alpha/ 2) 
} 

# Erstellt neuen Dataframe mit aggregierten Ausgaben pro Standarddrink pro Stratum (Getränketyp x Einkommensgruppe x Altersgruppe x Trinkgruppe)

aggregated_spendings <- evs_bis64_strata_trinkgruppe %>%
  group_by(trinkgruppe, einkommensgruppe, altersgruppe, sex) %>%
  summarize(
    bier_avg_wert_pro_stdd_w = mean(Bier_Wert_pro_stdd_w, na.rm = TRUE),
    bier_ci_low_wert_pro_stdd_w = mean_ci_low(Bier_Wert_pro_stdd_w),
    bier_ci_high_wert_pro_stdd_w = mean_ci_high(Bier_Wert_pro_stdd_w),
    wein_avg_wert_pro_stdd_w = mean(Wein_Wert_pro_stdd_w, na.rm = TRUE),
    wein_ci_low_wert_pro_stdd_w = mean_ci_low(Wein_Wert_pro_stdd_w),
    wein_ci_high_wert_pro_stdd_w = mean_ci_high(Wein_Wert_pro_stdd_w),
    sprit_avg_wert_pro_stdd_w = mean(Sprit_Wert_pro_stdd_w, na.rm = TRUE),
    sprit_ci_low_wert_pro_stdd_w = mean_ci_low(Sprit_Wert_pro_stdd_w),
    sprit_ci_high_wert_pro_stdd_w = mean_ci_high(Sprit_Wert_pro_stdd_w))

# Fügt Fallzahl pro Stratum hinzu
aggregated_spendings <- merge(aggregated_spendings, N_stratum_df, by = c("trinkgruppe", "altersgruppe", "sex", "einkommensgruppe"), all.x = TRUE)

# Optional je nach Verwendungszweck: Erstellt neue Spalte "beverage_type" und wandelt ursprüngliche Spalten entsprechend in long-format um
aggregated_spendings_long <- aggregated_spendings %>%
  pivot_longer(cols = starts_with(c("bier", "wein", "sprit")),
               names_to = "original_column") %>% 
  separate(original_column, into = c("beverage_type", "stat_type"), sep = "_", extra = "merge") %>%
  pivot_wider(names_from = stat_type, values_from = value)

# Ergebnisse als csv ausgeben lassen
write.csv(aggregated_spendings_long, "spendingsperdrink.csv")
#... and as RDS
saveRDS(aggregated_spendings_long, "spendingsperdrink.rds")