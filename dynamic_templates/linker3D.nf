process linker3D {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/3dlinker

    bash /run_3dlinker.sh

    echo '▶ Copying 3dlinker output...'
    mkdir -p curate
    cp -r /curate/3dlinker curate/ || echo '⚠️ No output found'
    """
}
