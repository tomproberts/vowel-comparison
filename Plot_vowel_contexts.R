library(dplyr)
library(ggplot2)


MONOPHTHONGS <- c("iː", "ɪ", "a", "aː", "ə", "ɛ", "eː", "ɐ", 
                  "ɔ", "oː", "ʊ", "uː", "œ", "øː", "ʏ", "yː")
POINTS_SAMPLED <- 6

# Read CSV
desired_vowel <- "ɪ"
my_vowels <- read.csv("./formants.csv", sep = ";", nrows = 0) %>%
  filter(phone == desired_vowel)

# Get formants from midpoint
my_vowels <- my_vowels %>%
  filter(point_in_phone == (POINTS_SAMPLED %/% 2))

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
  aes(x = f2, y = f1, color = context, label = word)+
  # stat_ellipse(type = "t", level = 0.67, linetype = 2, linewidth = 0.75,
  #              geom = "polygon", alpha = 0.05, aes(fill = context))+
  theme_classic()+
  theme(legend.position = "none")+
  scale_x_reverse(position = "top", name = "F2 (Hz)")+
  scale_y_reverse(position = "right", name = "F1 (Hz)")+
  geom_text(hjust=0, vjust=0, size = 3)+
  ggtitle(paste("Distribution of vowel '", desired_vowel, "' from Clone Reading Word List", sep = ""))

# Display plot
ggsave("ggplot.pdf", device=cairo_pdf)
print(p)
