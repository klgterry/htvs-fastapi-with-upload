process scaffoldDelete {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /script/run_delete.sh

    echo '▶ Copying scaffold output...'
    rm -rf curate/delete
    mkdir -p curate
    cp -r /curate/delete curate/
    """
}
