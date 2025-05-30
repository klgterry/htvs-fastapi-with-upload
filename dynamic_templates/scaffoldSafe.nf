process scaffoldSafe {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /script/run_safe.sh

    echo '▶ Copying scaffold output...'
    rm -rf curate/safe
    mkdir -p curate
    cp -r /curate/safe curate/
    """
}
