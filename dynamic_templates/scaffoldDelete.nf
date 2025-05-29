process scaffoldDelete {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /script/run_delete.sh

    echo '▶ Copying scaffold output...'
    rm -rf curate/output
    mkdir -p curate
    cp -r /curate/output curate/
    """
}
