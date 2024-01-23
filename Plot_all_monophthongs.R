library(dplyr)
library(ggplot2)


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
NASALS <- c("n", "n̩", "m", "m̩", "ɲ", "ŋ")
LIQUIDS <- c("l", "l̩", "ʁ")

# Read CSV
my_vowels <- read.csv("./formants.csv", sep = ";", nrows = 0) %>%
  filter(phon %in% MONOPHTHONGS, !(next_phon %in% c(NASALS, LIQUIDS)))

# Calculate bark formant values
my_vowels$b1 <- eval(to_bark(my_vowels$f1), my_vowels)
my_vowels$b2 <- eval(to_bark(my_vowels$f2), my_vowels)

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
  geom_text(hjust=0, vjust=0, size = 3)+
  ggtitle("Vowel Space of Clone, Monophthongs, \"Die Sonne und der Wind\"")

# Display plot
# ggsave("ggplot.pdf", device=cairo_pdf)
print(p)

to_bark <- function(f) {
  return (13 * atan(0.00076 * f) + 3.5 * atan((f / 7500) ** 2))
}
