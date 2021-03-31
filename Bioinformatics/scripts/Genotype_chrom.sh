#!/bin/bash
#$ -V
#$ -v TMPDIR=/data
#$ -N Geno_chrom
#$ -l mem_free=40G
#$ -S /bin/bash
#$ -cwd
#$ -t 1-122
#$ -tc 10

mkdir -p genotyped

i=$(expr $SGE_TASK_ID - 1)

CMD="/raid1/home/bpp/tabimaj/bin/gatk-4.0.1.2/gatk --java-options '-Xmx40g -Djava.io.tmpdir=/data -XX:ParallelGCThreads=1' GenotypeGVCFs -R /nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/CMW154.fa -L CMW154_Contig$SGE_TASK_ID -V Leptographium_2019.gvcf.gz -new-qual -O genotyped/Lepto.$SGE_TASK_ID.vcf.gz"

echo $CMD
eval $CMD

# EOF.
