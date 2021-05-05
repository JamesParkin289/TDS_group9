import pandas as pd
import os 
import re

work_dir = os.getcwd()

# need to do for various sheets?
dfs = pd.read_excel(os.path.join(work_dir, 'Data/UK_Biobank_data_dictionary.xlsx'), sheet_name=None)

sheet_names = ['Recruitment', 'Individual characteristics', 'Socio-demographics', 'Lifestyle', \
'Exposures', 'Measurements', 'Genomics', 'Health-Medical', 'Sex-specific factors', 'Psycho-social factors'] 

# get col names 
df26 = pd.read_csv(os.path.join(work_dir, 'Data/ukb26390.csv'), index_col=0, nrows=0).columns.tolist()
df27 = pd.read_csv(os.path.join(work_dir, 'Data/ukb27725.csv'), index_col=0, nrows=0).columns.tolist()

# get unique field_ids without suffix 
l26 = [re.sub(r'\-\w[^-]*$', '', fid) for fid in df26]
u26 = set(l26)

l27 = [re.sub(r'\-\w[^-]*$', '', fid) for fid in df27]
u27 = set(l27)

unique_fids = list(u26) + list(u27)
unique_fids = [int(i) for i in unique_fids]

# match field_ids with unique_fids to keep
# discard rest 

cleaned_df = pd.DataFrame()

for n in range(len(dfs)):
    print(sheet_names[n])
    fetch = pd.DataFrame()
    try: 
        fetch = dfs[sheet_names[n]][dfs[sheet_names[n]]['Field ID'].isin(unique_fids)]
    except:
        fetch = dfs[sheet_names[n]][dfs[sheet_names[n]]['Category ID'].isin(unique_fids)]    
    cleaned_df = cleaned_df.append(fetch)

# drop weird added columns
cleaned_df = cleaned_df[['Category', 'Sub-category', 'Field ID', 'Description']]

cleaned_df.to_csv('Output/cleaned_dictionary.csv')