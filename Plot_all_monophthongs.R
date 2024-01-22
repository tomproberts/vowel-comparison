library(dplyr)
library(ggplot2)

# Read CSV
my_vowels <- read.csv("./formants.csv", sep = ";", nrows = 0) %>%
  filter(phon %in% c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", "ɔ", "oː", "ʊ", "uː"))

# Plot
p <- my_vowels %>%
  ggplot(.)+
  aes(x = f2, y = f1, color = phon, label = phon)+
  stat_ellipse(type = "t", level = 0.67, linetype = 2, linewidth = 0.75,
               geom = "polygon", alpha = 0.05, aes(fill = phon))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_x_reverse(position = "top", name = "F2 (Hz)")+
  scale_y_reverse(position = "right", name = "F1 (Hz)")+
  geom_text(hjust=0, vjust=0, size = 3)

# Display plot
# pdf("ggplot.pdf")
print(p)
# dev.off() 
