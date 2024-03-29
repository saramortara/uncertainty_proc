do_brt <- function(species_name,
                   predictors,
                   models_dir = "./models",
                   algo = c("bioclim"),
                   project_model = FALSE,
                   proj_data_folder = "./data/proj",
                   mask = NULL,
                   write_png = FALSE,
                   write_bin_cut = FALSE,
                   threshold = "spec_sens",
                   conf_mat = TRUE,
                   equalize = TRUE,
                   proc_threshold = 0.5,
                   ...) {
  # replacing characters not welcome in species name
  # characters to avoid in file and dir names
  avoid_chars <- intToUtf8(c(91, 62, 33, 180, 60, 35, 63, 38, 47, 92, 46, 93))
  print_avoid <- intToUtf8(c(62, 33, 180, 60, 35, 63, 38, 47, 92, 46))
  if (grepl(avoid_chars, species_name) == TRUE) {
    species_name <- gsub(avoid_chars, "", species_name)
    warning(cat(paste0('You entered a bad character (any in "', print_avoid, '")
                       in the species name and we removed it for you')))
  }
  partition.folder <-
    paste(models_dir, species_name, "present", "partitions", sep = "/")
    if (file.exists(partition.folder) == FALSE)
      dir.create(partition.folder, recursive = TRUE)
  setup.folder <-
    paste(models_dir, species_name, "present", "data_setup", sep = "/")

    # reads sdmdata from HD
    if (file.exists(paste(setup.folder, "sdmdata.csv", sep = "/"))) {
        sdmdata <- read.csv(paste(setup.folder, "sdmdata.csv", sep = "/"))
    } else {
        stop("sdmdata.csv file not found, run setup_sdmdata() or check your
             folder settings")
        }

    message(paste(algo, "\n"))

    retained_predictors <-
        names(sdmdata)[(which(names(sdmdata) == "lat") + 1):ncol(sdmdata)]

    if (length(setdiff(names(predictors), retained_predictors)) > 0) {
        message(paste("Remember a variable selection was performed", "\n",
                      "retained variables:", paste(retained_predictors,
                                                   collapse = "-"), "\n"))
    }
    predictors <- raster::subset(predictors, retained_predictors)


    ##### Hace los modelos
    runs <- which(names(sdmdata) == "pa") - 1

    #para cada coluna da matriz de desenho experimental
    for (i in seq_along(1:runs)) {
        group.all <- sdmdata[, i]
        group  <- group.all[sdmdata$pa == 1]
        bg.grp <- group.all[sdmdata$pa == 0]
        occurrences <- sdmdata[sdmdata$pa == 1, c("lon", "lat")]#recria occs
        backgr      <- sdmdata[sdmdata$pa == 0, c("lon", "lat")]
        #para cada grupo
        for (g in setdiff(unique(group), 0)) {
            #excluding the zero allows for bootstrap. only 1 partition will run
            message(paste(species_name, algo, "run number", i, "part. nb.",
                          g, "\n"))
            pres_train <- occurrences[group != g, ]
            if (nrow(occurrences) == 1) #only distance algorithms can be run
                pres_train <- occurrences[group == g, ]
            pres_test  <- occurrences[group == g, ]
            backg_test <- backgr[bg.grp == g, ]
            sdmdata_train <- sdmdata[group.all != g, ]
            envtrain <-  sdmdata_train[, names(predictors)]

            message("fitting models")
            if (algo == "bioclim") mod <- dismo::bioclim(predictors, pres_train)
            if (algo == "mahal")   mod <- dismo::mahal(predictors, pres_train)
            if (algo == "domain")  mod <- dismo::domain(predictors, pres_train)
            if (algo == "maxent")
                mod <- dismo::maxent(envtrain, sdmdata_train$pa)
            if (algo == "maxnet")
                mod <- maxnet::maxnet(sdmdata_train$pa, envtrain)
            if (algo == "glm") {
                null.model <- glm(sdmdata_train$pa ~ 1, data = envtrain,
                                  family = "binomial")
                full.model <- glm(sdmdata_train$pa ~ ., data = envtrain,
                                  family = "binomial")
                mod <- step(object = null.model, scope = formula(full.model),
                            direction = "both", trace = FALSE)
            }
            if (algo == "svmk") {
                mod <- kernlab::ksvm(sdmdata_train$pa ~ ., data = envtrain)
            }
            if (algo == "svme") {
                sv <- 1
                while (!exists("mod")) {
                    mod <- e1071::best.tune("svm", envtrain, sdmdata_train$pa,
                                            data = envtrain)
                    sv <- sv + 1
                    message(paste("Trying svme", sv, "times"))
                    if (sv == 10 & !exists("mod")) {
                        break
                        message("svme algorithm did not find a solution in 10 runs")
                    }
                }
            }
            if (algo == "rf" | algo == "brt") {
                if (equalize == TRUE) {
                    #balanceando as ausencias
                    pres_train_n <- nrow(sdmdata_train[sdmdata_train$pa == 1, ])
                    abs_train_n  <- nrow(sdmdata_train[sdmdata_train$pa == 0, ])
                    prop <- pres_train_n:abs_train_n
                    aus.eq <- sample(prop[-1], pres_train_n)
                    envtrain.eq <- envtrain[c(1:pres_train_n, aus.eq), ]
                    sdmdata_train.eq <- sdmdata_train[c(1:pres_train_n, aus.eq),]
                } else {
                    envtrain.eq <- envtrain
                    sdmdata_train.eq <- sdmdata_train
                }
                if (algo == "rf") {
                    #mod <- randomForest::randomForest(sdmdata_train.eq$pa ~ .,
                    #                               data = envtrain.eq,
                    #                              importance = TRUE)
                    mod <- randomForest::tuneRF(envtrain.eq,
                                                sdmdata_train.eq$pa,
                                                trace = FALSE,
                                                plot = FALSE,
                                                doBest = TRUE,
                                                importance = FALSE)
                }
                if (algo == "brt") {
                    mod <- dismo::gbm.step(data = sdmdata_train.eq,
                                           gbm.x = names(predictors),
                                           gbm.y = "pa",
                                           family = "bernoulli",
                                           tree.complexity = 1,
                                           learning.rate = 0.01,
                                           bag.fraction = 0.8,
                                           plot.main = FALSE,
                                           n.minobsinnode = 10)
                    n.trees <- mod$n.trees
                }
            }

            message("projecting the models")
            if (exists("mod")) {
                if (algo == "brt") {
                    eval_mod <- dismo::evaluate(pres_test, backg_test, mod,
                                                predictors, n.trees = n.trees)
                    mod_cont <- dismo::predict(predictors, mod, n.trees = n.trees)
                }
                if (algo == "glm") {
                    eval_mod <- dismo::evaluate(pres_test, backg_test, mod,
                                                predictors, type = "response")
                    mod_cont <- raster::predict(predictors, mod, type = "response")
                }
                if (algo %in% c("bioclim",
                                "domain",
                                "maxent",
                                "mahal")) {
                    eval_mod <- dismo::evaluate(pres_test, backg_test, mod, predictors)
                    mod_cont <- dismo::predict(mod, predictors)
                }
                if (algo %in% c("svmk", "svme", "rf")) {
                    eval_mod <- dismo::evaluate(pres_test, backg_test, mod, predictors)
                    mod_cont <- raster::predict(predictors, mod)
                }
                if (algo == "maxnet") {
                    eval_mod <- dismo::evaluate(pres_test, backg_test, mod,
                                                predictors, type = "logistic")
                    mod_cont <- raster::predict(predictors, mod, type = "logistic")
                }


            message("evaluating the models")
            th_table <- dismo::threshold(eval_mod) #sensitivity 0.9
            mod_TSS  <- max(eval_mod@TPR + eval_mod@TNR) - 1
            #PROC kuenm
            proc <- kuenm::kuenm_proc(occ.test = pres_test,
                                      model = mod_cont,
                                      threshold = proc_threshold,
                                      ...)

            #threshold-independent values
            th_table$AUC <- eval_mod@auc
            th_table$AUCratio <- eval_mod@auc / 0.5
            th_table$pROC <- proc$pROC_summary[1]
            th_table$pval_pROC <- proc$pROC_summary[2]
            th_table$TSS <- mod_TSS
            th_table$algoritmo <- algo
            th_table$run <- i
            th_table$partition <- g
            th_table$presencenb <- eval_mod@np
            th_table$absencenb <- eval_mod@na
            th_table$correlation <- eval_mod@cor
            th_table$pvaluecor <- eval_mod@pcor
            row.names(th_table) <- species_name

            # threshold dependent values
            #which threshold? any value from function threshold() in dismo
            th_mod <- th_table[, threshold]
            th_table$threshold <- as.character(threshold)
            #confusion matrix
            if (algo == "brt") {
                conf <- dismo::evaluate(pres_test, backg_test, mod, predictors,
                                            n.trees = n.trees, tr = th_mod)
            } else {
                conf <- dismo::evaluate(pres_test, backg_test, mod, predictors,
                                        tr = th_mod)
            }
            th_table$prevalence.value <- conf@prevalence
            th_table$PPP <- conf@PPP
            th_table$NPP <- conf@NPP
            th_table$sensitivity.value <- conf@TPR / (conf@TPR + conf@FPR)
            th_table$specificity.value <- conf@TNR / (conf@FNR + conf@TNR)
            th_table$comission <- conf@FNR / (conf@FNR + conf@TNR)
            th_table$omission <- conf@FPR / (conf@TPR + conf@FPR)
            th_table$accuracy <- (conf@TPR + conf@TNR) / (conf@TPR + conf@TNR +
                                                            conf@FNR + conf@FPR)
            th_table$KAPPA.value <- conf@kappa

            #confusion matrix
            if (conf_mat == TRUE) {
                conf_res <-
                    data.frame(presence_record = conf@confusion[, c("tp", "fp")],
                               absence_record = conf@confusion[, c("fn", "tn")])
                rownames(conf_res) <- c("presence_predicted", "absence_predicted")
                write.csv(conf_res, file = paste0(partition.folder,
                                                  "/confusion_matrices_",
                                                  species_name, "_", i, "_", g,
                                                  "_", algo, ".csv"))
            }


            #writing evaluation tables

            message("writing evaluation tables")
            write.csv(th_table, file = paste0(partition.folder, "/evaluate_",
                                              species_name, "_", i, "_", g,
                                              "_", algo, ".csv"))

                # apply mask (optional)
                if (class(mask) %in% c("SpatialPolygonsDataFrame",
                                       "SpatialPolygons")) {
                    mod_cont <- crop_model(mod_cont, mask)
                }
                message("writing raster files")
                raster::writeRaster(x = mod_cont,
                                    filename = paste0(partition.folder, "/", algo,
                                                      "_cont_", species_name, "_",
                                                      i, "_", g, ".tif"),
                                    overwrite = TRUE)
                if (write_bin_cut == TRUE) {
                    message("writing binary and cut raster files")
                    mod_bin  <- mod_cont > th_mod
                    mod_cut  <- mod_cont * mod_bin
                    if (class(mask) == "SpatialPolygonsDataFrame") {
                        mod_bin <- crop_model(mod_bin, mask)
                        mod_cut <- crop_model(mod_cut, mask)
                    }
                    raster::writeRaster(x = mod_bin,
                                        filename = paste0(partition.folder, "/", algo,
                                                          "_bin_", species_name, "_",
                                                          i, "_", g, ".tif"),
                                        overwrite = TRUE)
                    raster::writeRaster(x = mod_cut,
                                        filename = paste0(partition.folder, "/", algo,
                                                          "_cut_", species_name, "_",
                                                          i, "_", g, ".tif"),
                                        overwrite = TRUE)
                }


                if (write_png == TRUE) {
                    message("writing png files")
                    png(paste0(partition.folder, "/", algo, "_cont_", species_name,
                               "_", i, "_", g, ".png"))
                    raster::plot(mod_cont,
                                 main = paste(algo, "raw", "\n", "AUC =",
                                              round(eval_mod@auc, 2), "-", "TSS =",
                                              round(mod_TSS, 2)))
                    dev.off()

                    if (write_bin_cut == TRUE) {
                        png(paste0(partition.folder, "/", algo, "_bin_", species_name,
                                   "_", i, "_", g, ".png"))
                        raster::plot(mod_bin,
                                     main = paste(algo, "bin", "\n", "AUC =",
                                                  round(eval_mod@auc, 2), "-", "TSS =",
                                                  round(mod_TSS, 2)))
                        dev.off()
                        png(paste0(partition.folder, "/", algo, "_cut_", species_name,
                                   "_", i, "_", g, ".png"))
                        raster::plot(mod_cut,
                                     main = paste(algo, "cut", "\n", "AUC =",
                                                  round(eval_mod@auc, 2), "-", "TSS =",
                                                  round(mod_TSS, 2)))
                        dev.off()
                    }

                }

                if (project_model == TRUE) {
                    pfiles <- list.dirs(proj_data_folder, recursive = FALSE)
                    for (proje in pfiles) {
                        v <- strsplit(proje, "/")
                        name_proj <- v[[1]][length(v[[1]])]
                        projection.folder <- paste0(models_dir, "/", species_name,
                                                    "/", name_proj, "/partitions")
                        if (file.exists(projection.folder) == FALSE)
                            dir.create(paste0(projection.folder),
                                       recursive = TRUE, showWarnings = FALSE)
                        pred_proj <- raster::stack(list.files(proje,
                                                              full.names = TRUE))
                        pred_proj <- raster::subset(pred_proj, names(predictors))
                        message(name_proj)

                        message("projecting models")
                        if (algo == "brt") {
                            mod_proj_cont <- dismo::predict(pred_proj,
                                                            mod,
                                                            n.trees = n.trees)
                        }
                        if (algo == "glm") {
                            mod_proj_cont <- raster::predict(pred_proj, mod,
                                                             type = "response")
                        }
                        if (algo %in% c("bioclim",
                                        "domain",
                                        "maxent",
                                        "mahal")) {
                            mod_proj_cont <- dismo::predict(pred_proj, mod)
                        }
                        if (algo %in% c("svmk",
                                        "svme",
                                        "rf")) {
                            mod_proj_cont <- raster::predict(pred_proj, mod)
                        }

                        if (write_bin_cut == TRUE) {
                            mod_proj_bin <- mod_proj_cont > th_mod
                            mod_proj_cut <- mod_proj_bin * mod_proj_cont
                            # Normaliza o modelo cut
                            #mod_proj_cut <- mod_proj_cut / maxValue(mod_proj_cut)
                        }
                        if (class(mask) == "SpatialPolygonsDataFrame") {
                            mod_proj_cont <- crop_model(mod_proj_cont, mask)
                            mod_proj_bin  <- crop_model(mod_proj_bin, mask)
                            mod_proj_cut  <- crop_model(mod_proj_cut, mask)
                        }
                        message("writing projected models raster")
                        raster::writeRaster(x = mod_proj_cont,
                                            filename = paste0(projection.folder,
                                                              "/", algo, "_cont_",
                                                              species_name, "_",
                                                              i, "_", g, ".tif"),
                                            overwrite = TRUE)

                        if (write_bin_cut == TRUE) {
                            raster::writeRaster(x = mod_proj_bin,
                                                filename = paste0(projection.folder,
                                                                  "/", algo, "_bin_",
                                                                  species_name, "_",
                                                                  i, "_", g, ".tif"),
                                                overwrite = TRUE)
                            raster::writeRaster(x = mod_proj_cut,
                                                filename = paste0(projection.folder,
                                                                  "/", algo, "_cut_",
                                                                  species_name, "_",
                                                                  i, "_", g, ".tif"),
                                                overwrite = TRUE)
                        }

                        if (write_png == TRUE) {
                            message("writing projected models .png")
                            png(paste0(projection.folder, "/", algo, "_cont_",
                                       species_name, "_", i, "_", g, ".png"))
                            raster::plot(mod_proj_cont,
                                         main = paste(algo, "proj_raw", "\n",
                                                      "AUC =",
                                                      round(eval_mod@auc, 2), "-",
                                                      "TSS =", round(mod_TSS, 2)))
                            dev.off()

                            if (write_bin_cut == TRUE) {
                                png(paste0(projection.folder, "/", algo, "_bin_",
                                           species_name, "_", i, "_", g, ".png"))
                                raster::plot(mod_proj_bin,
                                             main = paste(algo, "proj_bin", "\n",
                                                          "AUC =",
                                                          round(eval_mod@auc, 2),
                                                          "-", "TSS =",
                                                          round(mod_TSS, 2)))
                                dev.off()
                                png(paste0(projection.folder, "/", algo, "_cut_",
                                           species_name, "_", i, "_", g, ".png"))
                                raster::plot(mod_proj_cut,
                                             main = paste(algo, "proj_cut", "\n",
                                                          "AUC =",
                                                          round(eval_mod@auc, 2), "-",
                                                          "TSS =", round(mod_TSS, 2)))
                                dev.off()
                            }

                        }
                        rm(pred_proj)
                    }
                }
            } else message(paste(species_name, algo, "run number", i, "part. nb.",
                                 g, "could not be fit \n"))
        }

    }
    return(th_table)
    message("DONE!")
    print(date())
}
