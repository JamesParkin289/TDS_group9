# Title: using davids list to create my list of 1 3 and 5 year categories

# sample ids list for reference

rm(list=ls())

path="/rds/general/project/hda_students_data/live/Group9/General/ellie/Data_output"
setwd(path)

library(dplyr)
library(lubridate)
library(Matrix)

sample_ids <- read.csv("cases_controls_triplet_ID.csv") # for reference
sample_ids <- sample_ids %>%
  select(-X) %>%
  filter(eid != 1053284) # getting rid of the rogue case

case_ids <- sample_ids %>%
  filter(casecont == 1)


# let's get davids list of cases and their dates

diag_dates <- read.csv("ukb_hes_melanoma_incidence.csv")
diag_dates <- diag_dates %>%
  mutate(epistart = as_date(Melanoma_incidence)) %>%
  select(-Melanoma_incidence) %>%
  merge(sample_ids) %>%
  filter(eid != 1053284, epistart != "1970-01-01") # getting rid of the rogue case

case["eid" %in% setdiff(case_ids$eid, diag_dates$eid),]$triplet_id

get_rid_ids <- setdiff(case_ids$eid, diag_dates$eid)
get_rid_triplets <- case_ids %>%
  filter(eid %in% get_rid_ids) %>%
  select(triplet_id)

sample_ids <- sample_ids %>%
  filter(!(triplet_id %in% get_rid_triplets$triplet_id)) %>%
  merge(y = diag_dates, all.x = T)

write.csv(sample_ids, "case_control_triplets_with_dates.csv")
