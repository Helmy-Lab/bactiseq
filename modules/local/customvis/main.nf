
process CUSTOMVIS {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/custom-thesis-vis:1.5'

    input:
    path "embl_files/*", stageAs: "embl_files/*"
    // tuple val(meta), path(file)

    output:
    path "*.png", emit: images
    path "*csv"
    path "*.html"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    ls -la embl_files/
    echo "File count: $(find embl_files/ -name '*.embl' | wc -l)"
    """

    stub:
    """
    touch test.png
    touch test.csv
    touch test.html
    """
}
