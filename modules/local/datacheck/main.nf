
process DATACHECK {

    input:
    val sampleList

    // output:
    // // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    // tuple val(meta), path("*.bam"), emit: bam
    // // TODO nf-core: List additional required output channels/values here
    // path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:



    stub:

    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    """
    
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        datacheck: \$(datacheck --version)
    END_VERSIONS
    """
}
