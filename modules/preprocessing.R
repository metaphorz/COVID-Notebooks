#### Preprocessing

# Set provider capacity column names
colnames(provider_capacity) <- c("NAME","total_hosp_beds","hosp_beds_per_1000","total_CHCs","CHC_delivery_sites")
# Calculate hospital beds per 1000
provider_capacity$p_hosp_beds <-provider_capacity$hosp_beds_per_1000/1000 

# Calculate pUS
pUS.1 <- as.numeric(provider_capacity[which(provider_capacity$NAME=="United States"),"p_hosp_beds"])
pSK.1 <- 12.3/1000 # South Korean rate
pIT.1 <- 3.2/1000 # Italy rate
pDE.1 <- 8.0/1000 # Germany rate

#hosp_beds_ldi <- unlist(lapply(provider_capacity$p_hosp_beds, FUN=function(x){log((x/(1-x))/(pUS.1/(1-pUS.1)))}))
#hosp_beds_ldi <- unlist(lapply(provider_capacity$p_hosp_beds, FUN=function(x){log((x/(1-x))/(pSK.1/(1-pSK.1)))}))
#hosp_beds_ldi <- unlist(lapply(provider_capacity$p_hosp_beds, FUN=function(x){log((x/(1-x))/(pIT.1/(1-pIT.1)))}))
#hosp_beds_ldi <- unlist(lapply(provider_capacity$p_hosp_beds, FUN=function(x){-log(x/pIT.1)}))
hosp_beds_ldi <- unlist(lapply(provider_capacity$p_hosp_beds, FUN=function(x){log(x/pIT.1)}))

provider_capacity <- data.frame(provider_capacity, hosp_beds_ldi)
provider_capacity <- provider_capacity[match(states$NAME, provider_capacity$NAME),]
provider_capacity <- provider_capacity[1:51,]

provider_capacity <- provider_capacity %>% 
  mutate(hosp_beds_ldi = replace(hosp_beds_ldi, hosp_beds_ldi < -5, -5)) 

states <- data.frame(states, "hosp_beds_ldi"=provider_capacity$hosp_beds_ldi) # Append to states

## COVID-19 Testing fixing
# colnames(state_covid_testing) <- c("NAME","total_num_tests","tests_pos_results")
# Inner join to add population
state_covid_testing <- left_join(state_covid_testing, population, by = c('NAME'))

# TODO: This is really just the test rate, not "per 1000"
state_covid_testing <- state_covid_testing %>% 
  mutate(tests_per_1000 = total_num_tests / Population)  # This is actual rate, not "per 1000"

# Use current US rate
pUS.2 <- as.numeric(state_covid_testing[which(state_covid_testing$NAME=="United States"),"tests_per_1000"])

# Scraped values (updated every few days): see https://bit.ly/2yMyjFX
# Checked: 30 Apr 2020
#pUS.2 <- 18.5 / 1000
pPR.2 <- 37.2 / 1000
pIT.2 <- 31.6 / 1000
pIR.2 <- 31.2 / 1000
pDE.2 <- 30.4 / 1000
pSP.2 <- 30.3 / 1000
pCH.2 <- 30.1 / 1000
pRU.2 <- 23.9 / 1000
pCA.2 <- 20.7 / 1000
pUK.2 <- 12.1 / 1000

# for drop-down
country_testing_choices <- c("us","pr","ch","it","sp","ir","de","ca","ru","uk")

names(country_testing_choices) <- c(paste0("United States (" ,round(pUS.2*1000),"/1000)"),
                             paste0("Portugal ("      ,pPR.2*1000,"/1000)"),
                             paste0("Switzerland ("   ,pCH.2*1000,"/1000)"),
                             paste0("Italy ("         ,pIT.2*1000,"/1000)"),
                             paste0("Spain ("         ,pSP.2*1000,"/1000)"),
                             paste0("Ireland ("       ,pIR.2*1000,"/1000)"),
                             paste0("Germany ("       ,pDE.2*1000,"/1000)"),
                             paste0("Canada ("        ,pCA.2*1000,"/1000)"),
                             paste0("Russia ("        ,pRU.2*1000,"/1000)"),
                             paste0("United Kingdom (",pUK.2*1000,"/1000)"))

# Calculate state DIs based on a country's selected rate
# UPDATE: make several values available . See https://bit.ly/2yMyjFX for current rates!
tests_ldi.us <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pUS.2)}))
tests_ldi.pr <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pPR.2)}))
tests_ldi.ch <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pCH.2)}))
tests_ldi.it <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pIT.2)}))
tests_ldi.sp <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pSP.2)}))
tests_ldi.ir <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pIR.2)}))
tests_ldi.de <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pDE.2)}))
tests_ldi.ca <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pCA.2)}))
tests_ldi.uk <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pUK.2)}))
tests_ldi.ru <- unlist(lapply(state_covid_testing$tests_per_1000, FUN=function(x){log(x/pRU.2)}))

# Write to data frame
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.us)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.pr)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.ch)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.it)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.sp)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.ir)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.de)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.ca)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.uk)
state_covid_testing <- data.frame(state_covid_testing, tests_ldi.ru)

state_covid_testing <- state_covid_testing[match(states$NAME, state_covid_testing$NAME),]

state_covid_testing <- state_covid_testing[1:51,]

state_covid_testing <- state_covid_testing %>% 
  mutate(tests_ldi.us = replace(tests_ldi.us, tests_ldi.us < -5, -5)) %>%
  mutate(tests_ldi.pr = replace(tests_ldi.pr, tests_ldi.pr < -5, -5)) %>%
  mutate(tests_ldi.ch = replace(tests_ldi.ch, tests_ldi.ch < -5, -5)) %>%
  mutate(tests_ldi.it = replace(tests_ldi.it, tests_ldi.it < -5, -5)) %>%
  mutate(tests_ldi.sp = replace(tests_ldi.sp, tests_ldi.sp < -5, -5)) %>%
  mutate(tests_ldi.ir = replace(tests_ldi.ir, tests_ldi.ir < -5, -5)) %>%
  mutate(tests_ldi.de = replace(tests_ldi.de, tests_ldi.de < -5, -5)) %>%
  mutate(tests_ldi.ca = replace(tests_ldi.ca, tests_ldi.ca < -5, -5)) %>%
  mutate(tests_ldi.ru = replace(tests_ldi.ca, tests_ldi.ru < -5, -5)) %>%
  mutate(tests_ldi.uk = replace(tests_ldi.uk, tests_ldi.uk < -5, -5)) 

states <- data.frame(states, "tests_per_1000"=state_covid_testing$tests_per_1000) # Append to states
states <- data.frame(states, "Population"=state_covid_testing$Population) # Append to states (reference)

states <- data.frame(states, "tests_ldi.us"=state_covid_testing$tests_ldi.us) # Append to states
states <- data.frame(states, "tests_ldi.pr"=state_covid_testing$tests_ldi.pr) # Append to states
states <- data.frame(states, "tests_ldi.ch"=state_covid_testing$tests_ldi.ch) # Append to states
states <- data.frame(states, "tests_ldi.it"=state_covid_testing$tests_ldi.it) # Append to states
states <- data.frame(states, "tests_ldi.sp"=state_covid_testing$tests_ldi.sp) # Append to states
states <- data.frame(states, "tests_ldi.ir"=state_covid_testing$tests_ldi.ir) # Append to states
states <- data.frame(states, "tests_ldi.de"=state_covid_testing$tests_ldi.de) # Append to states
states <- data.frame(states, "tests_ldi.ca"=state_covid_testing$tests_ldi.ca) # Append to states
states <- data.frame(states, "tests_ldi.uk"=state_covid_testing$tests_ldi.uk) # Append to states
states <- data.frame(states, "tests_ldi.ru"=state_covid_testing$tests_ldi.ru) # Append to states

## At-risk Adults fixing

# Calculate pUS
# All at-risk
pUS.3 <- as.numeric(at_risk_adults[which(at_risk_adults$NAME=="United States"),"p_at_risk_adults"])

at_risk_ldi <- unlist(lapply(at_risk_adults$p_at_risk_adults, FUN=function(x){log((x/(1-x))/(pUS.3/(1-pUS.3)))}))

at_risk_adults <- data.frame(at_risk_adults, at_risk_ldi)

#Older at-risk
pUS.4 <- as.numeric(at_risk_adults[which(at_risk_adults$NAME=="United States"),"p_older_at_risk_adults"])

older_at_risk_ldi <- unlist(lapply(at_risk_adults$p_older_at_risk_adults, FUN=function(x){log((x/(1-x))/(pUS.4/(1-pUS.4)))}))

at_risk_adults <- data.frame(at_risk_adults, older_at_risk_ldi)

# at_risk_adults <- at_risk_adults %>% 
#   mutate(at_risk_adults = replace(at_risk_adults, at_risk_adults < -5, -5)) %>%
#   mutate(older_at_risk_ldi = replace(older_at_risk_ldi, older_at_risk_ldi < -5, -5)) 

# RE-order to match states ordering
at_risk_adults <- at_risk_adults[match(states$NAME, at_risk_adults$NAME),]

at_risk_adults <- at_risk_adults[1:51,]

# Append the new columns to states
states <- data.frame(states, "at_risk_ldi"=at_risk_adults$at_risk_ldi) # Append to states

states <- data.frame(states, "older_at_risk_ldi"=at_risk_adults$older_at_risk_ldi) # Append to states

# Cardio mortality (NEW)
# UPDATED: 16 Apr (new source and math corrections)
pUS.5 <- as.numeric(cardio_deaths_2015[which(cardio_deaths_2015$NAME=="United States"),"p_Overall"])

#cardio_death_rate_ldi <- unlist(lapply(cardio_deaths_2017$cardio_deaths_p_100000, FUN=function(x){log((x/(1-x))/(pUS.5/(1-pUS.5)))}))
cardio_death_rate_ALL_ldi <- unlist(lapply(cardio_deaths_2015$p_Overall, FUN=function(x){-log(pUS.5/x)}))
cardio_death_rate_BNH_ldi <- unlist(lapply(cardio_deaths_2015$p_Black_Non_Hispanic, FUN=function(x){-log(pUS.5/x)}))

cardio_deaths_2015 <- data.frame(cardio_deaths_2015, cardio_death_rate_ALL_ldi)
cardio_deaths_2015 <- data.frame(cardio_deaths_2015, cardio_death_rate_BNH_ldi)

cardio_deaths_2015 <- cardio_deaths_2015 %>% 
  mutate(cardio_death_rate_ALL_ldi = replace(cardio_death_rate_ALL_ldi, cardio_death_rate_ALL_ldi < -5, -5)) %>%
  mutate(cardio_death_rate_ALL_ldi = replace(cardio_death_rate_BNH_ldi, cardio_death_rate_BNH_ldi < -5, -5)) 

# RE-order to match states ordering
cardio_deaths_2015 <- cardio_deaths_2015[match(states$NAME, cardio_deaths_2015$NAME),]

cardio_deaths_2015 <- cardio_deaths_2015[1:51,]

# Append the new Cardio columns to states
states <- data.frame(states, "cardio_deaths_p_Overall"=cardio_deaths_2015$p_Overall) # Append to states
states <- data.frame(states, "cardio_deaths_p_Black_Non_Hispanic"=cardio_deaths_2015$p_Black_Non_Hispanic) # Append to states
states <- data.frame(states, "cardio_death_rate_ALL_ldi"=cardio_deaths_2015$cardio_death_rate_ALL_ldi) # Append to states
states <- data.frame(states, "cardio_death_rate_BNH_ldi"=cardio_deaths_2015$cardio_death_rate_BNH_ldi) # Append to states

# COVID-19 Deaths per COVID-19 Case
pUS.6.cases <- as.numeric(covid_data_states[which(covid_data_states$NAME=="United States"),"calc_case_rate"])
pUS.6.deaths <- as.numeric(covid_data_states[which(covid_data_states$NAME=="United States"),"p_death_rate"])

#death_rate_ldi <- unlist(lapply(covid_data_states$p_death_rate, FUN=function(x){log((x/(1-x))/(pUS.6/(1-pUS.6)))}))
case_rate_ldi <- unlist(lapply(covid_data_states$calc_case_rate, FUN=function(x){-log(pUS.6.cases/x)}))
death_rate_ldi <- unlist(lapply(covid_data_states$p_death_rate, FUN=function(x){-log(pUS.6.deaths/x)}))

covid_data_states <- data.frame(covid_data_states, death_rate_ldi)
covid_data_states <- data.frame(covid_data_states, case_rate_ldi)

covid_data_states <- covid_data_states %>% 
  mutate(death_rate_ldi = replace(death_rate_ldi, death_rate_ldi < -5, -5)) %>%
  mutate(case_rate_ldi = replace(case_rate_ldi, case_rate_ldi < -5, -5)) 

# RE-order to match states ordering
covid_data_states <- covid_data_states[match(states$NAME, covid_data_states$NAME),]

# Append the new column to states
covid_data_states <- covid_data_states[1:51,]

states <- data.frame(states, "death_rate_ldi"=covid_data_states$death_rate_ldi) # Append to states
states <- data.frame(states, "covid_death_rate"=covid_data_states$p_death_rate) # Append to states

##### US Racial Disparity
# DI's based on covid_racial_data_states.wide
# Percent cases / percent population, per-state

# Unweighted population pct
# covid_racial_data_states.wide$death_rate_ldi_nhw <- log(covid_racial_data_states.wide$nhw_deaths_pct / covid_racial_data_states.wide$nhw_un_pop_pct)
# covid_racial_data_states.wide$death_rate_ldi_nhbaa <- log(covid_racial_data_states.wide$nhbaa_deaths_pct / covid_racial_data_states.wide$nhbaa_un_pop_pct)
# covid_racial_data_states.wide$death_rate_ldi_nhaian <- log(covid_racial_data_states.wide$nhaian_deaths_pct / covid_racial_data_states.wide$nhaian_un_pop_pct)
# covid_racial_data_states.wide$death_rate_ldi_nhapi <- log(covid_racial_data_states.wide$nhapi_deaths_pct / covid_racial_data_states.wide$nhapi_un_pop_pct)
# covid_racial_data_states.wide$death_rate_ldi_hlt <- log(covid_racial_data_states.wide$hlt_deaths_pct / covid_racial_data_states.wide$hlt_un_pop_pct)
# covid_racial_data_states.wide$death_rate_ldi_other <- log(covid_racial_data_states.wide$other_deaths_pct / covid_racial_data_states.wide$other_un_pop_pct)

# Weighted population percentage
covid_racial_data_states.wide$death_rate_ldi_nhw <- log(covid_racial_data_states.wide$nhw_deaths_pct / covid_racial_data_states.wide$nhw_wd_pop_pct)
covid_racial_data_states.wide$death_rate_ldi_nhbaa <- log(covid_racial_data_states.wide$nhbaa_deaths_pct / covid_racial_data_states.wide$nhbaa_wd_pop_pct)
covid_racial_data_states.wide$death_rate_ldi_nhaian <- log(covid_racial_data_states.wide$nhaian_deaths_pct / covid_racial_data_states.wide$nhaian_wd_pop_pct)
covid_racial_data_states.wide$death_rate_ldi_nhapi <- log(covid_racial_data_states.wide$nhapi_deaths_pct / covid_racial_data_states.wide$nhapi_wd_pop_pct)
covid_racial_data_states.wide$death_rate_ldi_hlt <- log(covid_racial_data_states.wide$hlt_deaths_pct / covid_racial_data_states.wide$hlt_wd_pop_pct)
covid_racial_data_states.wide$death_rate_ldi_other <- log(covid_racial_data_states.wide$other_deaths_pct / covid_racial_data_states.wide$other_wd_pop_pct)

# colnames(covid_racial_data_states.wide) <- covid_racial_data_states.wide %>%
#   rename(NAME = state)

# Join our new columns in by NAME
# NOTE: This is cleaner than elsewhere and imports ALL of the race/ethnicity data
states <- dplyr::left_join(states, covid_racial_data_states.wide[,-1], by = c("NAME" = "NAME"))


#####
# NY specific calculations: Death Rates
pNY.6.deaths <- sum(NY.data$deaths)/sum(NY.data$Population)
pNY.6.cases <- sum(NY.data$cases)/sum(NY.data$Population)
pNY.6.diabetes <- as.numeric(NY_counties_diabetes[1,"pct_Adults_with_Diabetes"])

NY.data <- transform(NY.data, death_rate = deaths/Population)
#NY.data <- transform(NY.data, case_rate = cases/Population) # We already do this

NY.data <- NY.data %>% 
  filter(!County == c("Out of NY","Unassigned"))

# NY.data$death_rate_ldi <- unlist(lapply(NY.data$death_rate, FUN=function(x){-log(pNY.6.deaths/x)}))  # vs NY rate
NY.data$death_rate_ldi <- unlist(lapply(NY.data$death_rate, FUN=function(x){-log(pUS.6.deaths/x)})) # vs UR rate

NY.data$case_rate_ldi <- unlist(lapply(NY.data$case_rate, FUN=function(x){-log(pUS.6.cases/x)}))

# Need this for NY Diabetes...
pUS.7.diabetes <- as.numeric(diabetes_data_states[which(diabetes_data_states$State=="United States"),"pct_Adults_with_Diabetes"])

NY.data$diabetes_ldi <- unlist(lapply(NY.data$pct_Adults_with_Diabetes, FUN=function(x){-log(pUS.7.diabetes/x)}))

# Clean up the ranges
NY.data <- NY.data %>% 
  mutate(death_rate_ldi = replace(death_rate_ldi, death_rate_ldi < -5, -5)) %>%
  mutate(case_rate_ldi = replace(case_rate_ldi, case_rate_ldi < -5, -5)) %>%
  mutate(diabetes_ldi = replace(diabetes_ldi, diabetes_ldi < -5, -5)) 

### NEW: US Diabetes Rates
#pUS.7 <- as.numeric(diabetes_data_states[which(diabetes_data_states$State=="United States"),"pct_Adults_with_Diabetes"])

diabetes_rate_ldi <- unlist(lapply(diabetes_data_states$pct_Adults_with_Diabetes, FUN=function(x){-log(pUS.7.diabetes/x)}))

diabetes_data_states <- data.frame(diabetes_data_states, diabetes_rate_ldi)

diabetes_data_states <- diabetes_data_states %>% 
  mutate(diabetes_rate_ldi = replace(diabetes_rate_ldi, diabetes_rate_ldi < -5, -5)) 

# RE-order to match states ordering
diabetes_data_states <- diabetes_data_states[match(states$NAME, diabetes_data_states$State),]

# Append the new column to states
diabetes_data_states <- diabetes_data_states[1:51,]

states <- data.frame(states, "diabetes_rate_ldi"=diabetes_data_states$diabetes_rate_ldi) # Append to states
states <- data.frame(states, "pct_Adults_with_Diabetes"=diabetes_data_states$pct_Adults_with_Diabetes) # Append to states


## Needed for NY TS plot

# Pre-filter to remove small numbers
covid_NY_TS_counties_long <- covid_NY_TS_counties_long %>% 
  filter(cases >= 2) %>%
  filter(County != "Unassigned")

covid_NY_TS_counties_long.cases <- covid_NY_TS_counties_long.cases %>% 
  filter(cases >= 2) %>%
  filter(County != "Unassigned")

covid_NY_TS_plot <- covid_NY_TS_counties_long %>%
  group_by(date)

covid_NY_TS_counties_long <- dplyr::inner_join(covid_NY_TS_counties_long, as.data.frame(NY_counties_regions), by = c("County" = "County"))

# NOTE: The new TS plot is using this special version
covid_NY_TS_counties_long.cases <- dplyr::inner_join(covid_NY_TS_counties_long.cases, as.data.frame(NY_counties_regions), by = c("County" = "County"))

# covid_NY_TS_plot.cases <- covid_NY_TS_counties_long.cases %>%
#   group_by(date)
# Do it this way to be safe:
covid_NY_TS_plot.cases <- read_csv("data/csv/time_series/covid_NY_TS_plot.cases.csv")
