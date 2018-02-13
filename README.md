# 2018 motif scraper paper
Code used to generate the motif scraper paper.

## Directory layout
The top-level of the folder contains the Makefile and associated text files to generate timing data for the sequence motifs.

The R Markdown file can be executed after Make to generate the figure and stats.

Other directories are generated by Make automatically.

## Running the analysis

### Requirements
The work was run on a computer running Ubuntu, so the requirements are assuming the code would be run in a Linux environment. You may be able to modify it to run in other environments.

**System**

* Linux
* bash
* make
* wget
* gunzip
* time
* Python
* motif_scraper
* RStudio

**R packages**

* tidyverse
* cowplot
* stringr (if not included in your tidyverse version)

### Modifications
The motifs searched, iterations, and number of CPUs can be altered.

cpu_tests - Alter the numbers to increase / decrease the number of CPUs tested.

iterations - Alter numbers to increase / decrease number of iterations **per CPU**.

motif_list.txt - Every motif listed in the file will be searched independently in separate runs. Add / remove as needed. The only requirement is the motif should only include IUPAC approved single-base letters.

### Running analysis

```bash
pip install motif_scraper
```

```bash
git clone https://github.com/RobersonLab/2018_motif_scraper_paper.git
```

```bash
nohup make -f run_motif_paper.make 1>motif_paper.log 2>&1 &
```

Once Make exits **without error**, right-click and open the R Markdown in a new RStudio session. Knit to generate figure and stats.
