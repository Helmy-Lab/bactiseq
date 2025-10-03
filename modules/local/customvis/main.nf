
process CUSTOMVIS {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/custom-thesis-vis:v1.0'


    output:
    path "*.png", emit: images
    path "*csv"
    path "*.html"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    python data_extract.py $params.outdir
    """

    stub:
    """
    touch test.png
    touch test.csv
    touch test.html
    """
}
