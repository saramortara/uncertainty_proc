sun_map <- function(algo, dir, sp, occ){
  sun.files <- list.files(path = paste0(dir, "/", sp, "/present/partitions/final"),
                          pattern = paste0(algo, ".*.tif"), full.names = TRUE)
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
