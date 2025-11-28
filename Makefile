# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266 


run_experiments: $(DEP1)
	Rscript rand_exp.R
	bash run_experiment.sh

plot_data: 
	Rscript scripts/gerarBoxplot.R
	Rscript scripts/outrosGraficos.R
	Rscript scripts/plotMemUse.R
	Rscript scripts/regressao_varianca.R
	Rscript scripts/regressaoMediaMem.R
	Rscript scripts/regressaoMemPeak.R
	Rscript scripts/gerarGraficos.R 
	
	