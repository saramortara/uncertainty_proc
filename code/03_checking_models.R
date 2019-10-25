#### Script to check runs and evaluates ####

# loading function
source("R/check.R")

exp_names <- list.files("models_low")

algos <- c("bioclim", "svmk", "rf", "maxent", "glm", "brt")

## check function
mod.check <- check("models_low", exp_names)
dim(mod.check)

table(mod.check$algo)

algo.trat <- table(mod.check$trat, mod.check$algo)

# how many missing treatments
apply(algo.trat, 2, function(x) sum(x == 0))

trat_part <- table(mod.check$trat, mod.check$partition)

tp_check <- data.frame(check = rowSums(table(mod.check$trat, mod.check$partition)) != 24)
sum(tp_check$check)

rownames(tp_check)[tp_check$check]

sp_check <- which(tp_check$check)

write.table(sp_check, "results/sp_check.csv", sep = ',',
            row.names = FALSE, col.names = FALSE)

#which(exp_names == "Vriesea_carinata_C_050")

algo.trat <- table(mod.check$trat, mod.check$algo)

# how many missing treatments
apply(algo.trat, 2, function(x) sum(x == 0))
# which
apply(algo.trat, 2, function(x) which(x == 0))$brt

# how many files inside each agorithm
table(mod.check$algo) #  bioclim, domain, maxent, rf, svm, have all data!

