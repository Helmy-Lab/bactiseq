process NEXTPOLISH {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nextpolish:1.4.1--py312h4e9d295_4':
        'biocontainers/nextpolish:1.4.1--py312h4e9d295_4' }"

    input:
    tuple val(meta), path(assembly)
    tuple val(meta2), path(short_read1), path(short_read2)

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    tuple val(meta), path("*.fasta"), emit: fasta
    tuple val(meta), path("*.fasta.stat"), emit: stats
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ls ${short_read1} ${short_read2} > sgs.fofn
    echo -e "task = best\ngenome = ${assembly}\nmultithread_jobs = ${task.cpus}\nworkdir = .\nsgs_fofn = sgs.fofn" > run.cfg
    
    nextPolish run.cfg

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nextpolish: \$(nextpolish --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${meta.id}.nextpolish.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        nextpolish: \$(nextpolish --version)
    END_VERSIONS
    """
}
