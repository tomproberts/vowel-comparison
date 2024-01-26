library(dplyr)
library(ggplot2)


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
NASALS <- c("n", "n̩", "m", "m̩", "ɲ", "ŋ")
LIQUIDS <- c("l", "l̩", "ʁ")
POINTS_SAMPLED <- 6


to_bark <- function(f) {
  return (13 * atan(0.00076 * f) + 3.5 * atan((f / 7500) ** 2))
}

# Read CSV
my_vowels_ungrouped <- read.csv("./ElevenLabsMp3/formants.csv", sep = ";", nrows = 0) %>%
  filter(phone %in% MONOPHTHONGS, !(next_phone %in% c(NASALS, LIQUIDS)))

# Get average formant values
my_vowels <- my_vowels_ungrouped %>%
  filter(point_in_phone < POINTS_SAMPLED - 1,
         timepoint_in_phone > 0.015) %>%
  group_by(phone_id) %>%
  mutate(avg_f1 = mean(f1)) %>%
  mutate(avg_f2 = mean(f2)) %>%
  filter(point_in_phone == (POINTS_SAMPLED %/% 2)) # just pick one data point for each phone_id

# Filter out failed formant tracking
my_vowels <- my_vowels %>%
  filter(avg_f1 < 800, avg_f2 < 2500)

# Calculate bark formant values
my_vowels$b1 <- eval(to_bark(my_vowels$avg_f1), my_vowels)
my_vowels$b2 <- eval(to_bark(my_vowels$avg_f2), my_vowels)

# Plot
p <- my_vowels %>%
  ggplot(.)+
  aes(x = b2, y = b1, color = phone, label = phone)+
  stat_ellipse(type = "t", level = 0.67, linetype = 2, linewidth = 0.75,
               geom = "polygon", alpha = 0.05, aes(fill = phone))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_x_reverse(position = "top", name = "F2 (Barks)")+
  scale_y_reverse(position = "right", name = "F1 (Barks)")+
  geom_text(hjust=0, vjust=0, size = 3)+
  ggtitle("Vowel Space of Clone, Monophthongs, \"Die Sonne und der Wind\"")

# Display plot
ggsave("ggplot.pdf", device=cairo_pdf, width=6, height = 3)
print(p)
