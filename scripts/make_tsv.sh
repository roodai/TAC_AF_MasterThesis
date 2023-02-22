#!/bin/bash

sorted_names=()
tm_scores=()
pdqs=()
minShared=()
maxShared=()

#create arrays for names and tm scores ranked by tm_scores
for dir in results/*/*
do
  #sort pdb files by rank
  sorted_names+=( $(find "$dir" -name "*.pdb" | sort -t_ -k2 -n) )
  # find tm scores from json Files
  tm_scores+=( $( grep -o '[0-9]\+\.[0-9]\+' "$dir"/*json| sort -r) )
done

# calculate metrics in order of previously made arrays
# new loop since tm scores are chunked by 25 entries and these are one-by-one
for ((i=0; i<${#sorted_names[@]}; i++)); do
  pdb_dir=$(dirname "${sorted_names[i]}")
  #condition 1 is true if prediction is dimeric
  if [[ ${#pdb_dir} -eq 15  ]]; then
    #condition 2 is true if directory does not include mt15 in name
    if [[ "{$pdb_dir}" != *mt15*  ]]; then
      #match dimer to trimer via directory names
      dimers_trimer=$(echo "$pdb_dir"| cut -d "/" -f1,2)"/ATC/ranked_0.pdb"
      #calculate shared interface metrics
      shared_ifs=$(python3 scripts/common_interfacer.py "${sorted_names[i]}" "$dimers_trimer")
      minShared+=( $(echo $shared_ifs | cut -d " " -f10))
      maxShared+=( $(echo $shared_ifs | cut -d " " -f7))
    else
      minShared+=($"\t")
      maxShared+=($"\t")
    fi
  #calculate pDockQ
  pdqs+=( $(python3 scripts/pdockq.py --pdbfile "${sorted_names[i]}"| grep "pDockQ" | cut -d "=" -f2| cut -d " " -f2))
  else
  # add tabs where no metrics are calulcated
    pdqs+=($"\t")
    minShared+=($"\t")
    maxShared+=($"\t")
  fi
done

# Header row
echo -e "System\tType\tpTM+ipTM\tpDockQ\tminShared\tmaxShared" > q_mterics.tsv
# new loop to keep order, without the ordering would be bad with added tabs
for ((i=0; i<${#sorted_names[@]}; i++));
do
    system=$( echo "${sorted_names[i]}" | cut -d "/" -f2)
    type=$( echo  "${sorted_names[i]}" | cut -d "/" -f3)
    echo -e "$system\t$type\t${tm_scores[i]}\t${pdqs[i]}\t${minShared[i]}\t${maxShared[i]}" >> q_mterics.tsv
done
