# ----------------------------------------------------------------------------------------------------------
# make_toy_dataset() 
# ----------------------------------------------------------------------------------------------------------

# Function will take a dataset (either as an object or a path) and an input for the desired number of rows and create a toy dataset with shuffled data to allow download for local use

# WARNING: if you pass a dataframe object as the input and this dataframe has an order then this may create a biased toy dataset 
#           Consider either 1) using this function iteratively on subsets of the data
#                           2) passing a path object to this function rather than a data.frame / tibble object


make_toy_dataset <- function(original_dataset, nrows_for_toy_dataset){
    
    if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
    if (!require("data.table")) install.packages("data.table", repos = "http://cran.us.r-project.org")
    
    # This ifelse allows original_dataset to either be a path/to/a/file or an object already asigned to a df
    if (typeof(original_dataset) == 'list') {
        df <- as_tibble(original_dataset)[1:nrows_for_toy_dataset,] 
    } else {
        df <- as_tibble(fread(original_dataset, nrows = nrows_for_toy_dataset))
    }
    
    # Create empty toy_df
    toy_ncols <- length(unlist(colnames(df)))
    toy_df <- as_tibble(matrix(ncol = toy_ncols, nrow = nrows_for_toy_dataset))
    colnames(toy_df) <- colnames(df)
    
    # Columnwise, take original df, shuffle values, insert into toy_df
    for (i in 1:ncol(df)){
        toy_df[,i] <- sample(unlist(df[,i]), size = nrow(df), replace = TRUE)
    }

    toy_df
}

# Test
#toy_df_test = make_toy_dataset(original_dataset = "../Data/InputDataFiles/ukb26390.csv", nrows_for_toy_dataset = 12)



# ----------------------------------------------------------------------------------------------------------
# import_data_using_fields
# ----------------------------------------------------------------------------------------------------------

import_data_using_fields = function(fields, data){
# Import all observations of given dataset selecting only columns with field id specified in 'fields' list
# Takes either a data object or path/to/data - this dual ability is facilitated by the two elifs
# Will return all columns including the field id i.e. all instances and arrays 
  
  if (typeof(data) == 'list') {
        data_head <- as_tibble(data)[1:5,] 
    } else {
        data_head <- as_tibble(fread(data, nrows = 5))
    }

  selected_col_ids <- data_head %>%
    select(starts_with(fields)) %>%
    colnames()
  
  if (typeof(data) == 'list') {
        data %>% select(selected_col_ids) 
    } else {
        as_tibble(fread(data, select = all_of(selected_col_ids)))
    }
}

  
# ----------------------------------------------------------------------------------------------------------
# Functions for finding eids based on values in the eid 'row'
# ----------------------------------------------------------------------------------------------------------

# Create list of eids for all individuals with at least one ICD code for melanoma
eids_w_at_least_1__specified_ICD = function(data, ICDs){
    eid_list = data %>%
        filter_all(any_vars(. %in% ICDs)) %>%
        select(eid)
}

# Create frequency table of ICDs specified. N.B. should be quicker using unique(unlist(data)) currently takes a long time to run, don't be concerned if slow
total_freq_of_ICDs = function(data, ICDs){
    freq_table = as_tibble(as.data.frame(table(unlist(data)))) %>%
    filter(Var1 %in% ICDs)
}

# Table of ICDs and the total number of unique eids that has each ICD
unique_eids_by_ICD = function(data, ICDs){
    eid_count = NULL
    for (i in ICDs){
        n_cases = data %>%
              filter_all(any_vars(. == i)) %>%
              select(eid)
    eid_count = bind_rows(eid_count, c(i = length(n_cases$eid)))
    }
    eid_count
}

# List of eids from unique_eids_by_ICD table
list_of_eids = function(data, ICDs){
    eid_list = NULL
    for (i in ICDs){
        n_cases = data %>%
              filter_all(any_vars(. == i)) %>%
              select(eid)
    eid_list = bind_rows(eid_list, n_cases)
    }
    eid_list = distinct(eid_list)
}

# ----------------------------------------------------------------------------------------------------------
# Recoding values
# ----------------------------------------------------------------------------------------------------------

recode_values = function(data, codings, data_dict) {

    codings <- if (typeof(codings) == 'list'){codings} else {as_tibble(fread(codings))}
    data <- if (typeof(data) == 'list'){data} else {as_tibble(fread(data))}
    data_dict <- if (typeof(data_dict) == 'list'){data_dict} else {read_excel(data_dict)}

    # Create 2-col coding lookup
    two_col_recode_lookup = codings %>%
        mutate(Coding_Value = paste0(Coding,"_",Value)) %>%
            select(Meaning, Coding_Value)

    # Use a forloop to relabel as could not extract col name from apply() <- requires that all the field ids you want to extract are in the data dict and have a pared Data_Coding
    for (i in 1:ncol(data)){
    col_i_name = colnames(data[,i])
    if (col_i_name %in% c('eid', 'casecont')) {
        print("No change made to column")
    } else {
        Coding <- data_dict$Data_Coding[data_dict$Field_ID == sub("\\-.*", "", col_i_name)]
        Coding = rep(Coding, length(unlist(data[,i]))) 
        data[,i] = paste0(Coding,"_", unlist(data[,i]))
        data[,i] = mapvalues(unlist(data[,i]), two_col_recode_lookup$Coding_Value, two_col_recode_lookup$Meaning, warn_missing = FALSE)
        }
    }

    # Recode NAs
    data = as_tibble(lapply(data, function(x) {
    gsub('.*_NA$', 'No Value', x)
    }))

}

# ==========================================================================================================
# WIP
# ==========================================================================================================

# Applying column names ------------------------------------------------------------------------------------

name_columns_w_data_dict <- function(data, data_dict){

    data <-
    data_dict <- 

    # Create a tibble of extracted col names with each component broken out: field_id, instance_id, coding_id
    f_id_to_ddict_lookup = tibble('extracted_col_names' = colnames(data))
    temp = separate(f_id_to_ddict_lookup, extracted_col_names, into = c('field_id', 'instance_id', 'array_id'), sep = "\\.") 
    f_id_to_ddict_lookup = as_tibble(cbind(f_id_to_ddict_lookup, temp)) 
    f_id_to_ddict_lookup = mutate(f_id_to_ddict_lookup, field_id = field_id %-% 'X') 
    f_id_to_ddict_lookup$field_id = as.integer(f_id_to_ddict_lookup$field_id)
    f_id_to_ddict_lookup$array_id = as.integer(f_id_to_ddict_lookup$array_id)

    # Add descriptions from data dictionary to f_id_to_ddict_lookup
    f_id_to_ddict_lookup = f_id_to_ddict_lookup %>%
        left_join(data_dict, c('field_id' = 'Field_ID'))

    # Concetenate and apply labels
    f_id_to_ddict_lookup$final_names = gsub(" ", "_",paste0(f_id_to_ddict_lookup$Description, ".", f_id_to_ddict_lookup$instance_id, ".", f_id_to_ddict_lookup$array_id))
    f_id_to_ddict_lookup$final_names = gsub(",", "_",f_id_to_ddict_lookup$final_names)
    colnames(main_data) = f_id_to_ddict_lookup$final_names
}