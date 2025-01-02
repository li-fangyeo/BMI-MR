whr<- df_lm_whr_results %>%
  dplyr::slice(1:15) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("WHR", 15))

bmi <- df_lm_bmi_results %>%
  dplyr::slice(1:15) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("BMI", 15))

waist <- df_lm_waist_results %>%
  dplyr::slice(1:15) %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_Species:","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,3) %>%
  dplyr::mutate_at(c(5:6), round, 3) %>%
  dplyr::mutate(Origin = rep("waist", 15))

hi <- rbind(whr, bmi, waist)

#define colors
my_colors <- c("waist" = "darkgreen", "BMI" = "orange", 
               "WHR" = "thistle")

q <- ggplot(data=hi, aes(x=taxa, y=estimate, fill = Origin)) +
  geom_bar(stat="identity", position = 'dodge') +
  scale_fill_manual(values=my_colors) +
  coord_flip() +
  theme_classic() +
  theme(axis.text.y = element_text(face = 'italic'))
q

#ANCOMBC
sig.taxa <- BMI_df %>%
  dplyr::slice(1:10) %>%
  select(taxon)

waist <- waist_df %>% 
  dplyr::right_join(sig.taxa, join_by(taxon == taxon)) %>%
  rename_at('lfc_VYOTARO', ~'lfc') %>%
  dplyr::mutate(Origin = rep("waist", 10)) %>%
  dplyr::select(taxon, lfc, Origin)

bmi <- BMI_df %>%
  dplyr::right_join(sig.taxa, join_by(taxon == taxon)) %>%
  rename_at('lfc_BMI', ~'lfc') %>%
  dplyr::mutate(Origin = rep("BMI", 10)) %>%
  dplyr::select(taxon, lfc, Origin)
whr <- WHR_df %>%
  dplyr::right_join(sig.taxa, join_by(taxon == taxon)) %>%
  rename_at('lfc_WHR', ~'lfc') %>%
  dplyr::mutate(Origin = rep("WHR", 10))%>%
  dplyr::select(taxon, lfc, Origin)
hi <- rbind(whr, bmi, waist)

#define colors
my_colors <- c("waist" = "darkgreen", "BMI" = "orange", 
               "WHR" = "pink")

p <- ggplot(data=hi, aes(x=taxon, y=lfc, fill = Origin)) +
  geom_bar(stat="identity", position = 'dodge') +
  scale_fill_manual(values=my_colors) +
  coord_flip() +
  theme_classic() +
  theme(axis.text.y = element_text(face = 'italic'))
p
