library(dplyr)
library(ggplot2)
library(effectsize)
source("Vowel_utils.R")


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
POINTS_SAMPLED <- 6 # Number of points within phone duration where formants were sampled

PLOT_TITLE <-
  "Distribution of German /uː/ (and English /ʉː/) from Clone voice\nand my voice (Me), when reading word list"

# Read CSVs via util function
me_german_ungrouped <-
  v_get_raw_formant_values_for_speaker_and_vowel("Me", "uː")

clone_german_ungrouped <-
  v_get_raw_formant_values_for_speaker_and_vowel("Clone", "uː")

me_english_ungrouped  <-
  v_get_raw_formant_values_for_speaker_and_vowel("Me", "ʉː", language="English")

# clone_i_ungrouped <- 
#   v_get_raw_formant_values_for_speaker_and_vowel("Clone", "ɪ")

# Merge vowels
vowels_ungrouped <- rbind(
  me_german_ungrouped, clone_german_ungrouped#, me_english_ungrouped
)

# Get average formant values
my_vowels <- vowels_ungrouped %>%
  filter(point_in_phone < POINTS_SAMPLED - 1,
         timepoint_in_phone > 0.018) %>%
  group_by(phone_id, source) %>%
  mutate(avg_f1 = mean(f1)) %>%
  mutate(avg_f2 = mean(f2)) %>%
  filter(point_in_phone == (POINTS_SAMPLED %/% 2)) # just pick one data point for each phone_id

# Assign context label
my_vowels$context <- eval(v_get_context(my_vowels$next_phone), my_vowels)

# Plot
p <- my_vowels %>%
  ggplot(.)+
  aes(x = avg_f2, y = avg_f1, color = source,
      # label = word
      )+
  geom_point(shape = 4)+
  stat_ellipse(type = "t", level = 0.95, linetype = 2, linewidth = 0.75,
              geom = "polygon", alpha = 0.05, aes(fill = source))+
  theme_classic()+
  theme(legend.position = c(0.8, 0.3))+
  scale_x_reverse(position = "top", name = "F2 (Hz)")+
  scale_y_reverse(position = "right", name = "F1 (Hz)")+
  # geom_text(hjust=0, vjust=0, size = 3)+
  ggtitle(PLOT_TITLE)

# Display plot
ggsave("ggplot.pdf", device=cairo_pdf)
print(p)

# Analyse
manova <- manova(cbind(avg_f1, avg_f2) ~ source + context, data = my_vowels)
anovas <- lm(cbind(avg_f1, avg_f2) ~ source + context, data = my_vowels)

writeLines("\n# Summary of MANOVA on F1 and F2\n")
print(summary.manova(manova))
print(effectsize::eta_squared(manova))
writeLines("\n# Summary of univariate ANOVA on F1 and F2\n")
print(summary.aov(manova))
print(effectsize::eta_squared(anovas, partial = FALSE))
