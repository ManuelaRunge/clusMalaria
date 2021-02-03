#### ----------------------------------------------------------
### Get and extract means from Malaria Atlas Project Rasters
#### ----------------------------------------------------------
#require(tidyverse)
#require(malariaAtlas)
#require(raster)


years <- seq(2000, 2015, 5)
map_vars_time_varying <- c(
  "Plasmodium falciparum PR2-10",
  "Indoor Residual Spraying (IRS) coverage version 2020",
  "Effective treatment with an Antimalarial drug version 2020",
  "Insecticide treated bednet (ITN) use version 2020"
)

map_vars_static <- c(
  "Plasmodium falciparum Temperature Suitability",
  "Walking-only travel time to healthcare map without access to motorized transport"
)


map_rasters <- list()
for (map_var in map_vars_time_varying) {
  for (year in years) {
    map_rasters[[length(map_rasters) + 1]] <- getRaster(surface = map_var, shp = admin0_sp, year = year)
  }
}
for (map_var in map_vars_static) {
  map_rasters[[length(map_rasters) + 1]] <- getRaster(surface = map_var, shp = admin0_sp)
}

i <- 0
toresample <- c()
for (map_raster in map_rasters) {
  i <- i + 1
  res_val <- res(map_raster)[1]
  if (res_val < 0.04) {
    toresample <- c(toresample, i)
  }
}


for (i in toresample) {
  if (extent(map_rasters[[1]]) == extent(map_rasters[[i]])) {
    map_rasters[[i]] <- raster::resample(map_rasters[[i]], popdens_raster, method = "bilinear")
  } else {
    print("Raster files do not have same extent")
    extent(map_rasters[[i]]) <- extent(map_rasters[[1]])
    map_rasters[[i]] <- raster::resample(map_rasters[[i]], map_rasters[[1]], method = "bilinear")
  }
}


##### Load and resample population raster
# pop_raster <- raster(file.path("raster", "tza_ppp_2020_constrained.tif"))
## replace NA with 0
# beginCluster()
# pop_raster[is.na(pop_raster[])] <- 0
# endCluster()
#
# beginCluster()
#  if (extent(map_rasters[[1]]) == extent(pop_raster)) {
#    pop_raster_res <- raster::resample(pop_raster, popdens_raster, method = "bilinear", na.rm=TRUE)
#  } else {
#    print("Raster files do not have same extent")
#    extent(pop_raster) <- extent(map_rasters[[1]])
#    pop_raster_res <- raster::resample(pop_raster, map_rasters[[1]], method = "bilinear", na.rm=TRUE)
#  }
# endCluster()


beginCluster()
map_values <- list()
for (map_raster in map_rasters) {
  #map_values[[length(map_values) + 1]] <- exact_extract(map_raster, admin2_sp, fun = weighted.mean, values = pop_raster_res, na.rm = TRUE)
  map_values[[length(map_values) + 1]] <- raster::extract(map_raster, admin2_sp,  fun = mean, na.rm = TRUE)
}
endCluster()

rnames <- c()
for (map_raster in map_rasters) {
  rnames <- c(rnames, names(map_raster))
}
rnames <- gsub("Indoor.Residual.Spraying..IRS..", "IRS", rnames)
rnames <- gsub("Effective.treatment.with.an.Antimalarial.drug", "effAntimalarial", rnames)
rnames <- gsub("Insecticide.treated.bednet..ITN..use", "ITN", rnames)
rnames <- gsub("Plasmodium.falciparum.Temperature.Suitability", "PfTSI", rnames)
rnames <- gsub("Plasmodium.falciparum.PR2.10", "PfPR", rnames)
rnames <- gsub("Walking.only.travel.time.to.healthcare.map.without.access.to.motorized.transport", "walkTimeHF", rnames)
rnames <- gsub("version.2020.", "", rnames)


map_df <- map_values %>%
  bind_cols() %>%
  as.data.frame()
colnames(map_df) <- rnames
map_df[, "NAME_0"] <- admin2_sp$NAME_0
map_df[, "NAME_1"] <- admin2_sp$NAME_1
map_df[, "NAME_2"] <- admin2_sp$NAME_2

save(map_df, file = file.path("rdata", "map_df.rdata"))
