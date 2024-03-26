### =====================================================================================================================================
### Berechnung der durchschnittlichen Ausgaben für eine Alkoholeinheit nach Getränketyp, Einkommensgruppe, Altersgruppe und Trinkgruppe
### =====================================================================================================================================

library("tidyverse")

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
