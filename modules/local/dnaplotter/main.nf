
process DNAPLOTTER {
    label 'process_single'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/artemis:18.2.0--hdfd78af_0':
    //     'biocontainers/artemis:18.2.0--hdfd78af_0' }"

    input:
        path seq
    output:
        path "dnaplotter_completed.txt", emit: confirmation

    script:

    """    
    dnaplotter 
    touch dnaplotter_completed.txt
    """
}
