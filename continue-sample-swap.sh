#!/usr/bin/env bash
# Please execute this after you have executed: "${current_date}-data-files-to-move_part-6.txt"
# Usage: continue-sample-swap.sh

####################################################
# 14444_fa(SSC11822) & 14444_mo(SSC11667) swap fix #
####################################################
# Only the nanopore are swapped.
for s in SSC11822:SSC11667 SSC11667:SSC11822
do
  pseudo=$(echo $s | cut -f1 -d':')
  real=$(echo $s | cut -f2 -d':')

  # Then rename the file names.
  declare -a files_to_rename=($(find {raw_data,fastq_assembly}/${real}-intermediate/nanopore/STD/{bam,fastq} -type f 2> /dev/null))

# #The below command is commented out for my own testing purposes- leave commented please.
#  declare -a files_to_rename=($(find {raw_data,fastq_assembly}/${pseudo}/nanopore/STD/{bam,fastq} -type f 2> /dev/null))

  for f in "${files_to_rename[@]}"
  do
    if echo $f | grep -q "\.md5"
    then
      # replace the names within the md5 sum files
      echo "sed -i 's/${pseudo}/${real}/g' $f" >> "${current_date}-data-files-to-move_part-8.txt"
    else
      # Replace all file path names
      echo "mv ${f} ${f//${pseudo}/${real}}" >> "${current_date}-data-files-to-move_part-7.txt"
    fi
  done

  # Reunite with the HiFi + genome assemblies.
  {
    echo "mv raw_data/${real}-intermediate/nanopore raw_data/${real}"
    echo "mv fastq_assembly/${real}-intermediate/nanopore fastq_assembly/${real}"
  } >> "${current_date}-data-files-to-move_part-9.txt"

done