process RACON {
    tag "$meta.id"
    label 'process_medium'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/racon:1.5.0--h077b44d_6':
        'biocontainers/racon:1.5.0--h077b44d_6' }"

    input:
    // TODO nf-core: Update the information obtained from bio.tools and make sure that it is correct 
    tuple val(meta), path(fasta)
    tuple val(meta1), path(paf)
    tuple val(meta2), path(reads)

    output:
    // TODO nf-core: Update the information obtained from bio.tools and make sure that it is correct
    tuple val(meta), path("*.{fasta}"), emit: polished
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    racon \\
        $args \\
        -t $task.cpus \\
        ${reads} \\
        ${paf} \\
        ${fasta} \\
        > polished.fasta


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        racon: \$(racon --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    
    touch ${prefix}.bam
    touch ${prefix}.sam
    touch ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        racon: \$(racon --version)
    END_VERSIONS
    """
}
