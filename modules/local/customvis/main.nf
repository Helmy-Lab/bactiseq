
process CUSTOMVIS {
    label 'process_single'
    conda "${moduleDir}/environment.yml"
    container 'docker.io/sli254/custom-thesis-vis:1.5'

    input:
    path "bakta/*", stageAs: "bakta/*"
    path "rgi/*", stageAs: "rgi/*"
    path "amr/*", stageAs: "amr/*"
    path "mobsuite/*", stageAs: "mobsuite/*"
    path "virulence/*", stageAs: "virulence/*"
    path "mlst/*", stageAs: "mlst/*"
    path "seqkit/*", stageAs: "seqkit/*"
    // tuple val(meta), path(file)

    output:
    path "*.png", emit: images
    path "*csv"
    path "*.html"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo bakta
    ls -la bakta/
    echo rgi
    ls -la rgi/
    echo amr
    ls -la amr/
    echo mobsuite
    ls -la mobsuite/
    echo virulence
    ls -la virulence/
    echo mlst
    ls -la mlst/
    echo seqkit
    ls -la seqkit/
    """

    stub:
    """
    touch test.png
    touch test.csv
    touch test.html
    """
}
