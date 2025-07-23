
process DATACHECK {
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/python:3.10' :
    'docker.io/python:3.10.18-bookworm'}"

    input:
    val list

    output:
    stdout

    when:
    task.ext.when == null || task.ext.when

    script:
        """
        #!/usr/bin/env python
        import sys
        import json
        import ast
    
        # Convert Nextflow input to Python list
        input_list = ast.literal_eval('${list}')
    
        # Process the list (example: create new list)
        processed_list = [x * 2 for x in input_list]  # Just an example
        my_list = [1, 2, 3, 4]
        print(json.dumps(my_list))
        """
    stub:
    """
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        datacheck: \$(datacheck --version)
    END_VERSIONS
    """
}
