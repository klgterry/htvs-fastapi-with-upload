process fakeDocking {
    input:
    path input
    output:
    path "docking_result.csv", emit: dock_out

    script:
    """
    echo "ligand,score" > docking_result.csv
    echo "ligand.sdf,-7.3" >> docking_result.csv
    """
}
