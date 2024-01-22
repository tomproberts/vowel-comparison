# extract_vowels_and_export.praat
# Written by Thomas Paul Roberts
# 22nd January 2024


# In and Outs
audio_dir$ = "../ElevenLabsMp3/"
aligned_dir$ = "../ElevenLabsMp3/aligned/"

# Create the table
Create Table with column names: "formants", 0, "word_i word"
row_i = 0

# Get file
file_name$ = "ElevenLabs_2024-01-21T21_47_56_Juan Schubert_pvc_s50_sb75_m1"
file_name_underscore$ = "ElevenLabs_2024-01-21T21_47_56_Juan_Schubert_pvc_s50_sb75_m1"
Read from file: aligned_dir$ + file_name$ + ".TextGrid"

# Formant extraction
words_tier = 1
phones_tier = 2

select TextGrid 'file_name_underscore$'
n_word_intervals = Get number of intervals: words_tier

for word_index from 1 to n_word_intervals
    # Extract word
    select TextGrid 'file_name_underscore$'
    label$ = Get label of interval: words_tier, word_index

    # if label != ""
    if label$ <> ""
        # Insert into table
        select Table formants
        row_i = row_i + 1
        Insert row: row_i
        Set numeric value: row_i, "word_i", word_index
        # Make sure Praat "Text Reading Preferences" are set to "UTF-8"
        Set string value: row_i, "word", label$
    endif
endfor

# Export as csv
select Table formants
Save as semicolon-separated file: audio_dir$ + file_name$ + ".csv"

# Tidy
# selectObject: "Strings files"
# Remove
