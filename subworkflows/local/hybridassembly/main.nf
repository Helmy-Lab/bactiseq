include {SHORTREADQA              } from '../../../subworkflows/local/shortreadqa/main'


workflow HYBRIDASSEMBLY {

    take:
    ch_bam // channel: [ val(meta), [ bam ] ]

    main:

    ch_versions = Channel.empty()


    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}
