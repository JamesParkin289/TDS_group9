### Crafting table 1 ###
# Load ID's list for cases and controls #
IDs = read.csv("Data_output/cases_controls_ID.csv")

# Column list for table 1 columns #

# Age -> 21003
# Sex -> 31
# Ethnicity -> 21000
# Current employment status -> 20119
# Deprivation score -> 189
# Average income before tax -> 738
# Skin colour -> 1717
# Childhood sunburn occasions -> 1737
# Smoking =============================
#        => Ever smoked -> 20160
#        => Smoking status -> 20116
#        => Current daily number of cigarettes -> 3456
#        => Previous daily number of cigarettes -> 2887
# Age at cancer diag ============================================
#                    => Cancer record origin -> 40021
#                    => Cancer record format -> 40019
#                    => Reported occurrences of cancer -> 40009
#                    => Age at cancer diagnosis -> 40008
# Mortality ====================================
#          => Age at death -> 40007
#          => Primary cause of death ICD-10 -> 40001
#          => Description of cause of death -> 40010


# Load data with the above columns #

data = readRDS("Data_output/cases_controls_table1.rds")


# Select the cases and controls based on ID variable #

data_clean = data.frame()

for (i in IDs$eid){
  case_or_control = filter(data, eid == i)
  data_clean = rbind(data_clean, case_or_control)
}


# Remove withdrawn participants if any #

withdrawn=as.character(read.csv("Data/w19266_20200204.csv")[,1])

for (i in 1:135){
  tag = noquote(withdrawn[i])
  data_clean = filter(data_clean, data_clean$eid != tag)
}


# Add case control status to data # 
IDs = IDs[,-1]
data_clean = merge(data_clean, IDs, by = "eid")


# Name columns # 
field_id = list("21003" = "Age", "31" = "Sex", "21000" = "Ethnicity", "20119" = "Current employment status", 
                "189" = "Deprivation score", "738" = "Average income before tax", "1717" = "Skin colour",
                "1737" = "Childhood sunburn occasions", "20160" = "Ever smoked", "20116" = "Smoking status",
                "3456" = "Current daily no. of cigarettes", "2887" = "Previous daily no. of cigarettes", 
                "40021" = "Cancer record origin", "40019" = "Cancer record format", 
                "40009" = "Reported occurences of cancer", "40008" = "Age at cancer diagnosis", 
                "40007" = "Age at death", "40001" = "Primary cause of death (ICD 10)", 
                "40010" = "Description of cause of death")



count = 0
col_names = c()

for (i in colnames(data_clean)){
  for (j in names(field_id)){
    if (i %like% j){
      tag = field_id[[j]]
      tag = paste(tag, as.character(count))
      col_names = rbind(col_names, tag)
      count = count + 1
    }
  }
}

# We now have a vector of columns names to apply to the data set

colnames(data_clean)[2:73] = col_names
colnames(data_clean)[65] = "Age at death 63"
colnames(data_clean)[68] = "Primary cause of death (ICD 10) 66"
colnames(data_clean)[71] = "Description of cause of death 69"
colnames(data_clean)[73] = "Case control status"


# Remove clearly redundant columns # 
data_clean = data_clean[-2]
data_clean = data_clean[-c(3,4,7,8,12,13,15,16,18,19,21,22,24,25,27,28,30,31)]



# Check for missingness # 
apply(is.na(data_clean), 2, sum)
# Current employment status is essentially completely empty, so lets remove #
# On inspection of smoking variables, smoking status looks the best here with few missing values and good resolution

data_clean = data_clean[-c(5,10,12,13)]



# Save data set at this point as it is reasonably tidy now #
write.csv(data_clean, "Data_output/case_control_table1_features.csv")



# Tidying the codings etc #
data_clean$`Ethnicity 4` = ifelse(data_clean$`Ethnicity 4` == 1001, "White", "Other")

data_clean$`Average income before tax 9` = ifelse(data_clean$`Average income before tax 9` == 1,
                                                  "Less than 18K",
                                                  ifelse(data_clean$`Average income before tax 9` == 2,
                                                         "18K to 31K",
                                                         ifelse(data_clean$`Average income before tax 9` == 3,
                                                                "31K to 52K",
                                                                ifelse(data_clean$`Average income before tax 9` == 4,
                                                                       "52K to 100K",
                                                                       ifelse(data_clean$`Average income before tax 9` == 5,
                                                                              "Greater than 100K", NA)))))

data_clean$`Skin colour 12` = ifelse(data_clean$`Skin colour 12` == 1, "Very fair",
                                     ifelse(data_clean$`Skin colour 12` == 2, "Fair",
                                            ifelse(data_clean$`Skin colour 12` == 3, "Light olive",
                                                   ifelse(data_clean$`Skin colour 12` == 4, "Dark olive",
                                                          ifelse(data_clean$`Skin colour 12` == 5, "Brown",
                                                                 ifelse(data_clean$`Skin colour 12` == 6, "Black", NA))))))

data_clean$`Childhood sunburn occasions 15`[data_clean$`Childhood sunburn occasions 15` == -1] = NA
data_clean$`Childhood sunburn occasions 15`[data_clean$`Childhood sunburn occasions 15` == -3] = NA
data_clean$`Childhood sunburn occasions 15`[data_clean$`Childhood sunburn occasions 15` == 400] = NA
data_clean$`Childhood sunburn occasions 15`[data_clean$`Childhood sunburn occasions 15` == 300] = NA
data_clean$`Childhood sunburn occasions 15`[data_clean$`Childhood sunburn occasions 15` == 100] = NA

data_clean$`Smoking status 21` = ifelse(data_clean$`Smoking status 21`== 0, "Never",
                                        ifelse(data_clean$`Smoking status 21`== 1, "Previous",
                                               ifelse(data_clean$`Smoking status 21` == 2, "Current", NA)))



# Make case/control datasets # 

cases = filter(data_clean, data_clean$"Case control status" == 1)
controls = filter(data_clean, data_clean$"Case control status" == 0)



### Descriptive Analysis ###
# Stratified by case/control #

# Age #
hist(cases$`Age 0`)
hist(controls$`Age 0`)
# as expected the distributions are the same #
mean(cases$`Age 0`) # 59 years
mean(controls$`Age 0`) # 59 years

sd(cases$`Age 0`) # 7.54
sd(controls$`Age 0`) # 7.54
sd(data_clean$`Age 0`)

# Sex #
table(cases$`Sex 3`) # 2858 female, 2417 male
table(controls$`Sex 3`) # 5716 female, 4834 male
# Ratio of male to female is equal for both cases and controls 

# Ethnicity #
table(cases$`Ethnicity 4`) # 4947 White, 325 other
table(controls$`Ethnicity 4`) # 9346 White, 1186 other
# Seemingly big difference in ethnicity of cases and controls

# Deprivation score # 
hist(cases$`Deprivation score 8`)
hist(controls$`Deprivation score 8`)
# Distributions look similar # 
mean(cases$`Deprivation score 8`, na.rm = TRUE) # -1.91
mean(controls$`Deprivation score 8`, na.rm = TRUE) # -1.33
# Possible significant difference here with cases being more affluent.

sd(cases$`Deprivation score 8`, na.rm = TRUE) # 2.69
sd(controls$`Deprivation score 8`, na.rm = TRUE) # 3.09
sd(data_clean$`Deprivation score 8`, na.rm=TRUE) # 2.97


# Average income (before tax) # 
table(cases$`Average income before tax 9`) # 18-31 1182, 31-52 1168, 52-100 913, >100 247, <18 941
table(controls$`Average income before tax 9`) # 18-31 2380, 31-52 2198, 52-100 1483, >100 425, <18 2339
# Looks like the main difference is in the 52-100k category and less than 18k 
# Cases have higher proportion in wealthy and vice versa for controls

# Skin colour # 
table(cases$`Skin colour 12`) # Brown 21, Dark olive 35, Fair 3904, Light olive 577, Very fair 680
table(controls$`Skin colour 12`) # Black 75, Brown 266, Dark olive 167, Fair 7187, Light olive 1900, Very fair 796
# Black category that wasn't present in the controls is now present in the cases 
# Essentially, theres much higher proportions of the darker skin colours and lower proportions of the lighter skin colours

# Sunburn as child # 
plot(density(cases$`Childhood sunburn occasions 15`, na.rm = TRUE))
plot(density(controls$`Childhood sunburn occasions 15`, na.rm = TRUE))
# Both poisson distributions # 
mean(cases$`Childhood sunburn occasions 15`, na.rm= TRUE) # 2.56 (median 1)
mean(controls$`Childhood sunburn occasions 15`, na.rm = TRUE) # 1.42 (median 0)
# This seems fairly obvious, but good to confirm

sd(cases$`Childhood sunburn occasions 15`, na.rm= TRUE) # 4.74
sd(controls$`Childhood sunburn occasions 15`, na.rm = TRUE) # 3.07
sd(data_clean$`Childhood sunburn occasions 15`, na.rm=TRUE) # 3.71

# Smoking status # 
table(cases$`Smoking status 21`) # Current 367, Never 3012, Previous 1870
table(controls$`Smoking status 21`) # Current 1098, Never 5585, Previous 3795
# Oddly, seems to be more current smokers (proportionally) in the control group!

# Reported occurrences of cancer # 
hist(cases$`Reported occurences of cancer 30`)
hist(controls$`Reported occurences of cancer 30`)
# Both poisson distributions 
mean(cases$`Reported occurences of cancer 30`, na.rm=TRUE) # 3.61 (median 3)
mean(controls$`Reported occurences of cancer 30`, na.rm=TRUE) # 2.98 (median 3)

sd(cases$`Reported occurences of cancer 30`, na.rm=TRUE) # 2.16
sd(controls$`Reported occurences of cancer 30`, na.rm=TRUE) # 1.45
sd(data_clean$`Reported occurences of cancer 30`, na.rm = TRUE) # 1.98

# Age at cancer diagnosis #
nrow(data_clean) - sum(is.na(data_clean$`Age at cancer diagnosis 31`)) # 5739 cancers in whole group
nrow(cases) - sum(is.na(cases$`Age at cancer diagnosis 31`)) # 3932 belong to cases group
nrow(controls) - sum(is.na(controls$`Age at cancer diagnosis 31`)) # 1807 belong to controls group
# QUESTION -> Useful to include in table 1 

hist(cases$`Age at cancer diagnosis 31`)
hist(controls$`Age at cancer diagnosis 31`)
# Distributions look similar 

mean(cases$`Age at cancer diagnosis 31`, na.rm=TRUE) # 56.33 (median 58)
mean(controls$`Age at cancer diagnosis 31`, na.rm=TRUE) # 58.65 (median 61)

sd(cases$`Age at cancer diagnosis 31`, na.rm=TRUE) # 10.30
sd(controls$`Age at cancer diagnosis 31`, na.rm=TRUE) # 10.61
sd(data_clean$`Age at cancer diagnosis 31`, na.rm = TRUE) # 10.46

sum(cases$`Age at cancer diagnosis 32` != cases$`Age at cancer diagnosis 31`, na.rm = TRUE) # 961 
sum(controls$`Age at cancer diagnosis 32` != controls$`Age at cancer diagnosis 31`, na.rm = TRUE) # 249
# So, overall not very many go on to have a different age at second instance of cancer diagnosis 
# QUESTION -> is this worth proceeding with in terms of descriptive analysis?


# Age at death # 
nrow(cases) - sum(is.na(cases$`Age at death 63`)) # 273 deaths 
nrow(controls) - sum(is.na(controls$`Age at death 63`)) # 396 deaths 

mean(cases$`Age at death 63`, na.rm = TRUE) # 66.10
mean(controls$`Age at death 63`, na.rm = TRUE) # 67.64

sd(cases$`Age at death 63`, na.rm = TRUE) # 7.35
sd(controls$`Age at death 63`, na.rm = TRUE) # 5.97
sd(data_clean$`Age at death 63`, na.rm= TRUE) # 6.61



# QUESTION -> do we need to go into cause of death for table 1...? 






