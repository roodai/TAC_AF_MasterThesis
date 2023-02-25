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

# Header row
echo -e "System\tType\tpTM+ipTM\tpDockQ\tminShared\tmaxShared" > q_metrics.tsv
# calculate metrics in order of previously made arrays
# new loop since tm scores are chunked by 25 entries and these are one-by-one
for ((i=0; i<${#sorted_names[@]}; i++)); do
  echo -n "${sorted_names[i]}" | cut -d "/" -f2 | tr -d '\n' >> q_metrics.tsv
   echo -en "\t" >> q_metrics.tsv
   echo -n "${sorted_names[i]}" | cut -d "/" -f3 | tr -d '\n' >> q_metrics.tsv
   echo -en "\t" >> q_metrics.tsv
   echo -en ${tm_scores[i]}"\t" >> q_metrics.tsv
  pdb_dir=$(dirname "${sorted_names[i]}")
  #condition 1 is true if prediction is dimeric
  if [[ ${#pdb_dir} -eq 15  ]]; then
    pdq=( $(python3 scripts/pdockq.py --pdbfile "${sorted_names[i]}"| grep "pDockQ" | cut -d "=" -f2| cut -d " " -f2| tr -d '\n'))
    echo -en "$pdq\t" >> q_metrics.tsv
    #condition 2 is true if directory does not include mt15 in name
    if [[ "{$pdb_dir}" != *mt15*  ]]; then
      dimers_trimer=$(echo "$pdb_dir"| cut -d "/" -f1,2)"/ATC/ranked_0.pdb"
      #calculate shared interface metrics
      shared_ifs=$(python3 scripts/common_interfacer.py "${sorted_names[i]}" "$dimers_trimer")
      minShared=( $(echo $shared_ifs | cut -d " " -f10 | tr -d '\n'))
      maxShared=( $(echo $shared_ifs | cut -d " " -f7 | tr -d '\n'))
      echo -en "$minShared\t" >> q_metrics.tsv
      echo -e "$maxShared\t" >> q_metrics.tsv
    else
      echo -e "\t\t" >> q_metrics.tsv
    fi
  else
# add tabs where no metrics are calulcated
    echo -e "\t\t\t" >> q_metrics.tsv
  fi
done
