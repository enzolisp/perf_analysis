# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

#fatores e seus níveis
fatores <- list(
  linguagem = c("python", "julia"),
  dimensao  = c("1d", "2d", "3d"),
  size      = c("low", "mid", "high") # Incluindo o novo nível "mid"
)

#cria uma tabela com todas as 12 combinações únicas (2 * 2 * 3)
plano_base <- expand.grid(fatores)

print("Plano base com as 12 combinações únicas:")
print(plano_base)

REPLICACOES <- 50 #era 10

# repetir com base em REPLICACOES
plano_replicado <- plano_base[rep(1:nrow(plano_base), each = REPLICACOES), ]
rownames(plano_replicado) <- NULL # Limpa os nomes das linhas para evitar confusão

#ordem aleatoria de execução
set.seed(26052) 

plano_final_aleatorizado <- plano_replicado[sample(nrow(plano_replicado)), ]

print("Cabeçalho do plano de execução final e aleatorizado:")
print(head(plano_final_aleatorizado))

print("Dimensões do plano final:")
print(dim(plano_final_aleatorizado))
write.csv(plano_final_aleatorizado, "plano.csv", row.names = FALSE, col.names = FALSE)
