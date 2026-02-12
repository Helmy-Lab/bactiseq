include { GAMBIT              } from '../../../modules/local/gambit/main'
include { KRAKEN2_KRAKEN2 } from '../../../modules/nf-core/kraken2/kraken2/main'
workflow TAXONOMY {

    take:
    ch_input // channel: [ val(meta), [ input ] ] //the reads for kraken2
    ch_assembled // [val(meta), [assembled data]] //fasta for gambit
    krakendb //Path to kraken2db
    gambitdb //path to gambitdb

    main:
    ch_versions = Channel.empty()
    kraken2_out = Channel.empty()
    gambit_out = Channel.empty()

    GAMBIT(ch_assembled, gambitdb)
    gambit_out = gambit_out.mix(GAMBIT.out.csv)
    ch_versions = ch_versions.mix(GAMBIT.out.versions)
    KRAKEN2_KRAKEN2(ch_input, krakendb, true, true)
    kraken2_out = kraken2_out.mix(KRAKEN2_KRAKEN2.out.report)
    ch_versions = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions)

    emit:
    kraken2report = kraken2_out
    gambitreport = gambit_out
    versions = ch_versions                     // channel: [ versions.yml ]
}
