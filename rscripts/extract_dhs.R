#### ----------------------------------------------------------
### Get DHS survey data
#### ----------------------------------------------------------

# require(tidyverse)
# require(rdhs)

dhs_df <- dhs_data(tagIds = 36, countryIds = c("TZ"), breakdown = "subnational", surveyYearStart = 2010)
levels_to_keep <- grep("[..]", dhs_df$CharacteristicLabel)
dhs_df <- dhs_df[levels_to_keep, ]
dhs_df$NAME_1 <- gsub("[..]", "", dhs_df$CharacteristicLabel)

# table(dhs_df$SurveyId  , dhs_df$Indicator )
dhs_df <- dhs_df %>%
  filter(Indicator %in% c("Malaria prevalence according to microscopy", "Malaria prevalence according to RDT")) %>%
  dplyr::select(SurveyYear, Indicator, Value, NAME_1) %>%
  mutate(Indicator = gsub("Malaria prevalence according to ", "", Indicator)) %>%
  pivot_wider(names_from = "Indicator", values_from = "Value") %>%
  pivot_wider(names_from = "SurveyYear", values_from = c("RDT", "microscopy"))

if (SAVE) save(dhs_df, file = file.path("rdata", "dhs_df.rdata"))
