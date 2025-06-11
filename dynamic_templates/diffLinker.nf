process diffLinker {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/difflinker

    bash /run_difflinker.sh

    echo '▶ Copying difflinker output...'
    mkdir -p curate
    cp -r /curate/difflinker curate/ || echo '⚠️ No output found'
    """
}
