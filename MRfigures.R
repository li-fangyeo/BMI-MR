###########Figure and tables###################
#MR_All object to df
hi <- mr_allmethods(MRInputObject, method = "main", iterations = 10000. )
slotNames(hi)
values <- hi@Values %>%
  dplyr::rename(
    SE = `Std Error`,
    CIlower = `95% CI `,
    CIupper = ` `,
    P = `P-value`
  )


#MRLasso object to df
hi <- mr_lasso(MRInputObject, distribution = "normal", hutan = 0.05, lambda = numeric(0))
df <- data.frame(
  Method = "Lasso",
  Estimate = hi@Estimate,
  SE = hi@StdError,
  CIlower= hi@CILower,
  CIupper = hi@CIUpper,
  P = hi@Pvalue
)

#rbind two df
Medi_torq <- rbind(values, df) %>%
  filter(!row_number() %in% c(4,5)) %>%
  dplyr::mutate_at(c(2:6),round,3) %>%
  dplyr::mutate(Taxa = "Medirraneibacter_A_155507_torques")

Mass_coli
E_ramu
CAG

hutan <- rbind(Mass_coli, E_ramu, CAG)
write.table(hutan, "hutan.tsv", sep = "\t", quote = FALSE)
##12072024
#forest plot
library(readr)
library(grid)
library(forestploter)
library(gridExtra)

hutan <- read.delim("hutan.tsv.txt")
hutan$` ` <- paste(rep(" ", 30), collapse = " ")

# Create a confidence interval column to display
hutan$`Estimate (95% CI)` <- ifelse(is.na(hutan$SE), "",
                              sprintf("%.2f (%.2f to %.2f)",
                                      hutan$Estimate, hutan$CIlower, hutan$CIupper))
hutan

#make the words center
tm <- forest_theme(base_size = 18,
                   rowhead=list(fg_params=list(hjust=0, x=0)),
                   colhead=list(fg_params=list(hjust=0.5, x=0.5)),
                   #core=list(bg_params = list(fill = c("#80DEEA", "#98E4EE", "#C8F1F6", "#E0F7FA"))),
                   ci_Theight = 0.3,
                   ci_lwd = 2)

hutan_ft <- forest(hutan[,c(7, 1, 8, 9, 6)],
                   est = hutan$Estimate,
                   lower = hutan$CIlower, 
                   upper = hutan$CIupper,
                   #sizes = hutan$SE,
                   ci_column = 3,
                   #ref_line = 1,
                   xlim = c(-0.1, 0.1),
                   #x_trans = c("log10"),
                   xlab = "Causal estimate",
                   theme = tm)

# Print plot
plot(hutan_ft)

# Save plots to PDF, specifying dimensions
pdf("hutan.pdf", width = 15, height = 7)
print(hutan_ft)
dev.off()

########## plotting graph
library(plotly)
library(htmlwidgets)
library(webshot)
#waist hip ratio - Mediterraneibacter_A_155507_torques
a

#bmi - CAG-313_sp0035396252
b
#Eubacterium_I_ramulus
c
#Massilioclostridium_coli
d

plots <- c(a, b, c, d)
hi <- subplot(a, b, c, d, nrows = 2, shareX = FALSE, shareY = TRUE, titleX = FALSE, titleY = FALSE)

# Save as HTML first
saveWidget(hi, "MR-sig.html")

# Convert HTML to PDF
webshot("MR-sig.html", "MR-sig.pdf", delay = 5)