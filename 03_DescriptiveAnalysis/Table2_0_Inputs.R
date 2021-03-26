# Define inputs for Table2

field_ids_to_extract <- c('eid', 'casecont', '20001', '20002') 
output_folder <- 'Ross/Data/Table2/' # MUST INCLUDE '/' AT THE END N.B. this is the path from the working directory set in each script, typically set to default
job_ID <- '25_Mar_2000X_final_' # Identifies the job and forms the start of the filename therefore ends with '_'

# List of commonly used field IDs
#   20001: cancer code, self reported
#   20002: non-cancer illness code, self-reported; 
#   40009: Reported occurrences of cancer
#   40006: Type of cancer: ICD10
#   40013: Type of cancer: ICD9
# NOTE: any ID entered will require the data dictionary file to include a matched array id for this field ID