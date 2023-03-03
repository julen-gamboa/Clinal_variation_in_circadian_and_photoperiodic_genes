#################
# Summary plot script for normalised and raw data
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com

library(readr)
library(ggplot2)

dat_summary = read.delim("summary_all.tsv", sep = "\t",
                              header = T)

dat_summary_norm = read.delim("summary_all_normalized_IHS.tsv", sep = "\t",
                              header = T)


#Summary stats plot (normalised and unnormalised data)

exploratory_plot = ggplot(dat_summary, aes(y=Median, x=as.factor(Aminoacid))) + 
  geom_bar(stat="identity", 
           position="stack", 
           alpha=0.5) + theme_minimal() + 
  theme(text=element_text(family="sans", 
                          face="plain", 
                          color="#000000", 
                          size=15, 
                          hjust=0.5, 
                          vjust=0.5)) + 
  xlab("Amino acid") + 
  ylab("Median number of amino acids per protein")
exploratory_plot

exploratory_plot2 = ggplot(dat_summary_norm, aes(y=Median, x=as.factor(Aminoacid))) + 
  geom_bar(stat="identity", 
           position="stack", 
           alpha=0.5) + theme_minimal() + 
  theme(text=element_text(family="sans", 
                          face="plain", 
                          color="#000000", 
                          size=15, 
                          hjust=0.5, 
                          vjust=0.5)) + 
  xlab("Amino acid") + 
  ylab("Median number of amino acids per protein")
exploratory_plot2
