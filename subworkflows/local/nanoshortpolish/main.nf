include {NEXTPOLISH                         } from '../../../modules/local/nextpolish/main'

workflow NANOSHORTPOLISH {

    take:
    ch_assembled
    ch_polish

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    NEXTPOLISH(ch_assembled, ch_polish)
    ch_versions.mix(NEXTPOLISH.out.versions)
    ch_output.mix(NEXTPOLISH.out.fasta)

    emit:
    polished = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
