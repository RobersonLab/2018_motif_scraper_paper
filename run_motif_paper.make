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
DIRS := motifs logs fasta benchmark fimo fimo_benchmark std_fimo

MOTIFS := $(shell cat motif_list.txt)
OUTPUT_MOTIF_FILES := $(addprefix motifs/, $(addsuffix .csv, $(MOTIFS)))

MEMES := $(shell cat meme_list.txt)
OUTPUT_FIMO_FILES := $(addprefix fimo/, $(addsuffix .tsv, $(MEMES)))

STD_FIMO_OUT := $(addprefix std_fimo/, $(addsuffix /fimo.txt, $(MEMES)))

BENCHMARK_LOGS := $(addprefix benchmark/, $(CPU_LIST))
BENCHMARK_LOGS := $(foreach ITER, $(ITERATION_LIST), $(addsuffix _$(ITER), $(BENCHMARK_LOGS) ) )
BENCHMARK_LOGS := $(foreach MOTIF, $(MOTIFS), $(addsuffix _$(MOTIF), $(BENCHMARK_LOGS) ) )
BENCHMARK_LOGS := $(addsuffix .log, $(BENCHMARK_LOGS) )

FIMO_BENCHMARK_LOGS := $(addprefix fimo_benchmark/, 1)
FIMO_BENCHMARK_LOGS := $(foreach ITER, $(ITERATION_LIST), $(addsuffix _$(ITER), $(FIMO_BENCHMARK_LOGS)))
FIMO_BENCHMARK_LOGS := $(foreach MEME, $(MEMES), $(addsuffix _$(MEME), $(FIMO_BENCHMARK_LOGS)))
FIMO_BENCHMARK_LOGS:= $(addsuffix .log, $(FIMO_BENCHMARK_LOGS))

#######
# run #
#######
all: $(DIRS) $(FASTA) $(BENCHMARK_LOGS) $(FIMO_BENCHMARK_LOGS) $(OUTPUT_MOTIF_FILES) $(OUTPUT_FIMO_FILES) $(STD_FIMO_OUT)
	@echo CPUS: $(CPU_LIST)
	@echo ITERATIONS: $(ITERATION_LIST)
	@echo Ensembl release: $(RELEASE)
	@echo directories: $(DIRS)
	@echo motifs: $(MOTIFS)
	@echo benchmark logs: $(BENCHMARK_LOGS)
	@echo output files: $(OUTPUT_MOTIF_FILES)
	@echo fimo benchmark logs: $(FIMO_BENCHMARK_LOGS)
	@echo fimo output: $(OUTPUT_FIMO_FILES)
	
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
 	
##############
# benchmarks #
##############
benchmark/%.log:
	$(eval LOCAL_CPUS=$(firstword $(subst _, ,$*)))
	$(eval LOCAL_MOTIF=$(lastword $(subst _, ,$*)))
	
	/usr/bin/time -f "%e real-time" motif_scraper --motif $(LOCAL_MOTIF) --cores $(LOCAL_CPUS) --outputFile tmp.csv $(FASTA) 1>$@ 2>&1
	rm tmp.csv
	
###################
# fimo benchmarks #
###################
fimo_benchmark/%.log:
	$(eval LOCAL_MEME=$(lastword $(subst _, ,$*)))
	
	/usr/bin/time --output=$@ -f "%e real-time" fimo --thresh 0.01 --text memes/$(LOCAL_MEME).meme $(FASTA) > tmp.tsv
	rm tmp.tsv
	
########################
# Save actual analysis #
########################
motifs/%.csv:
	motif_scraper --motif $* --outputFile $@ $(FASTA) 1>logs/$*_keep.log 2>&1

#####################
# run and keep fimo #
#####################
fimo/%.tsv:
	fimo --thresh 0.01 --text memes/$*.meme $(FASTA) > $@

##################################
# standard output with filtering #
##################################
std_fimo/%/fimo.txt:
	/usr/bin/time --output=std_fimo/$*_default_fimo_time.log -f "%e real-time" fimo --o std_fimo/$* memes/$*.meme $(FASTA) 1>std_fimo/$*_run.log 2>&1

