### Instructions
1. The script will output 9 files, starting from 1, that must be executed sequentially. It's better to inspect before execution just to be safe. The parts have such pattern: `*-data-files-to-move_part-*`
2. Please make sure you have permissions to 1) make directory in the working directory 2) rename files
3. Please make sure this command works: `echo "hi" > greeting.txt && sed -i 's/hi/bye/g' greeting.txt`. I checked the manual of `sed` and it should work without appending after the `-i` option but just to be safe.
4. Make sure none of these files `*-data-files-to-move_part-*` exist when you execute the script- as we're just going to append to it.

#### To execute
```shell
sfari-consolidation.sh 2> stderr.log
```

#### Things to check for
1. It would be weird to find "fast5.md" in `-data-files-to-move_part-5.txt"` but alas, go ahead and regenerate the fast5. :weary:
2. Please debug if you find `Unaccounted for scenario in creating md5` or `Multiple md5 identified` in `stderr.log`. You should not find multiple md5 files for any deepest directory.

Your directory should now have the 9 txt files. I recommend executing them (after checking), like so:
```shell
cat [the first iteration] | parallel -j 10
```
OR, execute them sequentially but loop through the contents inside
```shell
for x in $(ls *-data-files-to-move_part-*.txt)
do
  echo "${x}"
#  while read line
#  do
#    ${line}
#  done < "${x}"
done
```