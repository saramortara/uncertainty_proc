# function to check model runs from the experiment
check <- function(dir, sp.trat){
  mod.list <- list.files(path = paste0(dir,  "/", sp.trat, "/present/partitions"),
                         pattern = ".tif")
  mod.list.full <- list.files(path = paste0(dir, "/", sp.trat, "/present/partitions"),
                              pattern = ".tif", full.names = TRUE)
  # 1 algo, 3 genero, 4 sp, 5 N ou C, 6 sample size, 7 partition
  seleciona <- function(n) sapply(strsplit(mod.list, "_"), function(x) x[n])
  check.tab <- data.frame(file = mod.list,
                          trat = NA,
                          sp = paste(seleciona(n = 3), seleciona(n = 4), sep = "_"),
                          clump = seleciona(n = 5),
                          sample.size = seleciona(n = 6),
                          partition = seleciona(n = 7),
                          algo = seleciona(1),
                          full.file = mod.list.full)
  check.tab$trat <- paste(check.tab$sp,
                          check.tab$clump,
                          check.tab$sample.size,
                          sep = "_")
  new.dir <- "results"
  dir.create(new.dir, showWarnings = FALSE)
  write.table(check.tab, paste0(new.dir, "/", "mod_check.csv"),
              sep = ",", row.names = FALSE)
  return(check.tab)
}
