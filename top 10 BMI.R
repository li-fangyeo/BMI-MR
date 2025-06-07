#Top 15 significant taxa

whr<- df_lm_whr_results %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_","", .))) %>%
  dplyr::filter(taxa %in% c('Borkfalkia ceftriaxoniphila', 'CAG-313 sp003539625', "Eubacterium_G ventriosum",
                            "Eubacterium_I ramulus", "Faecalitalea cylindroides", "Lachnoclostridium_B sp900066555",
                            "Massilioclostridium coli", "Mediterraneibacter_A_155507 torques", "Muricomes contortus_B",
                            "Ventrimonas sp003481825")) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,5) %>%
  dplyr::mutate_at(c(5:6), round, 5)%>%
  dplyr::mutate(Origin = rep("WHR", 8))

bmi <- df_lm_bmi_results %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_","", .))) %>%
  dplyr::filter(taxa %in% c('Borkfalkia ceftriaxoniphila', 'CAG-313 sp003539625', "Eubacterium_G ventriosum",
                            "Eubacterium_I ramulus", "Faecalitalea cylindroides", "Lachnoclostridium_B sp900066555",
                            "Massilioclostridium coli", "Mediterraneibacter_A_155507 torques", "Muricomes contortus_B",
                            "Ventrimonas sp003481825")) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_","", .))) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,5) %>%
  dplyr::mutate_at(c(5:6), round, 5) %>%
  dplyr::mutate(Origin = rep("BMI", 10))

waist <- df_lm_waist_results %>%
  dplyr::select(taxa,estimate,conf.low, conf.high, p.value, qval_fdr) %>%
  dplyr::mutate(across(everything(),~ gsub("GUT_","", .))) %>%
  dplyr::filter(taxa %in% c('Borkfalkia ceftriaxoniphila', 'CAG-313 sp003539625', "Eubacterium_G ventriosum",
                            "Eubacterium_I ramulus", "Faecalitalea cylindroides", "Lachnoclostridium_B sp900066555",
                            "Massilioclostridium coli", "Mediterraneibacter_A_155507 torques", "Muricomes contortus_B",
                            "Ventrimonas sp003481825")) %>%
  dplyr::mutate_at(c(2:6), as.numeric) %>%
  dplyr::mutate_at(c(2:4),round,5) %>%
  dplyr::mutate_at(c(5:6), round, 5) %>%
  dplyr::mutate(Origin = rep("waist", 10))

hi <- rbind(whr, bmi, waist)

#define colors
my_colors <- c("BMI" = "darkgreen", "waist" = "darkolivegreen2", 
               "WHR" = "orange")

bb <- ggplot(data=hi, aes(x=taxa, y=estimate, fill = Origin)) +
  geom_bar(stat="identity", position = 'dodge') +
  scale_fill_manual(values=my_colors) +
  coord_flip() +
  theme_classic() +
  theme(axis.text.y = element_text(face = 'italic'))
bb

##

