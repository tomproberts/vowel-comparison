# extract_vowels_and_export.praat
# Written by Thomas Paul Roberts
# 22nd January 2024
#
# Takes a selected Sound and aligned TextGrid, and extracts the vowel formants
#

# START
# Sanitise input
@checkTextGridAndSoundAreSelected
text_grid_object = selected: "TextGrid"
sound_object = selected: "Sound"

# Check if aligned TextGrid has been selected, not the prealigned by accident
@checkIsAlignedTextGrid
words_tier = 1
phons_tier = 2

# Create the formants table
Create Table with column names: "formants", 0, "word phon_id phon f1 f2 f3 next_phon duration"
row_i = 0

# Formant tracking
@trackFormants
select text_grid_object
n_word_intervals = Get number of intervals: words_tier
n_phon_intervals = Get number of intervals: phons_tier

# For every phon
for phon_index from 1 to n_phon_intervals
    select text_grid_object
    phon_label$ = Get label of interval: phons_tier, phon_index

    if phon_label$ <> ""
        # Phon data
        phon_start_abs = Get start time of interval: phons_tier, phon_index
        phon_end_abs = Get end time of interval: phons_tier, phon_index
        duration = phon_end_abs - phon_start_abs
        mid_point = (phon_start_abs + phon_end_abs) / 2.0
        next_phon$ = Get label of interval: phons_tier, phon_index + 1
        
        # Word data
        word_index = Get interval at time: words_tier, phon_start_abs
        word_label$ = Get label of interval: words_tier, word_index

        # Get formants
        select formant_object
        f1 = Get value at time: 1, mid_point, "hertz", "Linear"
		f2 = Get value at time: 2, mid_point, "hertz", "Linear"
		f3 = Get value at time: 3, mid_point, "hertz", "Linear"

        @insertIntoTable: word_label$, phon_index, phon_label$, f1, f2, f3, next_phon$, duration
    endif
endfor

@exportAsCsv
# END

# Procedures
procedure checkIsAlignedTextGrid
    select text_grid_object
    n_tiers = Get number of tiers
    if n_tiers < 2
        exitScript: "TextGrid doesn't have a words tier and phons tier. Is this the aligned TextGrid?"
    endif
endproc

procedure checkTextGridAndSoundAreSelected
    if numberOfSelected ("TextGrid") <> 1
        exitScript: "No TextGrid selected"
    endif
    if numberOfSelected ("Sound") <> 1
        exitScript: "No Sound selected"
    endif
endproc

procedure insertIntoTable: .word_label$, .phon_id, .phon_label$, .f1, .f2, .f3, .next_phon$, .duration
    # Insert new row
    select Table formants
    row_i = row_i + 1
    Insert row: row_i

    # Insert values
    Set numeric value: row_i, "phon_id", .phon_id
    Set string value: row_i, "phon", .phon_label$
    Set string value: row_i, "next_phon", .next_phon$
    Set string value: row_i, "word", .word_label$
    Set numeric value: row_i, "duration", .duration
    Set numeric value: row_i, "f1", .f1
    Set numeric value: row_i, "f2", .f2
    Set numeric value: row_i, "f3", .f3

    # Make sure Praat "Text Writing Preferences" are set to "UTF-8"
endproc

procedure exportAsCsv
    select Table formants
    Save as semicolon-separated file: "../formants.csv"
endproc

procedure trackFormants
    select sound_object
    .timestep = 0 ; seconds, default is 25% of window length
    .n_formants = 4
    .ceiling = 4200 ; hz
    .window = 0.015 ; window size (s)
    .pre_emph = 30 ; hz, everything under is not emphasized
    To Formant (burg)... .timestep .n_formants .ceiling .window .pre_emph
    formant_object = selected: "Formant"
endproc
