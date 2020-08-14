data {
  int n;
  int I;
  real e[n]; //expression
  int m[n]; //mutation
  int i[n]; //case
}
parameters {
  real<lower=0> s;
  real alpha;
  real alpha_m[2];
  
  real r_i[I];
  real<lower=0> t;
  
  real<lower=0> v;
}

transformed parameters {
  real alpha_j[n];
  real r_j[n];
  real beta_j[n];
  real delta;
  
  for (k in 1:n){
     alpha_j[k] = alpha_m[m[k]+1];
     r_j[k] = r_i[i[k]];
     beta_j[k] = alpha_j[k] + r_j[k];
  }
  
  delta = alpha_m[2] - alpha_m[1];
  
}
model {
  alpha ~ cauchy(0.0, 1.0);
  s ~ cauchy(0.0, 1.0);
  t ~ cauchy(0.0, 1.0);
  v ~ cauchy(0.0, 1.0);
  alpha_m[1] ~ cauchy(alpha, s);
  alpha_m[2] ~ cauchy(alpha, s);
  
  for (k in 1:I){
    r_i[k] ~ cauchy(0.0, t);
  }
  
  for (k in 1:n){
      e[k] ~ normal(beta_j[k], v);
  }
}

