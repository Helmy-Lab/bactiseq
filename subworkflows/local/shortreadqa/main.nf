include { SEQKIT_STATS            } from '../../../modules/nf-core/seqkit/stats/main'
include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'

workflow SHORTREADQA {

    take:
    ch_input // channel: [ val(meta), [ fastq reads, fastq reads] ] if paired end reads

    main:
    ch_versions = Channel.empty()


    //HANDLE IF SINGLE OR PAIRED END READS
    def ch_fastq_files = ch_input.flatMap { meta, reads ->
        if (meta.single_end) {
            // Single-end: just return the single file
            return [meta, reads[0]]
        } else {
            // Paired-end: return both files individually with appropriate metadata
            def file1 = [id: "${meta.id}", single_end: true, original_id: meta.id]
            def file2 = [id: "${meta.id}", single_end: true, original_id: meta.id]
            return [
                [file1, reads[0]],
                [file2, reads[1]]
            ]
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
    ch_versions = ch_versions.mix(SEQKIT_STATS.out.versions)

    emit:

    versions = ch_versions                     // channel: [ versions.yml ]
}
