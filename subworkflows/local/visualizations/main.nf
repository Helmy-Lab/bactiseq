include {   CGVIEW                       } from '../../../modules/local/cgview/main'
include {   TINYCOV                      } from '../../../modules/local/tinycov/main'
include { SAMTOOLS                       } from '../../../modules/local/samtools/main'
include { GUNZIP as GUNZIP_GFA       } from '../../../modules/nf-core/gunzip/main'
include { BANDAGE_IMAGE } from '../../../modules/nf-core/bandage/image/main'
workflow VISUALIZATIONS {

    take:
    ch_embl
    ch_gfa
    ch_bam // channel: [ val(meta), [ bam ] ]

    main:
    ch_versions = Channel.empty()

    CGVIEW(ch_embl)

    GUNZIP_GFA(ch_gfa)
    GUNZIP_GFA
        .out
        .gunzip
        .filter { meta, gfa -> gfa.size() > 0 }
        .set { gfa }
    BANDAGE_IMAGE(gfa)
    ch_versions    = ch_versions.mix(BANDAGE_IMAGE.out.versions.first())

    if (params.aligned){
        def ch_convert = ch_bam.branch { meta, long_file ->
            convert: long_file.extension == 'sam'
            non_convert: long_file.extension == 'bam'
        }.set{conversions}
        SAMTOOLS(conversions.convert)
        def all_bam = conversions.non_convert.mix(SAMTOOLS.out.bam) //bam files.mix with converted sam files as ch_bam
        TINYCOV(all_bam)
    }

    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}
