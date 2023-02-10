# TAC_AF_MasterThesis
 Repository for files and scripts used to analyse AlphaFold models of TAC proteins

#### Requirements
 - Python v3.10.6
 - BioPython v1.78
 - PyMol v2.5.2


#### Structural Predcitions
Predictions are made with FoldDock and AlphaFold2, detailed instructions for their installation and running can be found at:

FoldDock https://gitlab.com/ElofssonLab/FoldDock \
Alphafold2 https://github.com/deepmind/alphafold

Alternatively the ColabFold suite can be used to make predictions with essentially no installations.

ColabFold https://github.com/sokrypton/ColabFold

Input and output differ based on what method is used. The primary sequences used to make predictions are included in the sequences folder.  In these analyses the .pdb files and a file containing pTM+ipTM scores are necessary, these are included in the results folder.

Regardless of method, AlphaFold2 runs are heavily seeded, reproductions from these sequences will produce somewhat different results than the ones included in this repository.
