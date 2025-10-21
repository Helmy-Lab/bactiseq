
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
    // tuple val(meta), path(file)

    output:
    path "*.png", emit: images
    path "*csv"
    path "*.html"

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    ls -la bakta/
    ls -la rgi/
    ls -la amr/
    ls -la mobsuite/
    ls -la virulence/
    ls -la mlst/
    """

    stub:
    """
    touch test.png
    touch test.csv
    touch test.html
    """
}
