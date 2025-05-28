#!/bin/bash

#######generate job ID
#add this if you want to run the script multiple times so it doesn't overwrite things
#job_id=$(printf "%04d" $(( RANDOM % 10000 )))
#echo "JOB ID: $job_id"

########create dirs

if [ ! -d "fetched_sdf" ]; then
  mkdir -p "fetched_sdf"
  echo "Directory created: fetched_sdf"
else
  echo "Directory already exists: fetched_sdf"
fi

if [ ! -d "vina_results" ]; then
  mkdir -p "vina_results"
  echo "Directory created: vina_results"
else
  echo "Directory already exists: vina_results"
fi

if [ ! -d "vinardo_results" ]; then
  mkdir -p "vinardo_results"
  echo "Directory created: vinardo_results"
else
  echo "Directory already exists: vinarodo_results"
fi

echo -e "start"
date

#######FETCH MOLECULE BY THE ID
while read -r CAS_ID
do
	unset CID
	echo -e "$CAS_ID is a CAS_ID"
	CID=$(curl "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/${CAS_ID}/cids/TXT")
	if [[ -z "$CID" ]]; then
		echo "Could not fetch CID for $CAS_ID :("
	else
		echo -e "$CID is CID"
		
		curl -s -o "${CAS_ID}.sdf" "https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/${CID}/SDF"
		if [[ ! -s "${CAS_ID}.sdf" ]]; then
			echo "Could not fetch SDF for CID $CID ($CAS_ID) :("
		else
			head -5 "${CAS_ID}.sdf"
		fi
	fi
########LIGAND PREP
	scrub.py ${CAS_ID}.sdf -o ${CAS_ID}_H.sdf
	mk_prepare_ligand.py -i ${CAS_ID}_H.sdf -o ${CAS_ID}.pdbqt

########LIGANDS DOCKING

	#1 ligand
	#vina
        vina --receptor protein.pdbqt --ligand ${CAS_ID}.pdbqt  --config config.txt  --exhaustiveness=32 --out ${CAS_ID}_vina_1.pdbqt > ${CAS_ID}_vina_results_1.txt
	echo -e "Docked one ${CAS_ID} molecule (vina), saved as ${CAS_ID}_vina_1.pdbqt and ${CAS_ID}_vina_results_1.txt"
	#vinardo
	vina --receptor protein.pdbqt --ligand ${CAS_ID}.pdbqt  --config config.txt  --exhaustiveness=32 --out ${CAS_ID}_vinardo_1.pdbqt --scoring vinardo > ${CAS_ID}_vinardo_results_1.txt
	echo -e "Docked one ${CAS_ID} molecule (vinardo), saved as ${CAS_ID}_vinardo_1.pdbqt and ${CAS_ID}_vinardo_results_1.txt"


	#2 lignads
	#vina
	vina --receptor protein.pdbqt --ligand ${CAS_ID}.pdbqt ${CAS_ID}.pdbqt  --config config.txt  --exhaustiveness=32 --out ${CAS_ID}_vina_2.pdbqt > ${CAS_ID}_vina_results_2.txt
	echo -e "Docked two ${CAS_ID} molecules (vina), saved as  ${CAS_ID}_vina_2.pdbqt and ${CAS_ID}_vina_results_2.txt"
	#vinardo
	vina --receptor protein.pdbqt --ligand ${CAS_ID}.pdbqt ${CAS_ID}.pdbqt  --config config.txt  --exhaustiveness=32 --out ${CAS_ID}_vinardo_2.pdbqt --scoring vinardo > ${CAS_ID}_vinardo_results_2.txt
	 echo -e "Docked two ${CAS_ID} molecules (vinardo), saved as ${CAS_ID}_vinardo_2.pdbqt and ${CAS_ID}_vinardo_results_2.txt"
	#date

########clean up
	mv ${CAS_ID}.sdf fetched_sdf/
	mv ${CAS_ID}_H.sdf fetched_sdf/
	mv ${CAS_ID}.pdbqt fetched_sdf/
	mv ${CAS_ID}_vina_1.pdbqt vina_results/
	mv ${CAS_ID}_vina_results_1.txt vina_results/
	mv ${CAS_ID}_vinardo_1.pdbqt vinardo_results/
	mv ${CAS_ID}_vinardo_results_1.txt vinardo_results/
        mv ${CAS_ID}_vina_2.pdbqt vina_results/
        mv ${CAS_ID}_vina_results_2.txt vina_results/
        mv ${CAS_ID}_vinardo_2.pdbqt vinardo_results/
        mv ${CAS_ID}_vinardo_results_2.txt vinardo_results/
	#if [ ! -d "preped_ligands" ]; then
	#	mkdir -p "preped_ligands"
	#fi
	#mv ${CAS_ID}.pdbqt preped_ligands 

done < "CAS_IDs.txt"
echo -e "everything done"

#print time
date

#####################PROTEIN PREP
#mk_prepare_receptor.py -i BK_open_6v22_MD_III_2022_v2_autopsf.pdb -o protein -p -v -g \
#--box_center 0 0 0 --box_size 25 25 50



