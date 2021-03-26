# Data exploration of cases/controls total # 

IDs = read.csv("Data_output/cases_controls_ID.csv")
data = readRDS("Data_output/melanoma_descriptive.rds") # Data contains age at entry, sex, age at diagnosis and ICD 10 codings

# Filter based on IDs #

case_con_data = data.frame()

for (i in IDs$eid){
  case_control = filter(data, eid == i)
  case_con_data = rbind(case_con_data, case_control)
}

# Remove withdrawn participants #

withdrawn=as.character(read.csv("Data/w19266_20200204.csv")[,1])

for (i in 1:135){
  tag = noquote(withdrawn[i])
  case_con_data = filter(case_con_data, case_con_data$eid != tag)
}

## No participants removed! :) ##

# Remove redundant columns 
case_con_data = case_con_data[c(1:5, 8, 11, 14, 17, 20, 52)]

# Name columns 
colnames(case_con_data) = c("EID", "Age at entry", "Sex","Townsend deprivation index", 
                      "Average household (before tax)", "Ethnic background", 
                      "Alchohol intake frequency", "Skin colour",
                      "Time spent outdoors in Summer", "Age at cancer diagnosis", "ICD10 code")


# Basic descriptives #
## Age at entry ##
mean(case_con_data$`Age at entry`) # 59 years
median(case_con_data$`Age at entry`) # 61 years
hist(case_con_data$`Age at entry`) # Left skewed dist

## Sex ##
table(case_con_data$Sex) # female 8574, male 7251

## Age at diagnosis ##
mean(case_con_data$`Age at cancer diagnosis`, na.rm = TRUE) # 57 years
median(case_con_data$`Age at cancer diagnosis`, na.rm = TRUE) # 59 years
hist(case_con_data$`Age at cancer diagnosis`) # Normal dist/left skew


# Count number of incident cases of melanoma # 
sum(case_con_data$`Age at cancer diagnosis` > case_con_data$`Age at entry`, na.rm = TRUE) # 2457 incident cases **
## ** Need to tally this up with full column data for ICD diag etc...# 
sum(case_con_data$`Age at cancer diagnosis` <= case_con_data$`Age at entry`, na.rm = TRUE) # 3283 prevalent cases
## ** Prevalent data logic should be fine 


# Count NAs ##
sapply(case_con_data, function(x) sum(is.na(x))) # Only significant missingness in data columns is age at cancer
# diagnosis, which makes sense #


# Townsend index #
hist(case_con_data$`Townsend deprivation index`) # right skew normal distribution
mean(case_con_data$`Townsend deprivation index`, na.rm = TRUE) # -1.52, (-1.93 melanoma), (whole biobank -1.29)
median(case_con_data$`Townsend deprivation index`, na.rm=TRUE) # -2.34, (-2.63 melanoma)

# Household income #
case_con_data$`Average household (before tax)` = ifelse(case_con_data$`Average household (before tax)` == 1,
                                                  "Less than 18K",
                                                  ifelse(case_con_data$`Average household (before tax)` == 2,
                                                         "18K to 31K",
                                                         ifelse(case_con_data$`Average household (before tax)` == 3,
                                                                "31K to 52K",
                                                                ifelse(case_con_data$`Average household (before tax)` == 4,
                                                                       "52K to 100K",
                                                                       ifelse(case_con_data$`Average household (before tax)` == 5,
                                                                              "Greater than 100K", NA)))))

counts = table(case_con_data$`Average household (before tax)`)
barplot(counts)


# Ethnic background # 
case_con_data$`Ethnic background` = ifelse(case_con_data$`Ethnic background` == 1001, "White", "Other")

counts = table(case_con_data$`Ethnic background`)
barplot(counts)


# Alcohol intake frequency # 
case_con_data$`Alchohol intake frequency` = ifelse(case_con_data$`Alchohol intake frequency` == 1, "Daily or almost daily",
                                             ifelse(case_con_data$`Alchohol intake frequency` == 2, "Three or four times daily",
                                                    ifelse(case_con_data$`Alchohol intake frequency` == 3, "Once or twice a week",
                                                           ifelse(case_con_data$`Alchohol intake frequency` == 4, "One to three times a week",
                                                                  ifelse(case_con_data$`Alchohol intake frequency` == 5, "Special occasions", "Other")))))

counts = table(case_con_data$`Alchohol intake frequency`)
barplot(counts)


# Skin colour #
case_con_data$`Skin colour` = ifelse(case_con_data$`Skin colour` == 1, "Very fair",
                               ifelse(case_con_data$`Skin colour` == 2, "Fair",
                                      ifelse(case_con_data$`Skin colour` == 3, "Light olive",
                                             ifelse(case_con_data$`Skin colour` == 4, "Dark olive",
                                                    ifelse(case_con_data$`Skin colour` == 5, "Brown",
                                                           ifelse(case_con_data$`Skin colour` == 6, "Black", NA))))))


counts = table(case_con_data$`Skin colour`)
barplot(counts)


# Time spent outdoors in summer #
case_con_data$`Time spent outdoors in Summer` = ifelse(case_con_data$`Time spent outdoors in Summer` == -10, "Less than one hour a day", NA)


counts = table(case_con_data$`Time spent outdoors in Summer`)
barplot(counts)



# Extract the data #
write.csv(case_con_data, "Data_output/cases_controls_data_exploration.csv")


## Summary stat to include ##
# Age, sex, age at diagnosis (get better variable for this), deprivation score, average income, sun exposure variable,
# ethnicity, skin colour, smoking (better variable for this), mortality variable, occupation.



