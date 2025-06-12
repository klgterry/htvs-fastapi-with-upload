process dockingSim_default {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    echo '▶ Docking with no input'
    bash /curate.sh
    cp -r /curate/docking curate/
    """
}
