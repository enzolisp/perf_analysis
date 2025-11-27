# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266 

DEP1 = rand_exp.R run_experiment.sh
DEP2 = regressaoMemPeak.R gerarGraficos.R regressaoMediaMem.R regressao_varianca.R

run_experiments: $(DEP1)
	Rscript rand_exp.R
	bash run_experiment.sh

plot_data: $(DEP2)	
	Rscript regressaoMemPeak.R
    Rscript gerarGraficos.R 
    Rscript regressaoMediaMem.R
    Rscript regressao_varianca.R