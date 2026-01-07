process ANY2FASTA {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://pvstodghill/any2fasta:latest' :
        'pvstodghill/any2fasta:latest' }"

    input:
    tuple val(meta), path(file)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta_file
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    any2fasta \\
        $file > "${prefix}".fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        any2fasta: \$(any2fasta -v)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    
    touch ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        any2fasta: \$(any2fasta -v)
    END_VERSIONS
    """
}
