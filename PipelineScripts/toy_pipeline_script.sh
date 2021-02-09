#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=1:mem=10gb

module load anaconda3/personal

cd /rds/general/project/hda_students_data/live/Group9/General/<your foldername>/Data/PipelineScripts

Rscript 01_DataPipeline_UnlabelledOutput.R
Rscript 02_toy_generator.R
