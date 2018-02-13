###########################################################
# You may be able to get this to work with shell          #
# I tend to lean bash and have used that environment here #
###########################################################
SHELL := /bin/bash

###########################
# keep intermediate files #
###########################
.SECONDARY:

###################
# set some values #
###################
CPU_LIST := $(shell cat cpu_tests.txt)
ITERATION_LIST := $(shell cat iterations.txt)
FASTA := fasta/Hsapiens_GRCh38.fa
RELEASE := 91
DIRS := motifs logs fasta benchmark
MOTIFS := $(shell cat motif_list.txt)
OUTPUT_MOTIF_FILES := $(addprefix motifs/, $(addsuffix .csv, $(MOTIFS) ) )

BENCHMARK_LOGS := $(addprefix benchmark/, $(CPU_LIST))
BENCHMARK_LOGS := $(foreach ITER, $(ITERATION_LIST), $(addsuffix _$(ITER), $(BENCHMARK_LOGS) ) )
BENCHMARK_LOGS := $(foreach MOTIF, $(MOTIFS), $(addsuffix _$(MOTIF), $(BENCHMARK_LOGS) ) )
BENCHMARK_LOGS := $(addsuffix .log, $(BENCHMARK_LOGS) )

#######
# run #
#######
all: $(DIRS) $(FASTA) $(BENCHMARK_LOGS) $(OUTPUT_MOTIF_FILES)
	@echo CPUS: $(CPU_LIST)
	@echo ITERATIONS: $(ITERATION_LIST)
	@echo Ensembl release: $(RELEASE)
	@echo directories: $(DIRS)
	@echo motifs: $(MOTIFS)
	@echo benchmark logs: $(BENCHMARK_LOGS)
	@echo output files: $(OUTPUT_MOTIF_FILES)
	
###############
# Directories #
###############
$(DIRS):
	mkdir -p $@
	
########################
# download human fasta #
########################
fasta/%.fa:
	wget --quiet ftp://ftp.ensembl.org/pub/release-$(RELEASE)/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz -O $@.gz
	gunzip $@.gz
 	
#################
# Do benchmarks #
#################
benchmark/%.log:
	$(eval LOCAL_CPUS=$(firstword $(subst _, ,$*)))
	$(eval LOCAL_MOTIF=$(lastword $(subst _, ,$*)))
	
	/usr/bin/time -f "%e real-time" motif_scraper --motif $(LOCAL_MOTIF) --cores $(LOCAL_CPUS) --outputFile tmp.csv $(FASTA) 1>$@ 2>&1
	rm tmp.csv
	
########################
# Save actual analysis #
########################
motifs/%.csv:
	motif_scraper --motif $* --outputFile $@ $(FASTA) 1>logs/$*_keep.log 2>&1
	