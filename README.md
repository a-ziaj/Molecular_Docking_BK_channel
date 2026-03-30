# Automated Docking of Ligands to the BK Channel

## Overview

This directory contains a bash script that automates molecular docking of one, two, and four ligand molecules, taken from a list, to the human BK channel using **AutoDock Vina** and **Vinardo** scoring functions. Vinardo was selected as an additional scoring function as it is well suited for ion channel targets.
This script follows the guidelines from the AutoDock Vina manual, available at: [AutoDock Vina documentation](https://autodock-vina.readthedocs.io/en/latest/introduction.html) guidelines.

## Directory structure
├── dock.sh   *# Main docking script - see Script WorkFlow section for details*   <br>
├── CAS_IDs.txt *# List of CID numbers for ligands of interest* <br>
├── protein.pdbqt *# BK Channel for docking* <br>
├── config.txt *# Box grid parameters for docking* <br>
├── environment_docking.yml *# — YAML file listing all dependencies and package versions for the conda environment used in this project* <br>
├── fetched_sdf/ *# Directory with ligand structures in SDf format, with and without added hydrogens* <br>
├── vina_results/ *# Directory with obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **AutoDock Vina** scoring function.* <br>
└──  vinardo_results/ *# Directory with obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **Vinardo** scoring function.* <br>

## Installing dependencies
`environment_docking.yml` contains all dependencies and packages needed for dock.sh to work. Set up the environment by running:
  ```bash
  conda env create -f environment_docking.yml
```

## Protein Preparation

The receptor file `protein.pdbqt` was prepared from the BK channel crystal structure using **AutoDock Tools (ADT) v1.5.7**.

### Steps performed in ADT:

1. **Load structure**
   - `File → Read Molecule` — load the cleaned PDB file

2. **Remove water molecules and potassium ions**
   - `Edit → Delete Water`
   - manually select and delete potassium ions

3. **Add polar hydrogens**
   - `Edit → Hydrogens → Add → Polar Only`

4. **Add Kollman charges**
   - `Edit → Charges → Add Kollman Charges`

5. **Merge non-polar hydrogens**
   - `Edit → Hydrogens → Merge Non-polar`

6. **Assign AutoDock 4 atom types**
   - `Edit → Atoms → Assign AD4 typ`

7. **Save receptor as PDBQT**
   - `Grid → Macromolecule → Choose` → select protein → save as `protein.pdbqt`
   - only `ATOM` records are saved (CONECT, CRYST1, END excluded)

8. **Define the docking grid box**
   - `Grid → Grid Box` — center and dimensions set to cover the BK channel binding site
   - grid parameters saved to `config.txt`

## Script Workflow

1. **Logging**
   All terminal output is echoed to `run.log` via `tee`

2. **Create necessary directories**
   The script creates the following directories if they don't exist:
   - `fetched_sdf` — stores ligand structures with and without hydrogen in SDF format and prepared PDBQT files
   - `vina_results` — stores obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **AutoDock Vina** scoring function
   - `vinardo_results` — stores obtained docking poses for each ligand in PDBQT format and TXT file containing information about obtained docking poses using **Vinardo** scoring function

3. **Fetch molecules by CAS IDs**
   For each CAS number in `CAS_IDs.txt`:
   - Obtains CID from CAS number by querying PubChem
   - Fetches the SDF file for the CID

4. **Ligand Preparation**
   - For each SDF file runs `scrub.py` and `mk_prepare_ligand.py` to prep ligand for the docking

5. **Molecular Docking**
   For each prepped ligand, performs docking against a BK channel (`protein.pdbqt`) with `--exhaustiveness=32` using two scoring functions and three ligand copy configurations:
   - Vina docking with 1, 2 and 4 ligand copies
   - Vinardo docking with 1, 2 and 4 ligand copies

6. **Clean-up**
   Moves all docking outputs to appropriate folders.


## Usage
Perform the docking by running:
  ```bash
  ./dock.sh
```

- The list of docked ligands can be updated by modifying the `CAS_IDs.txt` file.
- This script uses `protein.pdbqt` file, which contains a BK channel structure but it can be replaced by any protein of interest - in that case grid box parameters have to be updated in `config.txt` file to match the binding site of the new protein.

Cheers! :)
