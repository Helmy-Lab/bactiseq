
process AMRDB {
    tag "update"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ncbi-amrfinderplus:3.12.8--h283d18e_0':
        'biocontainers/ncbi-amrfinderplus:3.12.8--h283d18e_0' }"

    publishDir "${params.db_path + '/amrdb'}", mode: 'copy', overwrite: true

    output:
    path "amrfinderdb.tar.gz", emit: uncompressed
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        """
        amrfinder_update -d amrfinderdb
        tar czvf amrfinderdb.tar.gz -C amrfinderdb/\$(readlink amrfinderdb/latest) ./

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            amrfinderplus: \$(amrfinder --version)
        END_VERSIONS
        """

        stub:
        """
        mkdir -p ./amrdb
        touch amrdb/.placeholder
        touch amrfinderdb.tar
        gzip amrfinderdb.tar
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            amrfinderplus: \$(amrfinder --version)
        END_VERSIONS
        """
}
