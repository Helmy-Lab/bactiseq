process GAMBIT {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gambit:1.1.0--py310h1fe012e_2':
        'biocontainers/gambit:1.1.0--py310h1fe012e_2' }"

    input:
    tuple val(meta), path(fasta)
    path db_directory


    output:
    tuple val(meta), path("*.csv") , emit: csv
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    gambit -d ${db_directory} query ${args} -o ${prefix}.csv -c ${task.cpus} ${fasta}
       

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gambit: \$(gambit --version 2>&1 | sed -e "s/gambit, version //g")
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    
    touch ${prefix}.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gambit: \$(gambit --version)
    END_VERSIONS
    """
}
