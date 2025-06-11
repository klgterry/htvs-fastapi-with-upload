process drugEx_RL {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/drugex

    bash /run_w_RL.sh

    echo '▶ Copying drugex output...'
    mkdir -p curate
    cp -r /curate/drugex curate/ || echo '⚠️ No output found'
    """
}
