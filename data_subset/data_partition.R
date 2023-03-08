#################
# Short script to randomly partition the H. sapiens gnomAD v3 dataset
# prior to clustering with cd-hit, aa frequency estimation, normalisation,
# and ML classification and clustering algos
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com
library(here)
library(readr)

# retrieve the requisite dataset using the here() function
here()

data = read.delim("H_sapiens_linearized_wo_control_and_clock_set.out", 
                  header = FALSE, sep = "\t")

sample_size = floor(0.8*nrow(data))
set.seed(5391)

selected = sample(seq_len(nrow(data)), size = sample_size)
training_set = data[selected, ]
holdout_set = data[-selected, ]

write_tsv(training_set, "training_set.tsv")
write_tsv(holdout_set, "holdout_set.tsv")
