#Figure circular - Joo, se on mun nimi, kertoo Rfile
library(ggtree)
library(ggtreeExtra)
library(ggnewscale)
library(ggplot2)
library(dplyr)
library(scales)
df_lm_bmi_results <- read.table("df_lm_bmi.tsv", sep = "\t")
df_lm_whr_results <- read.table("df_lm_whr.tsv", sep = "\t")

#getting significant taxa, after validation in west cohort
bmi<- df_lm_bmi_results %>%
  dplyr::arrange(p.value) %>% 
  dplyr::filter(qval_fdr < 0.05)
#DT::datatable(caption = "Linear model for bmi")

whr <- df_lm_whr_results %>%
  dplyr::arrange(p.value) %>% 
  dplyr::filter(qval_fdr < 0.05)
#DT::datatable(caption = "Linear model for whr")

#joining them into a dataframe
a<- whr%>% select(taxa, estimate)
b<- bmi %>% select(taxa, estimate)
e<- full_join(a,b, by = "taxa",suffix = c(".whr",".bmi"))

#tidying and renaming the columns
colnames(e)[2] <- "WHR"
colnames(e)[3] <- "BMI"
colnames(e)[1] <- "Species"
e <- as.data.frame(e)
e$Species <- gsub("GUT_", "",x=e$Species) 
e <- e%>% replace(is.na(.), 0) %>% arrange(Species)

e <- merge(e, metadata[, c("Species", "Phylum")], by = "Species")
e <- merge(e, metadata[, c("Species", "Family")], by = "Species")
e<- e %>% unique() %>% as.data.frame

#subset tse to significant taxa in bmi and whr
selected_rows <- rowData(tse)$Species %in% e$Species & 
  !is.na(rowData(tse)$Species)
tse2 <- tse[selected_rows, ]

#agglomerate and update tree
tse2 <- tse2 %>% 
  mia::agglomerateByRank(rank = "Species", update.tree = TRUE) %>%
  mia::transformAssay(method = "clr", pseudocount = 1)

tse2 <- subsetByLeaf(tse2, rowLeaf = rownames(tse2))

tse2 <- mia::addHierarchyTree(tse2)

tree <- rowTree(tse2)
metadata <- rowData(tse2)

#need this to map the tree
e$taxa <- gsub("^(.*)$", "Species:\\1", e$Species)
p <- ggtree(tree, layout = "fan", open.angle = 20)
p <- rotate_tree(p, 130)
##Different colour
q <- p + geom_fruit(
  data = e,
  geom = geom_tile,
  mapping = aes(y = taxa, x = 1, fill = Phylum),
  width = 0.04,
  offset = 0.1
) +
  scale_fill_brewer(palette = "Spectral", name = "Phylum") + # phylum colors
  theme(legend.position = "bottom") 
#new_scale_fill() + # allows a new fill scale for the next layer
q <- q + new_scale_fill() + # allows a new fill scale for the next layer
  geom_fruit(
    data = e,
    geom = geom_bar,
    mapping = aes(y = taxa, x = WHR, fill = Family),
    orientation = "y",
    stat = "identity",
    width = 0.6,
    offset = 0.2,
    axis.params = list(title = "WHR", title.position = "top")
  )+
  geom_fruit(
    data = e,
    geom = geom_bar,
    mapping = aes(y = taxa, x = BMI, fill = Family),
    orientation = "y",
    stat = "identity",
    width = 0.6,
    offset = 0.2,
    axis.params = list(title = "BMI", title.position = "top")
  ) +
  theme(legend.position = "right") +
  geom_vline(xintercept = 0.9, color = "grey50", linetype = "solid", size = 0.4) +  # WHR
  geom_vline(xintercept = 1.14, color = "grey50", linetype = "solid", size = 0.4) # BMI


ggsave("beautifulcircle.pdf", 
       q,
       width = 15,
       height = 10,
       units = "in"
       )
