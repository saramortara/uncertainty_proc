#### Code to build models ####

library(modleR)
library(parallel)
library(rgdal)
library(raster)

# loading objects
my_dir <- 'models_low/'

exp_names <- list.files(my_dir)

AF <- readOGR("data/MA/Atlantic_MMA_miltinho_LEI_WWF_INTERNATIONAL_albers_sad69_LATLONG_WGS84.shp")

env_files <- list.files(path = paste0("./data/pca_env/"),
                        pattern = '.*.tif',
                        full.names = TRUE)
env_low <- stack(env_files[1:4])


# 1. creating objects for custerMap ####
#sp_count <- 1:length(exp_names)
#excluir <- 209:216
#sp_count <- !1:length(exp_names) %in% excluir
sp_count <- read.csv('results/sp_check.csv', header = FALSE)$V1
length(sp_count)

## algorithms
#algos <- c("svmk", "rf", "maxent", "glm", "brt") #"bioclim"
algos <- c("brt")
algo_rep <- rep(algos, length(sp_count))
length(algo_rep)

## species
sp_rep <- rep(exp_names[sp_count], times = length(algos))
length(sp_rep)

# running clusterMap ####
# teste <- do_any(species_name = exp_names[211],
#                 predictors = env_low,
#                 models_dir = my_dir,
#                 mask = AF,
#                 write_png = TRUE)


do_all <- function(sp, algos, ...){
  modleR::do_any(species_name = sp,
                 algo = algos,
                 equalize = TRUE,
                 ...)
}

n_cl <- detectCores()
cl <- makeCluster(n_cl - 1,
                   type = "SOCK",
                   outfile = "data/log/02_do_any_brt.log")
# my_dir <- 'models_low'
# sp_rep <- exp_names[i]
# algo_rep <- 'brt'

ini_time <- Sys.time()
out_low <- clusterMap(cl,
                      fun = do_all,
                      sp = sp_rep,
                      algos = algo_rep,
                      MoreArgs = list(predictors = env_low,
                                      #lon = "lon", lat = "lat",
                                      models_dir = my_dir,
                                      mask = AF,
                                      write_png = TRUE))
final_time <- Sys.time()

(delta_time <- final_time - ini_time)

stopCluster(cl)

##########################################
### test w/ brt ##########################
##########################################
#  bag.fraction = 0.5 instead of 0.75

source('R/do_brt.R')

n_cl <- detectCores()
cl <- makeCluster(n_cl - 1,
                  type = "SOCK",
                  outfile = "data/log/02_do_any_brt.log")

ini_time <- Sys.time()
out_low <- clusterMap(cl,
                      fun = do_brt,
                      species_name = sp_rep,
                      algo = algo_rep,
                      MoreArgs = list(predictors = env_low,
                                      #lon = "lon", lat = "lat",
                                      models_dir = my_dir,
                                      mask = AF,
                                      write_png = TRUE))
final_time <- Sys.time()

(delta_time <- final_time - ini_time)

stopCluster(cl)
