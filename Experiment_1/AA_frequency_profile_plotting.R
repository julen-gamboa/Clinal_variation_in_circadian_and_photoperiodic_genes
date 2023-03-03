#################
# Script to manipulate amino acid frequency data for cd-hit output
# prior to plotting individual barplots to represent specific 
# frequency profiles for each of the 9 million+ protein sequences
# contained in the input file.
# The input file has been split for convenience into subsets of 
# 100,000 individual sequences but it can be divided further to
# accomodate memory requirements.
# The bash command used was:
# split --verbose -l 100000 H_sapiens_all_100pc_cd_hit_normalized_ihs.tsv H_sapiens_cd_hit_100pc_AA_frequencies_
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com


# Load libraries
library(readr)
library(tidyr)
library(purrr)
library(ggplot2)

# Plot all these in a separate "Plots" directory.

data_aa = read.delim("../normalised_aa_frequencies/H_sapiens_cd_hit_100pc_AA_frequencies_aa", sep = "\t",
                     header = T)
aminoacids = c("A","R","N","D","C","Q","E","G","H","I","L","K","M","F","P","S"
               ,"T","W","Y","V","X")

df_tidy = pivot_longer(data_aa, cols = aminoacids, 
                        names_to = "Residues", 
                        values_to = "Frequency")

df_list = split(df_tidy, df_tidy$ID)

plots = map(df_list, function(df){
  ggplot(df, aes(x=Residues, y=Frequency)) +
    geom_bar(stat="identity") +
    ylim(0, 8.6) +
    theme_classic() 
#    ggtitle(unique(df$ID))
  
  # Save each plot locally with a unique name based on the ID
  ggsave(paste0("plot_", unique(df$ID), ".jpeg"), bg = NULL, width = 8, height = 6)
  
})
