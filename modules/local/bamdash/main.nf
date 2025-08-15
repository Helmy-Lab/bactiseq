
process BAMDASH {
    label 'process_low'

    //  nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda "${moduleDir}/environment.yml"
    // container 'community.wave.seqera.io/library/pip_bamdash:48d26bfffda77a05'

    publishDir "results/bamdash", mode: 'copy'
    container "community.wave.seqera.io/library/pip_bamdash:48d26bfffda77a05"

    input:
        path bam_file
        val seq_id
        path bai

    
    output:
        path "*_plot.html", emit: html 
        path "*.pdf", emit: pdf
        // path "*.jpg", emit: jpg
        // path "*.png", emit: png


    script:
    """
    echo ${seq_id}
    bamdash -b ${bam_file} -r ${seq_id} -e pdf
    """
}



// # WORKING CODE
    // # read one line at at time in its entirety (IFS= ) from seq_ids.txt into the while loop  
    // while IFS= read -r seq_id
    //     do
    //         echo \$seq_id
    //         bamdash -b ${bam_file} -r \$seq_id -e pdf
    // done < $seq_ids

// this also works on HEV but not on multiline bam so not usefule, requires more memory
    // while IFS= read -r seq_id
    //     do
    //         echo \$seq_id
    //         samtools view -b ${bam_file} \$seq_id > temp_\${seq_id}.bam
    //         samtools index temp_\${seq_id}.bam
    //         bamdash -b temp_\${seq_id}.bam -r \$seq_id -e pdf
    //         rm temp_\${seq_id}.bam
    // done < $seq_ids




// RE INDEX ERRORS
    // often gets index not found errors; tried creating .bai to same folder as .bam but didnt help.
    // tried feeding bai into the bamdash process without calling on it in the script:  worked !!
  
    // # Copy bam and bai to input directory so bamdash caqn find it
    // cp ${bam_file} ./input.bam
    // cp ${bai} ./input.bam.bai




// -e flag only takes one input --> how to do multiple -e images? 

    // # bamdash -b ${bam_file} -r \${seq_id} -e jpg
    // # bamdash -b ${bam_file} -r \${seq_id} -e png

