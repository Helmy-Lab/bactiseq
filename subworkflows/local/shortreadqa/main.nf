include { SEQKIT_STATS            } from '../../../modules/nf-core/seqkit/stats/main'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'

workflow SHORTREADQA {

    take:
    ch_input // channel: [ val(meta), [ fastq reads, fastq reads] ] if paired end reads

    main:
    ch_versions = Channel.empty()
    def ch_stats = Channel.empty()

    //HANDLE IF SINGLE OR PAIRED END READS
    def ch_fastq_files = ch_input.flatMap { meta, reads ->
        if (meta.single_end) {
            // Single-end: just return the single file
            return [meta, reads[0]]
        } else {
            // Paired-end: return both files togetehr
            return [meta, reads[0], reads[1]]
        }
    }

    //fastqc works on paired or single end
    FASTQC(
        ch_fastq_files
    )
    ch_versions = ch_versions.mix(FASTQC.out.versions)

    SEQKIT_STATS(
        ch_fastq_files
    )
    ch_stats = ch_stats.mix(SEQKIT_STATS.out.stats)
    ch_stats.view()
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)

    emit:
    seqkit = ch_stats
    versions = ch_versions                     // channel: [ versions.yml ]
}
