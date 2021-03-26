# Set up --------------------------------------------------------------------------------------------

if (!require("plyr")) install.packages("plyr", repos = "http://cran.us.r-project.org")
if (!require("tidyverse")) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if (!require("data.table")) install.packages("data.table", repos = "http://cran.us.r-project.org")
if (!require("readxl")) install.packages("readxl", repos = "http://cran.us.r-project.org")

setwd('/rds/general/project/hda_students_data/live/Group9/General')

# Inputs
source('Ross/Scripts/Table2_0_Inputs.R')

# Data
comorbs_1hot_plus <- as_tibble(fread(paste0(output_folder,job_ID,'3_comorbs_1hot.csv'))) %>% select(-V1)
cases_controls_eids <- read_csv('Data/cases_controls_ID.csv') #Cols: X1, eid, casecont
        
# =====================================================================================================================================================
# Add summary info
# =====================================================================================================================================================

# Add row sums and create summary by eid --------------------------------------------------------------------------------------------
comorbs_1hot_plus[,"Total_n_of_comorbidities"] <- rowSums(select(comorbs_1hot_plus, -casecont, -eid), na.rm = TRUE)

summ_by_eid <- comorbs_1hot_plus %>%
    select(casecont, eid, Total_n_of_comorbidities)

print('Row sums added')
print(Sys.time())


# Add col sums --------------------------------------------------------------------------------------------

comorbs_1hot_plus <- as_tibble(comorbs_1hot_plus)

# 1. Create object for Total_n_of_individuals N.B. for troubleshooting: this for loop only seems to work on a tibble format of comorbs_1hot_plus
Total_n_of_individuals <- data.frame()
for (i in 1:ncol(comorbs_1hot_plus)) {
    Total_n_of_individuals <- rbind(Total_n_of_individuals, sum(comorbs_1hot_plus[,i], na.rm = TRUE))
}
Total_n_of_individuals <- t(Total_n_of_individuals)
colnames(Total_n_of_individuals) <- colnames(comorbs_1hot_plus)


print('Colsums mid-milestone') 
print(Sys.time())


# 2. Subject to checks, rbind Total_n_of_individuals to comorbs_1hot_plus to create final output
if (ncol(comorbs_1hot_plus) == length(Total_n_of_individuals) & colnames(comorbs_1hot_plus[,which.max(Total_n_of_individuals)]) == 'eid'){
    comorbs_1hot_plus <- rbind(comorbs_1hot_plus, Total_n_of_individuals = Total_n_of_individuals)
} else {
    print("Checks have failed. Lengths do not match or eid is not max column. Investigate")
}

comorbs_1hot_plus <- as_tibble(comorbs_1hot_plus)

print('Col sums added')
print(Sys.time())


# Create summary by comorb (case and cont) --------------------------------------------------------------------------------------------

summ_by_comorb <- comorbs_1hot_plus %>% 
    group_by(casecont) %>% 
    summarise_all(sum, na.rm = TRUE)

# Re-arrange from wide to tall format
summ_by_comorb <- summ_by_comorb %>% select(-eid, -'No Value')
to_be_colnames <- colnames(summ_by_comorb)
summ_by_comorb <- t(as.data.frame(summ_by_comorb))
colnames(summ_by_comorb) <- c('control', 'case', 'all')
summ_by_comorb <- as_tibble(summ_by_comorb) # Need to add rownames
summ_by_comorb[,'Comorbs'] <- to_be_colnames
summ_by_comorb <- summ_by_comorb[,c(4,1,2,3)]
summ_by_comorb <- as_tibble(summ_by_comorb)

print('Summ by comorb made taller')
print(Sys.time())


# =====================================================================================================================================================
# Create 'Table 2' style output
# =====================================================================================================================================================

# Dynamic calculation of number cases and controls
total_N_cases <- sum(cases_controls_eids$casecont)
total_N_controls <- sum(cases_controls_eids$casecont == 0)
total_N_all <- dim(cases_controls_eids)[1]

# Subject to checks, create 'Table 2' style output
if(total_N_all == total_N_cases + total_N_controls) {
    table2 <- summ_by_comorb
    table2 <- table2 %>%
        mutate(control_percent = round(control / total_N_controls, 4) *100,
               case_percent = round(case / total_N_cases, 4) *100,
               all_percent = round(all / total_N_all,4) *100)
    
    table2 <- table2 %>%
        mutate(control_N_percent = paste0(control,"   (", control_percent," %)"),
               case_N_percent = paste0(case,"   (", case_percent," %)"),
               all_N_percent = paste0(all,"   (", all_percent," %)"))
} else
{print("Error in Table 2: check number of cases and controls is correct")
}


# =====================================================================================================================================================
# Write final output to csv
# =====================================================================================================================================================

write.csv(comorbs_1hot_plus, paste0(output_folder,job_ID,'4_comorbs_1hot_plus.csv'))
write.csv(summ_by_comorb, paste0(output_folder,job_ID,'5_summ_by_comorb.csv'))
write.csv(summ_by_eid, paste0(output_folder,job_ID,'6_summ_by_eid.csv'))
write.csv(table2, paste0(output_folder,job_ID,'7_table2.csv'))
