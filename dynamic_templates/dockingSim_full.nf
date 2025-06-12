process dockingSim_full {
    label 'gpu'

    input:
    path protein_done
    path ligand_done

    output:
    path "curate/**"

    script:
    """
    echo '▶ Docking with both inputs'
    bash /curate.sh
    cp -r /curate/docking curate/
    """
}
