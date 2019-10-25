#### Code to prepare data for modeling ####

# loading packages
library(modleR)
library(raster)
library(data.table)
#library(parallel)

#### 1. preparing data ####
# 1.1. loading occ data ####

# species names
spp_names <- list.files("./data/epiphyte_occ/")

# listing .csv files
occ_files <- list()
for (i in 1:length(spp_names)) {
  occ_files[[i]] <- list.files(path = paste0("./data/epiphyte_occ/", spp_names[i]),
                               pattern = '.*0.csv',
                               full.names = TRUE)
}

# experiment names
exp_names <- unlist(
  strsplit(sapply(strsplit(unlist(occ_files), "/"), function(x) x[5]),
           ".csv"))

# reading csv files
occ_data <- lapply(unlist(occ_files),
                   fread, sep = ',')

occ_data[[1]]

# checking N of occurrences
sapply(occ_data, nrow)

sp_check <- read.csv("results/sp_check.csv", header = FALSE)$V1

sapply(occ_data, nrow)[sp_check]

# 1.2. loading environmental data ####
env_files <- list.files(path = paste0("./data/pca_env/"),
                        pattern = '.*.tif',
                        full.names = TRUE)

env_low <- stack(env_files[1:4])

#### 2. Running setup in parallel ####
# setup_df <- list()

# n_cl <- detectCores()
# cl <- makeCluster(n_cl - 1,
#                   type = "SOCK",
#                   outfile = "data/log/01_setup.log")

teste <- list()

i = 1

start_time <- Sys.time()
for (i in 1:length(exp_names)) {
teste[[i]] <- setup_sdmdata(species_name = exp_names[i],
                            occurrences = occ_data[[i]],
                            predictors = env_low,
                            models_dir = "models_low",
                            lon = "lon",
                            lat = "lat",
                            buffer_type = "mean",
                            partition_type = "bootstrap",
                            boot_proportion = 0.8,
                            boot_n = 4,
                            clean_nas = TRUE,
                            clean_dupl = TRUE,
                            clean_uni = TRUE
                            #n_back = 100*nrow(occ_data[[i]])
                            )

}
end_time <- Sys.time()

end_time - start_time
#
# clusterMap(cl,
#            fun = setup_sdmdata,
#            species_name = exp_names[7],
#            occurrences = occ_data[1:7],
#            MoreArgs = list(predictors = env_low,
#                            models_dir = "models_low",
#                            buffer_type = "mean"))
#
# stopCluster()


