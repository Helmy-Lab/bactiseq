process TINYCOV {
    tag "$meta.id"
    label 'process_medium'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/tinycov:0.4.0'

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.png"), emit: png
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    tinycov covhist\\
        $args \\
        $bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tinycov: \$(tinycov --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        tinycov: \$(tinycov --version)
    END_VERSIONS
    """
}
