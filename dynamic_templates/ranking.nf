process ranking {
    input:
    path input
    output:
    path "ranked.csv"
    publishDir "results", mode: 'copy'

    script:
    """
    sort -t, -k2 -n ${input} > ranked.csv
    """
}
