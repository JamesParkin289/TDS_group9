# Purpose of script:
Transform the hesin and hesin_diag datasets into a summary by eid of each patient's diagnoses and the date of this diagnosis

# Inputs
## hesin: records key info for each hospital episode, by patient
  eid - patient eid (globally unique within UKBB datasets)
  ins_index - unique, non-chronological identifier for each episode (because each patient may have multiple hospital episodes over their lifetime)
  dsource
  source
  epistart - date of episode start
  epiend - date of episode end
  ... further info
  
## hesin_diag: for each episode, multiple diagnoses may be recorder, each record receives a hesin_diag entry
  eid - patient eid (globally unique within UKBB datasets)
  ins_index - unique, non-chronological identifier for each episode <<< eid + ins_index links the two hesin tables
  arr_index - for each unique episode, each separate diagnosis is recorded with a unique, sequential identifier
  level - ?
  diag_icd9 - icd9 coded diagnosis
  diag_icd9_nb - ?
  diag_icd10 - icd10 coded diagnosis
  diag_icd10_nb - ?

## case_cont_eid
  list of eids of cases and controls as defined via case control matching performed elsewhere
  

# Output dataset has shape:

| eid | 1st diagnosis | 1st epistart | 2nd diagnosis | 2nd epistart | ... | ... | nth diagnosis | nth epistart |
| --- | ------------- | ------------ | ------------- | ------------ | --- | --- | ------------- | ------------ |
| 001 | 10_J45        | 01/09/1995   | 10_S7203      | 10/10/2002   | ... | ... | NA            | NA           |
| ... | ......        | ..........   | ........      | ..........   | ... | ... | ..            | ..           |

With:
N# rows = total N# case+control eids
N# cols = 1 + 2 * max(N# rows in hesin_diag for single patient)
     1 represents the first column: eids
     2 cols for each icd becuase there will be a diagnosis and an earliest date of this diagnosis
     

# Required inputs / edits to run script
- Update paths to input files
- Update prefix name / job_ID for output files
- Update path for output files


# Overview of method
## Set up 
## Data Prep
    1. Create hesin_joined to add epistart to hesin_diag 
    2. Combine icd9 and icd10 diagnoses into single 'diagnosis' col 
          When combining into this column, diagnoses are prefixed with 9_ or 10_ to allow for later recoding into English diagnoses
    3. Create working hesin_final dataset by select only relevant columns and filtering to only eids in cases_controls_eids

## Iteratively create 1hot encoded summary by eid
    1. Create an empty dataset consisting of the column names for the final output
          | eid | 1st diagnosis | 1st epistart | 2nd diagnosis | 2nd epistart | ... | ... | nth diagnosis | nth epistart |
    2.. Create eid list to iterate over
    3. Iteratively (by eid) create the final output 
        Filter (by eid) to create a temporary subset of the hesin_final data
        Select only the two columns of interest: epistart and diagnosis
        Combine these two into a single list:          eid, 1st diagnsis, 2nd diagnosis, ... , nth diagnosis, 1st epistart, 2nd epistart, ... ,  nth epistart
        Reorder  to interleave the list:               eid, 1st diagnsis, 1st epistart, 2nd diagnosis, 2nd epistart, ... , ... , nth diagnosis,  nth epistart
        Bind to out final output
    4. Reassign top row of resulting table to colnames

## Write output to csv


# Comments on method: 
- Using a for loop is quite slow and computationally expensive; however, the need to select by eid and extract this eid (I believe) necessitates its use
    - This may be sped up by automatically chunking the eid list into X number of sequential, non-overlapping segments and running the for loop over each segment in parallel
- Creating the selected(filtered()) subset by eid was simple, the difficulty was in translating this two column subset into the interleaved output
    - There may be a more automatic way of doing this but the above method appears robust, even if clunky and slow