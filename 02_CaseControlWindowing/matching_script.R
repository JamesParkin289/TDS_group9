# =====================================
# = Attempt at matching cases and controls
# =====================================
rm(list=ls())

#install.packages("MatchIt")
library(MatchIt)
library(dplyr)

path="/rds/general/project/hda_students_data/live/Group9/General/ellie/scripts"
setwd(path)

# X31.0.0 is sex, X21003.0.0 is age at recruitment

# read in the ukb dataset with eids and columns of interest for efficiency
mydata=data.frame(fread("../Data/ukb26390.csv", header = TRUE, select = c('eid', '21003-0.0', '31-0.0')))

# list of melanoma case eids
cases <- as.vector(read.csv("../Data/mm_cases_ID_final.csv")[,2]) # gets the eids

# remove people who have withdrawn consent
withdrawn=as.vector(read.csv("../Data/w19266_20200204.csv")[,1]) # 135 rows

mydata = subset(mydata, !(eid %in% withdrawn)) # this only removes 31 rows ??
row.names(mydata) <- 1:nrow(mydata)
# mark out cases and potential controls

mydata$casecont <- ifelse(mydata$eid %in% cases, 1, 0)
table(mydata$casecont) # 5275 cases and 497231 controls

# selection of controls ========================================================

# age at recruitment is X21003.0.0

controls <- matchit(casecont ~ X21003.0.0 + X31.0.0, data = mydata, ratio = 2, distance = "mahalanobis", method = "nearest")

matches <- controls$match.matrix
matches
View(matches)

caserows <- rownames(matches)
summary(as.numeric(caserows))
which(rownames(matches)== i)
print(matches[which(rownames(matches)== i),])

k = 1
mydata$triplet_id <- 0
for (i in 1:length(caserows)) {
  case <- as.numeric(caserows[i])
  control1 <- as.numeric(matches[i,][1])
  control2 <- as.numeric(matches[i,][2])
  mydata$triplet_id[control1] <- k
  mydata$triplet_id[control2] <- k
  mydata$triplet_id[case] <- k
  k <- k+1
}
table(mydata$triplet_id)

sum(mydata$triplet_id > 0)

print(head(mydata))

mydata <- mydata %>%
  filter(triplet_id >0)

write.csv(mydata, "../Data_output/cases_controls_triplet_ID.csv")

