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
  pdqs+=( $(python3 scripts/pdockq.py --pdbfile ${sorted_names[i]}| grep "pDockQ" | cut -d "=" -f2| cut -d " " -f2))
  if [[ $pdb_dir != *"mt15"*  ]]; then
  dimers_trimer=$(echo $pdb_dir| cut -d "/" -f1,2)"/ATC/ranked_0.pdb"
  shared_ifs=$(python3 scripts/common_interfacer.py ${sorted_names[i]} $dimers_trimer)
  echo ${sorted_names[i]} $dimers_trimer
  minShared+=( $(echo $shared_ifs | grep "minShared" | cut -d " " -f10))
  maxShared+=( $(echo $shared_ifs | grep "maxShared" | cut -d " " -f7))
else
  pdqs+=("\t")
  minShared+=("\t")
  maxShared+=("\t")
fi
fi
done

echo -e "System\tType\tpTM+ipTM\tpDockQ\tminShared\tmaxShared" > table_debug.tsv  # Header row

for ((i=0; i<${#sorted_names[@]}; i++));
do
    system=$( echo ${sorted_names[i]} | cut -d "/" -f2)
    type=$( echo  ${sorted_names[i]} | cut -d "/" -f3)
    echo -e "$system\t$type\t${tm_scores[i]}\t${pdqs[i]}\t${minShared[i]}\t${maxShared[i]}" >> table.tsv
    echo -e "$system\t$type\t${tm_scores[i]}\t${pdqs[i]}\t$system\t$type" >> table_debug.tsv
done
