
process SAMTOOLS {
    // tag "$meta.id"
    label 'process_single'
    //     Copy bam and bai to input directory so bamdash caqn find it
    publishDir "results/bamdash", mode: 'copy'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/samtools:1.22.1--h96c455f_0':
        'staphb/samtools:1.22.1' }"

    input:
        path bam_file

    output:
        path "*seq_ids.txt" , emit: seq_ids
        path "*.bam.bai", emit: bai

    script:
    """
    # create .bai
    samtools index ${bam_file}
    # Extract sequence ID from BAM file using samtools
    samtools view -H ${bam_file} | grep '^@SQ' | sed -n 's/.*SN:\\([^ \\t]*\\).*/\\1/p' > ${bam_file}.seq_ids.txt
    """
}

// removed the | head -1 | pipe section so we get mutliple 
//