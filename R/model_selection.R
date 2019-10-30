# function to perform model selection
mod_sel <- function(data, m) {
  if (m == "M1")  M <- cbind(data$good, data$bad)
  if (m == "M3")   M <- cbind(data$good, data$good_bad)
  m00 <- glmer(M ~ 1 + (1|sp.gen),
               data = data, family = "binomial")
  m01 <- glmer(M ~ algorithm + (1|sp.gen),
               data = data, family = "binomial")
  m02 <- glmer(M ~ clump + (1|sp.gen),
               data = data, family = "binomial")
  m03 <- glmer(M ~ size + (1|sp.gen),
               data = data, family = "binomial")
  m04 <- glmer(M ~ clump + size + (1|sp.gen),
               data = data, family = "binomial")
  m05 <- glmer(M ~ clump + algorithm + (1|sp.gen),
               data = data, family = "binomial")
  m06 <- glmer(M ~ size + algorithm + (1|sp.gen),
               data = data, family = "binomial")
  m07 <- glmer(M ~ clump + size + algorithm + (1|sp.gen),
               data = data, family = "binomial")
  mlist <- list(m00 = m00, m01 = m01, m02 = m02, m03 = m03,
                m04 = m04, m05 = m05, m06 = m06, m07 = m07)
  myaic <- AICtab(mlist,
                  base = TRUE, weights = TRUE, sort = FALSE)
  aic_df <- data.frame(model = names(mlist),
                       AIC = myaic$AIC,
                       dAIC = myaic$dAIC,
                       df = myaic$df,
                       weight = myaic$weight)
  aic_df_or <- aic_df[order(aic_df$dAIC),]
  return(list(mods = mlist,
              aic_tab = aic_df_or))
}


# mod_sel <- function(data, m) {
#   if (m == "M1")  M <- cbind(data$good, data$bad)
#   if (m == "M3")   M <- cbind(data$good, data$good_bad)
#   m01 <- glmer(M ~ (clump + size)*algorithm + (1|sp.gen),
#                data = data, family = "binomial")
#   m02 <- glmer(M ~ clump * algorithm + (1|sp.gen),
#                data = data, family = "binomial")
#   m03 <- glmer(M ~ size * algorithm + (1|sp.gen),
#                data = data, family = "binomial")
#   m04 <- glmer(M ~ clump + size + algorithm + (1|sp.gen),
#                data = data, family = "binomial")
#   m05 <- glmer(M ~ size + (1|sp.gen),
#                data = data, family = "binomial")
#   m06 <- glmer(M ~ algorithm + (1|sp.gen),
#                data = data, family = "binomial")
#   m07 <- glmer(M ~ clump + (1|sp.gen),
#                data = data, family = "binomial")
#   m00 <- glmer(M ~ 1 + (1|sp.gen),
#                data = data, family = "binomial")
#   mlist <- list(m01 = m01, m02 = m02, m03 = m03,
#                 m04 = m04, m05 = m05, m06 = m06, m07 = m07,
#                 m00 = m00)
#   myaic <- AICtab(mlist,
#                   base = TRUE, weights = TRUE)
#   return(list(mods = mlist,
#               aic_tab = myaic))
# }
