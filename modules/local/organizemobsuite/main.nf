process ORGANIZE_MOBSUITE {
    label 'process_low'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/custom-thesis-vis:1.5'  // Your existing container

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