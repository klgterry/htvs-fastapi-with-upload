#!/bin/bash -ue
bash /curate.sh

echo '▶ Copying output back into Nextflow work directory...'
rm -rf curate/protein_prep
mkdir -p curate
cp -r /curate/protein_prep curate/
