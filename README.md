# TDS Group 9 Git repo 
~ Hello and welcome to the TDS group 9 UKBB repo! ~  
This page as serves both as a wiki for our project and repository of code.

## About
Our project is focused on malignant melanoma prediction using machine learning techniques. We performed a time-windowing of comorbidities based on a triplet-paired case control matching. Full details of this and the results are as described in our report.

## Scripts
These are organized into 4 folders for your reading:
1. Data Wrangling
2. Case Control Selection and Windowing
3. Descriptive Analysis and Vizualization
4. Modelling 


</br>


## What's with all the files? *

| Filename      | Description |  Content  |
| ----------- | ----------- | -----------  |
|   |   |  |
| ukb26390.csv      | Main dataset | Demographics and questionnaire answers |
| ukb227725.csv   | Hospital Episodes Statistics dataset | Blood biochemistry, inpatient diagnoses,  health-related outcomes (ie death register, cancer register) |
| codings_showcase.csv | decode categorical variables | ie. synonymous with Data-coding on UKB |
| Biomaker_anotation.xlsx | to pair for decoding ukb227725.csv | ie. Calcium blood level = Field_ID 30680 |
|    |   |   |
| hesin_diag.txt | medical history for each participant, to couple with recoding_disease.R | icd9 diagnoses ie. B968 |
| hesin.txt | HES further info - pair with hesin_diag.txt | contains HES diagnoses dates  |
| recoding_disease.R | R code to pull out disease outcomes | outputs: disease_outcomes.rds | 
|    |   |   |
| w19266_20200204.csv | withdrawn participants eid |  | 

---------------------------

</br>  
  

## Group folder format on HPC

```
Group9/General/
|
├── Data/
│   ├── InputDataFiles/       *contains all files in above table ^
│   ├── PipelineScripts/      Rscripts by Ross + toy dataset generator
│   └── pipeline_README.txt 
│   
├── GIT_repo_9/
│   ├── README.md             <-- where this wiki lives
│   └── ...
|
├── Init_files/               original files provided by department
|   ├── example_extraction/   folder with original implementation of field_ID extraction
|   ├── ...                   copies of original scripts 
|   └── nina.yml              example anaconda environment yaml file 
|
└── Personal folders/         where personal scripts are

```
-------------------------------

</br>

## UK Biobank jargon

**“F_I_A” format for column names**

where F is the field ID, I is the instance index and A is the array index.

- example from UKB - 

>46_0_0 corresponds to :  
>Field 46 (Hand grip strength (left))
Instance 0 (baseline measurement)
Array 0 (first measurement taken)

>46_1_0 corresponds to:   
> Field 46 (Hand grip strength (left))
Instance 1 (repeat assessment measurement)
Array 0 (first measurement taken)

</br>

**HES dataset glossary**

>"hesin" = master table containing inpatient episodes of UK (including ICU/op/maternity,etc..)  

>"hesin_diag" = diagnosis codes (ICD-9 or ICD-10) relating to inpatient episodes

>"spell" = single inpatient admission, a duration from admission to dischage  
 * 1 spell can be split into, or have several 'episodes'  
 * episodes here refer to being under one consultant in that hospital   
 * if patients' care is transferred to another consultant, then a new 'episode' is generated   

"spell_index" = attempt at grouping several episodes under a spell 


</br>




------------------------------
</br>

## Further Useful Links

* [BiobankRead - Python Github ? outdated 2019](https://github.com/saphir746/BiobankRead-Bash)
* [BiobankRead - biorxiv.org](https://www.biorxiv.org/content/10.1101/569715v1.full.pdf)

* [How data was collected and some glossary (ukb26390.csv)](https://biobank.ndph.ox.ac.uk/~bbdatan/Repeat_assessment_doc_v1.0.pdf)


* [Hospital Episode Statistics (HES) or more on hesin_diag + hesin.txt](https://biobank.ndph.ox.ac.uk/showcase/showcase/docs/HospitalEpisodeStatistics.pdf)

* [HES Data Dictionary](https://biobank.ndph.ox.ac.uk/showcase/showcase/docs/HESDataDic.xlsx)

* [UK Biobank Simplified Web browser](https://biobank.ndph.ox.ac.uk/showcase/browse.cgi)

* [UK Biobank Search Tool (find specific Field IDs or Data-coding)](https://biobank.ndph.ox.ac.uk/showcase/search.cgi)

* [Full List of UK Biobank resources](https://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=UnderstandingUKB)