### Script generating figures for the manuscript

# loading packages
library("ggplot2")
source("R/sun_plot.R")

cores <- c("#F21A00", "#3B9AB2", "grey")

# Figure 1. plot and quadrants and definition of indices
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

