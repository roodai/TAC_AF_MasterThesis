# TAC_AF_MasterThesis
 Repository for files and scripts used to analyse AlphaFold models of TAC proteins

#### Requirements
- Python v3.10.6
- BioPython v1.78
- numpy v1.23.3
- pandas v1.5.1
- PyMol v2.5.2

#### Structural Predcitions
Predictions are made with FoldDock and AlphaFold2, detailed instructions for their installation and running can be found at:

FoldDock https://gitlab.com/ElofssonLab/FoldDock \
Alphafold2 https://github.com/deepmind/alphafold

Alternatively the ColabFold suite can be used to make predictions with essentially no installations.

ColabFold https://github.com/sokrypton/ColabFold

Input and output differ based on what method is used. The primary sequences used to make predictions are included in the sequences folder.  In these analyses the .pdb files and a file containing pTM+ipTM scores are necessary, these are included in the results folder.

Regardless of method, AlphaFold2 runs are heavily seeded, reproductions from these sequences will produce somewhat different results than the ones included in this repository.

#### PyMol
PyMol is used to visualize, align and determine sequences and interfaces. Files of interest are loaded into the PyMol session. Commands are executed line by line in PyMols own terminal. Chains, with interfaces of interest are selected by selection commands. For MT16 2A4C, all results are loaded and the interfaces of antitoxins to chaperones are of interest. The interfaces are determined with the "within" command.

```code
sele as, chain A:B
sele cs, chain C:F
sele ifs, as within 3.5 of cs
````

Sequences of interest are found and selected

````code
import findseq
findseq NLNDEMTSDGNYLLLP, all, chad
````
It is then determined if the found sequences are interfacing

```code
create top_c, cs and ranked_0
create if_chad, chad and ifs
create non_if_chad, chad and not ifs
```
All the objects in the session are aligned. The interface selections are copied unto objects. Depictions and colors are chosen.

````
align ranked_0, all
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
