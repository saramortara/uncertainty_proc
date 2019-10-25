sun_map <- function(algos, dir, sp, occ){
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
  sun.mod <- raster::stack(sun.files)
  nomes <- c("suitability", "uncertainty")
  tits <- paste(algo, sp, nomes, sep = " ")
  my_at <- seq(0, 1, length.out = 16)
  # my_breaks <- seq(0,1, by=0.01)
  paleta <- wesanderson::wes_palette("Zissou1", 16, type = "continuous")
  # que pacote???
  myTheme <- rasterVis::rasterTheme(region = paleta)
  # que pacote???
  rasterVis::levelplot(sun.mod, par.settings = myTheme, at = my_at)
  # par(mfrow=c(1,2))
  # for(i in 1:2){
  #   plot(sun.mod[[i]], main=tits[i],  breaks=my_breaks, main.cex=0.7, col=paleta)
  #        #lab.breaks=my_breaks_lab, legend.lab = my_breaks_lab, at=my_breaks_lab)
  #   points(occ$lat ~ occ$lon, pch = 19, cex=.6, col=rgb(0,0,0, alpha=.3))
  # }
  # par(mfrow=c(1,1))
}
