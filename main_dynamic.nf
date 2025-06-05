nextflow.enable.dsl=2
params.outdir = "./results/${workflow.runName}"

curate_dir = Channel.fromPath('/home/klgterry/home/klgterry/curate')

// 이 프로세스는 proteinPrep 컨테이너를 실행합니다
process proteinPrep {
    label 'gpu'

    // 결과 디렉토리 전체와 완료 플래그 파일을 출력
    output:
    path "curate/**"
    path "curate/protein_prep/.done", emit: protein_done

    script:
    """
    # 실제 protein 준비 스크립트 실행
    bash /curate.sh

    echo '▶ Copying output back into Nextflow work directory...'
    
    # 중복 디렉토리 정리 및 결과 복사
    rm -rf curate/protein_prep
    mkdir -p curate
    cp -r /curate/protein_prep curate/

    # 워크플로우 의존성을 위한 완료 마커 파일 생성
    touch curate/protein_prep/.done
    """
}


workflow {
    protein_result = proteinPrep()
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
