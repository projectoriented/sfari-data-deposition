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

  # Triple-check that src exists, although the command find already does this
  for src_dir in {raw_data,fastq_assembly}/${real}-intermediate/nanopore
  do
    if [ ! -d $src_dir ]
    then
      echo "$src_dir does not exist, try again plz." 1>&2
      exit 1
    fi
  done

  # Then rename the file names.
  declare -a files_to_rename=($(find {raw_data,fastq_assembly}/${real}-intermediate/nanopore/STD/{bam,fastq} -type f 2> /dev/null))

# #The below command is commented out for my own testing purposes- leave commented please.
#  declare -a files_to_rename=($(find {raw_data,fastq_assembly}/${pseudo}/nanopore/STD/{bam,fastq} -type f 2> /dev/null))

  for f in "${files_to_rename[@]}"
  do
    # If it is md5 file, replace the names within the file.
    if echo $f | grep -q "\.md5"
    then
      # replace the names within the md5 sum files
      echo "sed -i 's/${pseudo}/${real}/g' $f" >> "${current_date}-data-files-to-move_part-8.txt"
    else
      # Otherwise, replace file path names
      echo "mv ${f} ${f//${pseudo}/${real}}" >> "${current_date}-data-files-to-move_part-7.txt"
    fi
  done

  # Reunite with the HiFi + genome assemblies by moving the nanopore folder.
  {
    echo "if [ ! -d raw_data/${real} ]; then echo \"raw_data/${real} does not exist 1>&2 ; (exit 1)\"; fi && mv raw_data/${real}-intermediate/nanopore raw_data/${real}"

    echo "if [ ! -d fastq_assembly/${real} ]; then echo \"fastq_assembly/${real} does not exist 1>&2 ; (exit 1)\"; fi && mv fastq_assembly/${real}-intermediate/nanopore fastq_assembly/${real}"
  } >> "${current_date}-data-files-to-move_part-9.txt"

done