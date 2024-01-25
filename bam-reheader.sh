#!/usr/bin/env bash
# Usage: bam-reheader.sh
# Please run this after you have run through sfari-consolidation + continue-sample-swap.sh.

if ! echo $PATH | grep -iq samtools || ! command -v samtools > /dev/null
then
  echo "cannot find samtools executable, try again please." 1>&2
  exit 1
fi

current_date=$(date +%F)

####################################################
# 14444_fa(SSC11822) & 14444_mo(SSC11667) swap fix #
####################################################
# Only the nanopore raw data are swapped.
for s in SSC11822:SSC11667-14444_fa:14444_mo SSC11667:SSC11822-14444_mo:14444_fa
do
  ssc=$(echo $s | cut -f1 -d'-')
  internal=$(echo $s | cut -f2 -d'-')

  ssc_pseudo=$(echo $ssc | cut -f1 -d':')
  ssc_real=$(echo $ssc | cut -f2 -d':')

  internal_pseudo=$(echo $internal | cut -f1 -d':')
  internal_real=$(echo $internal | cut -f2 -d':')

  declare -a sample_bams=($(find raw_data/${ssc_real}/nanopore/STD/bam/ -type f -name "*.bam"))
  for b in "${sample_bams[@]}"
  do
    echo "samtools reheader --no-PG -c \"sed 's/${ssc_pseudo}/${ssc_real}/g; s/${internal_pseudo}/${internal_real}/g'\" ${b} > ${b}-reheader" >> "${current_date}-data-files-to-move_part-10.txt"
    echo "mv ${b}-reheader ${b}" >> "${current_date}-data-files-to-move_part-11.txt"
  done
done
