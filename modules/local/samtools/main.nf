
process SAMTOOLS {
    // tag "$meta.id"
    label 'process_single'
    //     Copy bam and bai to input directory so bamdash caqn find it
    publishDir "results/bamdash", mode: 'copy'

    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    // container "txx99/bamdash:latest" //--5fbbd7a07fc865335571e5589773157bd08c77b483e75e828b85f65919071bd3"
    // container 'community.wave.seqera.io/library/samtools:1.22.1--eccb42ff8fb55509'

    input:
        path bam_file

    output:
        path "seq_ids.txt" , emit: seq_ids
        path "*.bam.bai", emit: bai

    script:
    """
    # create .bai
    samtools index ${bam_file}
    # Extract sequence ID from BAM file using samtools
    samtools view -H ${bam_file} | head -5 | grep '^@SQ' | sed -n 's/.*SN:\\([^ \\t]*\\).*/\\1/p' > seq_ids.txt
    """
}

// removed the | head -1 | pipe section so we get mutliple 
