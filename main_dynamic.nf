nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"

curate_dir = Channel.fromPath('/home/klgterry/curate')

process proteinPrep {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    bash /curate.sh
    
    echo '▶ Copying output back into Nextflow work directory...'
    rm -rf curate/protein_prep
    mkdir -p curate
    cp -r /curate/protein_prep curate/
    """
}
workflow {
    proteinPrep()
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

    // Also move report and timeline if they exist
    ["report.html", "timeline.html"].each { fileName ->
        def file = new File(fileName)
        if (file.exists()) {
            file.renameTo(new File("${outdir}/${fileName}"))
        }
    }
}
