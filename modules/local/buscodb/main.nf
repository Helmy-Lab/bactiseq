process BUSCO_DOWNLOAD {
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/c6/c607f319867d96a38c8502f751458aa78bbd18fe4c7c4fa6b9d8350e6ba11ebe/data'
        : 'community.wave.seqera.io/library/busco_sepp:f2dbc18a2f7a5b64'}"



    publishDir "${params.db_path}/buscodb", 
        saveAs: { filename -> 
            if (filename.startsWith("busco_downloads/lineages")) {
                // Extract only the filename (e.g., "eukaryota_odb10.tar.gz")
                return filename.substring(filename.lastIndexOf("/") + 1)
            }
            // Optional: Skip saving other files (return null)
            return null
        },
    mode: 'copy',
    overwrite: true

    // publishDir "${params.db_path + '/buscodb'}", mode: 'copy', overwrite: true //Save the checkm2DB into a local folder

    output:
    path "busco_downloads/*", emit: download_dir
    path "versions.yml"   , emit: versions
    stdout emit: dbpath


    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: params.busco_db_type
    """
    busco \\
        --download ${params.busco_db_type} \\
        $args > busco_download.log 2>&1
    echo "\${PWD}/busco_downloads"
    rm -rf busco_downloads/file_versions.tsv
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2> /dev/null | sed 's/BUSCO //g' )
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    mkdir busco_downloads

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        busco: \$( busco --version 2> /dev/null | sed 's/BUSCO //g' )
    END_VERSIONS
    """
}