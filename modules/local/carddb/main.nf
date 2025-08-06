
process CARDDB {
    tag '$bam'
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/rgi:6.0.3--pyha8f3691_1':
        'biocontainers/rgi:6.0.3--pyha8f3691_1' }"
    
    publishDir "${params.db_path}/carddb", 
        saveAs: { filename -> 
            // Remove 'localDB/' prefix from the path (keep only filename)
            if (filename.startsWith("localDB/")) {
                return filename.substring("localDB/".length())
            }
        },
    mode: 'copy',
    overwrite: true
    // publishDir "${params.db_path}/carddb", 
    //     pattern: '*localDB/*',  // Copy contents only (no directory)
    //     mode: 'copy',
    //     overwrite: true

    output:
        path "localDB/*",     emit: db
        path "versions.yml"             , emit: versions
        stdout emit: dbpath //emits the EXACT work directory (tmp directory) that the database is being downloaded to
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    wget https://card.mcmaster.ca/latest/data
    tar -xf data ./card.json

    rgi load --card_json ./card.json --local 
    rgi card_annotation \\
        -i card.json \\
        $args
        
    DB_VERSION=\$(ls card_database_*_all.fasta | sed "s/card_database_v\\([0-9].*[0-9]\\).*/\\1/")

    mv card*.fasta localDB

    RGI_VERSION=\$(rgi main --version)

    echo "\${PWD}/localDB"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        carddb: \$(carddb --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir localDB
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        carddb: \$(carddb --version)
    END_VERSIONS
    """
}
