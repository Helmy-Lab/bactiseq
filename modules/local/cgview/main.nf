
process CGVIEW {
    tag "$meta.id"
    label 'process_single'
    publishDir "results/cgview"
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    // container 'docker://pstothard/cgview:2.0.3'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://pstothard/cgview:2.0.3':
        'docker.io/pstothard/cgview:2.0.3' }"

    input:
        tuple val(meta), path(sequence) //genbank, fasta, embl

    output:
        path 'map_*', emit: map
        path "versions.yml"             , emit: versions

    script:
    def args = task.ext.args ?: ''
    """
    # convert to cgview-type xml file
    perl /usr/bin/cgview_xml_builder.pl -sequence $sequence $args -output ${sequence}.xml 
    # input to cgview
    java -jar /usr/bin/cgview.jar -i ${sequence}.xml -o map_${sequence}.svg -f svg

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cgview: \$( java -jar /usr/bin/cgview.jar --version 2>&1 | sed 's/cgview //g' )
    END_VERSIONS
    """
    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch map_${sequence}.svg

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cgview: \$( java -jar cgview.jar --version 2>&1 | sed 's/cgview //g' )
    END_VERSIONS
    """
}
