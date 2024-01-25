### Instructions
1. In total, there will be 9 output files, starting from 1, that must be executed sequentially. It's better to inspect before execution just to be safe. The parts have such pattern: `*-data-files-to-move_part-*`
2. Please make sure you have permissions to 1) make directory in the working directory 2) rename files
3. Please make sure this command works: `echo "hi" > greeting.txt && sed -i 's/hi/bye/g' greeting.txt`. I checked the manual of `sed` and it should work without appending after the `-i` option but just to be safe.
4. Make sure none of these files `*-data-files-to-move_part-*` exist when you execute the script- as we're just going to append to it.

#### To execute
This script will generate 6 files: going from 1 to 6.
```shell
sfari-consolidation.sh 2> stderr.log
```

This script will generate 3 files: going from 7 to 9.
```shell
continue-sample-swap.sh
```

#### Things to check for
1. It would be weird to find "fast5.md" in `-data-files-to-move_part-5.txt"` but alas, go ahead and regenerate the fast5. :weary:
2. Please debug if you find `Unaccounted for scenario in creating md5` or `Multiple md5 identified` in `stderr.log`. You should not find multiple md5 files for any deepest directory.

Please execute the output files in order by their numbers.

#### Discussion
1. For the sample swap, do you think it's necessary to `samtools reheader` where it applies? Precisely, the nanopore unmapped bams for those files. We can either remove the tags with misleading sample or perform regex in-placement.

#### Post-discussion
We are doing `samtools reheader`.

1. According to the samtools docs for reheader, the `in-place` replacement only works for CRAM files. The solution in [bam-reheader script](bam-reheader.sh) will perform the following steps:
   1. Perform the re-header & output to a different BAM file: `*-data-files-to-move_part-10.txt"`
   2. Overwrite the original file with the updated one: `*-data-files-to-move_part-11.txt"`
      1. To make sure overwriting doesn't require the `--force` argument, try this test first: `echo hi > hi.txt && echo bye > bye.txt && mv bye.txt hi.txt`. The resulting hi.txt file should contain `bye`. :tada: