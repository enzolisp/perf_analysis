# Stage 2 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266

Finite Difference Methods

Explicit scheme (forward euler) <- resolucao da edp

https://github.com/reamat/CalculoNumerico


## Repository Structure
```
.
├── Dockerfile      --> source code for building python and julia images
├── docs            --> all sorts of documents used 
│   ├── material
│   ├── relatorio
│   └── slides
├── experiments-csv -->
├── plano.csv       -->
├── rand_exp.R      --> R script for randomizeing all experimentation cases
├── README.md   
├── requirements.txt    
├── results.csv         --> csv file for keeping results
├── run_experiment.sh --> bash script to run experiments
└── src
    ├── 1d.jl
    ├── 1d.py
    ├── 2d.jl
    └── 2d.py
```

## Run Experiments
makefile?

```
docker build -t calor:latest .
```

## Usage
 
#