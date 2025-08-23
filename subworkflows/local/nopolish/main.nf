include { PILON } from '../../../modules/nf-core/pilon/main'
include {RACON  } from '../../../modules/local/racon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'

workflow NOPOLISH {

    take:
    assembly 

    main:
    ch_output = Channel.empty()


    ch_output.mix(assembly)
    emit:
    output = ch_output
    // versions = ch_versions                     // channel: [ versions.yml ]
}
