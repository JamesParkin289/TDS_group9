# Libraries #
library(tidyverse)
library(ggthemes)
library(hrbrthemes)

# Descriptive graphs # 
setwd("/rds/general/project/hda_students_data/live/Group9/General/James/TDS_project/")
data = read.csv("Data_output/case_control_table1_features.csv")

# Split cases and controls #
cases = filter(data, data$"Case.control.status" == 1)
controls = filter(data, data$"Case.control.status" == 0)

data$Case.control.status = as.factor(data$Case.control.status)

# Age graphs # 
casevscontrol_age_plot = ggplot(data=data, aes(x=Age.0, group=Case.control.status, fill =Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Age Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Age (Years)") +
  geom_vline(xintercept = mean(cases$Age.0), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Age.0) + 2.5 , y = 0.02, label = "Mean age") 

casevscontrol_age_plot


# Deprivation score #
casevscontrol_deprivation_plot = ggplot(data=data, aes(x=Deprivation.score.8, group=Case.control.status, fill=Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Deprivation score Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Deprivation score") +
  geom_vline(xintercept = mean(cases$Deprivation.score.8, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Deprivation.score.8, na.rm=TRUE) - 1.5, y = 0.02, label = "Cases mean") +
  geom_vline(xintercept = mean(controls$Deprivation.score.8, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(controls$Deprivation.score.8, na.rm=TRUE) + 1.7, y = 0.04, label = "Controls mean") 


casevscontrol_deprivation_plot

# Childhood sunburn # 
casevscontrol_sunburn_plot = ggplot(data=data, aes(x=Childhood.sunburn.occasions.15, group=Case.control.status, fill=Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Childhood Sunburn Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Childhood sunburn (frequency)") +
  xlim(0, 25) +
  geom_vline(xintercept = mean(cases$Childhood.sunburn.occasions.15, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Childhood.sunburn.occasions.15, na.rm=TRUE) + 2.25, y = 0.2, label = "Cases mean") +
  geom_vline(xintercept = mean(controls$Childhood.sunburn.occasions.15, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(controls$Childhood.sunburn.occasions.15, na.rm=TRUE) + 2.5, y = 0.3, label = "Controls mean") 


casevscontrol_sunburn_plot

# Reported occurences of cancer #
casevscontrol_canceroccurences_plot = ggplot(data=data, aes(x=Reported.occurences.of.cancer.30, group=Case.control.status, fill=Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Reported Cancer Occurences Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Reported Cancer Occurences (frequency)") +
  xlim(0,15) +
  geom_vline(xintercept = mean(cases$Reported.occurences.of.cancer.30, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Reported.occurences.of.cancer.30, na.rm=TRUE) + 1.3, y = 0.5, label = "Cases mean") +
  geom_vline(xintercept = mean(controls$Reported.occurences.of.cancer.30, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(controls$Reported.occurences.of.cancer.30, na.rm=TRUE) - 1.5, y = 0.4, label = "Controls mean") 


casevscontrol_canceroccurences_plot


# Age at cancer diagnosis #
casevscontrol_agediagnosis_plot = ggplot(data=data, aes(x=Age.at.cancer.diagnosis.31, group=Case.control.status, fill=Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Age At Cancer Diagnosis Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Age at Cancer Diagnosis (years)") +
  geom_vline(xintercept = mean(cases$Age.at.cancer.diagnosis.31, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Age.at.cancer.diagnosis.31, na.rm=TRUE) -6, y = 0.005, label = "Cases mean") +
  geom_vline(xintercept = mean(controls$Age.at.cancer.diagnosis.31, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(controls$Age.at.cancer.diagnosis.31, na.rm=TRUE) +7, y = 0.01, label = "Controls mean") 


casevscontrol_agediagnosis_plot



# Age at death # 
casevscontrol_ageatdeath_plot = ggplot(data=data, aes(x=Age.at.death.63, group=Case.control.status, fill=Case.control.status)) + 
  geom_density(adjust=1.5, alpha=.4) +
  theme_ipsum() +
  ggtitle("Cases vs Controls Age At Death Density") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  labs(x="Age at Death (years)") +
  geom_vline(xintercept = mean(cases$Age.at.death.63, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(cases$Age.at.death.63, na.rm=TRUE) -3.5, y = 0.02, label = "Cases mean") +
  geom_vline(xintercept = mean(controls$Age.at.death.63, na.rm = TRUE), linetype="dotted") +
  annotate(geom = "label", x= mean(controls$Age.at.death.63, na.rm=TRUE) +4, y = 0.01, label = "Controls mean") 


casevscontrol_ageatdeath_plot


# 



