
process HIFIADAPTERFILT {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hifiadapterfilt:3.0.0--hdfd78af_0':
        'biocontainers/hifiadapterfilt:3.0.0--hdfd78af_0' }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*.filt.fastq.gz")       , emit: filt
    tuple val(meta), path("*.contaminant.blastout"), emit: blast_search
    tuple val(meta), path("*.stats")               , emit: stats
    tuple val(meta), path("*.blocklist")           , emit: headers
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    def args = task.ext.args ?: ''
    def base_name = reads.name.replaceFirst(/\.(bam|fastq(\.gz)?|fq(\.gz)?)$/, "")
    """
    hifiadapterfilt.sh \\
        ${args} \\
        
    tree .
    mv *.filt.fastq.gz ${base_name}.filt.fastq.gz
    mv *.contaminant.blastout ${base_name}.contaminant.blastout
    mv *.stats ${base_name}.stats
    mv *.blocklist ${base_name}.blocklist


    cat <<-END_VERSIONS > versions.yml

    "${task.process}":
        hifiadapterfilt: \$(bash hifiadapterfilt.sh -v)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def base_name = reads.name.replaceFirst(/\.(bam|fastq(\.gz)?|fq(\.gz)?)$/, "")
    """
    
    touch ${base_name}.contaminant.blastout
    touch ${base_name}.blocklist
    touch ${base_name}.filt.fastq.gz
    touch ${base_name}.stats

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hifiadapterfilt: \$(bash hifiadapterfilt.sh -v)
    END_VERSIONS
    """
}
