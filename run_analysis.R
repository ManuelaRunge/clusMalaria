### ---------------------------------------
### ---------------------------------------

### Settings
createDataframe <- TRUE 
runAnalysis <- TRUE 
SAVE <- TRUE

Country <- "Tanzania"

### Load packages, functions and custom objects
source("rscripts/setup.R")

### Create folder structure
if (!dir.exists("dat")) dir.create("dat")
if (!dir.exists("shp")) dir.create("shp")
if (!dir.exists("fig")) dir.create("fig")
if (!dir.exists("rasters")) dir.create("rasters")


### Run scripts
if (createDataframe) {
  source(file.path("rscripts", "extract_wordlpop.R"))
  source(file.path("rscripts", "extract_wordlclim.R"))
  source(file.path("rscripts", "extract_map.R"))
  source(file.path("rscripts", "extract_dhs.R"))
  source(file.path("rscripts", "combine_df.R"))
}
if (runAnalysis) {
  load(file = file.path("rdata", "combined_df.rdata"))
  load(file = file.path("rdata", "combined_df_scaled.rdata"))
  source(file.path("rscripts", "correlations.R"))
  source(file.path("rscripts", "cluster_analysis.R"))
}
