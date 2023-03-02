# Exploratory data analysis for cd-hit derived amino acid frequencies
# for 9,120,437 distinct protein sequences.
# j.a.r.gamboa@gmail.com

library(readr)
library(ggplot2)
library(caret)

data_all = read.delim("H_sapiens_all_100pc_cd_hit_aa_freqs.tsv", sep = "\t",
                      header = T)

data_summary = data.frame(unclass(summary(data_all)), check.names = FALSE)

dat_summary = read.delim("summary_all.tsv", sep = "\t",
                         header = T)

# Normalise the dataset
process = preProcess(as.data.frame(data_all), method = c("range"))

norm_scale = predict(process, as.data.frame(data_all))

write.csv(norm_data, file = "H_sapiens_all_100pc_cd_hit_normalized.csv")

dat_summary_norm = read.delim("summary_all_normalized.tsv", sep = "\t",
                              header = T)

#Summary stats plot (normalised and unnormalised data)

exploratory_plot = ggplot(dat_summary, aes(y=Mean, x=as.factor(Aminoacid))) + 
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
  ylab("Mean number of amino acids per protein")
exploratory_plot

exploratory_plot2 = ggplot(dat_summary_norm, aes(y=Mean, x=as.factor(Aminoacid))) + 
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
  ylab("Mean number of amino acids per protein")
exploratory_plot2
