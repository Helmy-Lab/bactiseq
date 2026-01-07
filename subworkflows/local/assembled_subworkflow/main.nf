include { ANY2FASTA } from '../../../modules/local/any2fasta/main'
include { GAMBIT              } from '../../../modules/local/gambit/main'
workflow ASSEMBLED_SUBWORKFLOW {

    take:
    ch_input // channel: [ val(meta), assembled_data ]
    main:
    def ch_input_for_any2fasta = ch_input.map { item ->
        def meta = item[0]
        def assembly_file = file(item[4])  // Convert to file path
        return [meta, assembly_file]
    }
    ch_output = Channel.empty()
    ch_versions = Channel.empty()

    ANY2FASTA(ch_input_for_any2fasta)
    ch_output = ch_output.mix(ANY2FASTA.out.fasta_file)
    ch_versions = ch_versions.mix(ANY2FASTA.out.versions)

    emit:
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
}
