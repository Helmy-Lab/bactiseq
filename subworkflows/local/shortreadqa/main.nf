include { SEQKIT_STATS            } from '../../../modules/nf-core/seqkit/stats/main'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'

workflow SHORTREADQA {

    take:
    ch_input // channel: [ val(meta), [ fastq reads] ]

    main:
    ch_versions = Channel.empty()

    FASTQC(
        ch_input
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)

    SEQKIT_STATS(
        ch_input
    )
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)

    emit:

    versions = ch_versions                     // channel: [ versions.yml ]
}
