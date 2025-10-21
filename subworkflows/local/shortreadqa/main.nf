include { SEQKIT_STATS            } from '../../../modules/nf-core/seqkit/stats/main'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'

workflow SHORTREADQA {

    take:
    ch_input // channel: [ val(meta), [ fastq reads, fastq reads] ] if paired end reads

    main:
    ch_versions = Channel.empty()
    def ch_stats = Channel.empty()

    //fastqc works on paired or single end
    FASTQC(
        ch_input
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)

    SEQKIT_STATS(
        ch_input
    )
    ch_stats = ch_stats.mix(SEQKIT_STATS.out.stats)
    ch_stats.view()
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)

    emit:
    seqkit = ch_stats
    versions = ch_versions                     // channel: [ versions.yml ]
}
