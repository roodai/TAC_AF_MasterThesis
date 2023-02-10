#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 27 15:23:35 2022
@author: roni

This program uses .pdb files as input, parses them and stores them in a list.
HSE is calculated for each protein and its chains. If HSE for a residue is
higher in the protein than in the chain the residue is considered interfacing.
Common interfacing residues between all input proteins are produced.
Minshared and maxShared metrics are calculated to represent how similar
interfaces are between two proteins.

Run example from the terminal:
python3 protein1.pdb protein2.pdb
"""
import sys
from Bio.PDB import *
from itertools import combinations
p = PDBParser()
io=PDBIO()

def splitNHSE(structure, radius=10):
#Load structure into model, calculate HSE for whole model
    m=structure[0]
    mod_hses=HSExposureCA(m, radius)
#Seperate chains from model and calculate HSE for each standalone chain
    pdb_chains = m.get_chains()
    ch_hses=[]
    for chain in pdb_chains:
        ch_hses.append(HSExposureCA(chain, radius))
#Compare HSE per residue of model and chain HSE calculations
    ittit=0
    IFresidues=[]
    for ch_hse in ch_hses:
        for k, v in ch_hse.property_dict.items():
#If there are more HSE contacts in the model residue vs the chain residue
#The residue in question is likely interfacing
            if mod_hses.property_dict[k][0]>v[0] or mod_hses.property_dict[k][1]>v[1] :
                ittit+=1
                IFresidues.append(m[k[0]][k[1][1]])
    return(IFresidues)

#produces common elements between two lists
def common_elements(list1, list2):
    return [element for element in list1 if element in list2]

#class IntfSelect(Select):
    def accept_residue(self, residue):
        if residue in common:
            return 1
        else:
            return 0
interfaces=[]
proteins=[]

n = len(sys.argv)
for i in range(1, n):
    proteins.append(p.get_structure(sys.argv[i].split(".")[0],sys.argv[i]))

for protein in proteins:
    interfaces.append(splitNHSE(protein))

iterab=0
commons=[]
L=range(len(interfaces))
#Generates unique sets of number pairs for each protein provided
#These are used to produce common elements between all protein interfaces

pairs=[list(map(str, comb)) for comb in combinations(L, 2)]

while iterab < len(pairs):
    #Produces common elements of interfaces using unique number pairs
    commons.append(common_elements(interfaces[int(pairs[iterab][0])],interfaces[int(pairs[iterab][1])]))

    if len(interfaces[int(pairs[iterab][0])]) == 0 or len(interfaces[int(pairs[iterab][1])]) == 0:
        maxShared = 0
        minShared = 0
    else:
        # Calculate maxShared and minShared
        maxShared = len(commons[iterab]) / min(len(interfaces[int(pairs[iterab][0])]) , len(interfaces[int(pairs[iterab][1])]))
        minShared = len(commons[iterab]) / max(len(interfaces[int(pairs[iterab][0])]) , len(interfaces[int(pairs[iterab][1])]))

    print("Between "+ proteins[int(pairs[iterab][0])].id
          + " and " + proteins[int(pairs[iterab][1])].id + "\n maxShared = " + str(maxShared)
          + "\n minShared = " + str(minShared)
          )
    #common=commons[iterab]
    #io.set_structure(protein)
    #io.save(proteins[int(pairs[iterab][0])].id + proteins[int(pairs[iterab][2])].id+"common.pdb", IntfSelect())
    iterab+=1
