include {RACON  } from '../../../modules/local/racon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'

workflow ILLUMINALONGPOLISH {

    take:
    assembly
    ch_polish // channel: [ val(meta), [ bam ] ]

    main:
    ch_versions = Channel.empty()
    ch_output = Channel.empty()

    MINIMAP2_ALIGN(ch_polish, assembly, false, [], true, false)
    RACON(assembly,  MINIMAP2_ALIGN.out.paf, ch_polish)
    ch_output = ch_output.mix(RACON.out.polished)

    emit:
    polished = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
