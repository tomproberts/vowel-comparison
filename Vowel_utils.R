# Constants
PATH_START <- "./singleWords/Formants_"

# Lists of file name endings
german_vowel_files <- c(
  "uː"="U_vowel_Blut.csv",
  "ɪ"="I_vowel_Schnitt.csv"
)

english_vowel_files <- c(
  "ʉː"="U_vowel_English.csv"
)

# Get file name end for a given vowel and language
v_get_file_for_vowel <- function(vowel, language="German") {
  if (language != "German" && language != "English") {
    stop("Unsupported language '", language, "', please use either 'German' or 'English'")
  }
  
  if (language == "German") {
    vowel_files <- german_vowel_files
  } else if (language == "English") {
    vowel_files <- english_vowel_files
  }
  
  if (!(vowel %in% names(vowel_files))){
    stop("Could not find formant values .csv file for vowel '", vowel, "' in ", language)
  }
  base <- vowel_files[vowel]
  return (base)
}

# Generate a "source" label, e.g. "Me, German, /uː/"
v_get_source_label <- function(speaker, vowel, language="German") {
  return (paste(speaker, ", ", language, " /", vowel, "/", sep = ""))
}

# Load ungrouped formant data from .csv file, for a given speaker, vowel, and language
v_get_raw_formant_values_for_speaker_and_vowel <- function(speaker, desired_vowel, language="German") {
  if (speaker != "Me" && speaker != "Clone") {
    stop("Unrecognised speaker '", speaker, "', please try either 'Me' or 'Clone'")
  }
  
  filename <-
    paste(PATH_START, speaker, "_", v_get_file_for_vowel(desired_vowel, language), sep = "")
  ungrouped <- read.csv(
    filename,
    sep = ";", nrows = 0) %>%
    filter(phone == desired_vowel)
  ungrouped$source <- v_get_source_label(speaker, desired_vowel, language)
  return (ungrouped)
}

# Generate a context label, i.e. grab the phone after the current vowel
v_get_context <- function (next_phone) {
  # Take first character of next_phone to avoid aspiration or non syllabic making a difference
  return (substring(next_phone, 1, 1))
}

# Convert to bark units
v_to_bark <- function(f) {
  return (13 * atan(0.00076 * f) + 3.5 * atan((f / 7500) ** 2))
}
