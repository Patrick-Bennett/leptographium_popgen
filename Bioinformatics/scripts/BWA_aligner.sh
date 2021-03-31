#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N BWA_aligner
#$ -q fangorn
#$ -V
#$ -t 1-115:1
i=$(expr $SGE_TASK_ID - 1)
REF="/nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/CMW154.fa"
FILE=( `cat /nfs1/BPP/LeBoldus_Lab/user_folders/bennetpa/BSRD_popgen/reads.list`)
IFS=';' read -a arr <<< "${FILE[$i]}"
mkdir -p sams
mkdir -p bams
echo "${arr[1]}"
###
# Step 1: BWA mapping
# The GATK needs read group info:
# https://software.broadinstitute.org/gatk/guide/article?id=6472
# SM: sample
# LB: library, may be sequenced multiple times
# ID: Read Group Identifier, a unique identifier
# PL: Platform/technology used
RG="@RG\tID:${arr[0]}\tLB:${arr[0]}\tPL:illumina\tSM:${arr[0]}\tPU:${arr[0]}"
echo "Mapping reads using BWA"
echo "#####"
CMD="/raid1/home/bpp/tabimaj/bin/bwa/bwa mem -M -R \"$RG\" $REF ${arr[1]} ${arr[2]} > sams/${arr[0]}.sam"
echo $CMD
eval $CMD
echo -n "BWA finished at "
date
#
###
###
# Step 2. SAMtools post-processing
echo "SAMtools: Fixing mates"
echo "#####"
CMD="samtools view -bSu sams/${arr[0]}.sam | samtools sort -n -O bam -o bams/${arr[0]}_nsort -T bams/${arr[0]}_nsort_tmp"
echo $CMD
eval $CMD
CMD="samtools fixmate -O bam bams/${arr[0]}_nsort /dev/stdout | samtools sort -O bam -o - -T bams/${arr[0]}_csort_tmp | samtools calmd -b - $REF > bams/${arr[0]}_fixed.bam"
echo $CMD
eval $CMD
echo -n "SAMtools step 1 finished at "
date
#
# Step 3. PICARD tools marking duplicates
echo "PICARD: Marking duplicates"
echo "#####"
CMD="/raid1/home/bpp/tabimaj/bin/jre1.8.0_144/bin/java -Xmx4g -Djava.io.tmpdir=/data -jar /raid1/home/bpp/tabimaj/bin/picard.jar MarkDuplicates I=bams/${arr[0]}_fixed.bam O=bams/${arr[0]}_dupmrk.bam MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 ASSUME_SORT_ORDER=coordinate M=bams/${arr[0]}_marked_dup_metrics.txt"
echo $CMD
eval $CMD
CMD="samtools index bams/${arr[0]}_dupmrk.bam"
echo $CMD
eval $CMD
echo -n "PICARD: Marking duplicates finished at "
date
echo "Indel Realigner"
CMD="/raid1/home/bpp/tabimaj/bin/jre1.8.0_144/bin/java -Xmx4g -Djava.io.tmpdir=/data -jar /raid1/home/bpp/tabimaj/bin/GenomeAnalysisTK.jar -T RealignerTargetCreator -R $REF -I bams/${arr[0]}_dupmrk.bam -o bams/${arr[0]}.intervals"
echo $CMD
eval $CMD
CMD="/raid1/home/bpp/tabimaj/bin/jre1.8.0_144/bin/java -Xmx4g -Djava.io.tmpdir=/data -jar /raid1/home/bpp/tabimaj/bin/GenomeAnalysisTK.jar -T IndelRealigner -R $REF -I bams/${arr[0]}_dupmrk.bam -targetIntervals bams/${arr[0]}.intervals -o bams/${arr[0]}.reindel.bam --consensusDeterminationModel USE_READS -LOD 0.4"
echo $CMD
eval $CMD
###

