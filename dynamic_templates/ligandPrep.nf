// 이 프로세스는 proteinPrep 컨테이너를 실행합니다
process ligandPrep {
    label 'gpu'

    // 결과 디렉토리 전체와 완료 플래그 파일을 출력
    output:
    path "curate/**"
    path "curate/ligand_prep/.ligand_done", emit: ligand_done

    script:
    """
    # 실제 protein 준비 스크립트 실행
    bash /curate_ligand.sh

    echo '▶ Copying output back into Nextflow work directory...'
    
    # 중복 디렉토리 정리 및 결과 복사
    rm -rf curate/ligand_prep
    mkdir -p curate
    cp -r /curate/ligand_prep curate/

    # 워크플로우 의존성을 위한 완료 마커 파일 생성
    touch curate/ligand_prep/.ligand_done
    """
}
