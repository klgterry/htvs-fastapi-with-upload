process reinventMolopt {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/molopt

    bash /run_opt.sh

    echo '▶ Copying reinvent Molopt output...'
    mkdir -p curate
    cp -r /curate/molopt curate/ || echo '⚠️ No output found'
    """
}
