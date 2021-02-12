# TDS Group 9 Git repo 
~ Hello and welcome to the most awesome group! ~  
Have put up some starter info after lurking around the UKB website.  
We can use this page as a quick wiki for our project.

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
  

## Group folder format 

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
└── Personal folders/         where your darkest secrets lives.. and maybe your git clone

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


------------------------------
</br>

## Further Useful Links

* [How data was collected and some glossary (ukb26390.csv)](https://biobank.ndph.ox.ac.uk/~bbdatan/Repeat_assessment_doc_v1.0.pdf)


* [Hospital Episode Statistics (HES) or more on hesin_diag + hesin.txt](https://biobank.ndph.ox.ac.uk/showcase/showcase/docs/HospitalEpisodeStatistics.pdf)

* [UK Biobank Simplified Web browser](https://biobank.ndph.ox.ac.uk/showcase/browse.cgi)

* [UK Biobank Search Tool (find specific Field IDs or Data-coding)](https://biobank.ndph.ox.ac.uk/showcase/search.cgi)

* [Full List of UK Biobank resources](https://biobank.ndph.ox.ac.uk/showcase/exinfo.cgi?src=UnderstandingUKB)