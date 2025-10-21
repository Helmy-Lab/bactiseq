process ORGANIZE_MOBSUITE {
    label 'process_low'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/alpine:3.19'  // Your existing container

    input:
    tuple val(meta), path(files)
    
    output:
    path "mobsuite/${meta.id}/*", emit: organized
    
    script:
    """
    mkdir -p mobsuite/${meta.id}
    for file in ${files}; do
        cp "\$file" "mobsuite/${meta.id}/"
    done
    """
}