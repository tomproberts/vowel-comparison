library(dplyr)
library(ggplot2)
library(effectsize)


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
POINTS_SAMPLED <- 6

SPEAKER <- "Me"
# SPEAKER <- "Clone"

# Read CSV
desired_vowel <- "uː"
file <- "U_vowel_Blut"
my_vowels_ungrouped <- read.csv(
  paste("./singleWords/Formants_Me_", file, ".csv", sep = ""),
  sep = ";", nrows = 0) %>%
  filter(phone == desired_vowel)
my_vowels_ungrouped$source <- "Me, German /uː/"

clone_vowels_ungrouped <- read.csv(
  paste("./singleWords/Formants_Clone_", file, ".csv", sep = ""),
  sep = ";", nrows = 0) %>%
  filter(phone == desired_vowel)
clone_vowels_ungrouped$source <- "Clone, German /uː/"

my_vowels_ungrouped <- rbind(my_vowels_ungrouped, clone_vowels_ungrouped)

# english_vowels_ungrouped <- read.csv(
#   paste("./singleWords/Formants_Me_U_vowel_English.csv", sep = ""),
#   sep = ";", nrows = 0) %>%
#   filter(phone == "ʉː")
# english_vowels_ungrouped$source <- "Me, English /ʉː/"
# 
# my_vowels_ungrouped <- rbind(my_vowels_ungrouped, english_vowels_ungrouped)

# i_vowels_ungrouped <- read.csv(
#   paste("./singleWords/Formants_Clone_I_vowel_Schnitt.csv", sep = ""),
#   sep = ";", nrows = 0) %>%
#   filter(phone == "ɪ")
# i_vowels_ungrouped$source <- "Clone, German /ɪ/"
# 
# my_vowels_ungrouped <- rbind(my_vowels_ungrouped, i_vowels_ungrouped)

# Get average formant values
my_vowels <- my_vowels_ungrouped %>%
  filter(point_in_phone < POINTS_SAMPLED - 1,
         timepoint_in_phone > 0.018) %>%
  group_by(phone_id, source) %>%
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
# my_vowels <- rbind(my_vowels, my_vowels)


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
  ggtitle("Distribution of German /uː/ (and English /ʉː/) from Clone voice\nand my voice (Me), when reading word list")

# Display plot
# ggsave("ggplot.pdf", device=cairo_pdf)
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
