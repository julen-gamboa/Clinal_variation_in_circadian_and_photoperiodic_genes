#################
# DBSCAN cluster validation script.
# This script takes the tuned hyperparameter values (epsilon and minPts)
# and reruns dbscan prior to cluster validation with silhouette visualisation
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com

library(tibble)
library(magrittr)
library(dplyr)
library(tidyr)
library(dbscan)
library(purrr)
library(cluster)
# do not load tidylog or clusterSim packages to avoid the hyperparameter tuning
# section from running. tidylog hides 'select' from dplyr and clusterSim hides
# dbscan.

data(banknote, package = "mclust")

swissTib = select(banknote, -Status) %>% 
  as_tibble()

# IHS normalisation function
ihs = function(x) {
  log(x + sqrt(x ^ 2 + 1))
}

# Scale/normalise because dbscan is sensitive to variable scales.
swissScaled = swissTib %>% ihs()

# Silhoutte metric on selected eps and minPts combination

d_ihs = dist(swissScaled)
str(d_ihs)
d_ihs
# DBSCAN on selected hyperparameters after hyperparameter tuning

swissDbscan = dbscan(swissScaled, eps = 0.058, minPts = 9)

library(factoextra)
# Need the cluster vector as the first argument
fviz_silhouette(silhouette(swissDbscan$cluster, d_ihs))
#   cluster size ave.sil.width
# 0       0    8         -0.30
# 1       1  106          0.51
# 2       2   86          0.56