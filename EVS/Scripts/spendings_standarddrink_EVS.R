### =====================================================================================================================================
### Berechnung der durchschnittlichen Ausgaben für einen Standarddrink nach Getränketyp, Einkommensgruppe, Altersgruppe, Geschlecht und Trinkgruppe
### =====================================================================================================================================

# ==================================================================================================================================================================
# 0) ESSENTIALS
# ______________________________________________________________________________________________________________________
# clean workspace
rm(list=ls())

packages <- c("tidyverse", "readxl", "ggdist", "knitr") 

# Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())
if (any(installed_packages == FALSE)) {
  install.packages(packages[!installed_packages])
}
# Load packages
invisible(lapply(packages, library, character.only = TRUE))

# Export des Outputs
print(getwd())
exportdata <- TRUE # TRUE -> resultierende Datafiles werden exportiert
output_path <- "EVS/Output/" # Pfad für Export der Ergebnisse
if (!dir.exists(output_path)) {
  dir.create(output_path)
}

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
# -----------------------------------------------------------------------------------------------------------------------

# 2.1) ESA

# Auswahl der relevanten Spalten (Geschlecht, Alter, Einkommen, Risikoarm(%), Riskant(%), Hoch(%)) für die Einteilung der Trinkgruppen

esa_perctrinkgruppen <- esa_socgruppen_raw %>%
  select("Geschlecht", "Alter", "Einkommen", "Risikoarm", "Riskant", "Hoch")

# Anpassen an EVS
esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  mutate(Einkommen_new = factor(Einkommen, levels = c("Niedriges Einkommen", "Mittleres Einkommen", "Hohes Einkommen"), labels = c(1, 2, 3)),
         Sex_new = factor(Geschlecht, levels = c("Male", "Female"), labels = c(1, 2)),
         Alter_new = factor(sub(" Jahre", "", Alter), labels = c("18-34", "35-59", "60+")))

# Prozente zu Dezimalzahlen umwandeln
esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  mutate(across(c(Risikoarm, Riskant, Hoch), ~ . / 100))

## einschub: plot der verteilung der risikogruppen
#------------------------------------------------------------
esa_perctrinkgruppen_long <- esa_perctrinkgruppen %>%
  pivot_longer(cols = c("Risikoarm", "Riskant", "Hoch"), names_to = "Trinkgruppe", values_to = "Anteil") %>%
  mutate(Trinkgruppe = factor(Trinkgruppe, levels = c("Risikoarm", "Riskant", "Hoch")))

# anteil risikogruppen nach geschlecht, alter, einkommen -> kaum unterschiede zwischen geschlechtern?
perc_trgr_sexageincome <- ggplot(esa_perctrinkgruppen_long, aes(x = Alter, y = Anteil, fill = Trinkgruppe)) +
  geom_bar(position = "stack", stat = "identity") +
  facet_grid(Einkommen~Geschlecht) +
  scale_fill_manual(values = c("Risikoarm" = "#FFCCCC", "Riskant" = "#FF6666", "Hoch" = "#8B0000")) +
  labs(title = "ESA: Verteilung der Trinkgruppen",
       subtitle = "nach Alter, Geschlecht und Einkommen (unter Konsumierenden)",
       y = "Anteil", x = "Altersgruppe") +
  theme_minimal()

# nur hochrisikogruppe - vor allem ältere männer, unter jungen frauen und jungen männern ähnlich hoch?!
perc_highrisk_sexage <- ggplot(esa_perctrinkgruppen, aes(x = Geschlecht, y = Hoch, fill = Alter)) +
  stat_summary(fun = "mean", geom = "bar", position = "dodge") +
  labs(title = "Anteil mit Hochrisikonsum nach Alter und Geschlecht (unter Konsumierenden)",
       y = "Anteil", x = "Geschlecht") +
  theme_minimal()

if (exportdata == TRUE) {
  ggsave(file.path(output_path, "perc_trgr_sexageincome.png"), perc_trgr_sexageincome, width = 10, height = 6, units = "in")
  ggsave(file.path(output_path, "perc_highrisk_sexage.png"), perc_highrisk_sexage, width = 6, height = 6, units = "in")
}

# -----------------------------------------------------------------------------------------------------------------------
# 2.2) EVS

# Filtern und Umbenennen der relevanten Variablen
evs <- evs_raw %>%
  rename(ID = "EF3", #HaushaltsID
         N_Haushaltsmitglieder = "EF7", #Anzahl Personen im Haushalt
         sex_pers1 = "EF8u2", #Geschlecht Person 1 (Pers 1 ist immer Haupteinkommensbezieher)
         yob_pers1 = "EF8u3", #Alter Person 1
         sex_pers2 = "EF9u2", #Geschlecht Person 2
         yob_pers2 = "EF9u3", #Alter Person 2
         sex_pers3 = "EF10u2", #Geschlecht Person 3
         yob_pers3 = "EF10u3", #Alter Person 3
         sex_pers4 = "EF11u2",
         yob_pers4 = "EF11u3",
         sex_pers5 = "EF12u2",
         yob_pers5 = "EF12u3",
         sex_pers6 = "EF13u2",
         yob_pers6 = "EF13u3",
         sex_pers7 = "EF14u2",
         yob_pers7 = "EF14u3",
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
  select(ID, N_Haushaltsmitglieder, sex_pers1, yob_pers1, yob_pers2, sex_pers2, yob_pers3, sex_pers3,
         yob_pers4, sex_pers4, yob_pers5, sex_pers5, yob_pers6, sex_pers6, yob_pers7, sex_pers7, yob_pers8, sex_pers8, n_kinder_u1, n_kinder_1_3,
         n_kinder_3_6, n_kinder_6_12, n_kinder_12_18, haushaltsnettoeinkommen_quartal, bier_untergärig_wert, bier_untergärig_menge, bier_anderes_wert,
         bier_anderes_menge, bier_misch_wert, bier_misch_menge, bier_ohneBez_wert, bier_ohneBez_menge, mischgetraenke_wert, mischgetraenke_menge,
         wein_rot_wert, wein_rot_menge, wein_weiss_wert, wein_weiss_menge, wein_rose_wert, wein_rose_menge, wein_schaum_wert, wein_schaum_menge,
         wein_apfel_wert, wein_apfel_menge, wein_frucht_wert, wein_frucht_menge, wein_wermut_wert, wein_wermut_menge, wein_sherry_wert,
         wein_sherry_menge, wein_portwein_wert, wein_portwein_menge, wein_anderes_wert, wein_anderes_menge, wein_ohneBez_wert, wein_ohneBez_menge,
         sprit_likör_wert, sprit_likör_menge, sprit_whisky_wert, sprit_whisky_menge, sprit_branntwein_wert, sprit_branntwein_menge, sprit_anderes_wert,
         sprit_anderes_menge)
 
# Konvertiere alle Bier-, Wein- und Spirituosenmengen und -ausgaben in numerische Werte
evs[, grep("wein|bier|sprit", names(evs))] <- sapply(evs[, grep("wein|bier|sprit", names(evs))], as.numeric)
# ______________________________________________________________________________________________________________________
## Anzahl der erwachsenen Haushaltsmitglieder berechnen
evs$N_Haushaltsmitglieder_adult <- evs$N_Haushaltsmitglieder - evs$n_kinder_u1 - evs$n_kinder_1_3 - evs$n_kinder_3_6 - evs$n_kinder_6_12 - evs$n_kinder_12_18
# ______________________________________________________________________________________________________________________
## Äquivalenzeinkommen
# Bedarfsgewichtungsfaktor pro Haushalt berechnen nach neuer OECD-Skala:
# Bedarfsgewicht 1 für erste erwachsenen Person im Haushalt
# 0,5 für weitere Personen im Alter von 14 und mehr Jahren
# 0,3 für jedes Kind im Alter von unter 14 Jahren

berechne_gewichtungsfaktor <- function(row) {
  gewichtung <- 1 # Faktor für Hauptverdiener (pers1)
  
  # iterate over other household members (pers2-pers8)
  for (i in 2:8) {
    pers <- paste0('yob_pers', i)
#    print(pers)
    yob <- row[[pers]]
#    print(yob)
    if (is.na(yob)) {
      gewichtung <- gewichtung + 0 # Wenn Geburtsjahr NA (=Person existiert nicht), addiere 0 zur Gewichtung
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


# check: Kontrolliere, ob die Gewichtungsfaktoren korrekt berechnet wurden beispielhaft für Haushalte mit 2 Personen
evs[evs$N_Haushaltsmitglieder == 2, c("N_Haushaltsmitglieder", "gewichtungsfaktor", "yob_pers1", "yob_pers2")]

# Haushaltsnettoeinkommen in Monatseinkommen umrechnen (Original auf Quartalsbasis)
evs$haushaltsnettoeinkommen_month <- evs$haushaltsnettoeinkommen_quartal/3
evs$netequincome <- evs$haushaltsnettoeinkommen_month / evs$gewichtungsfaktor

summary(evs$haushaltsnettoeinkommen_month) #median 3496.7
summary(evs$netequincome) #median 2354
#laut statistischem bundesamt liegt das median äquivalenzeinkommen bei 22713/12 = 1892 euro
#evtl. hier erhöht, weil hochrechnugnsfaktoren nciht berücksichtigt?

## Terzile für Nettohaushaltseinkommen -> Bilden der Einkommensgruppen
# Einkommensgruppe: 1 = 1. Terzil, 2 = 2. Terzil, 3 = 3. Terzil des Nettoäquivaleinkommens
terzile_einkommen_grenzen <- quantile(evs$netequincome, c(0, 1/3, 2/3, 1)) #Terzile finden
evs$einkommensgruppe <- cut(evs$netequincome, #neue Spalte mit Einkommensgruppen bilden
                            breaks = terzile_einkommen_grenzen,
                            labels = c(1, 2, 3), include.lowest = TRUE)

# ==================================================================================================================================================================
## 3) Berechnungen: gewichtete (nach Anzahl erwachsener Haushaltsmitgleider) Ausgaben pro Standarddrink auf Haushaltsebene
# ______________________________________________________________________________________________________________________

## summarize bier, wein, sprit
evs$Bier_Wert <- evs$bier_untergärig_wert + evs$bier_anderes_wert + evs$bier_misch_wert + evs$bier_ohneBez_wert
evs$Bier_Menge <- evs$bier_untergärig_menge + evs$bier_anderes_menge + evs$bier_misch_menge + evs$bier_ohneBez_menge
evs$Wein_Wert <- evs$wein_rot_wert + evs$wein_weiss_wert + evs$wein_rose_wert + evs$wein_schaum_wert + evs$wein_apfel_wert + evs$wein_frucht_wert + evs$wein_wermut_wert + evs$wein_sherry_wert + evs$wein_portwein_wert + evs$wein_anderes_wert + evs$wein_ohneBez_wert
evs$Wein_Menge <- evs$wein_rot_menge + evs$wein_weiss_menge + evs$wein_rose_menge + evs$wein_schaum_menge + evs$wein_apfel_menge + evs$wein_frucht_menge + evs$wein_wermut_menge + evs$wein_sherry_menge + evs$wein_portwein_menge + evs$wein_anderes_menge + evs$wein_ohneBez_menge
evs$Sprit_Wert <- evs$sprit_likör_wert + evs$sprit_whisky_wert + evs$sprit_branntwein_wert + evs$sprit_anderes_wert
evs$Sprit_Menge <- evs$sprit_likör_menge + evs$sprit_whisky_menge + evs$sprit_branntwein_menge + evs$sprit_anderes_menge


## gekaufte Mengen und Ausgaben (Wert) nach Anzahl der Haushaltsmitglieder gewichten
zu_gewichtende_spalten <- c("Bier_Wert", "Wein_Wert", "Sprit_Wert", "Bier_Menge", "Wein_Menge", "Sprit_Menge")
# Teilt ausgewählte Spalten durch Anzahl der erwachsenen Haushaltsmitglieder und speichert Ergebnisse in neuen Spalten (w=weighted)
evs <- evs %>%
  mutate(across(all_of(zu_gewichtende_spalten), list(~ . / N_Haushaltsmitglieder_adult), .names = "{.col}_w"))


## gekaufte Mengen (in l) in Standarddrinks (stdd=standarddrinks) umrechnen (0,33l Bier, 0,125l Wein, 0,04l Spirituosen), um Getränketypen bzgl. Alkoholgehalt vergleichbar zu machen
evs$bier_menge_stdd_w = evs$Bier_Menge_w / 0.33
evs$wein_menge_stdd_w = evs$Wein_Menge_w / 0.125
evs$sprit_menge_stdd_w = evs$Sprit_Menge_w / 0.04


## Ausgaben (Wert) pro Standarddrink (jeweils nach Getränketyp) berechnen, indem Ausgaben durch die Menge in Standarddrinks geteilt werden
# um auszuschließen, dass durch 0 geteilt wird (inf), wird gecheckt, ob Divisor == 0, falls ja, wird Ergebnis direkt auf 0 gesetzt
evs$Bier_Wert_pro_stdd_w <- with(evs, ifelse(bier_menge_stdd_w != 0, Bier_Wert_w / bier_menge_stdd_w, 0))
evs$Wein_Wert_pro_stdd_w <- with(evs, ifelse(wein_menge_stdd_w != 0, Wein_Wert_w / wein_menge_stdd_w, 0))
evs$Sprit_Wert_pro_stdd_w <- with(evs, ifelse(sprit_menge_stdd_w != 0, Sprit_Wert_w / sprit_menge_stdd_w, 0))

#------------------------------------------------------------
#plausi checks der Ausgaben pro stddrink
ggplot(evs[evs$Wein_Wert_pro_stdd_w>0, ], aes(x =  einkommensgruppe, y = Wein_Wert_pro_stdd_w)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 5)) #hohes einkommen -> höhere ausgaben pro stddrink, plausibel

summary(evs[evs$Wein_Wert_pro_stdd_w>0, ]$Wein_Wert_pro_stdd_w) #median spending 0.5€ per stddrink -> zu niedrig


ggplot(evs[evs$Bier_Wert_pro_stdd_w>0, ], aes(x =  einkommensgruppe, y = Bier_Wert_pro_stdd_w)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 2)) #hohes einkommen -> höhere ausgaben pro stddrink, plausibel

summary(evs[evs$Bier_Wert_pro_stdd_w>0, ]$Bier_Wert_pro_stdd_w) #median spending 0.5€ per stddrink -> zu niedrig
summary(evs[evs$Sprit_Wert_pro_stdd_w>0, ]$Sprit_Wert_pro_stdd_w)

# check: Kontrolliere, ob Ausgaben pro stdd korrekt berechnet wurden beispielhaft für sehr niedrige Ausgaben
evs[evs$Bier_Wert_pro_stdd_w < 0.2 & evs$Bier_Wert_pro_stdd_w != 0, c("N_Haushaltsmitglieder_adult", "Bier_Wert", "Bier_Menge", "Bier_Wert_pro_stdd_w", "Bier_Wert_w", "Bier_Menge_w", "bier_menge_stdd_w")]
#Berechnung sieht korrekt aus

# data to long format für plotting
evs_long_tmp <- evs %>%
  pivot_longer(cols=c("Bier_Wert_pro_stdd_w", "Wein_Wert_pro_stdd_w", "Sprit_Wert_pro_stdd_w"), names_to = "getraenketyp", values_to = "ausgaben_pro_stdd") %>%
  filter(ausgaben_pro_stdd > 0) #nur Haushalte mit gekauften Getränken

# plot Verteilung der Ausgaben pro Standarddrink nach Getränketyp -> sieht okay aus, wenn auch insgesamt sehr niedrige Ausgaben
spendingsstdd_dist_bybevtype <- ggplot(evs_long_tmp, aes(x = getraenketyp, y = ausgaben_pro_stdd)) +
  geom_violin() +
  geom_boxplot(width = 0.2, outlier.shape = NA) +
  geom_jitter(width = 0.45, size = 0.2, alpha=0.2) +
  scale_x_discrete(labels = c("Wein_Wert_pro_stdd_w" = "Wein", "Bier_Wert_pro_stdd_w" = "Bier", "Sprit_Wert_pro_stdd_w" = "Spirituosen")) +
  labs(title = "Verteilung der Ausgaben pro Standarddrink nach Getränketyp",
       subtitle = "(Standarddrink = 0,33l Bier; 0,04l Spirituosen; 0,125l Wein, y-Achse begrenzt bis 95. Perzentil)",
       y = "Ausgaben pro Standarddrink (€)", x = "Getränketyp") +
  theme_minimal() +
  scale_y_continuous(limits = c(0, quantile(evs_long_tmp$ausgaben_pro_stdd, 0.95)), breaks = seq(0, quantile(evs_long_tmp$ausgaben_pro_stdd, 0.95), 0.1))
ggsave(file.path(output_path, "spendingsstdd_dist_bybevtype.png"), spendingsstdd_dist_bybevtype, width = 6, height = 6, units = "in")

# ==================================================================================================================================================================
# 4) Berechnungen: Ausgaben pro Standarddrink gruppenspezifisch aggregiert

# Tranformiere Daten ins long format (eine Zeile pro Person, statt Zeile pro Haushalt, values to "sex" und "yob") um sex and age zu separieren (vorher nur auf Haushaltsebene)
evs_long <- evs %>%
  pivot_longer(cols = grep("sex_pers|yob_pers", names(evs)), names_to = c(".value", "person"), values_to = c("sex", "yob"), names_pattern = "(sex|yob)_pers(\\d)")

#______________________________________________________________________________________________________________________
# 4.1) Alter berechnen und Altersgruppen bilden
calculate_age <- function(year_of_birth) {
  current_year <- 2018  # year of evs data collection
  age <- current_year - year_of_birth
  return(age)
}

evs_long$age <- calculate_age(evs_long$yob)

# nur Erwachsene ab 18 berücksichtigen
evs_adults <- evs_long %>%
  filter(age >= 18) 


evs_adults <- evs_adults %>%
  mutate(altersgruppe = case_when(
    age >= 18 & age <= 34 ~ "18-34",
    age >= 35 & age <= 59 ~ "35-59",
    age >= 60 ~ "60+",
    TRUE ~ NA_character_ #Fallback falls keine der Bedingungen zutrifft
  ))

table(evs_adults$altersgruppe, useNA = "ifany")
prop.table(table(evs_adults$altersgruppe, useNA = "ifany"))

#______________________________________________________________________________________________________________________
# 4.2) TRINKGRUPPEN bilden
## = Wert X Gesamtmengen an Standarddrinks (proxy für Trinkgruppen) für Perzentilgrenze Y für  berechnen
## Perzentilgrenzen variieren je nach Geschlecht, Alter und Einkommen und wurden basierend auf ESA-Daten berechnet


## Gesamtmenge an Standarddrinks pro Haushalt (dient als proxy für die Trinkgruppen)
evs_adults$gesamtmenge_stdd_w = with(evs_adults, bier_menge_stdd_w + wein_menge_stdd_w + sprit_menge_stdd_w)
#plausi check: plot histogram der gesamtmenge_stdd_w
hist_gesamtmenge_stdd_w <- hist(evs_adults$gesamtmenge_stdd_w, breaks = 200, xlim = c(0, 400), main = "(Gekaufte) Menge an Standarddrinks, pro Monat)", xlab = "Menge an Standarddrinks pro Person", ylab = "Häufigkeit")

#plot histogram of gesamtmenge_stdd_w by sex, age, income
ggplot(filter(evs_adults, gesamtmenge_stdd_w > 0), aes(x = gesamtmenge_stdd_w, fill = as.factor(sex))) +
  geom_histogram(bins = 60, position = "identity", alpha = 0.5) +
  facet_grid(altersgruppe ~ einkommensgruppe, labeller = labeller(einkommensgruppe = c("1" = "niedriges Einkommen", "2" = "mittleres Einkommen", "3" = "hohes Einkommen"))) +
  scale_y_continuous(limits = c(0, 70)) +
  scale_x_continuous(limits = c(0, quantile(evs_adults$gesamtmenge_stdd_w, 0.95))) +
  scale_fill_discrete(labels = c("männlich", "weiblich")) +
  labs(title = "(Gekaufte) Menge an Standarddrinks nach Geschlecht, Alter und Einkommen",
       subtitle = "pro Monat, ausgeschlossen Fälle mit 0 gekauften Getränken",
       x = "Menge an Standarddrinks pro Person",
       y = "Häufigkeit",
       fill = "Geschlecht") +
  theme_minimal()

summary(evs_adults$gesamtmenge_stdd_w) #max: 1091, median: 17, mean: 33
#cases with gesamtmenge_stdd_w = 0
sum(evs_adults$gesamtmenge_stdd_w == 0) # n=4443 Personen bzw.
sum(evs_adults$gesamtmenge_stdd_w == 0)/nrow(evs_adults) # 25% aller Personen kaufen kein Alkohol

#if (exportdata == TRUE) {
#  ggsave(file.path(output_path, "hist_gesamtmenge_stdd_w.png"), hist_gesamtmenge_stdd_w)
#}


# Identifier für alle Kombinationen von Einkommen, Alter und Geschlecht bilden
evs_adults$identifier <- paste(evs_adults$einkommensgruppe, evs_adults$altersgruppe, evs_adults$sex, sep = "_")
esa_perctrinkgruppen$identifier <- paste(esa_perctrinkgruppen$Einkommen_new, esa_perctrinkgruppen$Alter_new, esa_perctrinkgruppen$Sex_new, sep = "_")

selected_esa_perctrinkgruppen <- esa_perctrinkgruppen %>%
  select(identifier, Risikoarm, Riskant, Hoch)

# Ordnet die Perzentilgrenzen aus ESA den entsprechenden Gruppen in EVS zu basierend auf der Spalte 'identifier'
evs_strata <- merge(selected_esa_perctrinkgruppen, evs_adults, by = c("identifier"), all.x = TRUE)

# Zunächst wird nach identifier gruppiert um so nach strata die Werte der entspechenden 
# Perzentile zu errechnen. Für jeden Haushalt wird dann die Gesamtmenge mit den 
# jeweiligen Grenzwerten verglichen und eine Gruppeneinteilung (Trinkgruppen) vorgenommen

evs_strata_trinkgruppe <- evs_strata %>%
  filter(gesamtmenge_stdd_w > 0) %>% #nur Haushalte mit gekauften Getränken (nur "Konsumierende")
  group_by(identifier) %>%
  mutate(Risikoarm_p = quantile(gesamtmenge_stdd_w, Risikoarm), #berechnet Gesamtmenge an standarddrinks an stellle perzentilgrenze (ESA) für jede Gruppe
         Riskant_p = quantile(gesamtmenge_stdd_w, (Risikoarm+Riskant)),
         Gefährlich_p = quantile(gesamtmenge_stdd_w, (Risikoarm+Riskant+Hoch))) %>% 
  ungroup() %>%
  # weist jeder Zeile in 'evs_strata' eine Trinkgruppe zu basierend auf den berechneten Perzentilen
  mutate(trinkgruppe = case_when(
    gesamtmenge_stdd_w <= Risikoarm_p ~ "risikoarm", #wenn gesamtmenge kleiner als perzentilgrenze für Risikoarm
    gesamtmenge_stdd_w <= Riskant_p ~ "riskant", #wenn gesamtmenge kleiner als perzentilgrenze für Riskant_p
    gesamtmenge_stdd_w > Riskant_p ~ "hochriskant", #wenn gesamtmenge größer als perzentilgrenze für Riskant_p
    TRUE ~ NA)) %>% #fallback falls keine der Bedingungen zutrifft
  mutate(trinkgruppe = factor(trinkgruppe, levels = c("risikoarm", "riskant", "hochriskant"))) %>% #sortierung der Trinkgruppen
  mutate(
    Bier_Wert_pro_stdd_w = ifelse(Bier_Wert_pro_stdd_w == 0, NA, Bier_Wert_pro_stdd_w), #setze 0 (entsteht, wenn keine Käufe) auf NA, um zu verhindern dass 0 in mean() einfließt
    Wein_Wert_pro_stdd_w = ifelse(Wein_Wert_pro_stdd_w == 0, NA, Wein_Wert_pro_stdd_w),
    Sprit_Wert_pro_stdd_w = ifelse(Sprit_Wert_pro_stdd_w == 0, NA, Sprit_Wert_pro_stdd_w)
  ) 

# check der ergebnisse vor aggregation
table(evs_strata_trinkgruppe$trinkgruppe, useNA = "ifany") #okay, no NAs

ggplot(evs_strata_trinkgruppe, aes(x = trinkgruppe, y = gesamtmenge_stdd_w)) +
  geom_boxplot() +
  scale_y_continuous(limits = c(0, 400)) #plausibel, da die Grenzen für die Trinkgruppen auf Basis der Gesamtmenge an Standarddrinks berechnet wurden
# plot by beverage type
# pivot data to long format
evs_strata_trinkgruppe_long <- evs_strata_trinkgruppe %>%
  pivot_longer(cols = starts_with(c("Bier_Wert_pro_stdd_w", "Wein_Wert_pro_stdd_w", "Sprit_Wert_pro_stdd_w")),
               names_to = "original_column_name") %>% 
  separate(original_column_name, into = c("beverage_type", "stat_type"), sep = "_", extra = "merge") %>%
  pivot_wider(names_from = stat_type, values_from = value) %>%
  mutate(einkommensgruppe = factor(einkommensgruppe, labels = c("niedriges Einkommen", "mittleres Einkommen", "hohes Einkommen")))

#ggplot(evs_strata_trinkgruppe_long, aes(x = trinkgruppe, y = Wert_pro_stdd_w, fill = trinkgruppe)) +
#  stat_dots(
#    # ploting on left side
#    side = "right",
#    # adjusting position
#    justification = 0.3,
#    alpha = 0.2,
    # adjust grouping (binning) of observations
#    binwidth = unit(c(1, Inf), "mm"), overflow = "compress"
    #stackratio = 0.5
#  ) +
#  geom_boxplot(
#    width = 0.12,
    # removing outliers
#    outlier.color = NA,
#    alpha = 0.5
#  ) +
#  scale_y_continuous(limits = c(0, 3.5)) +
#  facet_grid(beverage_type ~ einkommensgruppe, scales = "free_y") +
#  labs(title = "Verteilung der Ausgaben pro Standarddrink nach Trinkgruppe",
#       subtitle = "(Standarddrink = 0,33l Bier; 0,04l Spirituosen; 0,125l Wein)",
#       y = "Ausgaben pro Standarddrink (€)", x = "Trinkgruppe") +
#  theme_minimal() 


#______________________________________________________________________________________________________________________
# 4.3) Ausgaben pro Standarddrink mit Konfidenzintervallen (pro Getränketyp x Einkommensgruppe x Altersgruppe x Geschlecht x Trinkgruppe - Stratum)

# Funktionen um Konfidenzintervall des means zu berechnen
# untere Grenze
mean_ci_low <- function(x, conf = 0.95, na.rm = FALSE) { 
  if(na.rm) {
    x <- x[!is.na(x)]
  }
  se <- sd(x, na.rm = TRUE) / sqrt(length(x)) 
  alpha <- 1 - conf 
  mean(x, na.rm = TRUE) + se * qnorm(alpha / 2) 
} 

mean_ci_high <- function(x, conf = 0.95, na.rm = FALSE) { 
  if(na.rm) {
    x <- x[!is.na(x)]
  }
  se <- sd(x, na.rm = TRUE) / sqrt(length(x)) 
  alpha <- 1 - conf 
  mean(x, na.rm = TRUE) + se * qnorm(1 - alpha / 2) 
} 

# Erstellt neuen Dataframe mit aggregierten Ausgaben pro Standarddrink pro Stratum (Getränketyp x Einkommensgruppe x Altersgruppe x Geschlecht x Trinkgruppe)

aggregated_spendings <- evs_strata_trinkgruppe %>%
  group_by(trinkgruppe, einkommensgruppe, altersgruppe, sex) %>%
  summarize(
    bier_avg_wert_pro_stdd_w = mean(Bier_Wert_pro_stdd_w, na.rm = TRUE),
    bier_ci_low_wert_pro_stdd_w = mean_ci_low(Bier_Wert_pro_stdd_w, na.rm = TRUE),
    bier_ci_high_wert_pro_stdd_w = mean_ci_high(Bier_Wert_pro_stdd_w, na.rm = TRUE),
    bier_n = sum(!is.na(Bier_Wert_pro_stdd_w)),
    wein_avg_wert_pro_stdd_w = mean(Wein_Wert_pro_stdd_w, na.rm = TRUE),
    wein_ci_low_wert_pro_stdd_w = mean_ci_low(Wein_Wert_pro_stdd_w, na.rm = TRUE),
    wein_ci_high_wert_pro_stdd_w = mean_ci_high(Wein_Wert_pro_stdd_w, na.rm = TRUE),
    wein_n = sum(!is.na(Wein_Wert_pro_stdd_w)),
    sprit_avg_wert_pro_stdd_w = mean(Sprit_Wert_pro_stdd_w, na.rm = TRUE),
    sprit_ci_low_wert_pro_stdd_w = mean_ci_low(Sprit_Wert_pro_stdd_w, na.rm = TRUE),
    sprit_ci_high_wert_pro_stdd_w = mean_ci_high(Sprit_Wert_pro_stdd_w, na.rm = TRUE),
    sprit_n = sum(!is.na(Sprit_Wert_pro_stdd_w)))

# Optional je nach Verwendungszweck: Erstellt neue Spalte "beverage_type" und wandelt ursprüngliche Spalten entsprechend in long-format um
aggregated_spendings_long <- aggregated_spendings %>%
  pivot_longer(cols = starts_with(c("bier", "wein", "sprit")),
               names_to = "original_column") %>% 
  separate(original_column, into = c("beverage_type", "stat_type"), sep = "_", extra = "merge") %>%
  pivot_wider(names_from = stat_type, values_from = value)

# Exportiere Ergebnisse als csv und RDS
if (exportdata == TRUE) {
  # Ergebnisse als csv 
  write.csv(aggregated_spendings_long, file.path(output_path, "spendingsperdrink.csv"))
  # und als RDS ausgeben lassen
  saveRDS(aggregated_spendings_long, file.path(output_path, "spendingsperdrink.rds"))
} else {
  print("no data exported")
}