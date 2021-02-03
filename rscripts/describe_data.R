


admin2_sp.f <- as.MAPshp(admin2_sp)

raster_files <- c("tza_pd_2015_1km.tif", "alt.tif", "temp.tif", "bio4.tif", "bio12.tif", "map_pfpr_2015.tif", "map_itn_2015.tif", "map_irs_2015.tif", "map_effAntimalarial_2015.tif")
raster_file_labels <- c("Population density\n(per km2,log scale)", "Altitude", "Mean\nTemperature", "Temperature\nSeasonality", "Precipitation", "PfPR 2015", "ITN 2015", "IRS 2015", "effective\nAntimalarial")
raster_file_logs <- c(TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE)
raster_file_colors <- c("YlOrRd", "YlOrBr", "OrRd", "Spectral", "Blues", "Spectral", "YlGnBu", "YlGnBu", "YlGnBu")
raster_file_colorsdirs <- c(1, 1, 1, 1, 1, -1, 1, 1, 1)

# revert prec, ITN, pop, TSI, Temp, Alt,
# getPalette <- colorRampPalette(brewer.pal(8, "Dark2"))(ncluster)


map_list <- list()
for (i in c(1:length(raster_files))) {
  raster_file_log <- raster_file_logs[i]
  raster_file_label <- raster_file_labels[i]
  raster_file_color <- raster_file_colors[i]
  raster_file_colorsdir <- raster_file_colorsdirs[i]

  raster.f <- raster(file.path("raster", raster_files[i]))
  raster.f <- as.MAPraster(raster.f)
  if (raster_file_log) raster.f$z <- log(raster.f$z)

  map_list[[length(map_list) + 1]] <- ggplot(warnings = FALSE) +
    geom_raster(
      data = raster.f,
      aes(x = x, y = y, fill = z)
    ) +
    geom_polygon(
      data = admin2_sp.f,
      aes(x = long, y = lat, group = group), col = "black", fill = NA
    ) +
    geom_polygon(
      data = wat_sp.f,
      aes(x = long, y = lat, group = group), col = "grey", fill = "lightgrey", size = 0.5
    ) +
    theme_map() +
    scale_fill_distiller(palette = raster_file_color, direction = 1) +
    # scale_fill_gradientn(colours = brewer.pal(3, raster_file_color)) +
    labs(fill = raster_file_label, color = raster_file_label)

  if (SAVE) {
    ggsave(paste0(gsub("\n", "", raster_file_label), "_map.png"), plot = map_list[[length(map_list)]], path = "fig", width = 10, height = 8, device = "png")
  }
}

#### Add A B C D etc
pplot <- do.call(grid.arrange, map_list)
if (SAVE) {
  ggsave(paste0("combined_rasters_map.png"), plot = pplot, path = "fig", width = 16, height = 12, device = "png")
  ggsave(paste0("combined_rasters_map.pdf"), plot = pplot, path = "fig", width = 16, height = 12, device = "pdf")
}
