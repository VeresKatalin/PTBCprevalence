  #Se (constant or age specific)
  isSeconst = 0
  #Se_const = 0.25
  # Parameters of the model of age-dependent sensitivity (Meyer et al. 2018)
  parA = 1.2
  parB = 3.0
  parC = 0.30
  #Sp (constant)
  Sp_const = 0.986
  
  #sigmasq
  alphasigmasq <- 37.03
  betasigmasq  <- 4.62
  #sigm1sq
  alphasigm1sq <- 5.33
  betasigm1sq  <- 0.07
  #sigm2sq
  alphasigm2sq <- 6.05
  betasigm2sq  <- 0.09
  
#priors
  if (countryname == "Hungary")
  {

  #HTP <- herd true prevalence (beta prior)
    alphaHTP <- 150.589 
    betaHTP <- 12.25
  #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
    alphamu1 <- 65.7
    betamu1 <- 715.9
  #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
    alphamu2 <- 134.195
    betamu2 <- 716.1808
  #c - constant to calculate sigma-related priors
    c <- 1
} else if (countryname == "Denmark")
  #from posterior
  {
   
    #HTP <- herd true prevalence (beta prior)
    alphaHTP <- 425.11 
    betaHTP <- 144.641
    #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
    alphamu1 <- 1.77
    betamu1 <- 43.21
    #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
    alphamu2 <- 3.85
    betamu2 <- 45.09
    #c - constant to calculate sigma-related priors
    c <- 0.05755181
} else if (countryname == "S_Italy")
{
  #HTP <- herd true prevalence (beta prior)
  alphaHTP <- 5.03
  betaHTP <- 7.04
  #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
  alphamu1 <- 2.766
  betamu1 <- 46.335
  #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
  alphamu2 <- 6.018
  betamu2 <- 47.403
  #c - constant to calculate sigma-related priors
  c <- 0.062820417
} else if (countryname == "Veneto")
{
  
  #HTP <- herd true prevalence (beta prior)
  alphaHTP <- 13.32
  betaHTP <- 6.28
  #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
  alphamu1 <- 1.079
  betamu1 <- 18.347
  #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
  alphamu2 <- 2.347
  betamu2 <- 18.788
  #c - constant to calculate sigma-related priors
  c <- 0.024854444
} else if (countryname == "Lombardy")
{
  
  #HTP <- herd true prevalence (beta prior)
  alphaHTP <- 13.32
  betaHTP <- 6.28
  #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
  alphamu1 <- 1.079
  betamu1 <- 18.347
  #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
  alphamu2 <- 2.347
  betamu2 <- 18.788
  #c - constant to calculate sigma-related priors
  c <- 0.024854444
} else if (countryname == "Chile")
{
  #HTP <- herd true prevalence (beta prior)
  alphaHTP <- 14.2
  betaHTP <- 0.7
  #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
  alphamu1 <- 12.896
  betamu1 <- 172.151
  #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
  alphamu2 <- 28.061
  betamu2 <- 173.629
  #c - constant to calculate sigma-related priors
  c <- 0.236754221
}


today <- format(Sys.Date(), "%Y%m%d")
basename <- tools::file_path_sans_ext(basename(datafile))
output_name <- paste0("prevalence_", countryname, "_", basename, "_", today, ".docx")

rmarkdown::render("Prevalence.Rmd",
                  output_file = output_name,
                  params = list(filename = basename,
                                countryname=countryname,
                                iter=iter,
                                parA = parA,
                                parB = parB,
                                parC = parC,
                                Sp_const = Sp_const,
                                alphamu1 = alphamu1,
                                betamu1 = betamu1,
                                alphamu2 = alphamu2,
                                betamu2 = betamu2,
                                alphaHTP = alphaHTP,
                                betaHTP = betaHTP,
                                alphasigmasq=alphasigmasq,
                                betasigmasq=betasigmasq,
                                alphasigm1sq=alphasigm1sq,
                                betasigm1sq=betasigm1sq,
                                alphasigm2sq=alphasigm2sq,
                                betasigm2sq=betasigm2sq
                               ))