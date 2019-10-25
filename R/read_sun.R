read_sun <- function(algo = "bioclim", cod = "C_100", type = "raw_mean") {
type_full <- paste0(algo, "_", type, "_uncertainty_values.csv")
files <- list.files(path = paste0("results/uncertainty"),
                            pattern = paste0(cod, ".*", type_full),
                            full.names = TRUE,
                            recursive = TRUE)
sun <- lapply(files, data.table::fread)
return(sun)
}

