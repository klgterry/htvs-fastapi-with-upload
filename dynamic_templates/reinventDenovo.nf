process reinventDenovo {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/denovo

    bash /run_denovo.sh

    echo '▶ Copying reinvent Denovo output...'
    mkdir -p curate
    cp -r /curate/denovo curate/ || echo '⚠️ No output found'
    """
}
