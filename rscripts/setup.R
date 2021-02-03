#### ---------------------------------------------------
### SETUP
#### ---------------------------------------------------

#### -----------------
### Packages
library(tidyverse)

library(malariaAtlas)
library(rdhs)

library(raster)
library(exactextractr)
library(cluster)
library(factoextra)

library(gridExtra)
library(cowplot)
library(RColorBrewer)

#### -----------------
### Functions
source("functions.R")

#### -----------------
### Country specific objects and configurations
proj_str <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
admin0_sp <- getData("GADM", country = "TZA", level = 0)
admin1_sp <- getData("GADM", country = "TZA", level = 1)
admin2_sp <- getData("GADM", country = "TZA", level = 2)

admin2_sp.f <- as.MAPshp(admin2_sp)
admin2_sp.f$NAME_2 <- admin2_sp.f$id
admin2_df <- f_get_admin_df(admin2_sp)


#### Specific for TZA, TODO
wat_sp <- shapefile(file.path("shp", "TZA_wat", "TZA_water_areas_dcw.shp"))
wat_sp.f <- as.MAPshp(wat_sp)

TZA_PR <- getPR(country = "Tanzania", species = "Pf")
colnames(TZA_PR)

climate_vars <- c("mean_temp", "mean_TS", "mean_prec", "mean_alt", "PfTSI")
pfpr_vars <- c("PfPR.2000", "PfPR.2005", "PfPR.2010", "PfPR.2015")
interv_vars <- c(
  "IRScoverage.2010", "ITN.2005", "ITN.2010", "ITN.2015",
  "effAntimalarial.2010", "effAntimalarial.2010", "effAntimalarial.2015"
)
malaria_vars <- c(pfpr_vars, interv_vars)
pop_vars <- c("pop_density", "walkTimeHF", "area_sqkm")
all_vars <- c(climate_vars, malaria_vars, pop_vars)
