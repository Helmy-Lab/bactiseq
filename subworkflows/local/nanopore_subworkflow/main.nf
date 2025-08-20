include {LONGREADS_QA                       } from '../../../subworkflows/local/longreads_qa/main'
include {LONGREADS_QA as POST_FILTER_QA     } from '../../../subworkflows/local/longreads_qa/main'
include { PORECHOP_PORECHOP                 } from '../../../modules/nf-core/porechop/porechop/main'
include { CHOPPER                           } from '../../../modules/nf-core/chopper/main'
include {MEDAKA                           } from '../../../modules/local/medaka/main'
include {NEXTPOLISH                         } from '../../../modules/local/nextpolish/main'
include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include { ASSEMBLY_QA                  } from '../../../subworkflows/local/assembly_qa/main'

include {  FLYE                        } from '../../../modules/nf-core/flye/main'
workflow NANOPORE_SUBWORKFLOW {

    take:
    // TODO nf-core: edit input (take) channels
    ch_input // channel: [ val(meta), [ bam ] ]
    ch_polish 
    polish
    gambitdb
    krakendb

    main:
    ch_versions = Channel.empty()
    ch_output = Channel.empty()

    LONGREADS_QA(ch_input)

    PORECHOP_PORECHOP(ch_input)
    ch_versions = ch_versions.mix(PORECHOP_PORECHOP.out.versions)
    CHOPPER(PORECHOP_PORECHOP.out.reads, [])
    ch_versions = ch_versions.mix(CHOPPER.out.versions)

    POST_FILTER_QA(CHOPPER.out.fastq)

    FLYE(CHOPPER.out.fastq, '--nano-raw')
    ch_versions = ch_versions.mix(FLYE.out.versions)

    TAXONOMY(CHOPPER.out.fastq, FLYE.out.fasta, gambitdb, krakendb)

    ch_assembled = FLYE.out.fasta
        .map{meta, fasta -> [meta, fasta]}
        .collect()
        .flatMap()

    if (polish == 'long'){
        //.join the assembled genome and ch_polish to it looks like 
        //[val(meta), assembled_genome_path, original reads]
        ch_medaka = ch_assembled.join(ch_polish)
        MEDAKA(ch_medaka)
        ch_output.mix(MEDAKA.out.assembly)
    }else if (polish == 'short'){
        NEXTPOLISH(ch_assembled, ch_polish)
        ch_output.mix(NEXTPOLISH.out.fasta)
    }else{
        ch_output.mix(FLYE.out.fasta)
    }

    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
