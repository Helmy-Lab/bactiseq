process ORGANIZE_MOBSUITE {
    label 'process_low'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/ubuntu:22.04'

    input:
    tuple val(meta), path(files)
    
    output:
    path "mobsuite/${meta.id}/*", emit: organized
    path "mobsuite/${meta.id}", emit: directory
    
    script:
    """
    mkdir -p mobsuite/${meta.id}
    for file in ${files}; do
        cp "\$file" "mobsuite/${meta.id}/"
    done
    """
}