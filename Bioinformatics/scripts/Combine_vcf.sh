
#! /bin/bash
#$ -N Combine_vcf
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q fangorn


i=$(expr $SGE_TASK_ID - 1)

REF="/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/CMW154.fa"

CMD="/raid1/home/bpp/tabimaj/bin/gatk-4.0.1.2/gatk CombineGVCFs -R $REF -V gvcf.list  -O Leptographium_2019.gvcf.gz"
echo $CMD
eval $CMD

date

# EOF.
