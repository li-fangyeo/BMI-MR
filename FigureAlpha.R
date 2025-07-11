library(dplyr)
library(ggpubr)
library(purrr)
library(ggsignif)

#Box plot for alpha 
a<- tse %>% colData() %>% as.data.frame()

#Categorise BMI
colData(tse)$BMI_Category <- cut(colData(tse)$BMI,
                      breaks = c(-Inf, 18.5, 24.9, 29.9, 39.9, Inf),
                      labels = c("Underweight", "Normal", "Overweight", "Obese", "Morbid Obesity"))



a %>% as.data.frame %>% group_by(BMI_Category) %>%
  summarise(Count = n())
a$BMI_Category <- factor(a$BMI_Category, 
                         levels = c("Underweight", "Normal", "Overweight", "Obese", "Morbid Obesity"))
# For significance testing, all different combinations are determined
comb <- split(t(combn(levels(a$BMI_Category), 2)), 
              seq(nrow(t(combn(levels(a$BMI_Category), 2)))))


pvals <- purrr::map_dbl(comb, ~ wilcox.test(shannon ~ BMI_Category, data = a %>% filter(BMI_Category %in% .x))$p.value)

# Apply FDR correction
pvals_adj <- p.adjust(pvals, method = "fdr")

# Filter only significant comparisons
significant_comparisons <- comb[pvals_adj < 0.05]

my_colors <- c("#434247","#0A9396","#EE9800","#CA6702", "firebrick")

# Plot with only significant annotations
p<- ggplot(a, aes(x = BMI_Category, y = shannon)) +
  geom_violin(aes(fill = BMI_Category)) + 
  geom_boxplot(width = 0.1, outlier.shape = NA) + 
  theme_classic(base_size = 16) +
  scale_fill_manual(values = my_colors) +
  geom_signif(comparisons = significant_comparisons, map_signif_level = TRUE,
              step_increase = 0.1) +
  labs(
    x = "BMI category",
    y = "Shannon index",
    fill = "BMI category")
    

ggsave("alpha.pdf", 
       plot = p, 
       width = 8, 
       height = 6, 
       units = "in")

library(DataExplorer)
plot_intro(a)
plot_bar(a)
plot_histogram(a)
plot_correlation(na.omit(a), maxcat = 5L)