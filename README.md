# TAC_AF_MasterThesis
 Repository for files and scripts used to analyse AlphaFold models of TAC proteins.

#### Requirements
- Python v3.10.6
- BioPython v1.78
- numpy v1.24.2
- pandas v1.5.1
- PyMol v2.5.2

#### Structural Predcitions
Predictions are made with FoldDock and AlphaFold2, detailed instructions for their installation and running can be found at:

FoldDock https://gitlab.com/ElofssonLab/FoldDock \
Alphafold2 https://github.com/deepmind/alphafold

Alternatively the ColabFold suite can be used to make predictions with essentially no installations.

ColabFold https://github.com/sokrypton/ColabFold

Input and output differ based on what method is used. The primary sequences used to make predictions are included in the sequences folder. In these analyses the ranked .pdb files and a file containing pTM+ipTM scores are necessary, these are included in the results folder.

Regardless of method, AlphaFold2 runs are heavily seeded, reproductions from these sequences will produce somewhat different results than the ones included in this repository.

Parameters and flags used to run AF2 are consistent with versions 2.0 for FoldDock and 2.2 for AlphaFold-multimer

#### Installations
Conda is used as the package manager, instructions for it's installation can be found at : https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html

The following commands are used to create an environment and to install the necessary packages for this work:

````shell
conda create -n tac_af
conda activate tac_af
conda install -c conda-forge biopython=1.78
conda install -c anaconda pandas=1.5.1
````

The desktop client for PyMol is used in this work. Its installer can be downloaded from: https://pymol.org/2/#download


#### Quality metrics

The pTM+ipTM scores are contained in ranking_debug.json files produced by each run. The scores can be found in their files and matched to the rankings of the .pdbs with the following shell command

````shell
grep -o '[0-9]\+\.[0-9]\+' ranking_debug.json | sort -r
````

pDockQ scores are calculated with the pdockq.py script for all dimeric predictions. The script is ran as such:

````shell
python3 pdockq.py --pdbfile ranked_0.pdb
````
The output should then be similar to:
````
pDockQ = 0.16 for ranked_0.pdb
This corresponds to a PPV of at least 0.73044282
````
This loop can be used to calculate pDockQ for all dimers in the results

````shell
for dimer in results/*/??/ranked* ; do python3 pdockq.py --pdbfile $dimer ; done
````
The script common_interfacer.py calculates minShared and maxShared metrics for all files input. The script can be ran as such:

````shell
python3 common_interfacer.py protein1.pdb protein2.pdb protein3.pdb protein4.pdb
````
The output should then be similar to:

```
Between protein1.pdb and protein2.pdb
 maxShared = 0.6893203883495146
 minShared = 0.48299319727891155
Between protein1.pdb and protein3.pdb
 maxShared = 0.5952380952380952
 minShared = 0.5102040816326531
Between protein1.pdb and protein4.pdb
 maxShared = 0.5978260869565217
 minShared = 0.3741496598639456
Between protein2.pdb and protein3.pdb
 maxShared = 0.6601941747572816
 minShared = 0.5396825396825397
Between protein2.pdb and protein4.pdb
 maxShared = 0.6413043478260869
 minShared = 0.5728155339805825
Between protein3.pdb and protein4.pdb
 maxShared = 0.6413043478260869
 minShared = 0.46825396825396826
```
For these analyses the shared interface metrics between dimers and respective trimers are calculated, which can be done with this loop:

````shell
for dimer in results/*/??/ranked* ; do python3 common_interfacer.py $dimer $(echo "$dimer"| cut -d "/" -f1,2)"/ATC/ranked_0.pdb"; done
````

Although it is preferable to include all .pdb files in an array as input, to avoid running the script for the same trimer each iteration.

The script make_tsv.sh can be ran on the terminal from the top folder recreate the q_metrics.tsv table that includes all the quality metrics used in this work.

````shell
user@device:/TAC_AF_MasterThesis$ bash scripts/make_tsv.sh
````
For this script to work the folder structure needs to be equivalent to as follows:

```
.
├── results
│   ├── mt11
│   │   ├── AC
│   │   ├── AT
│   │   ├── ATC
│   │   └── TC
│   ├── mt12
│   │   ├── AC
│   │   ├── AT
│   │   ├── ATC
│   │   └── TC
│   ├── mt13
│   │   ├── AC
│   │   ├── AT
│   │   ├── ATC
│   │   └── TC
│   ├── mt14
│   │   ├── AC
│   │   ├── AT
│   │   ├── ATC
│   │   └── TC
│   ├── mt15
│   │   └── AT
│   └── mt16
│       ├── 16trunc2A4C
│       ├── 1A2C
│       ├── 2A4C
│       ├── 2A4C2T
│       ├── 3A4C
│       ├── 42trunc2A4C
│       ├── 4A4C
│       ├── AC
│       ├── AT
│       ├── ATC
│       └── TC
├── scripts
   ├── common_interfacer.py
   ├── make_tsv.sh
   └── pdockq.py

  ````

  The base folders under "results" should have the .pdb files with rank in numbers, and the scores in a .json file.
  ````
  .
  ├── results
      ├── mt11
          ├── AC
              ├── ranked_0.pdb
              ├── ranked_1.pdb
              ├── ranked_10.pdb
              | ...
              ├── ranked_9.pdb
              └── ranking_debug.json
  ````

#### PyMol
PyMol is used to visualize, align and determine sequences and interfaces. Files of interest are loaded into the PyMol session. Commands are executed line by line in PyMols own terminal. Chains, with interfaces of interest are selected by selection commands. For MT16 2A4C, all results are loaded and the interfaces of antitoxins to chaperones are of interest. The interfaces are determined with the "within" command. At the start all files are aligned to the top ranked file.

```code
align ranked_0, all
sele as, chain A:B
sele cs, chain C:F
sele ifs, as within 3.5 of cs
````

Sequences of interest are found and selected

````
run https://raw.githubusercontent.com/Pymol-Scripts/Pymol-script-repo/master/findseq.py
findseq NLNDEMTSDGNYLLLP, all, chad
````
It is then determined if the found sequences are interfacing

```
create top_c, cs and ranked_0
create if_chad, chad and ifs
create non_if_chad, chad and not ifs
```
 Depictions and colors are chosen.

````
hide everything
show mesh
color grey70, top_c cs
color orange, non_if_chad chad
color red, if_chad ifs
````
Objects of interest are then displayed, a scene is set and images are exported
````
disable
enable top_c if_chad non_if_chad
center
zoom
ray 2400,2400
png all_chad
disable non_if_chad
ray 2400,2400
png if_chad
````
Coloring by plDDT is done with the gradient command, plDDT scores are in the b-factor column and is used to color the .pdb files

````
spectrum b, red_yellow_cyan_blue
````
