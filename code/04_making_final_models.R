#### Generating average model per algorithm ####

library(modleR)
library(parallel)

# creating objects for cluster map

## directory
my_dir <- "models_low"

## species names and count
exp_names <- list.files(my_dir)
sp_count <- 1:length(exp_names)

## algorithms rep
# algos <- c("svmk", "rf", "maxent", "glm", "bioclim") # "brt
# algo_rep <- rep(algos, length(sp_count))
# length(algo_rep)

n_cl <- detectCores()
cl <- makeCluster(n_cl - 1,
                  type = "SOCK",
                  outfile = "data/log/04_final_model.log")

ini_time <- Sys.time()
out_low <- clusterMap(cl,
                      fun = modleR::final_model,
                      species_name = exp_names[8:length(exp_names)],
                      MoreArgs = list(models_dir = my_dir,
                                      uncertainty = TRUE,
                                      select_partitions = FALSE,
                                      which_models = c("raw_mean", "raw_mean_cut"),
                                      write_final = TRUE))
final_time <- Sys.time()

(delta_time <- final_time - ini_time)

stopCluster(cl)

# Nematanthus_crassifolius_C_050, Rhipsalis_lindbergiana_C_050
teste <- modleR::final_model(species_name = "Billbergia_distachia_N_020",
                             algorithms =  c("svmk", "rf", "maxent", "glm", "bioclim"),
                             models_dir = my_dir,
                             uncertainty = TRUE,
                             select_partitions = FALSE,
                             which_models = c("raw_mean", "raw_mean_cut"),
                             write_final = TRUE,
                             overwrite = TRUE)



#### check final models
final_list <- list()
for (i in 1:length(exp_names)) {
final_list[[i]] <- list.files(paste0("models_low/", exp_names[i], "/present/final_models"))
}

exp_names[sapply(final_list, length) < 30]
