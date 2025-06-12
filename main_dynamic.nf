nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"



process dockingSim_default {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    echo '▶ Docking with no input'
    bash /curate.sh
    cp -r /curate/docking curate/
    """
}


workflow {
    dockingSim_default()
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
