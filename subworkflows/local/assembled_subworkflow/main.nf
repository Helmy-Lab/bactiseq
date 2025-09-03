include { ANY2FASTA } from '../../../modules/local/any2fasta/main'
include { GAMBIT              } from '../../../modules/local/gambit/main'
workflow ASSEMBLED_SUBWORKFLOW {

    take:
    ch_input // channel: [ val(meta), assembled_data ]
    gambitdb
    main:
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    ANY2FASTA(ch_input)
    ch_output.mix(ANY2FASTA.out.fasta_file)
    ch_versions.mix(ANY2FASTA.out.versions)

    GAMBIT(ANY2FASTA.out.fasta_file, gambitdb)
    ch_versions = ch_versions.mix(GAMBIT.out.versions)

    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
