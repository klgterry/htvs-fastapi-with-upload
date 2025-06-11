process drugEx {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/drugex

    bash /run_wo_RL.sh

    echo '▶ Copying drugex output...'
    mkdir -p curate
    cp -r /curate/drugex curate/ || echo '⚠️ No output found'
    """
}
