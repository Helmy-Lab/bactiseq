process NEXTPOLISH {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/nextpolish:1.4.1--py312h4e9d295_4':
        'biocontainers/nextpolish:1.4.1--py312h4e9d295_4' }"

    input:
    tuple val(meta), path(assembly)
    tuple val(meta2), path(short_reads)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta
    tuple val(meta), path("*.fasta.stat"), emit: stats
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def illumina_reads = short_reads ? ( meta.single_end ? "$short_reads" : "${short_reads[0]} ${short_reads[1]}" ) : ""
    """
    # Create FOFN file based on read type
    if [ "${meta.single_end}" == "true" ]; then
        echo "${short_reads}" > sgs.fofn
    else
       echo "${short_reads[0]}" > sgs.fofn
       echo "${short_reads[1]}" >> sgs.fofn
    fi

    gunzip -c ${assembly} > assembly.fasta
    echo -e "task = best\ngenome = assembly.fasta\nmultithread_jobs = ${task.cpus}\nworkdir = ./nextpolish_workdir\nsgs_fofn = sgs.fofn" > run.cfg
    
    nextPolish run.cfg

    # Copy all fasta and fasta.stat files from nextpolish_workdir to current directory
    cp nextpolish_workdir/*.fasta ./
    cp nextpolish_workdir/*.fasta.stat ./

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
