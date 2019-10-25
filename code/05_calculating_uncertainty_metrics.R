#### Script to calculate metrics ####
## 1. AUC, TSS, omission and pROC (w/ pval) are in the combined final_statistics files
## 2. uncertainty
### generates table w/ uncertainty and suitability values
### geranates table w/ uncertainty metrics for all species

library(data.table)
library(dplyr)
library(parallel)

# loading function
source("R/sun_metrics.R")

## directory
my_dir <- "models_low"

## species names except for Vriesea carinata
exp_names <- list.files(my_dir)
# exclude Vriesea carinata
excluir <- exp_names[209:216]
exp_names <- exp_names[!exp_names %in% excluir]

###############################
# 1. getting final statistics #
###############################

## listing final statistics
list_final <- list()
for (i in 1:length(exp_names)) {
list_final[[i]] <- list.files(path = paste0(my_dir, "/", exp_names[i], "/present/final_models"),
                                   pattern = "final_statistics.*.csv",
                                   full.names = TRUE)
}

final_sta <- lapply(list_final, function(x) fread(x)[,-1])
length(final_sta)

# for now, excluding brt
final_stat_full <- bind_rows(final_sta) %>%
  filter(algoritmo != "brt")

dim(final_stat_full)

head(final_stat_full)

# all pROC p values are 0!
summary(final_stat_full$pval_pROC)

# mean values for all stats
stats_mean <- aggregate(AUC ~ species + algoritmo,
                        FUN = mean,
                        data = final_stat_full, na.rm = TRUE)

stats_mean$TSS <- aggregate(TSS ~ species + algoritmo,
                            FUN = mean,
                            data = final_stat_full, na.rm = TRUE)[,'TSS']

stats_mean$pROC <- aggregate(pROC ~ species + algoritmo,
                             FUN = mean,
                             data = final_stat_full, na.rm = TRUE,
                             drop = FALSE)[,'pROC']

stats_mean$omission <- aggregate(omission ~ species + algoritmo,
                                 FUN = mean,
                                 data = final_stat_full, na.rm = TRUE,
                                 drop = FALSE)[,'omission']

head(stats_mean)


cor(stats_mean[,3:6], use = "complete.obs")

# writing table w/ final statistics
write.table(final_stat_full, "results/all_final_statistics_full_table.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")

write.table(stats_mean, "results/all_final_statistics_mean.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")

#################################
# 2. getting uncertainty values #
#################################

# creating objects for clusterMap
#novas <- read.csv("results/sun_check.csv", header = FALSE)$V1
sp_count <- 1:length(exp_names)
#sp_count <- 1:length(novas)

## algorithms
algos <- c("bioclim", "svmk", "rf", "maxent", "glm")
algo_rep <- rep(algos, length(sp_count))
length(algo_rep)

## species
sp_rep <- rep(exp_names, times = length(algos))
#sp_rep <- rep(novas, times = length(algos))
length(sp_rep)

# type
type_rep <- rep(c("raw_mean", "raw_mean_cut"), each = length(sp_rep))

algo_rep2 <- rep(algo_rep, 2)
sp_rep2 <- rep(sp_rep, 2)

length(type_rep)
length(algo_rep2)
length(sp_rep2)

n_cl <- detectCores()
cl <- makeCluster(n_cl - 1,
                  type = "SOCK",
                  outfile = "data/log/02_do_any_brt.log")

ini_time <- Sys.time()
out_sun <- clusterMap(cl,
                      fun = sun_metrics,
                      algos = algo_rep2,
                      sp = sp_rep2,
                      type = type_rep,
                      MoreArgs = list(size = 1000, dir = my_dir))
final_time <- Sys.time()
(delta_time <- final_time - ini_time)

stopCluster(cl)

# my_dir <- "models_low"
# algos <- "glm"
# sp <- "Encyclia_patens_N_010"
# type <- "raw_mean_cut"
# dir <- my_dir
# size <- 1000
# seed <- 42
#
# teste <- sun_metrics(algos = algos,
#                      sp = sp,
#                      dir = dir,
#                      size = size,
#                      type = type,
#                      seed = seed)





