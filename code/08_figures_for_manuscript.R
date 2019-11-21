### Script generating figures for the manuscript

# loading packages
library("ggplot2")
# loading functions
source("R/sun_plot.R")
source('R/read_sun.R')

cores <- c("#F21A00", "#3B9AB2", "grey")

#### Figure 1. plot and quadrants and definition of indices ####
set.seed(42)
df <- data.frame(x = rnorm(1000, mean = 0.5, sd = 0.15),
                 y = rnorm(1000, mean = 0.5, sd = 0.15))
sun <- sun_plot(data = df,
                title = "")

sun

qt <- apply(df, 2, quantile)

qt

sun

sun2 <- sun +
  # annotate("text", x = qt[2,'x'] - 0.11 , y = 1 ,
  #          label = bquote("Su"["1st quantile"]), size = 3.5) +
  # annotate("text", x = qt[4,'x'] + 0.11 , y = 1 ,
  #          label = bquote("Su"["3rd quantile"]), size = 3.5) +
  # annotate("text", x = 0.95, y = qt[2,'y'] + 0.025,
  #          label = bquote("Un"["1st quantile"]), size = 3.5) +
  # annotate("text", x = 0.95, y = qt[4,'y'] + 0.025 ,
  #          label = bquote("Un"["3rd quantile"]), size = 3.5) +
  annotate("text", x = 0.18, y = 0.2,
           label = "Q1", size = 3.5, color = cores[1], fontface = 2) +
  annotate("text", x = 0.85, y = 0.2,
           label = "Q2", size = 3.5, color = cores[1], fontface = 2) +
  annotate("text", x = 0.18, y = 0.8,
           label = "Q4", size = 3.5, color = cores[2], fontface = 2) +
  annotate("text", x = 0.85, y = 0.8,
           label = "Q3", size = 3.5, color = cores[2], fontface = 2)


png("figs/figure01.png", res = 300, height = 1200, width = 1500)
sun2
dev.off()

##### Figure 2. Example plots from different species ####
#  to illustrate the different forms that the relationship can take

sp.df <- read.csv("data/epiphyte_species.csv", as.is = TRUE)
sp.list <- sp.df$sp
sp.list <- sp.list[-27]

# write_plot <- function(algo, trat){
#   # read files
#   file <- read_sun(algo = algo,
#                    cod = trat,
#                    type = "raw_mean")
#   # make plots
#   my_dir <- paste0("figs/Un_figs/", algo)
#   dir.create(my_dir, showWarnings = FALSE)
#   for (i in 1:length(file)) {
#     png(paste0(my_dir, "/sun_plot_", algo, "_",
#                sp.list[i], "_", trat, ".png"))
#     sun_plot(file[[i]],
#              title = sp.list[i])
#     dev.off()
#   }
# }
#
# trat <- c("N_010", "N_020", "N_050", "N_100")
#
# for (i in 1:length(trat)) {
# write_plot("svmk", trat[i])
# }

# Choosing species for figure 2
# bioclim Christensonella subulata 050
# glm Aechmea lamarchei 020
# maxent Bilbergia distachia 050 Bilbergia euphemiae 020
# rf Aechmea nudicaulis 010
# svmk Rhipsalis lindbergiana 100

sp.f2 <- c("Christensonella_subulata", "Aechmea_lamarchei",
           "Billbergia_distachia", "Billbergia_euphemiae",
           "Aechmea_nudicaulis", "Rhipsalis_lindbergiana")
algos.f2 <- c("bioclim", "glm", "maxent", "maxent", "rf", "svmk")

trat.f2 <- c("N_050", "N_020", "N_050", "N_020", "N_010", "N_100")

count <- sapply(sp.f2, function(x) which(sp.df$sp %in% x))
count

df.f2 <- data.frame(sp = sp.f2, algos = algos.f2, trat = trat.f2)
head(df.f2)

file <- list()

for (i in 1:nrow(df.f2)) {
  file[[i]] <- read_sun(algo = df.f2[,'algos'][i],
                        cod = df.f2[,'trat'][i],
                        type = "raw_mean")
}

file.f2 <- list()
for (i in 1:length(count)) {
  file.f2[[i]] <- file[[i]][count[i]]
}

file.f2[[1]]

sun_plot(as.data.frame(file.f2[[1]]), title = "")

f2a

sun_plot
