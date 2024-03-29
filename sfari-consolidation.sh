#!/usr/bin/env bash
# PLEASE EXECUTE THIS DIRECTORY ONE LEVEL BEFORE left-behind.
# PLEASE make sure you have permissions to overwrite!
# Usage: sfari-consolidation.sh

current_date=$(date +%F)

################################################
#              Moving files                    #
################################################
# Find all the files inside left-behind
declare -a left_behind_files=($(find left-behind/{raw_data,fastq_assembly} -type f | grep -v "\.md5"))

for line in "${left_behind_files[@]}"
do
  # Get the prefix of the file
  left_behind_directory_prefix=$(dirname $line)

  working_directory_prefix=${left_behind_directory_prefix/left-behind\//}

  working_directory_filepath=${line/left-behind\//}

  # Check if the file in left-behind is in current working directory
  if [ ! -f $working_directory_filepath ]
  then
    # print out the moving command
    echo "mkdir -p ${working_directory_prefix} && mv ${line} ${working_directory_filepath}" >> ${current_date}-data-files-to-move_part-1.txt

    # Find the md5 sum files & prepare move.
    declare -a md5_file=($(ls -d ${left_behind_directory_prefix}/*.md5))
    if [ ! ${#md5_file[@]} -gt 1 ]
    then

      # Check if the md5 already exists in the working directory folder.
      md5_basename=$(basename $md5_file)
      working_dir_md5_filepath=${working_directory_prefix}/${md5_basename}
      if [ ! -f $working_dir_md5_filepath ]
      then
        echo "mv $md5_file $working_dir_md5_filepath" >> ${current_date}-data-files-to-move_part-2.txt
      else
        echo "Exists, ignoring & regenerating: ${working_dir_md5_filepath}" 1>&2

        # if it exists, then re-generate in the working directory
        echo "cd ${working_directory_prefix} && rm -f ${md5_basename} && md5sum * | sed -r 's/(.*)\s+(.*)/\1\t.\/\2/g' > $md5_basename" >> ${current_date}-data-files-to-move_part-3.txt
      fi

    else
      echo "Multiple md5 identified, fix please: ${md5_file}" 1>&2
    fi
  else
    echo "Exists- skipping: ${working_directory_filepath}" 1>&2
  fi

done


# Remove duplicated lines
cat ${current_date}-data-files-to-move_part-2.txt | sort -u > ${current_date}-data-files-to-move_part-2_deduplicated.txt
cat ${current_date}-data-files-to-move_part-3.txt | sort -u > ${current_date}-data-files-to-move_part-3_deduplicated.txt

# Remove unwanted files
for idx in $(seq 2 3)
do
  rm ${current_date}-data-files-to-move_part-${idx}.txt
done


################################################
#     Modifying bam.md5 in nanopore/STD/bam    #
################################################
declare -a nanopore_bam_md5=($(find {raw_data,fastq_assembly} -type f | grep "bam.md5" | grep nanopore))

for md5_file in "${nanopore_bam_md5[@]}"
do
  echo "sed -i 's/_fastq/_bam/g' $md5_file"
done > ${current_date}-data-files-to-move_part-4.txt


################################################
#       Check if md5 files exist for all       #
################################################
declare -a deepest_directories=($(find ./{raw_data,fastq_assembly} -type d -links 2))

for deepest in "${deepest_directories[@]}"
do
  md5_file=$(find $deepest -type f -name "*.md5")
  if [ -z $md5_file ]
  then
    if echo $deepest | grep -q "nanopore/STD/fastq"
    then
      want_md5="fastq.md5"

    elif echo $deepest | grep -q "nanopore/STD/fast5"
    then
      # this should absolutely exist for all
      want_md5="fast5.md5"

    elif echo $deepest | grep -qE "PacBio_HiFi/subread|nanopore/STD/bam"
    then
      want_md5="bam.md5"
    else
      echo "Unaccounted for scenario in creating md5: ${deepest}" 1>&2
    fi
    echo "cd $deepest && md5sum * | sed -i -r 's/(.*)\s+(.*)/\1\t.\/\2/g' > ${want_md5}" >> "${current_date}-data-files-to-move_part-5.txt"
  else
    echo "$md5_file already exists, skipping." 1>&2
  fi

done

####################################################
# 14444_fa(SSC11822) & 14444_mo(SSC11667) swap fix #
####################################################
# Only the nanopore are swapped.

for s in SSC11822:SSC11667 SSC11667:SSC11822
do
  pseudo=$(echo $s | cut -f1 -d':')
  real=$(echo $s | cut -f2 -d':')

  # check if this source directory exists
  for src_dir in {raw_data,fastq_assembly}/${pseudo}/nanopore
  do
    if [ ! -d $src_dir ]
    then
      echo "$src_dir does not exist, which cannot be true." 1>&2
      exit 1
    fi
  done

  # First move the nanopore away from original directory
  {
    echo "mkdir -p raw_data/${real}-intermediate && if [ ! -d raw_data/${real}-intermediate ]; then echo \"raw_data/${real}-intermediate\ does not exist\" 1>&2 ; (exit 1); fi && mv raw_data/${pseudo}/nanopore raw_data/${real}-intermediate"

    echo "mkdir -p fastq_assembly/${real}-intermediate && if [ ! -d fastq_assembly/${real}-intermediate ]; then echo \"fastq_assembly/${real}-intermediate\ does not exist\" 1>&2 ; (exit 1); fi && mv fastq_assembly/${pseudo}/nanopore fastq_assembly/${real}-intermediate"
  } >> "${current_date}-data-files-to-move_part-6.txt"
done

