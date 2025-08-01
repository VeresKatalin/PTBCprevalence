# Setting work folder to the folder containing the data of the cows and the stan file. Use / to separate levels. 
# Results will be saved here.
setwd("C:/.../..")

#number of iterations, 20000 is suggested
iter<-20000

#name of input file with cow level data in the above folder
datafile <- "teszt.csv"

#name of the country
#this will be part of the name of the output and set the priors
countryname <- "Hungary"
#countryname <- "Denmark"
#countryname <- "S_Italy"
#countryname <- "Lombardy"
#countryname <- "Veneto"
#countryname <- "Chile"

#if your country or region is in the list above, you can stop here
########################################################################
########################################################################


#priors for custom country, provide a country name different from the ones above

if (!(countryname %in% (c("Hungary", "Denmark", "S_Italy",  "Lombardy", "Veneto", "Chile"))))
{
  #custom priors here 
 
      #HTP <- herd true prevalence (beta prior)
      alphaHTP <- 
      betaHTP <- 
      #mu1 -mean conditional within herd prevalence for primiparous cows (beta prior)
      alphamu1 <- 
      betamu1 <- 
      #mu2 - mean conditional within herd prevalence for multiparous cows (beta prior)
      alphamu2 <- 
      betamu2 <- 
      
      #sigmasq
      alphasigmasq <- 
      betasigmasq  <- 
      #sigm1sq
      alphasigm1sq <- 
      betasigm1sq  <- 
      #sigm2sq
      alphasigm2sq <- 
      betasigm2sq  <- 
      
      #do not change
      c <- 1
} 

source("Run_model.R")