# adaptation of barbara's script
# pull in user settings (ie. how many toys to generate, filenames, etc)
rm(list=ls())

if (!require("reader")) install.packages("reader", repos = "http://cran.us.r-project.org")
library("reader")

inputFilename <- n.readLines("toygen_settings.txt", n = 1, skip = 28)

numberOfToys <- strtoi(n.readLines("toygen_settings.txt", n = 1, skip = 31))

outputFilename <- n.readLines("toygen_settings.txt", n = 1, skip = 34)

print(outputFilename)

print("Your selected input data: ")
print(inputFilename)

####


# Function
GenerateToyData=function(x,n=100,p=NULL,seed=1,observation_consistency=FALSE){
  # x is the original (real) dataset
  # By default (p=NULL), all variables will be kept in the resulting toy example dataset
  # You can choose how many observations to keep in the toy example dataset (no need to go over 100 in general)
  # You can change the seed if you want to generate multiple toy example datasets (not needed in general)
  
  print("Trimming to desired number of patients....")
 
  if (is.null(p)){
    p=ncol(x)
  }
  
  if (n>nrow(x)){
    stop(paste0("Please set n to be smaller than the number of rows in the original dataset (i.e. n<=", nrow(x), ")"))
  }
  
  # Random sub-sample of rows and columns
  set.seed(seed)
  s=sample(nrow(x), size=n)
  if (p==ncol(x)){
    xtoy=x[s,1:p]
  } else {
    xtoy=x[s,sample(p)]
  }
  
  if (!observation_consistency){
    # Permutation of the observations by variable (keeping the structure of missing data)
    for (k in 1:p){
      xtmp=xtoy[,k]
      xtmp[!is.na(xtmp)]=sample(as.character(xtmp[!is.na(xtmp)]))
      xtoy[,k]=xtmp
    }
  }
  
  rownames(xtoy)=1:nrow(xtoy)
  return(xtoy)
}


# Loading the original (real) data
# change to csv and take user input 
print("Loading in data.... (takes a while)")
mydata = read.csv(paste0("../OutputDataFiles/", inputFilename))

# Define the number of observations you want in the toy data
n=numberOfToys

# Definition of the variables that need to be modelled together for the toy dataset to be meaningful
# For example: disease status and time of diagnosis for this disease 
# We want to ensure that controls do not have a date of diagnosis
# This information will be stored as a list with vectors containing the IDs of variables that go together
# In the example below, variables 2 and 3 go together, so do variables 4-10, and variables 11-14
mylist=list(c(2:3), c(4:10), c(11:14))

# Extracting random subsets of participants for each block of variables
# We subset n participants and ensure that the observations stay aligned by setting observation_consistency to TRUE
# Different subsets of participants are taken at each iteration (different seed)
toydata=NULL
for (i in 1:length(mylist)){
  tmp=GenerateToyData(x=mydata[,mylist[[i]]], seed=i, n=n, observation_consistency=TRUE)
  toydata=cbind(toydata, as.matrix(tmp))
}

# Extracting permuted observations for all remaining variables
# This time, we set observation_consistency to FALSE
# The observations will be permuted, i.e. the correlation structure between variables will be broken
ids=1:ncol(mydata)
ids=ids[!ids%in%unlist(mylist)]
tmp=GenerateToyData(x=mydata[,ids], seed=length(mylist)+1, n=n, observation_consistency=FALSE)
toydata=cbind(toydata, as.matrix(tmp))

# Re-ordering the variables (optional)
toydata=toydata[,colnames(mydata)]

print("Final sample size numbers: ")
print(numberOfToys)

# Saving the toy dataset (as csv and not rds >:))
# use user input for output filename 
write.csv(toydata, paste0("../OutputDataFiles/", outputFilename))

print("Your output is done: (now you can have a snack!)")
print(outputFilename)

print("Disclaimer: simulated and randomly shuffled data, columns may not match!")
# Notes: 
# - The object toydata is a matrix, you can then reformat it as a data frame and make sure continuous variables are coded as numeric, 
#   and categorical variables are given as factors (remember to correctly set the first level as reference for your models!)
# - You would not find significant associations using this toy dataset because of the permutations (but it can happen by chance)