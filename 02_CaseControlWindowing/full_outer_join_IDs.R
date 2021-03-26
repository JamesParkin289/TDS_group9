# Left join on eid between Malo IDs (ICD 10) and David IDs (ICD 9)

ICD_9_mm = read.csv("Data_output/mm_hes_IDs.csv")
ICD_10_mm = read.csv("Data/Malo_Melanomas_IDs.csv")
ICD_10_mm = cbind(ICD_10_mm$X, ICD_10_mm$eid)
ICD_10_mm = data.frame(ICD_10_mm)



mm_cases_ID_final = merge(ICD_10_mm, ICD_9_mm, by.y= "X1000230", by.x= "X2", all=TRUE)

colnames(mm_cases_ID_final) = c("eid", "ICD_10", "ICD_9")

write.csv(mm_cases_ID_final, "Data_output/mm_cases_ID_final.csv")