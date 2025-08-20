
include {HIFIADAPTERFILT               } from '../../../modules/local/hifiadapterfilt/main'

include {  FLYE                        } from '../../../modules/nf-core/flye/main'
include {  SAMTOOLS_FASTQ              } from '../../../modules/local/fastqsamtools/main'
include { CHOPPER                           } from '../../../modules/nf-core/chopper/main'
include { ANNOTATION                   } from '../../../subworkflows/local/annotation/main.nf'
include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include { ASSEMBLY_QA                  } from '../../../subworkflows/local/assembly_qa/main'
include {LONGREADS_QA as POST_FILTER_QA} from '../../../subworkflows/local/longreads_qa/main'
include {LONGREADS_QA                  } from '../../../subworkflows/local/longreads_qa/main'

include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'
include { NANOPLOT                } from '../../../modules/nf-core/nanoplot/main'


include { PILON } from '../../../modules/nf-core/pilon/main'
include {RACON  } from '../../../modules/local/racon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'
workflow PACBIO_SUBWORKFLOW {

    take:
    ch_input // channel: [ val(meta), files/data ]
    ch_polish //Reads to polish by [val(meta), files/data]
    bam_file //Boolean, is it a bam or sam file?
    polish
    gambitdb
    krakendb

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    if (bam_file){
        // ch_converted = Channel.empty()
        SAMTOOLS_FASTQ(ch_input)
        // ch_converted = ch_converted.concat(SAMTOOLS_FASTQ.out.fastq)
        ch_input = SAMTOOLS_FASTQ.out.fastq
            .map { meta, fastq -> [meta, fastq] }  // Preserve metadata
            .collect()
            .flatMap()
    }
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

    ch_assembled = FLYE.out.fasta
        .map{meta, fasta -> [meta, fasta]}
        .collect()
        .flatMap()

    // FLYE.out.fasta.view()
    if (polish == 'short'){
        MINIMAP2_ALIGN(ch_polish, FLYE.out.fasta, true, 'bai', false, false)
        align_ch = MINIMAP2_ALIGN.out.bam
            .combine(MINIMAP2_ALIGN.out.index)
            .map { meta, bam, meta2, index -> [meta, bam, index] }
        PILON( FLYE.out.fasta, align_ch, "bam")
        ch_output = ch_output.mix(PILON.out.improved_assembly)
    }else if (polish == 'long'){
        MINIMAP2_ALIGN(ch_polish, FLYE.out.fasta, false, [], true, false)
        RACON(FLYE.out.fasta,  MINIMAP2_ALIGN.out.paf, ch_polish)
        ch_output = ch_output.mix(RACON.out.polished)
    }else {
        ch_output = ch_output.mix(FLYE.out.fasta)
    }
    // ch_output = ch_output.concat(FLYE.out.fasta)
    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
