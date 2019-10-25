#### Script to generate tables to be used in understanding_uncertainty.Rmd ####

library(dplyr)

source("R/metadata.R")

# loading files
## all stats file
stats_full <- read.csv("results/all_final_statistics_full_table.csv")
## all mean stats file
stats_mean <- read.csv("results/all_final_statistics_mean.csv")
head(stats_mean)
dim(stats_mean)
## all sun metrics raw_mean
stats_sun_rm <- read.csv("results/all_uncertainty_metrics_raw_mean.csv")
stats_sun_rmc <- read.csv("results/all_uncertainty_metrics_raw_mean_cut.csv")

stats_sun <- bind_rows(stats_sun_rm, stats_sun_rmc)

# standardizing names
names(stats_mean)[1:2] <- c("treatment", "algorithm")
names(stats_sun_rm)[1:2] <- c("treatment", "algorithm")
names(stats_sun_rmc)[1:2] <- c("treatment", "algorithm")

head(stats_mean)
head(stats_sun)

all_rm <- merge(stats_mean, stats_sun_rm, by = c("treatment", "algorithm"), all.x = TRUE)
all_rmc <- merge(stats_mean, stats_sun_rmc, by = c("treatment", "algorithm"), all.x = TRUE)

dim(all_rm)
dim(all_rmc)

# creating M3 metric good / good + bad
all_rm$M3 <- all_rm$good/(all_rm$good + all_rm$bad)
all_rmc$M3 <- all_rmc$good/(all_rmc$good + all_rmc$bad)

# creating experiment metadata
all_rm_meta <- metadata(as.character(all_rm$treatment)) %>%
  bind_cols(., all_rm)

all_rmc_meta <- metadata(as.character(all_rmc$treatment)) %>%
  bind_cols(., all_rmc)

# writing files
write.table(all_rm_meta, "results/final_tables/stats_row_mean.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")

write.table(all_rmc_meta, "results/final_tables/stats_row_mean_cut.csv",
            row.names = FALSE, col.names = TRUE, sep = ",")

