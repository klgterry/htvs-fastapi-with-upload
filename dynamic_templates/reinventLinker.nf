process reinventLinker {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/linker

    bash /run_linker.sh

    echo '▶ Copying reinvent linker output...'
    mkdir -p curate
    cp -r /curate/linker curate/ || echo '⚠️ No output found'
    """
}
