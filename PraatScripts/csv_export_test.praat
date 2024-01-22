# csv_export_test.praat
# Written by Thomas Paul Roberts
# 22nd January 2024


# In and Outs
dir$ = "../ElevenLabsMp3/"
output_file$ = "out.csv"

# Create the table
Create Table with column names: "file_list", 0, "i file_name"
row_i = 0

# List files
Create Strings as file list: "files", dir$ + "*"
n_files = Get number of strings

for i from 1 to n_files
	selectObject: "Strings files"
	file_name$ = Get string: i

    # Insert into table
    select Table file_list
    row_i = row_i + 1
    Insert row: row_i
    Set numeric value: row_i, "i", i
    Set string value: row_i, "file_name", file_name$
endfor

# Export as csv
select Table file_list
Save as comma-separated file: dir$ + output_file$

# Tidy
selectObject: "Strings files"
Remove
