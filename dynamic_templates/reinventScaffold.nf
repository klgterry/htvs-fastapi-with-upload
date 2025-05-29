process reinventScaffold {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/scaffold

    bash /run_scaffold.sh

    echo '▶ Copying reinvent Scaffold output...'
    mkdir -p curate
    cp -r /curate/scaffold curate/ || echo '⚠️ No output found'
    """
}
