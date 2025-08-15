include { BAMDASH } from './modules/local/bamdash/main.nf'
include { SAMTOOLS } from './modules/local/samtools/main.nf'

nextflow.enable.dsl=2
params.bam = null

workflow {
      if (!params.bam) {
  error "You must provide a BAM file using --bam."
}
    SAMTOOLS(params.bam)
    seq_ids_ch = SAMTOOLS.output.seq_ids
                      .splitText()
                      .view()
                      .map { it.trim() } //removes whitespace + newlines
                      .filter { it } //removes empty strings
    BAMDASH(params.bam, seq_ids_ch, SAMTOOLS.output.bai)
}

//RUN:
// 1-line sample
    // nextflow run scriptbdash.nf --bam $pwd/test_bam/HEV.bam -profile docker
// multi-line, memory intensive sample
    // nextflow run scriptbdash.nf --bam $pwd/test_bam/Test.bam -profile docker
