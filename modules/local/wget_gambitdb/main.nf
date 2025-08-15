process WGET_GAMBITDB {
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/3b/3b54fa9135194c72a18d00db6b399c03248103f87e43ca75e4b50d61179994b3/data':
        'community.wave.seqera.io/library/wget:1.21.4--8b0fcde81c17be5e' }"

    input:
    val(url)
    val(url2)

    output:
    path "gambitdb", emit: database_dir
    path "versions.yml"                         , emit: versions
    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args   ?: ''

    """
    mkdir -p gambitdb
    wget \\
        -P ./gambitdb \\
        $args \\
        $url \\

    wget \\
        -P ./gambitdb \\
        $args \\
        $url2 \\


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -1 | cut -d ' ' -f 3)
    END_VERSIONS
    """

    stub:
    """
    mkdir -p ./gambit
    touch ./gambit/file1 ./gambit/file2
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        wget: \$(wget --version | head -1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
