data {
  int<lower = 2> K; //quantidade de classes, nesse caso será 3 pois é derrota, empate e vitoria 
  int<lower = 1> G; // numero de jogos modelo poisson == numero de observações do modelo logit
  int<lower = 1> T; // numero de times
  int<lower = 0,upper = T> h[G]; // time da casa do jogo G
  int<lower = 0,upper = T> a[G]; // time visitante do jogo G
  int<lower = 0> y1[G]; //numeros de gols para o time da casa
  int<lower = 0> y2[G]; // numero de gols do time da casa
  int<lower = 1 , upper = K> R[G]; //vetor de resultados dos jogos
}
parameters {
  real home; // estimativa do efeito de jogar de jogar em casa
  real mu; //estimava de media
  real<lower = 0> sigma_att; //estimativa da variancia dos efeitos de ataque
  real<lower = 0> sigma_def; //estimativa da variancia dos efeitos de ataque
  vector[T] att; //estimativa dos efeitos de ataque de cada time 
  vector[T] def; //estimativa dos efeitos de defesa decada time
  real beta_1; // estimativa do beta
  real beta_2;
  ordered[K-1] c; //estimativa dos pontosde corte ,variavel latente
}
model {
  for( g in 1:G) {
    y1[g] ~ poisson_log(mu + home + att[h[g]] + def[a[g]]);
    y2[g] ~ poisson_log(mu + att[a[g]] + def[h[g]]);
  }
  for(t in 1:T) {
    att[t] ~ normal(0 , sigma_att);
    def[t] ~ normal(0 , sigma_def);
  }
  for(g in 1:G) {
    R[g] ~ ordered_logistic( -(att[h[g]] + def[a[g]]) * beta_1 -(att[a[g]] + def[h[g]]) * beta_2 , c);
  }
  home ~ normal(0 , 10);
  mu ~ normal(0 , 10);
  beta_1 ~ normal(0 , 10);
  beta_2 ~ normal(0 , 10);
  sigma_att ~ cauchy(0 , 2.5);
  sigma_def ~ cauchy(0 , 2.5);
}
