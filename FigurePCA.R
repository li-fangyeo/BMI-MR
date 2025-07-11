#Beta
#PLOT
tse<- tse %>%  mia::agglomerateByRank(rank = "Species") %>% 
  mia::transformAssay(method = "relabundance") %>%
  scater::runMDS(FUN = getDissimilarity,
                 assay.type = "relabundance",
                 method = "bray",
                 na.action = na.exclude,
                 name = "MDS_bray")

# Create ggplot object
p <- plotReducedDim(tse, "MDS_bray", colour_by = "BMI")

# Calculate explained variance
e <- attr(reducedDim(tse, "MDS_bray"), "eig")
rel_eig <- e / sum(e[e > 0])

# Add explained variance for each axis
p <- p + labs(
  x = paste("PCoA 1 (", round(100 * rel_eig[[1]], 1), "%", ")", sep = ""),
  y = paste("PCoA 2 (", round(100 * rel_eig[[2]], 1), "%", ")", sep = "")
)

p<- p +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16))
plot(p)
ggplot2::ggsave(filename = "PCoA_BMI.pdf", 
                plot = p,
                #dpi = 300,
                width = 10,
                height = 8,
                units = "in" )

#PCA
tse <- tse %>% mia::transformAssay(method = "clr", pseudocount = 1)
tse <- runPCA(
  tse,
  name = "PCA", 
  assay.type = "clr", 
  ncomponents = 10
)
h<- plotReducedDim(tse, "PCA", colour_by = "BMI")
h +
  ggplot2::theme_classic() +
  ggplot2::theme(
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 14),
    axis.text = element_text(size = 14),
    axis.title = element_text(size = 16))

ggplot2::ggsave(filename = "PCA_BMI.pdf", 
                plot = h,
                #dpi = 300,
                width = 8,
                height = 7,
                units = "in" )
