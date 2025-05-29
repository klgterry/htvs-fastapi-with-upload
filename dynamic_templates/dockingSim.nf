process dockingSim {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /curate.sh

    echo '▶ Copying output back into Nextflow work directory...'
    rm -rf curate/docking
    mkdir -p curate
    cp -r /curate/docking curate/
    """
}