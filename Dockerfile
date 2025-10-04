# Stage 2 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

# --- Estágio 1: "Construtor" com uma instalação funcional do Julia ---
# Usamos a imagem oficial do Julia como uma base temporária e a nomeamos 'julia_base'
FROM julia:1.9.3 AS julia_base

# --- Estágio 2: Nossa imagem final com Python e Julia ---
# Começamos com a imagem Python estável que já estávamos usando
FROM python:3.10-bullseye

# Define o diretório de trabalho
WORKDIR /app

# Copia a instalação completa do Julia do estágio anterior para a nossa imagem final
# Esta é a mágica do multi-stage build!
COPY --from=julia_base /usr/local/julia /usr/local/julia

# Adiciona o executável do Julia ao PATH do sistema
# Isso permite que o shell encontre e execute o comando 'julia'
ENV PATH="/usr/local/julia/bin:${PATH}"

# Agora, instale as dependências do Python normalmente
RUN pip install numpy
