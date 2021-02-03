#### -------------------------------------
### Run for multiple sets and compare
#### -------------------------------------

f_cluster_map <- function(cluster_df) {
  mapdat <- f_addVar(admin2_sp.f, cluster_df)
  pmap <- ggplot(warnings = FALSE) +
    geom_polygon(
      data = mapdat,
      aes(x = long, y = lat, group = group, fill = cluster_nr)
    ) +
    geom_polygon(
      data = admin2_sp.f,
      aes(x = long, y = lat, group = group), col = "lightgrey", fill = NA, size = 0.5,
    ) +
    #  geom_polygon(
    #    data = admin1_sp.f,
    #    aes(x = long, y = lat, group = group), col = "black", fill = NA,size=1,
    #  ) +
    geom_polygon(
      data = wat_sp.f,
      aes(x = long, y = lat, group = group), col = "#2c7fb8", fill = "#41b6c4", size = 0.5
    ) +
    theme_map() +
    scale_fill_manual(values = getPalette) +
    labs(fill = "Cluster")

  return(pmap)
}

f_cluster_and_plot <- function(df, ncluster, FUNcluster, exportPDF = TRUE) {
  getPalette <- colorRampPalette(brewer.pal(8, "Dark2"))(ncluster)

  outList <- list()
  clus <- eclust(df, FUNcluster, k = ncluster, graph = FALSE)

  cluster_df <- as.data.frame(cbind(rownames(df), clus$cluster))
  colnames(cluster_df) <- c("NAME_2", "cluster_nr")
  cluster_df <- cluster_df %>% f_addVar(cluster_df)

  ## Export maps
  if (exportPDF) {

    ### Plots
    p_clusplot <- fviz_cluster(clus, ggtheme = theme_minimal_grid(), palette = getPalette, legend = "None") # scatter plot

    ### Map
    p_clus <- f_cluster_map(cluster_df = cluster_df)

    pdf(file.path("fig", paste0(FUNcluster, ".pdf")))
    print(p_clusplot)
    print(p_clus)
    dev.off()
  }

  cluster_df$cluster_nr <- factor(cluster_df$cluster_nr, levels = seq(1, ncluster, 1), labels = seq(1, ncluster, 1))
  return(cluster_df)
}


#### -------------------------------------
### Run code
#### -------------------------------------
ncluster <- 10
getPalette <- colorRampPalette(brewer.pal(8, "Dark2"))(ncluster)

set1_scaled <- mydata_scaled[, all_vars]
set2_scaled <- mydata_scaled[, pfpr_vars]
set3_scaled <- mydata_scaled[, climate_vars]
set_labels <- c("set1", "set2", "set3")

i <- 0
for (dat in list(set1_scaled, set2_scaled, set3_scaled)) {
  i <- i + 1
  set_label <- set_labels[i]
  print(dim(dat))


  df_diana <- f_cluster_and_plot(dat, ncluster, "diana") %>% mutate(cluster_method = "diana")
  df_agnes <- f_cluster_and_plot(dat, ncluster, "agnes") %>% mutate(cluster_method = "agnes")
  df_kmeans <- f_cluster_and_plot(dat, ncluster, "kmeans") %>% mutate(cluster_method = "kmeans")


  p1 <- f_cluster_map(df_diana) + labs(title = "diana")
  p2 <- f_cluster_map(df_agnes) + labs(title = "agnes")
  p3 <- f_cluster_map(df_kmeans) + labs(title = "kmeans")

  p_clus <- plot_grid(p1, p2, p3, nrow = 1)

  if (SAVE) ggsave(paste0(set_label, "_P_clus_method_comparison.png"), plot = p_clus, path = "fig", width = 20, height = 6, device = "png")
}

###### Validate cluster
# Stability measures
mydata_scaled <- mydata_scaled %>%
  as.data.frame() %>%
  dplyr::select(-c("IRScoverage.2000", "IRScoverage.2005"))

stab <- clValid(mydata_scaled,
  nClust = 1:20,
  clMethods = c("diana", "agnes", "kmeans"),
  validation = "stability"
)

optimalScores(stab)
summary(stab)
plot(stab)
