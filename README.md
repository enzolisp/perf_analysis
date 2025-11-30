# Stage 3 - Comp. Sys. Perf Analysis (2025/2)<br/>Lucas M. Schnorr
> ## Group F:<br/>Enzo Lisboa Peixoto - 00584827<br/>Nathan Mattes - 00342941<br/>Pedro Scholz Soares - 00578266

Finite Difference Methods

Explicit scheme (forward euler) <- resolucao da edp

https://github.com/reamat/CalculoNumerico


### Repository Structure
```
.
├── Dockerfile
├── Makefile
├── README.md
├── Rplots.pdf
├── docs
│   ├── imagensEtapa2
│   ├── imagensEtapa3
│   ├── material
│   ├── relatorio
│   └── slides
├── notebooks
├── plano.csv
├── rand_exp.R
├── results
│   └── main.ipynb
├── run_experiment.sh
├── scripts
│   ├── generate_boxplots_mem.R
│   ├── generate_combined_boxplots.R
│   ├── generate_comparison_boxplots.R
│   ├── generate_control_charts.R
│   ├── generate_general_boxplot.R
│   ├── generate_general_comparison.R
│   ├── generate_individual_boxplots.R
│   ├── generate_linear_regression_mem.R
│   ├── generate_linear_regression_mempeak.R
│   ├── generate_linear_regression_texec.R
│   └── read_csv.R
├── src
│   ├── julia
│   └── python
└── stats
    ├── performance
    └── results
```

### Run Experiments
```
docker build -t calor:latest .
```

### Usage
```
make run-experiments
```
```
make plot-data
```
### Docker 
