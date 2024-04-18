#old

# average age of the household (all household members >= 18)
calculate_age <- function(year_of_birth) {
  current_year <- 2018  # year of evs data collection
  age <- current_year - year_of_birth
  return(age)
}

evs$Haushaltsalter_adult <- apply(evs[, grep("yob_pers", names(evs))], 1, function(x) {
  # delete NA values (yob_persx is NA if there are not x persons in the household)
  x <- na.omit(x)
  # filter out persons born after 2000 (under 18 years in 2018)
  valid_years <- x[x <= 2000]
  #print(valid_years)
  # calculate average age of all persons in the househould born before 2000
  if (length(valid_years) > 0) {
    avg_age <- mean(calculate_age(valid_years))
    return(avg_age)
  } else {
    return(NA)  # if there are no persons in the household born before 2000
  }
})

# check Haushaltsalter_adult with histogram
hist(evs$Haushaltsalter_adult, breaks = 30)
summary(evs$Haushaltsalter_adult) #median 51, mean 51.3

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

# Fügt Fallzahl pro Stratum hinzu
aggregated_spendings <- merge(aggregated_spendings, N_stratum_df, by = c("trinkgruppe", "altersgruppe", "sex", "einkommensgruppe"), all.x = TRUE)


#Trink- und Altersgruppe von numerisch in Faktor umwandeln (Einkommensgruppe ist bereits ein Faktor)
#evs_bis64_strata_trinkgruppe <- evs_bis64_strata_trinkgruppe %>%
#  mutate(altersgruppe = as.factor(altersgruppe),
#         trinkgruppe = as.factor(trinkgruppe))
