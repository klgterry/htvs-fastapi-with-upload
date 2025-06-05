process posebusters {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /script/run_posebusters.sh

    echo '▶ Copying posebusters output...'
    rm -rf curate/posebusters
    mkdir -p curate
    cp -r /curate/posebusters curate/
    """
}
