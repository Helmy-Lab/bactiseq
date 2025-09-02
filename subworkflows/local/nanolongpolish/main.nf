include {MEDAKA                           } from '../../../modules/local/medaka/main'
workflow NANOLONGPOLISH {

    take:
    ch_assembled
    ch_polish

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    MEDAKA(ch_assembled, ch_polish)

    ch_output = ch_output.mix(MEDAKA.out.assembly)
    ch_versions = ch_versions.mix(MEDAKA.out.versions)


    emit:
    polished = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
