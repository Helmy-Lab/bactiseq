include { BUSCO_BUSCO } from '../../../modules/nf-core/busco/busco/main'
include { CHECKM2_PREDICT } from '../../../modules/nf-core/checkm2/predict/main'
include { QUAST } from '../../../modules/nf-core/quast/main'
workflow ASSEMBLY_QA {

    take:
    ch_input // channel: [ val(meta), [ assembly fasta.gz ] ]
    checkm2_db
    busco_db

    main:

    ch_versions = Channel.empty()

    BUSCO_BUSCO(ch_input, 'genome', params.busco_db_type, busco_db, [], true)
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions)
    CHECKM2_PREDICT(ch_input, checkm2_db)
    ch_versions = ch_versions.mix(CHECKM2_PREDICT.out.versions)

    QUAST(ch_input, [[], []], [[],[]])
    ch_versions = ch_versions.mix(QUAST.out.versions)
    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}
