
process CGVIEW {
    label 'process_single'
    publishDir "results/cgview"
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    // container 'docker://pstothard/cgview:2.0.3'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://pstothard/cgview:2.0.3':
        'docker.io/pstothard/cgview:2.0.3' }"

    input:
        path sequence //genbank, fasta, embl
        val format
        val extra


    output:
        path 'map_*', emit: map

    script:
    """
    # convert to cgview-type xml file
    perl /usr/bin/cgview_xml_builder.pl -sequence $sequence -output ${sequence}.xml 
    # input to cgview
    java -jar /usr/bin/cgview.jar -i ${sequence}.xml -o map_${sequence}.$format -f $format $extra

    """
}

    // java -jar /usr/bin/cgview.jar -i ${sequence}.xml -o map_${sequence}.jpg -f jpg
    // java -jar /usr/bin/cgview.jar -i ${sequence}.xml -o map_${sequence}.png -f png
    // java -jar /usr/bin/cgview.jar -i ${sequence}.xml -o map_${sequence}.svg -f svg