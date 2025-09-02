include {LONGREADS_QA                       } from '../../../subworkflows/local/longreads_qa/main'
include {LONGREADS_QA as POST_FILTER_QA     } from '../../../subworkflows/local/longreads_qa/main'
include { PORECHOP_PORECHOP                 } from '../../../modules/nf-core/porechop/porechop/main'
include { CHOPPER                           } from '../../../modules/nf-core/chopper/main'
include { SAMTOOLS_BGZIP } from '../../../modules/nf-core/samtools/bgzip/main'


include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include { ASSEMBLY_QA                  } from '../../../subworkflows/local/assembly_qa/main'
include { NANOLONGPOLISH                } from '../../../subworkflows/local/nanolongpolish/main.nf'
include { NANOSHORTPOLISH               } from '../../../subworkflows/local/nanoshortpolish/main.nf'
include {NOPOLISH             } from '../../../subworkflows/local/nopolish/main'
include {  FLYE                        } from '../../../modules/nf-core/flye/main'
workflow NANOPORE_SUBWORKFLOW {

    take:
    ch_input_full // channel: [ val(meta), [ bam ] ]
    gambitdb
    krakendb

    main:
    ch_versions = Channel.empty()
    ch_output = Channel.empty()

    def ch_input = ch_input_full.map{item -> [item[0], file(item[3])]}

    def ch_polish_final = ch_input_full.map { meta, short1, short2, long_reads, assembly ->
        if (meta.polish == 'short' && short2 != 'short2NA' && !short2.toString().trim().isEmpty()) {
            [meta, [file(short1), file(short2)]]  // Both short reads
        } else if (meta.polish == 'long' && meta.long != 'bam') {
            [meta, file(long_reads)]  // Long reads
        }
        else {
            [meta, file(short1)]  // Default: first short read, and no second short read
        }
    }

    LONGREADS_QA(ch_input)

    PORECHOP_PORECHOP(ch_input)
    ch_versions = ch_versions.mix(PORECHOP_PORECHOP.out.versions)
    CHOPPER(PORECHOP_PORECHOP.out.reads, [])
    ch_versions = ch_versions.mix(CHOPPER.out.versions)

    POST_FILTER_QA(CHOPPER.out.fastq)

    FLYE(CHOPPER.out.fastq, '--nano-raw')
    ch_versions = ch_versions.mix(FLYE.out.versions)

    //TAXONOMY(CHOPPER.out.fastq, FLYE.out.fasta, gambitdb, krakendb)

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

    NANOSHORTPOLISH(polish_branch.short_polish, polish_result.short_polish)
    SAMTOOLS_BGZIP(polish_branch.long_polish)
    ch_versions = ch_versions.mix(SAMTOOLS_BGZIP.out.versions)
    NANOLONGPOLISH(SAMTOOLS_BGZIP.out.fasta, polish_result.long_polish)

    ch_output = ch_output.mix(NANOSHORTPOLISH.out.polished)
    ch_output = ch_output.mix(NANOLONGPOLISH.out.polished)
    ch_output = ch_output.mix(polish_branch.no_polish)
    
    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
