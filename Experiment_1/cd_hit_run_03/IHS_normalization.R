#################
# Script to transform the data for downstream analysis
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com
library(readr)
library(tidyr)

data_all = read.delim("H_sapiens_training_set_aa_frequencies.tsv", sep = "\t",
                      header = F)

# Inverse hyperbolic sine (IHS) transformation as an option works best
ihs = function(x) {
  log(x + sqrt(x ^ 2 + 1))
}
# to invert the IHS 
# sinh(x)

# apply IHS normalization 
dat_norm_ihs = as.data.frame(lapply(data_all[2:22], ihs))

# Reconstitute the dataframe
dat_norm_ihs_all = as.data.frame(cbind(data_all$V1, dat_norm_ihs))
colnames(dat_norm_ihs_all) = c("ID","A","R","N","D","C","Q","E","G","H",
                           "I","L","K","M","F","P","S","T","W","Y",
                           "V","X")

write.table(dat_norm_ihs_all, file = "H_sapiens_training_set_normalized_IHS.tsv", 
            row.names=FALSE, sep="\t")

#data_all = read.delim("H_sapiens_all_100pc_cd_hit_normalized_IHS.tsv", sep = "\t",
#                      header = T)
summary(data_all)
summary(dat_norm_ihs_all)
