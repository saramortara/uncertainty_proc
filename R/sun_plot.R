### function to make sun plot
sun_plot <- function(df, title){
  # new.lista <- lapply(lista, function(x){
  #   names(x) = c("suit", 'un')
  #   return(x)})
  # df <- reshape2::melt(new.lista, id=1:2)
  suit <- df[,1]
  un <-  df[,2]
  quant <- function(x, n) quantile(x, na.rm = TRUE)[n]
  # q.suit25 <-aggregate(df$suit, list(L1=df$L1), quant, 2)
  # q.suit75 <- aggregate(df$suit, list(L1=df$L1), quant, 4)
  # q.un25 <- aggregate(df$un, list(L1=df$L1), quant, 2)
  # q.un75 <- aggregate(df$un, list(L1=df$L1), quant, 4)
  q.suit25 <- quant(suit, 2)
  q.suit75 <- quant(suit, 4)
  q.un25 <- quant(un, 2)
  q.un75 <- quant(un, 4)
  ## defining good and bad values
  df <- data.frame(suit = suit, un = un)
  df$quality <- factor("none", levels = c("good", "bad", "none"))
  # good: high suit & low uncertainty
  df$quality[suit >= q.suit75 & un <= q.un25] <- "good"
  # good: low suit & low uncertainty
  df$quality[suit <= q.suit25 & un <= q.un25] <- "good"
  # bad: low suit & high uncertainty
  df$quality[suit <= q.suit25 & un >= q.un75] <- "bad"
  # bad: high suit & high uncertainty
  df$quality[suit >= q.suit75 & un >= q.un75] <- "bad"
  p <- ggplot(df, aes(x = suit, y = un, colour = quality)) +
    labs(x = "Suitability", y = "Uncertainty", title = title) +
    geom_point(alpha = 0.3) +
    theme(plot.title = element_text(size = rel(0.5))) +
    scale_colour_manual(values = c("#F21A00","#3B9AB2",  "grey")) +
    geom_vline(xintercept = q.suit25, linetype = "dotted") +
    geom_vline(xintercept = q.suit75, linetype = "dotted") +
    geom_hline(yintercept = q.un25, linetype = "dotted") +
    geom_hline(yintercept = q.un75, linetype = "dotted") +
    theme_classic()
  #theme(plot.title = element_text(size=7))

  #   if(legend==FALSE){
  #   p <- p + theme_classic(legend.position='none')
  # }
  return(print(p))
}
