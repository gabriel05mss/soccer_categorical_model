setwd("C:/Users/gmore/OneDrive/Desktop/MCCD/stan")

#numeros de times
n_times <- 40

# combinando para todos jogarem como mandante e visitante
h = rep(1:n_times, each = n_times)
a = rep(1:n_times, times = n_times)

#excluindo os duplicados
tabela <- data.frame(h,a)
tabela <- tabela[tabela$h != tabela$a , ]

#numero de jogos
n_jogos <- length(tabela$h)

#efeito de jogar em casa
home_f <- 0.35

#b0
b0 <- -0.1

#efeito de ataque e defesa
att <- rnorm(n_times, 0 , 0.2)
def <- rnorm(n_times, 0 , 0.2)

#gerar resultados dos jogos
simulate_games <- function(tabela){
  n_jogos <- length(tabela$h)
  home <- tabela$h
  away <- tabela$a
  
  theta_1 <- b0 + home_f + att[home] + def[away]
  theta_2 <- b0 + att[away] + def[home]
  
  y1 <- rpois(n_jogos, exp(theta_1))
  y2 <- rpois(n_jogos, exp(theta_2))
  
  tabela$y1 <- y1
  tabela$y2 <- y2  
  
  assign("tabela", tabela, envir = .GlobalEnv)
}

simulate_games(tabela)

# adicionar resultados das partidas a tabela

# iniciar vetor nulo com tamanho da tabela
resultados_jogos <- vector("integer", length(tabela))

# classificar 1 como derrota , 3 como empate e 3 como vitoria , todos com o time da casa como referencia  
class <- for (i in 1 : nrow(tabela)) {
  y1 <- tabela$y1
  y2 <- tabela$y2
  if(y1[i] < y2[i]) {
    resultados_jogos[i] <- "1"
  } else if(y1[i] == y2[i]){
    resultados_jogos[i] <- "2"
  } else{
    resultados_jogos[i] <- "3"
  }
}

# anexar os resultados a tabela
tabela <- cbind(tabela, R = resultados_jogos)

#tranformar os resultados em numerico para funcionamento do modelo
tabela$R <- as.numeric(tabela$R)

# criar data stan
data_stan <- append(list(K = 3 , G = n_jogos , T = n_times), as.list(tabela))

library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

modelo<- stan_model(file = "logit_fut.stan")
fit <- sampling(modelo,iter = 5000,thin = 2 , data = data_stan, cores = 4, chains = 4)
fit

 
shinystan::launch_shinystan(fit)


#alguma cadeia teve erro , mensahem do pacote pediu para usar 1 cadeia para verificar 

