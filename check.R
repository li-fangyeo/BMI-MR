wh<- df_lm_whr_results %>%
  dplyr::slice(1:10) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("WHR", 10))
  

bmi <- df_lm_bmi_results %>%
  dplyr::slice(1:10) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("BMI", 10))

wis <- df_lm_waist_results %>%
  dplyr::slice(1:10) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("waist", 10))

hi <- rbind(wh, bmi, wis)

#define colors
my_colors <- c("waist" = "darkgreen", "BMI" = "orange", 
               "WHR" = "pink")

p <- ggplot(data=hi, aes(x=taxa, y=estimate, fill = Origin)) +
  geom_bar(stat="identity", position = 'dodge') +
  scale_fill_manual(values=my_colors) +
  coord_flip() +
  theme_classic() +
  theme(axis.text.y = element_text(face = 'italic'))
