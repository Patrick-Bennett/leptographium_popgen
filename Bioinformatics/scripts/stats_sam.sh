#!/bin/bash
#$ -cwd
#$ -S /bin/bash
#$ -N stats_sam
#$ -q fangorn
#$ -V
#$ -t 1-124:1

i=$(expr $SGE_TASK_ID - 1)
FILE=( `cat /raid1/home/bpp/tabimaj/sams.list`)
IFS=';' read -a arr <<< "${FILE[$i]}"

mkdir -p alin_stats

samtools flagstat ${arr[1]} > alin_stats/${arr[0]}
