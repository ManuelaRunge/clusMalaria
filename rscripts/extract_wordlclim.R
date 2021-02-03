#### ----------------------------------------------------------
### Get and extract means from WorldClim
#### ----------------------------------------------------------

# climate_vars <- c("tmean", "prec", "alt")
climate_vars <- c("bio1", "bio4", "bio12", "alt")
climate_vars_labels <- c("temp", "TS", "prec", "alt")


bioraster <- getData("worldclim", var = "bio", res = 2.5)
for (climate_var in climate_vars) {
  if (sum(grep("bio", climate_var)) > 0) {
    climate_raster_i <- bioraster[[climate_var]]
  } else {
    alt <- getData("worldclim", var = climate_var, res = 2.5)
  }
  climate_raster_i <- crop(x = climate_raster_i, y = extent(admin0_sp))
  climate_raster_i <- mask(x = climate_raster_i, mask = admin0_sp)
  climate_raster_i <- crop(x = climate_raster_i, y = extent(admin0_sp))
  climate_rasters[[length(climate_rasters) + 1]] <- climate_raster_i
}

### Extract area weighted mean
climate_df <- admin2_sp %>%
  as.data.frame() %>%
  dplyr::select(NAME_0, NAME_1, NAME_2)

beginCluster()
for (i in c(1:length(climate_rasters))) {
  if (SAVE) rf <- writeRaster(climate_rasters[[i]], filename = file.path("raster", paste0(climate_vars_labels[i], ".tif")), format = "GTiff", overwrite = TRUE)
  climate_df[, paste0("mean_", climate_vars_labels[i])] <- raster::extract(climate_rasters[[i]], admin2_sp, fun = mean, na.rm = TRUE, weights = TRUE)
}
endCluster()


if (SAVE) save(climate_df, file = file.path("rdata", "wordlclim_df.rdata"))
