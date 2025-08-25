include {MEDAKA                           } from '../../../modules/local/medaka/main'
workflow NANOLONGPOLISH {

    take:
    ch_assembled
    ch_polish

    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    ch_medaka = ch_assembled.join(ch_polish)
    MEDAKA(ch_medaka)

    ch_output.mix(MEDAKA.out.assembly)
    ch_versions.mix(MEDAKA.out.versions)


    emit:
    polished = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
