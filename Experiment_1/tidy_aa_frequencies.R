#################
# Script to turn the amino acid frequency data into long format for plotting
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com
library(readr)
library(tidyr)
library(purrr)
library(ggplot2)

data_all = read.delim("H_sapiens_all_100pc_cd_hit_normalized_IHS.tsv", sep = "\t",
                      header = T)

#df_max <- apply(data_all, 1, max, na.rm=TRUE)

aminoacids = c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S"
               ,"T","W","Y","V","X")

df_tidy = pivot_longer(data_all, cols = aminoacids, 
                       names_to = "Residues", 
                       values_to = "Frequency")

write.table(df_tidy, file = "H_sapiens_all_100pc_cd_hit_normalized_tidy_format.tsv", 
            row.names=FALSE, sep="\t")


