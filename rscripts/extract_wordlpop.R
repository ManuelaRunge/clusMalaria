
require(raster)
require(data.table)

popdens_raster <- raster(file.path("raster", "tza_pd_2015_1km.tif"))
beginCluster()
popdens_values <- raster::extract(popdens_raster, admin2_sp, fun = mean, na.rm = TRUE)
endCluster()
popdens_df <- popdens_values %>% as.data.frame()
colnames(pop_df) <- "pop_density"
popdens_df[, "NAME_0"] <- admin2_sp$NAME_0
popdens_df[, "NAME_1"] <- admin2_sp$NAME_1
popdens_df[, "NAME_2"] <- admin2_sp$NAME_2


# pop_raster <- raster(file.path("raster", "tza_ppp_2020_constrained.tif"))
# ## Check same extent
# if (extent(popdens_raster) == extent(pop_raster)) {
#   pop_raster_res <- raster::resample(pop_raster, popdens_raster, method = "bilinear")
# } else {
#   print("Raster files do not have same extent")
# }
# 
# beginCluster()
# pop_values <- raster::extract(pop_raster_res, admin2_sp, fun = sum, na.rm = TRUE)
# endCluster()
# 
# pop_values <- round(pop_values,0)
# popcount_df <- pop_values %>% as.data.frame()
# colnames(popcount_df) <- "pop_count"
# popcount_df[, "NAME_0"] <- admin2_sp$NAME_0
# popcount_df[, "NAME_1"] <- admin2_sp$NAME_1
# popcount_df[, "NAME_2"] <- admin2_sp$NAME_2
# tapply(popcount_df$pop_count, popcount_df$NAME_2, summary)
# sum(popcount_df$pop_count)  ## 58.01 million (2019)
# pop_df <- f_addVar(popdens_df, popcount_df)

## Check density times area gives count
pop_df <- f_addVar(popdens_df, f_get_admin_df(admin2_sp)) %>% 
               mutate(pop_count = round(pop_density*area_sqkm,0) ) 
sum(pop_df$pop_count,na.rm=TRUE) ##  51.48 million (2015)
save(pop_df, file = file.path("rdata", "pop_df.rdata"))


#### CREATE MAPs
popdens_raster.f <- as.MAPraster(popdens_raster)

p_pop <- ggplot(warnings = FALSE) +
  geom_raster(
    data = popdens_raster.f,
    aes(x = x, y = y, fill = log(z))
  ) +
  geom_polygon(
    data = admin2_sp.f,
    aes(x = long, y =lat,group=group),col='black',fill=NA
  ) +
  theme_map() +
  scale_fill_viridis_c()+
  labs(fill='Population per km2\n(log scale)')
print(p_pop)

if(SAVE)ggsave("population_density_map.png", plot = p_pop, path = "maps", width = 10, height = 8, device = "png")


# water_bodies.f <- as.MAPshp(water_bodies)
# p_wat <-  ggplot(warnings = FALSE) +
#   geom_polygon(
#     data = water_bodies.f,
#     aes(x = long, y =lat,group=group, fill = as.factor(F_CODE_DES))
#   )  + theme_map()


