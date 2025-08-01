
functions {
  vector inv_beta (vector y,
                   vector theta,
                   real[] x_r,
                   int[] x_i) {
    vector[1] f_y;
    f_y[1] = beta_cdf(inv_logit(y[1]),theta[1],theta[2])-theta[3];
    //inv_logit(y[1]):expected value of beta distribution, tipp for initializing the solver
    //solved for = 0, this is the reason for substracting theta[3]
    return f_y;
  }
}
data {
  int<lower=0> nAgegr_primi;     // Number of age groups for primis
  int<lower=1> nAllRec;          // Number of agegroups in primis + multis (all records in PTBCHerd2)
  int<lower=0> nCOW[nAllRec];    // Number of cows in by parity and agegroup - PTBCHerd2
  int<lower=0> POS[nAllRec];     // Number of positive cows by parity and agegroup - PTBCHerd2
  real<lower=0> AgeG[nAllRec];   // Age groups by parity - PTBCHerd2, measured in years
  real<lower=0> alphamu1;   // alpha parameter of the beta prior for mean conditional within herd prevalence of primiparous cows
  real<lower=0> betamu1;     // beta parameter of the beta prior for mean conditional within herd prevalence of primiparous cows
  real<lower=0> alphamu2;   // alpha parameter of the beta prior for mean conditional within herd prevalence of multiparous cows
  real<lower=0> betamu2;     // beta parameter of the beta prior for mean conditional within herd prevalence of multiparous cows
  real<lower=0, upper=1> Sp_const;     // 
    real<lower=0> parA;     // Parameters of the model of age-dependent sensitivity (Meyer et al. 2018) 
  real<lower=0> parB;   // Parameters of the model of age-dependent sensitivity (Meyer et al. 2018)
  real<lower=0> parC;     // Parameters of the model of age-dependent sensitivity (Meyer et al. 2018)
  real<lower=0>  alphasigmasq;
  real<lower=0>  betasigmasq;
  real<lower=0>  alphasigm1sq;
  real<lower=0>  betasigm1sq;
  real<lower=0>  alphasigm2sq;
  real<lower=0>  betasigm2sq;
  }

transformed data {//used by algebra-solver
  real x_r[0];
  int x_i[0];
  real rel_tol    = 10^(-4);//relative error
  real f_tol      = 1;//absolute error, putting 1 turns off the checking and prevent the sampler to stop
  real max_steps  = 10^4;// max number of iterations
}

parameters {
  real <lower = 0.00001, upper = 1> mu1;  // Mean CWHP for primiparous cows
  real <lower = 0.00001, upper = 1> mu2;  // Mean CWHP for primiparous cows
  real eta; // Herd level random effects
  real et1; // Additional herd level random effects for primiparous cows
  real et2; // Additional herd level random effects for multiparous cows
  real <lower = 0.00001> sigmasq; // sd of the herd level random effects - common baseline
  real <lower = 0.00001> sigm1sq; // Variance of the additional herd level random - primiparous
  real <lower = 0.00001> sigm2sq; // Variance of the additional herd level random - multiparous
}

transformed parameters {
  
}

model {

  vector[3] theta;//used in inv_beta
  
  real lmu1;
  real lmu2;
  
  real CWHP1; // Conditional within-herd animal-level prevalence among primiparous cows
  real CWHP2; // Conditional within-herd animal-level prevalence among multiparous cows
  
  real pi1;    // Apparent prevalence among primiparous cows
  real pi2;    // Apparent prevalence among multiparous cows
  real Se;     // Sensitivity
  real Sp; // Specificity
  real t1;

  real pszi1;
  real pszi2;

  real wgt1;
  real wgt2;
  real wgt3;
  real wgt4;
  
 
  //Priors for the mean true prevalence of primiparous and multiparous cows
  target += beta_lpdf(mu1 | alphamu1, betamu1);
  target += beta_lpdf(mu2 | alphamu2, betamu2);
  target += inv_gamma_lpdf(sigmasq | alphasigmasq, betasigmasq);
  target += inv_gamma_lpdf(sigm1sq | alphasigm1sq,  betasigm1sq);
  target += inv_gamma_lpdf(sigm2sq | alphasigm2sq, betasigm2sq);
  target += normal_lpdf(eta | 0, 1);
  target += normal_lpdf(et1 | 0, 1);
  target += normal_lpdf(et2 | 0, 1);

  // Specificity (Meyer et al. 2018)
  Sp = Sp_const;
   
  lmu1=logit(mu1);
  lmu2=logit(mu2);
  
  pszi1 = (sigmasq+sigm1sq)^(-1);//dispersion model 
  pszi2 = (sigmasq+sigm2sq)^(-1);
 
  wgt1  = sqrt(sigmasq/(sigmasq+sigm1sq));//weighting variances, squared sum equals 1
  wgt2  = sqrt(sigm1sq/(sigmasq+sigm1sq));
  wgt3  = sqrt(sigmasq/(sigmasq+sigm2sq));
  wgt4  = sqrt(sigm2sq/(sigmasq+sigm2sq));
  
    theta[1] = mu1*pszi1;//"a" parameter for inverse-beta distribution
    theta[2] = (1-mu1)*pszi1;//"b" parameter for inverse-beta distribution
    theta[3] = (normal_cdf(wgt1*eta+wgt2*et1, 0, 1)+0.001)*0.999;//has uniform distribution
    //probability->quantile

    CWHP1 = inv_logit(algebra_solver(inv_beta, [lmu1]', theta, x_r, x_i,
               rel_tol, f_tol, max_steps)[1]); 
               //inverse-beta(normal_cdf(eta[n]))
               //[lmu1]': number, should by specified in this format for algebra-solver

    theta[1] = mu2*pszi2;
    theta[2] = (1-mu2)*pszi2;
    theta[3] = (normal_cdf(wgt3*eta+wgt4*et2, 0, 1)+0.001)*0.999;
    CWHP2 = inv_logit(algebra_solver(inv_beta, [lmu2]', theta, x_r, x_i,
               rel_tol, f_tol, max_steps)[1]);
 

  // The loglikelihood 
    t1 = 0; // Loglikelihood component if herd n is supposed to be infected
  
    // Primiparous cows
    for (k in 1:nAgegr_primi) {

      // Age-dependent sensitivity of the kth cow
      Se = inv_logit(parA-parB*exp(-parC*AgeG[k]));

      // Apparent prevalence
      pi1   = Se*CWHP1 + (1-Sp)*(1-CWHP1);
      
      t1 += binomial_lpmf( POS[k] | nCOW[k], pi1);
      
    }

    // Multiparous cows
    for (k in (nAgegr_primi+1):nAllRec) {

      // Age-dependent sensitivity of the kth cow
      Se = inv_logit(parA-parB*exp(-parC*AgeG[k]));

      // Apparent prevalence
      pi2  = Se*CWHP2 + (1-Sp)*(1-CWHP2);

      t1 += binomial_lpmf( POS[k] | nCOW[k], pi2);

    }
     
    // The unconditional loglikelihood component of herd n is added to the loglikelihood total
    target += t1;
  
}

generated quantities {

  real CWHP1;
  real CWHP2;
  
  vector[3] theta;
  
  real pszi1x;
  real pszi2x;
  
  real wgt1x;
  real wgt2x;
  real wgt3x;
  real wgt4x;
  
  real Se;
  real Sp;
  
  real pi1;
  real pi2;
  
  pszi1x = (sigmasq+sigm1sq)^(-1);//dispersion model 
  pszi2x = (sigmasq+sigm2sq)^(-1);
  
  wgt1x  = sqrt(sigmasq/(sigmasq+sigm1sq));//weighting variances, squared sum equals 1
  wgt2x  = sqrt(sigm1sq/(sigmasq+sigm1sq));
  wgt3x  = sqrt(sigmasq/(sigmasq+sigm2sq));
  wgt4x  = sqrt(sigm2sq/(sigmasq+sigm2sq));
  
  theta[1] = mu1*pszi1x;//"a" parameter for inverse-beta distribution
  theta[2] = (1-mu1)*pszi1x;//"b" parameter for inverse-beta distribution
  theta[3] = (normal_cdf(wgt1x*eta+wgt2x*et1, 0, 1)+0.001)*0.999;//has uniform distribution
  
   CWHP1 = inv_logit(algebra_solver(inv_beta, [logit(mu1)]', theta, x_r, x_i,
               rel_tol, f_tol, max_steps)[1]); 
               
   theta[1] = mu2*pszi2x;
   theta[2] = (1-mu2)*pszi2x;
   theta[3] = (normal_cdf(wgt3x*eta+wgt4x*et2, 0, 1)+0.001)*0.999;
   
   CWHP2 = inv_logit(algebra_solver(inv_beta, [logit(mu2)]', theta, x_r, x_i,
               rel_tol, f_tol, max_steps)[1]);
               
Sp = Sp_const;
  
  for (k in 1:nAgegr_primi) {
  
         Se = inv_logit(parA-parB*exp(-parC*AgeG[k]));
        pi1   = Se*CWHP1 + (1-Sp)*(1-CWHP1);
  }
  
  for (k in (nAgegr_primi+1):nAllRec) {
  
         Se = inv_logit(parA-parB*exp(-parC*AgeG[k]));
        pi2   = Se*CWHP1 + (1-Sp)*(1-CWHP1);
  }
      
}