nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"



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


process reinventDenovo {
    label 'gpu'

    output:
    path "curate/**"

    script:
    """
    mkdir -p /curate/denovo

    bash /run_denovo.sh

    echo '▶ Copying reinvent Denovo output...'
    mkdir -p curate
    cp -r /curate/denovo curate/ || echo '⚠️ No output found'
    """
}


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


workflow {
    reinventLinker()
    reinventDenovo()
    reinventMolopt()
    reinventScaffold()
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
