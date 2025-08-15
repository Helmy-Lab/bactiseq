include {LONGREADS_QA                  } from '../../../subworkflows/local/longreads_qa/main'
include {HIFIADAPTERFILT               } from '../../../modules/local/hifiadapterfilt/main'
include {LONGREADS_QA as POST_FILTER_QA} from '../../../subworkflows/local/longreads_qa/main'
include {  FLYE                        } from '../../../modules/nf-core/flye/main'
include {  SAMTOOLS_FASTQ              } from '../../../modules/local/fastqsamtools/main'
include { ANNOTATION                   } from '../../../subworkflows/local/annotation/main.nf'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'
include { NANOPLOT                } from '../../../modules/nf-core/nanoplot/main'
workflow PACBIO_SUBWORKFLOW {

    take:
    ch_input // channel: [ val(meta), files/data ]
    bam
    polish

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    if (bam){
        // ch_converted = Channel.empty()
        SAMTOOLS_FASTQ(ch_input)
        // ch_converted = ch_converted.concat(SAMTOOLS_FASTQ.out.fastq)
        ch_input = SAMTOOLS_FASTQ.out.fastq
            .map { meta, fastq -> [meta, fastq] }  // Preserve metadata
            .collect()
            .flatMap()
    }
    // LONGREADS_QA(ch_input)

    // HIFIADAPTERFILT(ch_input)
    // ch_versions.mix(HIFIADAPTERFILT.out.versions)

    // HIFIADAPTERFILT.out.filt
    //     .filter {meta, filt -> filt.size() > 0 && filt.countFastq() > 0}
    //     .set{qc_reads}

    // qc_reads.view()

    // POST_FILTER_QA(qc_reads)

    // FLYE(qc_reads, "--pacbio-hifi")

    // FLYE.out.fasta.view()
    // ch_output = ch_output.concat(FLYE.out.fasta)
    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
