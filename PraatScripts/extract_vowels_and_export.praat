# extract_vowels_and_export.praat
# Written by Thomas Paul Roberts
# 22nd January 2024


# In and Outs
audio_dir$ = "../ElevenLabsMp3/"
aligned_dir$ = "../ElevenLabsMp3/aligned/"

# Create the table
Create Table with column names: "formants", 0, "i file_name"
row_i = 0

# Get file
file_name$ = "ElevenLabs_2024-01-21T21_47_56_Juan Schubert_pvc_s50_sb75_m1"

# Formant extraction

# Insert into table
select Table formants
row_i = row_i + 1
Insert row: row_i
Set numeric value: row_i, "i", 1
Set string value: row_i, "file_name", file_name$ + ".TextGrid"

# Export as csv
select Table formants
Save as comma-separated file: audio_dir$ + file_name$ + ".csv"

# Tidy
# selectObject: "Strings files"
# Remove
