include { NANOPLOT                } from '../../../modules/nf-core/nanoplot/main'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'
include { SEQKIT_STATS            } from '../../../modules/nf-core/seqkit/stats/main'


workflow LONGREADS_QA {

    take:
    ch_input // channel: [ val(meta), [ long read file] ]

    main:
    ch_versions = Channel.empty()
    def ch_stats = Channel.empty()
    NANOPLOT(
        ch_input
    )
    ch_versions = ch_versions.mix(NANOPLOT.out.versions)

    FASTQC(
        ch_input
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)

    SEQKIT_STATS(
        ch_input
    )
    ch_stats = ch_stats.mix(SEQKIT_STATS.out.stats)
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)


    emit:
    stats = ch_stats
    versions = ch_versions                     // channel: [ versions.yml ]
}
