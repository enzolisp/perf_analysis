# Stage 1 - Comp. Sys. Perf Analysis (2025/2) - Lucas M. Schnorr
# Group F: Enzo Lisboa Peixoto - 00584827, Nathan Mattes - 00342941 e Pedro Scholz Soares - 00578266 

SUBDIRS = slides relatorio
SUBDIRSCLEAN=$(addsuffix clean,$(SUBDIRS))

clean: $(SUBDIRSCLEAN)

clean_curdir:
	rm *.log *.aux *.out

%clean: %
	$(MAKE) -C $< -f $(PWD)/Makefile clean_curdir
