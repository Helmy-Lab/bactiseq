include { PILON } from '../../../modules/nf-core/pilon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'

workflow ILLUMINASHORTPOLISH {

    take:
    assembly // channel: [ val(meta), [ bam ] ]
    ch_polish

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    MINIMAP2_ALIGN(ch_polish, assembly, true, 'bai', false, false)
    ch_versions = ch_versions.mix(MINIMAP2_ALIGN.out.versions)
    align_ch = MINIMAP2_ALIGN.out.bam
        .join(MINIMAP2_ALIGN.out.index)
        .map { meta, bam, meta2, index -> [meta, bam, index] }
    PILON( assembly, align_ch, "bam")
    ch_versions = ch_versions.mix(PILON.out.versions)
    ch_output = ch_output.mix(PILON.out.improved_assembly)

    emit:
    polished = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
