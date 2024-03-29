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
phones_tier = 2

# Create the formants table
Create Table with column names: "formants", 0, "word phone_id phone f1 f2 point_in_phone timepoint_in_phone next_phone duration"
row_i = 0

# Formant tracking
@trackFormants
select text_grid_object
n_word_intervals = Get number of intervals: words_tier
n_phone_intervals = Get number of intervals: phones_tier
n_points = 6 ; number of points to sample formant values per phone

# For every phone
for phone_index from 1 to n_phone_intervals
    select text_grid_object
    phone_label$ = Get label of interval: phones_tier, phone_index

    if phone_label$ <> ""
        # phone data
        phone_start_abs = Get start time of interval: phones_tier, phone_index
        phone_end_abs = Get end time of interval: phones_tier, phone_index
        duration = phone_end_abs - phone_start_abs
        next_phone$ = Get label of interval: phones_tier, phone_index + 1
        
        # Word data
        word_index = Get interval at time: words_tier, phone_start_abs
        word_label$ = Get label of interval: words_tier, word_index

        # Get formants at each timepoint
        step = duration / (n_points - 1) ; timestep
        for timepoint from 1 to n_points
            sample_point = phone_start_abs + (timepoint - 1) * step
            select formant_object
            f1 = Get value at time: 1, sample_point, "hertz", "Linear"
            f2 = Get value at time: 2, sample_point, "hertz", "Linear"
    
            @insertIntoTable: word_label$, phone_index, phone_label$, f1, f2, timepoint, sample_point - phone_start_abs, next_phone$, duration
        endfor
    endif
endfor

@exportAsCsv
# END

# Procedures
procedure checkIsAlignedTextGrid
    select text_grid_object
    n_tiers = Get number of tiers
    if n_tiers < 2
        exitScript: "TextGrid doesn't have a words tier and phones tier. Is this the aligned TextGrid?"
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

procedure insertIntoTable: .word_label$, .phone_id, .phone_label$, .f1, .f2, .point, .timepoint, .next_phone$, .duration
    # Insert new row
    select Table formants
    row_i = row_i + 1
    Insert row: row_i

    # Insert values
    Set numeric value: row_i, "phone_id", .phone_id
    Set string value: row_i, "phone", .phone_label$
    Set string value: row_i, "next_phone", .next_phone$
    Set string value: row_i, "word", .word_label$
    Set numeric value: row_i, "duration", .duration
    Set numeric value: row_i, "f1", .f1
    Set numeric value: row_i, "f2", .f2
    Set numeric value: row_i, "timepoint_in_phone", .timepoint
    Set numeric value: row_i, "point_in_phone", .point

    # Make sure Praat "Text Writing Preferences" are set to "UTF-8"
endproc

procedure exportAsCsv
    select Table formants
    Save as semicolon-separated file: "../formants.csv"
endproc

procedure trackFormants
    select sound_object
    .timestep = 0 ; seconds, default is 25% of window length
    .n_formants = 5
    .ceiling = 4800 ; hz
    .window = 0.025 ; window size (s)
    .pre_emph = 30 ; hz, everything under is not emphasised
    To Formant (burg)... .timestep .n_formants .ceiling .window .pre_emph
    formant_object = selected: "Formant"
endproc
