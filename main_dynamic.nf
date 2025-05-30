nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"

curate_dir = Channel.fromPath('/home/bj/home/bj/protein_prep/curate_test')

process proteinPrep {
    label 'gpu'

    output:
    path "curate/**"
    path "curate/protein_prep/.done", emit: protein_done

    script:
    """
    bash /curate.sh
    
    echo '▶ Copying output back into Nextflow work directory...'
    rm -rf curate/protein_prep
    mkdir -p curate
    cp -r /curate/protein_prep curate/

    touch curate/protein_prep/.done
    """
}


process dockingSim {
    label 'gpu'

    input:
    path dummy_input

    output:
    path "curate/**"

    script:
    """
    bash /curate.sh

    echo '▶ Copying output back into Nextflow work directory...'
    rm -rf curate/docking
    mkdir -p curate
    cp -r /curate/docking curate/
    """
}

workflow {
    protein_result = proteinPrep()
    dockingSim(protein_result.protein_done)
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
