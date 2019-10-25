sun_metrics <- function(algos, sp, dir, size, type, seed = 42) {
  set.seed(seed)
  # mod files
  mod_dir <- paste0(dir, "/", sp, "/present/final_models")
  s.file <- list.files(path = mod_dir,
                          pattern = paste0(algos, ".*.", type, ".tif"),
                          full.names = TRUE,
                          recursive = FALSE)
  un.file <- list.files(path = mod_dir,
                         pattern = paste0(algos, ".*uncertainty.tif"),
                         full.names = TRUE,
                         recursive = FALSE)
  sun.files <- c(s.file, un.file)
  sun <- raster::stack(sun.files)
  vals <- raster::extract(sun, dismo::randomPoints(sun, n = 50000))
  vals_no0 <- vals[vals[,1] > 0,]
  if (nrow(vals_no0) > size) {
  su <- vals_no0[sample(1:nrow(vals_no0), size),]
  } else {
  su <- vals_no0
  }
  suit <- su[,1]
  un <- su[,2]
  # calculating quantile
  quant <- function(x, n) quantile(x, na.rm = TRUE)[n]
  q.suit25 <- quant(suit, 2)
  q.suit75 <- quant(suit, 4)
  q.un25 <- quant(un, 2)
  q.un75 <- quant(un, 4)
  ## defining good and bad values
  df <- data.frame(suit = suit, un = un)
  df$quality <- "none"
  # good: high suit & low uncertainty
  df$quality[suit >= q.suit75 & un <= q.un25] <- "good"
  # good: low suit & low uncertainty
  df$quality[suit <= q.suit25 & un <= q.un25] <- "good"
  # bad: low suit & high uncertainty
  df$quality[suit <= q.suit25 & un >= q.un75] <- "bad"
  # bad: high suit & high uncertainty
  df$quality[suit >= q.suit75 & un >= q.un75] <- "bad"
  # calculating metrics
  total <- nrow(df)
  good <- sum(df$quality == "good")
  bad <- sum(df$quality == "bad")
  M1 <- good/total
  M2 <- good/bad
  # plot.un <- function(){
  #   # defining colors for bad and good points
  #   cores <- adjustcolor(c("grey", "darkred", "navyblue"), alpha.f = 0.4)
  #   df$cor <- cores[1]
  #   df$cor[df$quality=="good"] <- cores[2]
  #   df$cor[df$quality=="bad"] <- cores[3]
  #   # making plot
  #   plot(un ~ suit, xlab="Suitability", ylab="Uncertainty", las=1, bty='l', data=df, pch=19, col=df$cor)
  #   abline(v=q.suit25, lty=2, col='grey')
  #   abline(v=q.suit75, lty=2, col='grey')
  #   abline(h=q.un25, lty=2, col='grey')
  #   abline(h=q.un75, lty=2, col='grey')
  #   legend("topright", c("good", "bad"), pch=19,
  #          col=cores[2:3])
  # }
  # png(file=paste0(dir.final, algos, "_", sp, "_sun_points.png"))
  # plot.un()
  # dev.off()
  resu <- data.frame(sp = sp,
                     algo = algos,
                     M1 = M1,
                     M2 = M2,
                     good = good,
                     bad = bad,
                     total = total)
  new.dir <- paste0('results/uncertainty/', sp, "/")
  dir.create(new.dir, showWarnings = FALSE)
  write.table(su,
              paste0(new.dir, sp, "_", algos, "_", type, "_uncertainty_values.csv"),
              sep = ",", col.names = TRUE, row.names = FALSE)
  write.table(resu,
              paste0(new.dir, sp, "_", algos, "_", type, "_uncertainty_metrics.csv"),
              sep = ",", col.names = TRUE, row.names = FALSE)
}
