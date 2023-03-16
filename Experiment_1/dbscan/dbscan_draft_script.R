#################
# DBSCAN draft script adapted from Hefin I. Rhys's version.
# It has been edited in places to perform IHS normalisation instead of
# the usual scaling or min-max normalisation.
# The internal metrics function has also been altered to stick with the more
# robust Dunn index instead and the resulting plot aesthetics have been inverted
# to better visualise the relationship between meanValue and num.
# I have retained the metricsTibSummary lines in case regular scaling/normalisation
# were desired for comparison as the result would require removing INF and NAs.
#################
# Author: J. Gamboa
# email: j.a.r.gamboa@gmail.com

library(tibble)
library(magrittr)
library(dplyr)
library(tidyr)
library(GGally)
library(dbscan)
library(purrr)
library(viridis)
library(cluster)


data(banknote, package = "mclust")

swissTib = select(banknote, -Status) %>% 
  as_tibble()

# IHS normalisation function
ihs = function(x) {
  log(x + sqrt(x ^ 2 + 1))
}

# Scale/normalise because dbscan is sensitive to variable scales.
swissScaled = swissTib %>% ihs()

#plot
ggpairs(swissTib, upper = list(continuous = "density")) +
  theme_light()

# plot knn with dbscan to select a value of epsilon (search distance)
# the value of k states the number of nearest neighbours to calculate distance
# to. The position of the knee on the plot is relatively robust to changes in
# k but you might want to test that yourself.
# The kNNdistplot() function creates a distance matrix with nrows = number of 
# case and ncols = the distance between each case and its k nearest-neighbours.

kNNdistplot(swissScaled, k = 5)
abline(h = c(0.043, 0.077), col = "red")

# define hyperparameter space for epsilon and minPts.
# search across a range of values of epsilon (eps) with a step size of your 
# choosing and across values of minPts between 1 and 9, with a step size of 1.
dbsParamSpace = expand.grid(eps = seq(0.043, 0.077, 0.001),
                            minPts = seq(1, 9, 1))

# run dbscan on each combination of hyperparameters using the purrr pmap() 
# function to apply the dbscan() function to each row of the dbsParamSpace 
# object.
swissDbs = pmap(dbsParamSpace, dbscan, x = swissScaled)


# cluster memberships from dbscan permutations
# Extract cluster memberships as a separate column using the map_dfc() function
# and bind to the swissTib tibble using bind_cols() and name the new tibble 
# appropriately
clusterResults = map_dfc(swissDbs, ~.$cluster)

swissClusters = bind_cols(swissTib, clusterResults)

# Plot and facet per permutation

swissClustersGathered = gather(swissClusters, 
                               key = "Permutation", value = "Cluster",
                               -Length, -Left, -Right, 
                               -Bottom, -Top, -Diagonal)

ggplot(swissClustersGathered, aes(Right, Diagonal,
                                  col = as.factor(Cluster))) +
  facet_wrap(~ Permutation) +
  geom_point() +
  theme_minimal() +
  theme(legend.position = "none")

# Visualise the number and size of clusters by permutation.
ggplot(swissClustersGathered, aes(reorder(Permutation, Cluster),
                                  fill = as.factor(Cluster))) +
  geom_bar(position = "fill", col = "black") +
  theme_minimal() +
  theme(legend.position = "none")

ggplot(swissClustersGathered, aes(reorder(Permutation, Cluster),
                                  fill = as.factor(Cluster))) +
  geom_bar(position = "fill", col = "black") +
  coord_polar() +
  theme_minimal() +
  theme(legend.position = "none")


# Choosing the best combination of epsilon and minPts by calculating internal
# cluster metrics using Dunn index and then validate with 
# silhouette analysis on a separate script.

# The reason why we use the dbscan package instead of mlr is because
# we can remove the noise cluster (cluster 0). 
# The noise cluster impacts the internal metrics because it isn't a distinct 
# cluster but it is rather spread out across parameter space and would make 
# internal metrics uninterpretable.

cluster_metrics = function(data, clusters, dist_matrix) {
  list(dunn = clValid::dunn(dist_matrix, clusters),
       clusters = length(unique(clusters))
  )
}

# # Generate 10 bootstrap samples from the swissScaled dataset with the sample_n()
# # function and setting the replace argument to TRUE.
# 
swissBootstrap = map(1:10, ~ {
  swissScaled %>%
    as_tibble() %>%
    sample_n(size = nrow(.), replace = TRUE)
})

# Hyperparameter Tuning

metricsTib = map_df(swissBootstrap, function(boot) {
  clusterResult = pmap(dbsParamSpace, dbscan, x = boot)
  map_df(clusterResult, function(permutation) {
    clust = as_tibble(permutation$cluster)
    filteredData = bind_cols(boot, clust) %>%
      filter(value != 0)
    d = dist(select(filteredData, -value))
    cluster_metrics(select(filteredData, -value),
                    clusters = filteredData$value,
                    dist_matrix = d)
  })
})

# Prepare hyperparameter tuning result for plotting

metricsTibSummary = metricsTib %>%
  mutate(bootstrap = factor(rep(1:10, each = 315)),
         eps = factor(rep(dbsParamSpace$eps, times = 10)),
         minPts = factor(rep(dbsParamSpace$minPts, times = 10))) %>%
  gather(key = "metric", value = "value",
         -bootstrap, -eps, -minPts) %>%
  mutate_if(is.numeric, ~ na_if(., Inf)) %>%
  drop_na() %>%
  group_by(metric, eps, minPts) %>%
  summarize(meanValue = mean(value),
            num = n()) %>%
  group_by(metric) %>%
  mutate(meanValue = ihs(meanValue)) %>%
  ungroup()

metricsTibSummary

# Plot the hyperparameter tuning results. Map eps and minPts to x and y. 

ggplot(metricsTibSummary, aes(eps, minPts,
                              fill = num, alpha = meanValue)) +
  facet_wrap(~ metric) +
  geom_tile(col = "black") +
  theme_bw() +
  theme(panel.grid.major = element_blank()) +
  scale_fill_viridis()

# Selected eps and minPts based on the Dunn index.
#I would choose eps = 0.058 and minPts = 9 

filter(swissClustersGathered, Permutation == "...296") %>%
  select(-Permutation) %>%
  mutate(Cluster = as.factor(Cluster)) %>%
  ggpairs(mapping = aes(col = Cluster),
          upper = list(continuous = "density")) +
  theme_light()

#Plotting the same but without outliers
filter(swissClustersGathered, Permutation == "...296", Cluster != 0) %>%
  select(-Permutation) %>%
  mutate(Cluster = as.factor(Cluster)) %>%
  ggpairs(mapping = aes(col = Cluster),
          upper = list(continuous = "density")) +
  theme_light()

# Jaccard index across bootstrap samples.
library(fpc)

clustBoot = clusterboot(swissScaled, B = 500,
                         clustermethod = dbscanCBI,
                         eps = 0.058, MinPts = 9,
                         showplots = FALSE)

clustBoot
#  Clusterwise Jaccard bootstrap (omitting multiple points) mean:
# [1] 0.9324203 0.9755960 0.5019344
# This indicates that clusters 1 and 2 have high stability at > 90% while
# the noise cluster is less stable at around 50% indicating that the noise is
# less concentrated than the clusters themselves.


