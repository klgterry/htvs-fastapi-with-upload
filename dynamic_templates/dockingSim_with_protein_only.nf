process dockingSim_with_protein_only {
    label 'gpu'

    input:
    path protein_done

    output:
    path "curate/**"

    script:
    """
    echo '▶ Docking with protein only'
    bash /curate.sh
    cp -r /curate/docking curate/
    """
}
