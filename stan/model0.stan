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
  real r_ij[n];
  real<lower=0> t;
  real<lower=0> t_i[I];
  
}

transformed parameters {
  real alpha_ij[n];
  real e_ij[n];
  
  for (k in 1:n){
     alpha_ij[k] = alpha_m[m[k]+1];
     e_ij[k] = alpha_ij[k] + r_ij[k];
  }
  
}
model {
  alpha ~ cauchy(0.0, 1.0);
  s ~ cauchy(0.0, 1.0);
  t ~ cauchy(0.0, 1.0);
  alpha_m[1] ~ cauchy(alpha, s);
  alpha_m[2] ~ cauchy(alpha, s);
  
  for (k in 1:I){
    r_i[k] ~ cauchy(0.0, t);
    t_i[k] ~ cauchy(0.0, 1.0);
  }
  for (k in 1:n){
      r_ij[k] ~ cauchy(r_i[i[k]], t_i[i[k]]);
  }
}

