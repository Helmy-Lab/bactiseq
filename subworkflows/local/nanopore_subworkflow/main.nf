include {LONGREADS_QA                  } from '../../../subworkflows/local/longreads_qa/main'
include {SEQKIT_STATS                  } from '../../../modules/nf-core/seqkit/stats/main'
include { PORECHOP_PORECHOP }           from '../modules/nf-core/porechop/porechop/main'
workflow NANOPORE_SUBWORKFLOW {

    take:
    // TODO nf-core: edit input (take) channels
    ch_input // channel: [ val(meta), [ bam ] ]

    main:

    ch_versions = Channel.empty()
    
    LONGREADS_QA(ch_input)
    SEQKIT_STATS(ch_input)
    // TODO nf-core: substitute modules here for the modules of your subworkflow

    SAMTOOLS_SORT ( ch_bam )
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

    SAMTOOLS_INDEX ( SAMTOOLS_SORT.out.bam )
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}
