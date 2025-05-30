process proteinPrep {
    label 'gpu'

    output:
    path "curate/**"
    path "curate/protein_prep/.done", emit: protein_done

    script:
    """
    bash /curate.sh
    
    echo '▶ Copying output back into Nextflow work directory...'
    rm -rf curate/protein_prep
    mkdir -p curate
    cp -r /curate/protein_prep curate/

    touch curate/protein_prep/.done
    """
}
