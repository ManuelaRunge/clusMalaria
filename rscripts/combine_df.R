
library(tidyverse)


load(file.path("rdata", "pop_df.rdata"))
load(file.path("rdata", "map_df.rdata"))
load(file.path("rdata", "dhs_df.rdata"))
load(file.path("rdata", "wordlclim_df.rdata"))


#### Build dataframe
combined_df <- admin2_df %>%
  f_addVar(pop_df) %>%
  f_addVar(climate_df) %>%
  # f_addVar(dhs_df) %>%
  f_addVar(map_df)

#-microscopy_2017
combined_df <- combined_df %>%
  dplyr::select(-IRScoverage.2000, -IRScoverage.2005)

#### Remove duplicates
dups <- duplicated(combined_df$NAME_2)
combined_df$NAME_2[dups]
combined_df <- combined_df[!duplicated(combined_df$NAME_2), ]

#### Remove Lakes
combined_df <- combined_df[!(grepl("Lake ", combined_df$NAME_2)), ]


sort(unique(combined_df$NAME_2))

dat <- combined_df
if (SAVE) save(combined_df, file = file.path("rdata", "combined_df.rdata"))

#### Secondary variables
### Change in pfpr
quantile(combined_df$pfpr_change)
combined_df$pfpr_change <- (combined_df$PfPR.2000 - combined_df$PfPR.2015) / combined_df$PfPR.2000
combined_df$pfpr_change_fct <- cut(combined_df$pfpr_change, c(-1, 0, 0.5, 0.9, 1), labels = c(1:4))
combined_df$pfpr_change_grp <- cut(combined_df$pfpr_change, c(-1, 0, 0.5, 0.9, 1))


df_long <- combined_df %>%
  dplyr::select(
    NAME_1, NAME_2, pfpr_change_fct,
    ITN.2000, ITN.2005, ITN.2010, ITN.2015,
    PfPR.2000, PfPR.2005, PfPR.2010, PfPR.2015
  ) %>%
  pivot_longer(cols = -c(NAME_1, NAME_2, pfpr_change_fct)) %>%
  separate(name, into = c("indicator", "year"), sep = "[.]")
colnames(df_long) <- c("NAME_1", "NAME_2", "pfpr_change_fct", "indicator", "year", "value")

pplot <- ggplot(data = df_long) +
  geom_point(aes(x = year, y = value, col = indicator, group = NAME_2)) +
  geom_line(aes(x = year, y = value, col = indicator, group = interaction(indicator, NAME_2))) +
  facet_wrap(~NAME_1) +
  theme_minimal_grid() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2")
pplot
if (SAVE) ggsave("p_timeline_map1.png", plot = pplot, path = "fig", width = 12, height = 6, device = "png")


pplot <- ggplot(data = df_long) +
  geom_point(aes(x = year, y = value, col = indicator, group = NAME_2)) +
  geom_line(aes(x = year, y = value, col = indicator, group = interaction(indicator, NAME_2))) +
  facet_wrap(~pfpr_change_fct) +
  theme_minimal_grid() +
  scale_color_brewer(palette = "Dark2") +
  scale_fill_brewer(palette = "Dark2")
pplot
if (SAVE) ggsave("p_timeline_map2.png", plot = pplot, path = "fig", width = 12, height = 6, device = "png")


if (SAVE) save(combined_df, file = file.path("rdata", "combined_df_ext.rdata"))


string_variables <- c("GID_0", "NAME_0", "NAME_1", "NAME_2")
variables_to_exclude <- c(string_variables, "cent_long", "cent_lat")
mydata_scaled <- combined_df %>% dplyr::select(-variables_to_exclude)
mydata_scaled <- data.matrix(mydata_scaled)
rownames(mydata_scaled) <- dat$NAME_2
### Scale , normalize variables
mydata_scaled <- scale((na.omit(mydata_scaled)))


if (SAVE) save(mydata_scaled, file = file.path("rdata", "combined_df_scaled.rdata"))
