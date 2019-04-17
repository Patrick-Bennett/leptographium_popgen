# README

This folder contains scripts used for the Leptographium population genomics analysis. Usage can be found in each of the R Markdown files associated to the project.

## Contents

1. `BWA_aligner.sh`: Aligns paired end reads to reference using BWA, converts to BAM, sorts BAM, removes duplicates and fixes by mates, and re-aligns indels. Make sure to have a reference index file built with `bwa index`
2. `stats_sam.sh`: Batch script for `samtools faidx` for a list of SAM files
3. `gVCF.sh`: Batch script to individually genotype each sample from a list of sorted BAMs. Remember to build a reference index as explained by [this page](https://gatkforums.broadinstitute.org/gatk/discussion/1601/how-can-i-prepare-a-fasta-file-to-use-as-reference)
