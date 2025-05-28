# Automated Docking of Ligands to the BK Channel

## Overview

This directory contains a bash script that automates molecular docking of one and two ligand molecules, taken from a list, to the human BK channel using **AutoDock Vina** and **Vinardo** scoring functions.
This script follows the guidelines from the AutoDock Vina manual, available at:
The script adheres to the official [AutoDock Vina documentation](https://autodock-vina.readthedocs.io/en/latest/introduction.html) guidelines.

## Directory structure
├── dock.sh   *# Main docking script - see Script WorkFlow section for details*   <br>
├── CAS_IDs.txt *# List of CID numbers for ligands of interest* <br>
├── protein.pdbqt *# BK Channel for docking* <br>
├── config.txt *# Box grid parameters for docking* <br>
├── environment_docking.yml *# — YAML file listing all dependencies and package versions for the conda environment used in this project* <br>
├── fetched_sdf/ *# Directory with ligand structures in SDf format, with and without added hydrogens* <br>
├── vina_results/ *# Directory with obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **AutoDock Vina* scoring function.* <br>
└──  vinardo_results/ *# Directory with obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **Vinardo* scoring function.* <br>

## Installing dependencies
`environment_vina.yml` contains all dependencies and packes needed for dock.sh to work. Set up the enviroment by running:  
  ```bash
  conda env create -f environment_docking.yml
```

## Script Workflow

1. **Create necessary directories**  
   The script creates the following directories if they don't exist:   
   - `fetched_sdf` — stores ligand structures with and without hydrogen in SDF format
   - `vina_results` — stores obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **AutoDock Vina* scoring function
   - `vinardo_results` — stores btained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **Vinardo* scoring function

2. **Fetch molecules by CAS IDs**  
   For each CAS number in `CAS_IDs.txt`:  
   - Obtains CID from CAS number by quering PubChem 
   - Fetches the SDF file for the CID   

3. **Ligand Preparation**  
   - For each SDF file runs `scrub.py`  and `mk_prepare_ligand.py` to prep ligand for the docking

4. **Molecular Docking**  
   For each prepped ligand, performs docking against a BK channel (`protein.pdbqt`) with two different scoring functions:
   - Vina docking with 1 ligand and then with 2 ligand copies  
   - Vinardo docking with 1 ligand and then with 2 ligand copies
   - 
5. **Clean-up**  
   Moves all docking outputs to appropriate folders.


## Usage
Perform the docking by running:
  ```bash
  ./dock.sh
```

- The list of docked ligands can be updated by modifying the `CAS_IDs.txt` file.
- This script uses `protein.pdbqt` file, which contains a BK channel structure but it can be replaced by any protein of interest - in that case grid box parameters have to be updated in `config.txt` file to match the binding site of the new protein.


