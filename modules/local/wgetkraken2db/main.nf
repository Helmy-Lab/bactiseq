process WGETKRAKEN2DB {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/3b/3b54fa9135194c72a18d00db6b399c03248103f87e43ca75e4b50d61179994b3/data':
        'community.wave.seqera.io/library/wget:1.21.4--8b0fcde81c17be5e' }"
    input:
    val(url)

    output:
    path "kraken2db"              , emit: database_dir
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    """
    mkdir -p kraken2db
    wget \\
        $args \\
        ${url}
    tar -xzvf *.tar.gz -C ./kraken2db

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -1 | cut -d ' ' -f 3)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    """
    
    touch kraken_db.tar.gz
    mkdir -p kraken2db
    touch kraken2db/file.kmer_distrib
    touch kraken2db/hash.k2d
    touch kraken2db/ktaxonomy.tsv
    touch kraken2db/inspect.txt
    touch kraken2db/library_report.tsv
    touch kraken2db/names.dmp
    touch kraken2db/nodes.dmp
    touch kraken2db/opts.k2d
    touch kraken2db/seqid2taxid.map
    touch kraken2db/taxo.k2d
    touch kraken2db/unmapped_accessions.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        \$(wget --version | head -1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
