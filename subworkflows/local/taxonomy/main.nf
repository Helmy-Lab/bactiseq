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
    KRAKEN2_KRAKEN2(ch_input, krakendb, true, true)

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}
