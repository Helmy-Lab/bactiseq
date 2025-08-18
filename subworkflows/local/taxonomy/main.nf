include { GAMBIT              } from '../../../modules/local/gambit/main'
include { KRAKEN2_KRAKEN2 } from '../../../modules/nf-core/kraken2/kraken2/main'
workflow TAXONOMY {

    take:
    ch_input // channel: [ val(meta), [ input ] ]
    krakendb //Path to kraken2db
    gambitdb //path to gambitdb

    main:
    ch_versions = Channel.empty()

    GAMBIT(ch_input, gambitdb)
    ch_versions.mix(GAMBIT.out.versions)
    KRAKEN2_KRAKEN2(ch_input, krakendb, true, true)
    ch_versions.mix(KRAKEN2_KRAKEN2.out.versions)

    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}
