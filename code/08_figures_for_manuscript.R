### Script generating figures for the manuscript

# loading packages
library("ggplot2")
library("ggpubr")
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

f2a <- sun_plot(as.data.frame(file.f2[[1]]), title = "")
f2b <- sun_plot(as.data.frame(file.f2[[2]]), title = "")
f2c <- sun_plot(as.data.frame(file.f2[[3]]), title = "")
f2d <- sun_plot(as.data.frame(file.f2[[4]]), title = "")
f2e <- sun_plot(as.data.frame(file.f2[[5]]), title = "")
f2f <- sun_plot(as.data.frame(file.f2[[6]]), title = "")


f2.all <- ggarrange(f2a + labs(x = "", y = "") + ggtitle("A"),
                    f2b + labs(x = "", y = "") + ggtitle("B"),
                    f2c + labs(x = "", y = "") + ggtitle("C"),
                    f2d + labs(x = "", y = "") + ggtitle("D"),
                    f2e + labs(x = "", y = "") + ggtitle("E"),
                    f2f + labs(x = "", y = "") + ggtitle("F"),
                    common.legend = TRUE)

png("figs/figure02.png", res = 300, height = 1800, width = 2400)
annotate_figure(f2.all,
                left = "Uncertainty",
                bottom = "Suitability")
dev.off()

#### Figure 3. Uncertainty metrics ~ N and algorithm ####
stats_rm <- read.csv("results/final_tables/stats_row_mean.csv")
stats_rm$size <- as.factor(stats_rm$size)
stats_rm$sp.gen <- paste(stats_rm$genus, stats_rm$epithet, sep = "_")
stats_rm$good_bad <- stats_rm$good + stats_rm$bad

# selecting only no clump data
stats_rm <- stats_rm[stats_rm$clump == "N",]

# color palette
# color palette
n.col <- 4
pal <-  wesanderson::wes_palette("Zissou1", n.col,
                    type = "continuous")

# algorithm names
algo_names <- c("Bioclim", "GLM", "Maxent", "Random Forest", "SVM")


head(stats_rm)

m1 <- ggplot(stats_rm, aes(x = algorithm, y = M1, fill = size)) +
  geom_boxplot() +
  labs(y = "Un_total", x = "Algorithm") +
  #facet_grid(clump ~ .) +
  scale_fill_manual(values = pal) +
  scale_x_discrete(labels = algo_names) +
  theme_classic()

m1

m2 <- m1 %+% aes(y = M3) +
  labs(y = "Un_partial")

m2

f3 <- ggarrange(m1 + ggtitle("A"),
                m2 + ggtitle("B"),
                common.legend = TRUE)

png("figs/figure03.png", res = 300, height = 1200, width = 2400)
f3
dev.off()
