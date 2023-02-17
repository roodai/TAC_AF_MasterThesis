#!/bin/bash

sorted_names=()
tm_scores=()
for dir in results/*/*
do
  #sort pdb files by rank
  sorted_names+=( $(find $dir -name "*.pdb" | sort -t_ -k2 -n) )
  # find tm scores from json Files
  tm_scores+=( $( grep -o '[0-9]\+\.[0-9]\+' $dir/*json| sort -r) )
  #calculate and extract pDockQ
done

#echo "${sorted_names[@]}" 
for ((i=0; i<${#sorted_names[@]}; i++))
do
  pdb_dir=$(dirname ${sorted_names[i]})
  if [[ "${#pdb_dir}" -eq 15 ]]; then
  #pdqs+=( $(python3 scripts/pdockq.py --pdbfile ${sorted_names[i]}| grep "pDockQ" | cut -d "=" -f2| cut -d " " -f2))
  dimers_trimer=$(echo $pdb_dir| cut -d "/" -f1,2)"/ATC/ranked_0.pdb"
  shared_ifs=$(python3 scripts/common_interfacer.py ${sorted_names[i]} $dimers_trimer)
  echo ${sorted_names[i]} $dimers_trimer
  minShared+=( $(echo $shared_ifs | grep "minShared" | cut -d "=" -f2))
  maxShared+=( $(echo $shared_ifs | grep "maxShared" | cut -d "=" -f2))
else 
  pdqs+=("lolkys")
  minShared+=("lolkys")
  maxShared+=("lolkys")
fi
done
echo ${minShared[@]}
echo ${maxShared[@]}
# find tm scores from json Files
#tm_scores=$(find . -name "*.json" -exec grep -o -E '[0-9]\+\.[0-9]\+' {} \;)


