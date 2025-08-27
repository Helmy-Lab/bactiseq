process MEDAKA {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/medaka:2.0.1--py39hf77f13f_0' :
        'biocontainers/medaka:2.1.0--py38ha0c3a46_0' }"

    input:
    tuple val(meta), path(reads), path(assembly)
    
    output:
    tuple val(meta), path("*.fa.gz"), emit: assembly
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def mode = "${meta.basecaller}"
    def m_option = mode != "NA" ? "-m ${mode}" : ''
    """
    medaka_consensus \\
        -t $task.cpus \\
        $args \\
        ${m_option} \\
        -i $reads \\
        -d $assembly \\
        -o ./

    mv consensus.fasta ${prefix}.fa

    gzip -n ${prefix}.fa

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        medaka: \$( medaka --version 2>&1 | sed 's/medaka //g' )
    END_VERSIONS
    """
}
