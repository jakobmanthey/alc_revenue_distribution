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
# 1) LOAD DATA
# ______________________________________________________________________________________________________________________
#EVS
evs_path <- file.path("EVS/Data", "evs_ngt2018_slr.csv")
evs_raw <- read.csv(evs_path, header = TRUE, sep = ";", dec = ",", stringsAsFactors = FALSE)
#ESA
esa_path <- file.path("ESA", "ESA_Alc_Share_240221.xlsx")
esa_trinkgruppen <- readxl::read_excel(esa_path, sheet = "Trinkgruppen")
esa_socgruppen <- readxl::read_excel(esa_path, sheet = "Soziodemographische Gruppen")

# ==================================================================================================================================================================
# 2) DATA PREPARATION
# ______________________________________________________________________________________________________________________
# EVS
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
         n_kinder_u1 = "EF22", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt unter 1 Jahr
         n_kinder_1_3 = "EF23", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 1 bis unter 3
         n_kinder_3_6 = "EF24", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 3 bis unter 6
         n_kinder_6_12 = "EF25", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 6 bis unter 12
         n_kinder_12_18 = "EF26", #Anzahl der ledigen Kinder des Haupteinkommensbeziehers / Partners im Haushalt zwischen 12 bis unter 18
         haushaltsnettoeinkommen = "EF30", #Haushaltsnettoeinkommen aus der Quartalsrechnung ( + / - Vorzeichen)
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
  select(ID, N_Haushaltsmitglieder, Stellung_pers1, sex_pers1, yob_pers1, Stellung_pers2, yob_pers2, Stellung_pers3, yob_pers3, Stellung_pers4,
         yob_pers4, Stellung_pers5, yob_pers5, Stellung_pers6, yob_pers6, Stellung_pers7, yob_pers7, Stellung_pers8, n_kinder_u1, n_kinder_1_3,
         n_kinder_3_6, n_kinder_6_12, n_kinder_12_18, haushaltsnettoeinkommen, bier_untergärig_wert, bier_untergärig_menge, bier_anderes_wert,
         bier_anderes_menge, bier_misch_wert, bier_misch_menge, bier_ohneBez_wert, bier_ohneBez_menge, mischgetraenke_wert, mischgetraenke_menge,
         wein_rot_wert, wein_rot_menge, wein_weiss_wert, wein_weiss_menge, wein_rose_wert, wein_rose_menge, wein_schaum_wert, wein_schaum_menge,
         wein_apfel_wert, wein_apfel_menge, wein_frucht_wert, wein_frucht_menge, wein_wermut_wert, wein_wermut_menge, wein_sherry_wert,
         wein_sherry_menge, wein_portwein_wert, wein_portwein_menge, wein_anderes_wert, wein_anderes_menge, wein_ohneBez_wert, wein_ohneBez_menge,
         sprit_likör_wert, sprit_likör_menge, sprit_whisky_wert, sprit_whisky_menge, sprit_branntwein_wert, sprit_branntwein_menge, sprit_anderes_wert,
         sprit_anderes_menge)
         
         
         

      
         




### Dataset generieren (beispielhaft für EVS Daten)

# Anzahl der Haushalte (Sample Size)
N_haushalte <- 1000 # Wert 1000 ist fiktiv und dient nur als Beispiel

# Seed Setzen für Reproduzierbarkeit der Zufallszahlen
set.seed(123)

# DataFrame generieren als Platzhalter für EVS 
haushalts_df_raw <- data.frame(
  HaushaltsID = 1:N_haushalte,
  N_Haushaltsmitglieder_adult = round(runif(N_haushalte, 1, 6)), #Anzahl der erwachsenen Personen im Haushalt, bitte Hauhaltsmitglieder <18 Jahren exkludieren
  Haushaltsnettoeinkommen = round(runif(N_haushalte, 900, 18000)), #monatliches Haushaltsnettoeinkommen
  Haushaltsalter = round(runif(N_haushalte, 18, 100)), #durchschnittliches Alter aller Haushaltsmitglieder >= 18
  Bier_Wert = round(runif(N_haushalte, 0, 1000), 2), #Ausgaben für Bier (Euro, Cent)
  Wein_Wert = round(runif(N_haushalte, 0, 1000), 2), #Ausgaben für Wein (Euro, Cent)
  Sprit_Wert = round(runif(N_haushalte, 0, 1000), 2), #Ausgaben für Spirituosen (Euro, Cent)
  Bier_Menge = round(runif(N_haushalte, 0, 100)), #Menge (in l) des erworbenen Bier
  Wein_Menge = round(runif(N_haushalte, 0, 100)), #Menge (in l) des erworbenen Wein
  Sprit_Menge = round(runif(N_haushalte, 0, 100)) #Menge (in l) der erworbenen Spirituosen
)

# Altersgruppen bilden 
haushalts_df <- haushalts_df_raw %>%
  mutate(altersgruppe = case_when(
    Haushaltsalter >= 18 & Haushaltsalter <= 34 ~ 1,
    Haushaltsalter >= 35 & Haushaltsalter <= 59 ~ 2,
    Haushaltsalter >= 60 ~ 3,
    TRUE ~ NA_integer_ #Fallback falls keine der Bedingungen zutrifft
  ))

### Berechnungen

## gekaufte Mengen, Ausgaben (Wert) und Nettohaushaltseinkommen nach Anzahl der Haushaltsmitglieder gewichten
zu_gewichtende_spalten <- c("Haushaltsnettoeinkommen", "Bier_Wert", "Wein_Wert", "Sprit_Wert", "Bier_Menge", "Wein_Menge", "Sprit_Menge")
# Teilt ausgewählte Spalten durch Anzahl der erwachsenen Haushaltsmitglieder und speichert Ergebnisse in neuen Spalten (w=weighted)
haushalts_df <- haushalts_df %>%
  mutate(across(all_of(zu_gewichtende_spalten), list(~ . / N_Haushaltsmitglieder_adult), .names = "{.col}_w"))


## gekaufte Mengen in l in Standarddrinks (stdd=standarddrinks) umrechnen (0,33l Bier, 0,125l Wein, 0,04l Spirituosen), um Getränketypen bzgl. Alkoholgehalt vergleichbar zu machen
haushalts_df$bier_stdd_w = haushalts_df$Bier_Menge_w / 0.33
haushalts_df$wein_stdd_w = haushalts_df$Wein_Menge_w / 0.125
haushalts_df$sprit_stdd_w = haushalts_df$Sprit_Menge_w / 0.04

## Ausgaben (Wert) pro Standarddrink (jeweils nach Getränketyp) berechnen, indem Ausgaben durch die Menge in Standarddrinks geteilt werden
# um auszuschließen, dass durch 0 geteilt wird (inf), wird gecheckt, ob Divisor == 0, falls ja, wird Ergebnis direkt auf 0 gesetzt
haushalts_df$Bier_Wert_pro_stdd_w <- with(haushalts_df, ifelse(bier_stdd_w != 0, Bier_Wert_w / bier_stdd_w, 0))
haushalts_df$Wein_Wert_pro_stdd_w <- with(haushalts_df, ifelse(wein_stdd_w != 0, Wein_Wert_w / wein_stdd_w, 0))
haushalts_df$Sprit_Wert_pro_stdd_w <- with(haushalts_df, ifelse(sprit_stdd_w != 0, Sprit_Wert_w / sprit_stdd_w, 0))

## Gesamtmenge an Standarddrinks pro Haushalt (dient als proxy für die Trinkgruppen)
haushalts_df$gesamtmenge_stdd_w = with(haushalts_df, bier_stdd_w + wein_stdd_w + sprit_stdd_w)

## Terzile für Nettohaushaltseinkommen -> Bilden der Einkommensgruppen
# Einkommensgruppe: 1 = 1. Terzil, 2 = 2. Terzil, 3 = 3. Terzil des Nettohaushaltseinkommens
terzile_einkommen_grenzen <- quantile(haushalts_df$Haushaltsnettoeinkommen_w, c(0, 1/3, 2/3, 1)) #Terzile finden
haushalts_df$einkommensgruppe <- cut(haushalts_df$Haushaltsnettoeinkommen_w, #neue Spalte mit Einkommensgruppen bilden
                                     breaks = terzile_einkommen_grenzen,
                                     labels = c(1, 2, 3), include.lowest = TRUE)


## TRINKGRUPPEN bilden

## = Perzentile für Gesamtmengen an Standarddrinks (proxy für Trinkgruppen) berechnen
## Notiz: Perzentilgrenzen variieren je nach Geschlecht, Alter und Einkommen. Geschlecht wird aufgrund der Haushaltebene hier ausgeklammert (wessen Geschlecht?)
## Perzentilgrenzen erhalten wir NACHTRÄGLICH durch Schätzungen des Epidemiologische Suchtsurvey (ESA)
## als Ersatz werden hier vorläufig fiktive Perzentilgrenzen generiert

## -------dieser Teil ist später durch ESA Schätzungen zu ersetzen-------
## Generieren von fiktiven Perzentilen pro EinkommensgruppexAltersgruppe (identifier)

# Identifier für alle Kombinationen von Einkommen und Alter bilden
haushalts_df$identifier <- paste(haushalts_df$einkommensgruppe, haushalts_df$altersgruppe, sep = "_")


# Erstellt Liste von eindeutigen Identifiern (Kombination von Einkommens- und Altersgruppe)
# um anschließend mittels sapply() für jedes Element Perzentilgrenzen zu generieren
identifiers <- unique(haushalts_df$identifier)


# Funktion zur Generierung von Zufallswerten für untere (perc1) und obere (perc2) Perzentilgrenze
generate_random_perc <- function() {
  perc1 <- runif(1, min = 0.1, max = 0.9)
  perc2 <- runif(1, min = perc1, max = 0.9)  # Stellt sicher, dass perc2 größer als perc1 ist
  c(perc1 = perc1, perc2 = perc2)
}

# Wendet Funktion 'generate_random_perc' auf jeden identifier an
# Ergebnis ist Liste von Vektoren mit zufällig generierten Perzentilgrenzen für jede Einkommens- und Altersgruppen-Kombination
random_perc <- sapply(identifiers, function(id) generate_random_perc())

# Erstellt DataFrame mit identifiers und den zugehörigen zufällig generierten Perzentilgrenzen
# t() transponiert den Vektor 'random_perc', sodass jede Zeile die Perzentilgrenzen für eine spezifische Kombination repräsentiert
pertentiles_by_strata <- data.frame(identifier = identifiers, t(random_perc), row.names = NULL)

## ----------ENDE Ersatz ESA Daten--------------

# Fusioniert 'pertentiles_by_strata' mit 'haushalts_df' basierend auf der Spalte 'identifier'
haushalts_df_strata <- merge(pertentiles_by_strata, haushalts_df, by = c("identifier"), all.x = TRUE)

# Zunächst wird nach identifier gruppiert um so nach strata die Werte der entspechenden 
# Perzentile zu errechnen. Für jeden Haushalt wird dann die Gesamtmenge mit den 
# jeweiligen Grenzwerten verglichen und eine Gruppeneinteilung (Trinkgruppen) vorgenommen

haushalts_df_strata_trinkgruppe <- haushalts_df_strata %>%
  group_by(identifier) %>%
  # Berechnet Perzentile für 'gesamtmenge_stdd basierend auf Grenzen in 'perc1' und 'perc2'
    mutate(percentile1 = quantile(gesamtmenge_stdd_w, perc1),
           percentile2 = quantile(gesamtmenge_stdd_w, perc2)) %>%
  ungroup() %>%
  # weist jeder Zeile in 'haushalts_df_strata' eine Trinkgruppe zu basierend auf den berechneten Perzentilen
  mutate(trinkgruppe = case_when(
    gesamtmenge_stdd_w <= percentile1 ~ 1, 
    gesamtmenge_stdd_w <= percentile2 ~ 2,
    gesamtmenge_stdd_w > percentile2 ~ 3,
    TRUE ~ NA)) #fallback falls keine der Bedingungen zutrifft

#Trink- und Altersgruppe von numerisch in Faktor umwandeln (Einkommensgruppe ist bereits ein Faktor)
haushalts_df_strata_trinkgruppe <- haushalts_df_strata_trinkgruppe %>%
  mutate(altersgruppe = as.factor(altersgruppe),
         trinkgruppe = as.factor(trinkgruppe))

## Fallzahlen pro Trinkgruppe, Einkommensgruppe und Altersgruppe ausgeben lassen

# Fallzahl pro Trinkgruppe
N_trinkgruppe <- as.data.frame(table(haushalts_df_strata_trinkgruppe$trinkgruppe))
colnames(N_trinkgruppe) <- c("Gruppe", "N")

# Fallzahl pro Altersgruppe
N_altersgruppe <- as.data.frame(table(haushalts_df_strata_trinkgruppe$altersgruppe))
colnames(N_altersgruppe) <- c("Gruppe", "N")

# Fallzahl pro Einkommensgruppe
N_einkommensgruppe <- as.data.frame(table(haushalts_df_strata_trinkgruppe$einkommensgruppe))
colnames(N_einkommensgruppe) <- c("Gruppe", "N")

# Fallzahl pro Stratum (TrinkgruppexEinkommensgruppexAltersgruppe)
N_stratum_df <- haushalts_df_strata_trinkgruppe  %>%
  group_by(trinkgruppe, altersgruppe, einkommensgruppe) %>%
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

aggregated_spendings <- haushalts_df_strata_trinkgruppe %>%
  group_by(trinkgruppe, einkommensgruppe, altersgruppe) %>%
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
aggregated_spendings <- merge(aggregated_spendings, N_stratum_df, by = c("trinkgruppe", "altersgruppe", "einkommensgruppe"), all.x = TRUE)

# Optional je nach Verwendungszweck: Erstellt neue Spalte "beverage_type" und wandelt ursprüngliche Spalten entsprechend in long-format um
aggregated_spendings_long <- aggregated_spendings %>%
  pivot_longer(cols = starts_with(c("bier", "wein", "sprit")),
               names_to = "original_column") %>% 
  separate(original_column, into = c("beverage_type", "stat_type"), sep = "_", extra = "merge") %>%
  pivot_wider(names_from = stat_type, values_from = value)

# Ergebnisse als csv ausgeben lassen
write.csv(aggregated_spendings_long, "spendingsperdrink.csv")
