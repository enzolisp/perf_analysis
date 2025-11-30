# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

FROM julia:1.9.3 AS julia_base
FROM python:3.10-bullseye

WORKDIR /app

COPY --from=julia_base /usr/local/julia /usr/local/julia

ENV PATH="/usr/local/julia/bin:${PATH}"

RUN pip install numpy
