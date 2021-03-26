#  title: "Univariate Analysis"
#  author: Ellie Van Vogt
#  Date: 03/03/21

rm(list=ls())
setwd("/rds/general/project/hda_students_data/live/Group9/General/ellie/Data_output")
library(tidyverse)
library(data.table)

data <- readRDS("univar_analysis_data.rds")


#list of independent variables
indep_vars <- colnames(data)
indep_vars <- indep_vars[! indep_vars %in% c("eid", "sex", "age_rec", "casecont")]

models <- lapply(indep_vars, function(x) {
  glm(substitute(casecont ~ i + age_rec + sex, list(i = as.name(x))), data = data,family = binomial(link="logit"))
})

results <- data.frame(matrix(ncol = 6, nrow =0))

colnames(results) <- c("indep_variable", "category", "odds_ratio", "lower_bd", "upper_bd", "pval")

k = 1
for (i in 1:length(indep_vars)) {
  factors <- length(coefficients(models[[i]])) - 3
  for (j in 1:factors) {
    or = round(exp(coefficients(models[[i]])[1+j]), 3)
    ci = round(exp(confint(models[[i]])[1+j,]), 3)
    pval = round(coef(summary(models[[i]]))[1+j,4], 3)
    try = c(or, ci, pval)
    try = c(indep_vars[i], names(try[1]), try)
    results[k,] <- try
    k = k+1
  }
}

write.csv(results, "univar_results.csv")
