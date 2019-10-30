sun_metrics2 <- function(su) { # data frame, first column suitability, second, uncertainty
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
  M3 <- good/(bad + good)
  resu <- data.frame(sp = sp,
                     algo = algos,
                     M1 = M1,
                     M2 = M2,
                     M3 = M3,
                     good = good,
                     bad = bad,
                     total = total)
  return(resu)
}
