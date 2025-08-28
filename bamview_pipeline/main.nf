nextflow.enable.dsl=2

workflow {
    // Check if BAM and reference FASTA are provided

    if (!params.bam || !params.ref) {
        // Log an error message if either is missing and exit
        log.error "Please provide both a BAM file and a reference FASTA using: --bam file.bam --ref file.fasta"
        System.exit(1)
    }

    // Convert the input parameters to file objects
    def bam_path = file(params.bam)       
    def ref_path = file(params.ref)      
    def jar_path = file("${workflow.projectDir}/artemis.jar")  // Path to Artemis JAR 

    // Call the BAMVIEW process
    BAMVIEW(bam_path, ref_path, jar_path)
}

// Define the BAMVIEW process
process BAMVIEW {
    // Tag the process with the BAM file name
    tag { bam_file }

    // Declare inputs
    input:
    path bam_file
    path ref_file
    path jar_file

    // Declare outputs
    output:
    path "bamview.done" 

    // Script block to execute
    script:
    """
    # Index the BAM file using samtools
    samtools index ${bam_file}

    # Run Artemis JAR with the reference and BAM file
    java -jar ${jar_file} ${ref_file} ${bam_file}

    # Create a file to indicate the process has finished
    touch bamview.done
    """
}
