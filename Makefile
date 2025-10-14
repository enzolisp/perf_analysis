# Stage 3 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266 

DEP = rand_exp.R run_experiment.sh

run: $(DEP)
	Rscript rand_exp.R
	bash run_experiment.sh