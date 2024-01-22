# extract_vowels_and_export.praat
# Written by Thomas Paul Roberts
# 22nd January 2024


# In and Outs
audio_dir$ = "../ElevenLabsMp3/"
aligned_dir$ = "../ElevenLabsMp3/aligned/"

# Sanitise input
if numberOfSelected ("TextGrid") <> 1
    exitScript: "No TextGrid selected"
endif
if numberOfSelected ("Sound") <> 1
    exitScript: "No Sound selected"
endif
text_grid_object = selected: "TextGrid"
sound_object = selected: "Sound"

# Check if aligned TextGrid has been selected, not the prealigned by accident
select text_grid_object
n_tiers = Get number of tiers
if n_tiers < 2
    exitScript: "TextGrid doesn't have a words tier and phons tier. Is this the aligned TextGrid?"
endif

words_tier = 1
phons_tier = 2

# Create the formants table
Create Table with column names: "formants", 0, "phon_i phon word"
row_i = 0

# Formant extraction
select text_grid_object
n_word_intervals = Get number of intervals: words_tier
n_phon_intervals = Get number of intervals: phons_tier

for phon_index from 1 to n_phon_intervals
    # Extract word
    select text_grid_object
    phon_label$ = Get label of interval: phons_tier, phon_index
    phon_start = Get start time of interval: phons_tier, phon_index
    # phon_end = Get end time of interval: phons_tier, phon_index

    if phon_label$ <> ""
        word_index = Get interval at time: words_tier, phon_start
        word_label$ = Get label of interval: words_tier, word_index
        # Insert into table
        select Table formants
        row_i = row_i + 1
        Insert row: row_i
        Set numeric value: row_i, "phon_i", phon_index
        # Make sure Praat "Text Reading Preferences" are set to "UTF-8"
        Set string value: row_i, "phon", phon_label$
        Set string value: row_i, "word", word_label$
    endif
endfor

# Export as csv
# select Table formants
# Save as semicolon-separated file: audio_dir$ + file_name$ + ".csv"

# Tidy
# selectObject: "Strings files"
# Remove
