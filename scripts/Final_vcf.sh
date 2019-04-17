
#! /bin/bash
#$ -N Final_vcf
#$ -V
#$ -cwd
#$ -S /bin/bash
#$ -q fangorn


i=$(expr $SGE_TASK_ID - 1)

REF="/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/CMW154.fa"

CMD="/raid1/home/bpp/tabimaj/bin/jre1.8.0_144/bin/java -Xmx4g -Djava.io.tmpdir=/data -jar /raid1/home/bpp/tabimaj/bin/GenomeAnalysisTK.jar -T GenotypeGVCFs -R $REF -V gvcf.list  -o Leptographium_2019.vcf.gz"
echo $CMD
eval $CMD

date

# EOF.
