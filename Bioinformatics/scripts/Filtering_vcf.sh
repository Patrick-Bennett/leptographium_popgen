#!/bin/bash
#$ -N Filter_VCF
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -l h='symbiosis'
#$ -l mem_free=10G
#$ -t 1-121:1
#$ -tc 10

i=$(expr $SGE_TASK_ID - 1)
FILE=( `cat "/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/chrom_vcf.list" `)
IFS=';' read -r -a arr <<< "${FILE[$i]}"

mkdir -p filteredVCF

CMD='Rscript Filtering_vcf.R ${arr[0]}'
echo $CMD
eval $CMD

# EOF.
