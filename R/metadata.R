metadata <- function(treatment){
seleciona <- function(n) {
  a <- sapply(strsplit(treatment, "_"), function(x) x[n])
  return(a)
}
genus <- seleciona(1)
epithet <- seleciona(2)
CN <- seleciona(3)
n <- seleciona(4)
df <- data.frame(treatment = treatment,
                 genus = genus,
                 epithet = epithet,
                 clump = CN,
                 size = n)
return(df)
}
