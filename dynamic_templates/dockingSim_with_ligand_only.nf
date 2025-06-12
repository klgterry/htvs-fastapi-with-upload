process dockingSim_with_ligand_only {
    label 'gpu'

    input:
    path ligand_done

    output:
    path "curate/**"

    script:
    """
    echo '▶ Docking with ligand only'
    bash /curate.sh
    cp -r /curate/docking curate/
    """
}
