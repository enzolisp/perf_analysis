# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266 


run_experiments: $(DEP1)
	Rscript rand_exp.R
	bash run_experiment.sh

plot_data: 
	mkdir -p graphs/
	Rscript scripts/generate_boxplots_mem.R
	Rscript scripts/generate_combined_boxplots.R
	Rscript scripts/generate_comparison_boxplots.R
	Rscript scripts/generate_control_charts.R
	Rscript scripts/generate_general_boxplot.R
	Rscript scripts/generate_general_comparison.R
	Rscript scripts/generate_individual_boxplots.R
	Rscript scripts/generate_linear_regression_mem.R
	Rscript scripts/generate_linear_regression_mempeak.R
	Rscript scripts/generate_linear_regression_texec.R
	
	
	