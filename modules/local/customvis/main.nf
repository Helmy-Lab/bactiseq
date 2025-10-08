
process CUSTOMVIS {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/custom-thesis-vis:1.5'

    input:
    path in_dir
    // tuple val(meta), path(file)

    output:
    path "*.png", emit: images
    path "*csv"
    path "*.html"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    data_extract.py "${in_dir}"
    """

    stub:
    """
    touch test.png
    touch test.csv
    touch test.html
    """
}
