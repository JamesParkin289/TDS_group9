#  title: "Univariate Analysis Data Prep"
#  author: Ellie Van Vogt
#  Date: 02/03/21
rm(list=ls())
path="/rds/general/project/hda_students_data/live/Group9/General/ellie/Data_output"
setwd(path)
library(tidyverse)

# i think that this is the easiest dataset to use
data <- data.table(fread("working_dataset_2.csv", nrows = 300))

# Age -> 21003
# Sex -> 31
# Ethnicity -> 21000
# Current employment status -> 20119
# Deprivation score -> 189
# Average income before tax -> 738
# Skin colour -> 1717
# Childhood sunburn occasions -> 1737 not gonna include at first bc it's messed up
# Smoking -> Smoking status -> 20116


f_ids <- c("eid", "X31.0.0", "21003", "21000", "189", "738", "1717", "20116", "1558", "C43X")
cols_to_extract <- NULL
for (i in f_ids) {
  cols_to_extract <- c(cols_to_extract, grep(i, colnames(data)))
}
cols_to_extract <- sort(cols_to_extract)

# to make things easier i will try and only use the specific columns that we need for analysis

data <- data.table(fread("working_dataset_2.csv", select = cols_to_extract))
cases_controls_ID <- read.csv("cases_controls_ID.csv") %>%
  select(-X)


# ok so now need to merge all the instance columns together and rename them

data <- data %>%
  merge(cases_controls_ID) %>%
  rename("age_rec" = "X21003.0.0.x", "ethnicity" = "X21000.0.0",
         "deprivation" = "X189.0.0", "av_income" = "X738.0.0",
         "skin_colour" = "X1717.0.0", "smoking_status" = "X20116.0.0",
         "alcohol_consumption" = "X1558.0.0", "sex" = "X31.0.0.x") %>%
  mutate(
    sex = as.factor(sex),
    ethnicity = ifelse(ethnicity == "White" | ethnicity == "British" | ethnicity == "Any other white background",
                             "White", "Other"),
    ethnicity = as.factor(ethnicity),
    ethnicity = relevel(ethnicity, ref = "White"),
    av_income = as.factor(av_income),
    av_income = relevel(av_income, ref = "18,000 to 30,999"),
    skin_colour = as.factor(skin_colour),
    skin_colour = relevel(skin_colour, ref = "Fair"),
    smoking_status = as.factor(smoking_status),
    smoking_status = relevel(smoking_status, ref = "Never"),
    alcohol_consumption = as.factor(alcohol_consumption),
    alcohol_consumption = relevel(alcohol_consumption, ref = "Once or twice a week")
  ) %>%
  select(-c(X21003.0.0.y, X31.0.0.y, X21003.1.0, X21003.2.0, X3140.0.0, X3160.0.0,
            X738.1.0, X738.2.0, X21000.1.0, X21000.2.0, X20116.1.0, X20116.2.0,
            X1558.1.0, X1558.2.0, X1717.1.0, X1717.2.0, X21003.0.0, X31.0.0))

na_test<- data %>%
  lapply(is.na) %>%
  sapply(sum,simplify=TRUE)
# there are 19 missing values for deprivation score so will just exclude these from analysis for the time being


saveRDS(data, file = "univar_analysis_data.rds")
