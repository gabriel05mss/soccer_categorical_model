data {
  int<lower=2> K; // numero de classes
  int<lower=0> N; //numero de observações
  int<lower=1> D; // quantidade de variaveis explicativas
  int<lower=1,upper=K> y[N]; //vetor que contem as categorias 
  matrix[N , D] X; // variaveis explicativas
}
parameters {
  vector[K] alfa; //estimar alfa de cada classe
  vector[D] beta; //estimar beta de cada variavel explicativa
  ordered[K-1] c; //pontos de corte
}
model {
  for (n in 1:N) {
    vector[K] eta = alfa + X[n] * beta;
    y[n] ~ ordered_logistic(eta, c);
  }
  alfa ~ normal(0 , 10);
  beta ~ normal(0 , 10);
//alfa[y[n]] ajusta mal
//alfa[K] muita demora para as iterações e mal ajuste
//alfa  colocar real alfa nos partametros // muita demora para as iterações e mal ajuste
}
