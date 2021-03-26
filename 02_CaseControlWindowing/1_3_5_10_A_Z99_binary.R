# Title: having a go at making a smaller hesin dataset

# aiming for 1 row per patient
rm(list=ls())


path="/rds/general/project/hda_students_data/live/Group9/General/ellie/Data_output"
setwd(path)

library(tidyverse)
library(lubridate)

hes_1yr <- readRDS("hes_1yr_long.rds")
hes_3yr <- readRDS("hes_3yr_long.rds")
hes_5yr <- readRDS("hes_5yr_long.rds")
hes_10yr <- readRDS("hes_10yr_long.rds")
sample_ids <- read.csv("case_control_triplets_with_dates.csv")
sample_ids <- sample_ids %>%
  select(-X, -epistart)

# functions for creating categories -------------------------------------------
append_nums <- function(x) {
  z <- NULL
  for (i in 0:9) {
    z <- c(z, paste(x, i, sep = ""))
  }
  print(z)
}

append_nums2 <- function(x) {
  z <- NULL
  for (i in 0:9) {
    for (j in 0:9) {
      z <- c(z, paste(x, i, j, sep = ""))
    }
  }
  print(z)
}
# function for merging datasets together at the end ----------------------------
merge_group <- function(x, y) {
  x <- x %>%
    cbind(y) %>%
    select(-c(epistart, diag_icd10, diag_icd9)) %>%
    group_by(eid, triplet_id) %>%
    summarise_all(max) %>%
    merge(y = sample_ids) %>%
    select(eid, X21003.0.0, X31.0.0, casecont, triplet_id, everything())
  to_add <- setdiff(sample_ids$eid, x$eid)
  to_add_matrix <- sample_ids %>%
    filter(eid %in% to_add) %>%
    cbind(matrix(0, nrow = length(to_add), ncol = ncol(x) - 5))
  colnames(to_add_matrix) <- colnames(x)
  x <- x %>%
    rbind(to_add_matrix) %>%
    select_if(~ !is.numeric(.) || sum(.) != 0)
}

# making the lists of ICD10 categories -----------------------------------------
AZ <- LETTERS
#names(AZ) <- "AZ"
A0Z9 <- unlist(lapply(AZ, FUN = append_nums))
#names(A0Z9) <- "A0Z9"
A00Z99 <- unlist(lapply(AZ, FUN = append_nums2))
#names(A00Z99) <- "A00Z99"

# making the empty dataframes to be filled with 0's and 1's --------------------

# AZ
hes_1yr_AZ <- data.frame(matrix(nrow = nrow(hes_1yr), ncol = length(AZ)))
colnames(hes_1yr_AZ) <- AZ
hes_3yr_AZ <- data.frame(matrix(nrow = nrow(hes_3yr), ncol = length(AZ)))
colnames(hes_3yr_AZ) <- AZ
hes_5yr_AZ <- data.frame(matrix(nrow = nrow(hes_5yr), ncol = length(AZ)))
colnames(hes_5yr_AZ) <- AZ
hes_10yr_AZ <- data.frame(matrix(nrow = nrow(hes_10yr), ncol = length(AZ)))
colnames(hes_10yr_AZ) <- AZ

# A0Z9
hes_1yr_A0Z9 <- data.frame(matrix(nrow = nrow(hes_1yr), ncol = length(A0Z9)))
colnames(hes_1yr_A0Z9) <- A0Z9
hes_3yr_A0Z9 <- data.frame(matrix(nrow = nrow(hes_3yr), ncol = length(A0Z9)))
colnames(hes_3yr_A0Z9) <- A0Z9
hes_5yr_A0Z9 <- data.frame(matrix(nrow = nrow(hes_5yr), ncol = length(A0Z9)))
colnames(hes_5yr_A0Z9) <- A0Z9
hes_10yr_A0Z9 <- data.frame(matrix(nrow = nrow(hes_10yr), ncol = length(A0Z9)))
colnames(hes_10yr_A0Z9) <- A0Z9

# A00Z99
hes_1yr_A00Z99 <- data.frame(matrix(nrow = nrow(hes_1yr), ncol = length(A00Z99)))
colnames(hes_1yr_A00Z99) <- A00Z99
hes_3yr_A00Z99 <- data.frame(matrix(nrow = nrow(hes_3yr), ncol = length(A00Z99)))
colnames(hes_3yr_A00Z99) <- A00Z99
hes_5yr_A00Z99 <- data.frame(matrix(nrow = nrow(hes_5yr), ncol = length(A00Z99)))
colnames(hes_5yr_A00Z99) <- A00Z99
hes_10yr_A00Z99 <- data.frame(matrix(nrow = nrow(hes_10yr), ncol = length(A00Z99)))
colnames(hes_10yr_A00Z99) <- A00Z99

# doing the 1 hot encoding -----------------------------------------------------
path="/rds/general/project/hda_students_data/live/Group9/General/ellie/Data_output/1_3_5_AtoZ99_binary"
setwd(path)

# hes 1yr
# AZ
for (i in colnames(hes_1yr_AZ)) {
  hes_1yr_AZ[,i] <- ifelse(grepl(i, hes_1yr$diag_icd10), 1, 0)
}
hes_1yr_AZ <- merge_group(hes_1yr_AZ, hes_1yr)
write.csv(hes_1yr_AZ, "hes_1yr_AZ_bin.csv", row.names = FALSE)

# A0Z9
for (i in colnames(hes_1yr_A0Z9)) {
  hes_1yr_A0Z9[,i] <- ifelse(grepl(i, hes_1yr$diag_icd10), 1, 0)
}
hes_1yr_A0Z9 <- merge_group(hes_1yr_A0Z9, hes_1yr)
write.csv(hes_1yr_A0Z9, "hes_1yr_A0Z9_bin.csv", row.names = FALSE)

# A00Z99
for (i in colnames(hes_1yr_A00Z99)) {
  hes_1yr_A00Z99[,i] <- ifelse(grepl(i, hes_1yr$diag_icd10), 1, 0)
}
hes_1yr_A00Z99 <- merge_group(hes_1yr_A00Z99, hes_1yr)
write.csv(hes_1yr_A00Z99, "hes_1yr_A00Z99_bin.csv", row.names = FALSE)

# hes 3yr
# AZ
for (i in colnames(hes_3yr_AZ)) {
  hes_3yr_AZ[,i] <- ifelse(grepl(i, hes_3yr$diag_icd10), 1, 0)
}
hes_3yr_AZ <- merge_group(hes_3yr_AZ, hes_3yr)
write.csv(hes_3yr_AZ, "hes_3yr_AZ_bin.csv", row.names = FALSE)

# A0Z9
for (i in colnames(hes_3yr_A0Z9)) {
  hes_3yr_A0Z9[,i] <- ifelse(grepl(i, hes_3yr$diag_icd10), 1, 0)
}
hes_3yr_A0Z9 <- merge_group(hes_3yr_A0Z9, hes_3yr)
write.csv(hes_3yr_A0Z9, "hes_3yr_A0Z9_bin.csv", row.names = FALSE)


# A00Z99
for (i in colnames(hes_3yr_A00Z99)) {
  hes_3yr_A00Z99[,i] <- ifelse(grepl(i, hes_3yr$diag_icd10), 1, 0)
}
hes_3yr_A00Z99 <- merge_group(hes_3yr_A00Z99, hes_3yr)
write.csv(hes_3yr_A00Z99, "hes_3yr_A00Z99_bin.csv", row.names = FALSE)

# hes 5yr
# AZ
for (i in colnames(hes_5yr_AZ)) {
  hes_5yr_AZ[,i] <- ifelse(grepl(i, hes_5yr$diag_icd10), 1, 0)
}
hes_5yr_AZ <- merge_group(hes_5yr_AZ, hes_5yr)
write.csv(hes_5yr_AZ, "hes_5yr_AZ_bin.csv", row.names = FALSE)

# A0Z9
for (i in colnames(hes_5yr_A0Z9)) {
  hes_5yr_A0Z9[,i] <- ifelse(grepl(i, hes_5yr$diag_icd10), 1, 0)
}
hes_5yr_A0Z9 <- merge_group(hes_5yr_A0Z9, hes_5yr)
write.csv(hes_5yr_A0Z9, "hes_5yr_A0Z9_bin.csv", row.names = FALSE)

# A00Z99
for (i in colnames(hes_5yr_A00Z99)) {
  hes_5yr_A00Z99[,i] <- ifelse(grepl(i, hes_5yr$diag_icd10), 1, 0)
}
hes_5yr_A00Z99 <- merge_group(hes_5yr_A00Z99, hes_5yr)
write.csv(hes_5yr_A00Z99, "hes_5yr_A00Z99_bin.csv", row.names = FALSE)

# hes 10yr
# AZ
for (i in colnames(hes_10yr_AZ)) {
  hes_10yr_AZ[,i] <- ifelse(grepl(i, hes_10yr$diag_icd10), 1, 0)
}
hes_10yr_AZ <- merge_group(hes_10yr_AZ, hes_10yr)
write.csv(hes_10yr_AZ, "hes_10yr_AZ_bin.csv", row.names = FALSE)

# A0Z9
for (i in colnames(hes_10yr_A0Z9)) {
  hes_10yr_A0Z9[,i] <- ifelse(grepl(i, hes_10yr$diag_icd10), 1, 0)
}
hes_10yr_A0Z9 <- merge_group(hes_10yr_A0Z9, hes_10yr)
write.csv(hes_10yr_A0Z9, "hes_10yr_A0Z9_bin.csv", row.names = FALSE)

# A00Z99
for (i in colnames(hes_10yr_A00Z99)) {
  hes_10yr_A00Z99[,i] <- ifelse(grepl(i, hes_10yr$diag_icd10), 1, 0)
}
hes_10yr_A00Z99 <- merge_group(hes_10yr_A00Z99, hes_10yr)
write.csv(hes_10yr_A00Z99, "hes_10yr_A00Z99_bin.csv", row.names = FALSE)
