#!/bin/bash
#$ -N mkgvcf_uf
#$ -V
#$ -q fangorn
#$ -cwd
#$ -S /bin/bash
#$ -l mem_free=10G
#$ -t 1-115:1

i=$(expr $SGE_TASK_ID - 1)
FILE=( `cat "/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/bams.list" `)
IFS=';' read -r -a arr <<< "${FILE[$i]}"

mkdir -p gvcf/

REF="/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/CMW154.fa"


CMD='/raid1/home/bpp/tabimaj/bin/gatk-4.0.1.2/gatk --java-options "-Xmx10g -Djava.io.tmpdir=/data" HaplotypeCaller --reference $REF --ERC GVCF -ploidy 1 --input ${arr[1]} -O gvcf/${arr[0]}.g.vcf.gz'
echo $CMD
eval $CMD

echo
date
echo "mkgvcf finished."

myEpoch=(`date +%s`)
echo "Epoch start:" $myEpoch

# EOF.
