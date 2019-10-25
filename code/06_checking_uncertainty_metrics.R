#### Script to make exploratory analysis ####

# loading packages
library(data.table)
library(dplyr)

# reading suitability and uncertainty values for plot
exp_names <- list.files("results/uncertainty")
length(exp_names)


#### 1. basic check ####
# ori_names <- list.files("models_low")
# setdiff(ori_names, exp_names)
#
# algos <- c("bioclim", "svmk", "rf", "maxent", "glm")
#
# all_files <- list.files(paste0("results/uncertainty/", exp_names),
#                         pattern = ".*uncertainty_metrics.csv")
#
# length(all_files)
#
# seleciona <- function(n) {
#   a <- sapply(strsplit(all_files, "_uncertainty_metrics.csv"), function(x) x[1])
#   b <- sapply(strsplit(a, "_"), function(x) x[n])
#   return(b)
# }
#
# genus <- seleciona(1)
# epithet <- seleciona(2)
# CN <- seleciona(3)
# n <- seleciona(4)
# algo <- seleciona(5)
# mod <- paste(seleciona(6), seleciona(7), seleciona(8), sep = "_") %>%
#   gsub("_NA", "", .)
#
# sun_check <- data.frame(trat = paste(genus, epithet, CN, n, sep = "_"),
#                         genus, epithet, CN, n, algo, mod,
#                         algo_mod = paste(algo, mod, sep = "_"))
# head(sun_check)
#
# trat_check <- table(sun_check$trat)
# nomes <- names(trat_check)[trat_check != 10]
# length(nomes)
#
# nomes
# write.table(nomes, 'results/sun_check.csv',
#              row.names = FALSE, col.names = FALSE, sep = ",")


#### Generating combined metric files ####

files_m <- list.files(path = paste0("results/uncertainty/", exp_names),
                            pattern = paste0(".*uncertainty_metrics.csv"),
                            recursive = TRUE,
                            full.names = TRUE)

length(files_m)

rmc_files <- files_m[stringr::str_detect(files_m, "raw_mean_cut_uncertainty")]
rm_files <- files_m[stringr::str_detect(files_m, "raw_mean_uncertainty")]

length(rmc_files)
length(rm_files)

##### 1. uncertainty metrics ####
rm_metrics <- lapply(rm_files, fread) %>% bind_rows()
rm_metrics$mod <- "raw_mean"

head(rm_metrics)

rmc_metrics <- lapply(rmc_files, fread) %>% bind_rows()
rmc_metrics$mod <- "raw_mean_cut"

head(rmc_metrics)

write.table(rm_metrics, "results/all_uncertainty_metrics_raw_mean.csv",
            col.names = TRUE, row.names = FALSE, sep = ",")

write.table(rmc_metrics, "results/all_uncertainty_metrics_raw_mean_cut.csv",
            col.names = TRUE, row.names = FALSE, sep = ",")

