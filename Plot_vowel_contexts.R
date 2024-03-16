library(dplyr)
library(ggplot2)
source("Vowel_utils.R")


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
POINTS_SAMPLED <- 6

DESIRED_VOWEL <- "ɪ" # "uː" or "ɪ"
SPEAKER <- "Clone" # "Me" or "Clone"

PLOT_TITLE <-
  paste("Distribution of Vowel '", DESIRED_VOWEL, "' from ", SPEAKER, " Reading Word List", sep = "")

# Read CSV
my_vowels_ungrouped <-
  v_get_raw_formant_values_for_speaker_and_vowel(SPEAKER, DESIRED_VOWEL)

# Get average formant values
my_vowels <- my_vowels_ungrouped %>%
  filter(point_in_phone < POINTS_SAMPLED - 1,
         timepoint_in_phone > 0.018) %>%
  group_by(phone_id) %>%
  mutate(avg_f1 = mean(f1)) %>%
  mutate(avg_f2 = mean(f2)) %>%
  filter(point_in_phone == (POINTS_SAMPLED %/% 2)) # just pick one data point for each phone_id

# Assign context label
my_vowels$context <- eval(v_get_context(my_vowels$next_phone), my_vowels)

# Plot
p <- my_vowels %>%
  ggplot(.)+
  aes(x = avg_f2, y = avg_f1, color = context, label = word)+
  # stat_ellipse(type = "t", level = 0.67, linetype = 2, linewidth = 0.75,
  #              geom = "polygon", alpha = 0.05, aes(fill = context))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_x_reverse(position = "top", name = "F2 (Hz)")+
  scale_y_reverse(position = "right", name = "F1 (Hz)")+
  geom_text(hjust=0, vjust=0, size = 3)+
  ggtitle(PLOT_TITLE)

# Display plot
ggsave("ggplot.pdf", device=cairo_pdf)
print(p)
