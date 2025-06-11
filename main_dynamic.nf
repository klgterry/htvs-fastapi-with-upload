nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"



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


workflow {
    linker3D()
}


workflow.onComplete {
    def outdir = params.outdir
    def json = [
        status: workflow.success ? "DONE" : "FAILED",
        succeeded: workflow.stats.succeededCount,
        failed: workflow.stats.failedCount,
        total: workflow.stats.totalCount
    ]
    new File("${outdir}/status.json").text = groovy.json.JsonOutput.toJson(json)
}
