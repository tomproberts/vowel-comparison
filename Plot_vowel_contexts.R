library(dplyr)
library(ggplot2)


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
POINTS_SAMPLED <- 6

# SPEAKER <- "Me"
SPEAKER <- "Clone"

# Read CSV
desired_vowel <- "uː"
my_vowels_ungrouped <- read.csv(
  paste("./singleWords/Formants_", SPEAKER, "_U_vowel_Blut.csv", sep = ""),
  sep = ";", nrows = 0) %>%
  filter(phone == desired_vowel)

# Get average formant values
my_vowels <- my_vowels_ungrouped %>%
  filter(point_in_phone < POINTS_SAMPLED - 1,
         timepoint_in_phone > 0.018) %>%
  group_by(phone_id) %>%
  mutate(avg_f1 = mean(f1)) %>%
  mutate(avg_f2 = mean(f2)) %>%
  filter(point_in_phone == (POINTS_SAMPLED %/% 2)) # just pick one data point for each phone_id

# Generate context label
get_context <- function (next_phone) {
  # Take first character of next_phone to avoid aspiration making a difference
  return (paste(desired_vowel, substring(next_phone, 1, 1), sep = ""))
  # return (paste(desired_vowel, next_phone, sep = ""))
}

my_vowels$context <- eval(get_context(my_vowels$next_phone), my_vowels)

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
  ggtitle(paste("Distribution of Vowel '", desired_vowel, "' from ", SPEAKER, " Reading Word List", sep = ""))

# Display plot
ggsave("ggplot.pdf", device=cairo_pdf)
print(p)
