
include {HIFIADAPTERFILT               } from '../../../modules/local/hifiadapterfilt/main'

include {  FLYE                        } from '../../../modules/nf-core/flye/main'
include {  SAMTOOLS_FASTQ              } from '../../../modules/local/fastqsamtools/main'
include { GATK4_SAMTOFASTQ            } from '../../../modules/nf-core/gatk4/samtofastq/main'
include { CHOPPER                           } from '../../../modules/nf-core/chopper/main'
include { ANNOTATION                   } from '../../../subworkflows/local/annotation/main.nf'
include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include { ASSEMBLY_QA                  } from '../../../subworkflows/local/assembly_qa/main'
include {LONGREADS_QA as POST_FILTER_QA} from '../../../subworkflows/local/longreads_qa/main'
include {LONGREADS_QA                  } from '../../../subworkflows/local/longreads_qa/main'
include {PACSHORTPOLISH             } from '../../../subworkflows/local/pacshortpolish/main'
include {PACLONGPOLISH             } from '../../../subworkflows/local/paclongpolish/main'
include {NOPOLISH             } from '../../../subworkflows/local/nopolish/main'

include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'
include { NANOPLOT                } from '../../../modules/nf-core/nanoplot/main'


include { PILON } from '../../../modules/nf-core/pilon/main'
include {RACON  } from '../../../modules/local/racon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'
workflow PACBIO_SUBWORKFLOW {

    take:
    ch_input_full // channel: [ val(meta), files/data, files/data, files/data..etc ]
    gambitdb
    krakendb

    main:
    def ch_output = Channel.empty()
    def ch_versions = Channel.empty()

    def ch_input = ch_input_full.map{item -> [item[0], file(item[3])]}

    def ch_polish_final = ch_input_full.map { meta, short1, short2, long_reads, assembly ->
        if (meta.polish == 'short' && short2 != 'short2NA' && !short2.toString().trim().isEmpty()) {
            [meta, file(short1), file(short2)]  // Both short reads
        } else if (meta.polish == 'long' && short2 != 'short2NA' && !short2.toString().trim().isEmpty()) {
            [meta, file(long_reads)]  // Long reads
        } else {
            [meta, file(short1)]  // Default: first short read
        }
    }

    def bam_files = ch_input.filter { meta, long1 ->
        meta.long == 'bam'
    }

    // GATK4_SAMTOFASTQ(bam_files)
    // GATK4_SAMTOFASTQ.collect().concat
    // ch_input = GATK4_SAMTOFASTQ.out.fastq.ifEmpty(ch_input)
    
    LONGREADS_QA(ch_input)

    HIFIADAPTERFILT(ch_input)
    ch_versions.mix(HIFIADAPTERFILT.out.versions)

    HIFIADAPTERFILT.out.filt
        .filter {meta, filt -> filt.size() > 0 && filt.countFastq() > 0}
        .set{qc_reads}
    CHOPPER(HIFIADAPTERFILT.out.filt, [])
    // qc_reads.view()

    POST_FILTER_QA(CHOPPER.out.fastq)

    FLYE(CHOPPER.out.fastq, "--pacbio-hifi")
    TAXONOMY(qc_reads, FLYE.out.fasta, gambitdb, krakendb)


    FLYE.out.fasta.branch {meta, value ->
        short_polish: meta.polish == 'short'
        long_polish: meta.polish == 'long'
        no_polish: meta.polish == 'NA'
    }.set { polish_branch }

        // Also branch ch_polish the same way
    ch_polish_final.branch { meta, data ->
        short_polish: meta.polish == 'short'
        long_polish: meta.polish == 'long'
        no_polish: meta.polish == 'NA'
    }.set { polish_result }
    
    PACSHORTPOLISH(polish_branch.short_polish, polish_result.short_polish)
    PACLONGPOLISH(polish_branch.long_polish, polish_result.long_polish)
    NOPOLISH(polish_branch.no_polish)

    ch_output.mix(PACSHORTPOLISH.out.polished)
    ch_output.mix(PACLONGPOLISH.out.polished)
    ch_output.mix(NOPOLISH.out.output)

    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
