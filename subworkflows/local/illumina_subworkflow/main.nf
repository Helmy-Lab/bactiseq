include {SHORTREADQA          } from '../../../subworkflows/local/shortreadqa/main.nf'
include {SHORTREADQA  as POST_FILTER_QA        } from '../../../subworkflows/local/shortreadqa/main.nf'
include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include {ILLUMINASHORTPOLISH             } from '../../../subworkflows/local/illuminashortpolish/main'
include {ILLUMINALONGPOLISH             } from '../../../subworkflows/local/illuminalongpolish/main'

include { BBMAP_BBDUK } from '../../../modules/nf-core/bbmap/bbduk/main'
include { SPADES                             } from '../../../modules/nf-core/spades/main'
include { UNICYCLER                          } from '../../../modules/nf-core/unicycler/main'

workflow ILLUMINA_SUBWORKFLOW {

    take:
    ch_input_full 
    gambitdb
    krakendb

    main:
    ch_versions = Channel.empty()
    ch_output = Channel.empty()

    // def ch_input = ch_input_full.map{item -> [item[0], file(item[3])]}
    def ch_input = ch_input_full.map{meta, short1, short2, long_reads, assembly -> 
        if (short1 != 'short1NA'  && short2 != 'short2NA'){
            [meta, [file(short1), file(short2)]]
        }else {
            [meta, file(short1)]
        }
    }

    def ch_polish_final = ch_input_full.map { meta, short1, short2, long_reads, assembly ->
        if (meta.polish == 'short' && short2 != 'short2NA' && !short2.toString().trim().isEmpty()) {
            [meta, file(short1), file(short2)]  // Both short reads
        } else if (meta.polish == 'long' && meta.long != 'bam') {
            [meta, file(long_reads)]  // Long reads
        }
        else {
            [meta, file(short1)]  // Default: first short read, and no second short read
        }
    }

    def ch_long = ch_input_full.map {meta, short1, short2, long_reads, assembly ->
        if (long_reads != 'longNA'){
            [meta, file(long_reads)]
        }
    }

    

    SHORTREADQA(ch_input)

    if (params.illumina_adapters == null){
        BBMAP_BBDUK(ch_input, [])
    }else {
        BBMAP_BBDUK(ch_input, params.illumina_adapters)
    }

    POST_FILTER_QA(BBMAP_BBDUK.out.reads)

    def ch_assembled = Channel.empty()
    if (params.hybrid_assembler == null){
        SPADES(ch_input, [],[])
        ch_assembled = (SPADES.out.scaffolds)
    } else if (params.hybrid_assembler == 'spades'){
        def ch_hybrid = ch_input.join(ch_long).map{meta, illumina, long_read ->
            if (meta.long == 'pac'){
                [meta, illumina, long_read, []]
            }else if (meta.long == 'nano') {
                [meta, illumina, [], long_read]
            }
        }
        SPADES(ch_hybrid, [],[])
        ch_assembled = (SPADES.out.scaffolds)
    }else if (params.hybrid_assembler == 'unicycler'){
        def ch_hybrid = ch_input.join(ch_long)
        UNICYCLER(ch_hybrid)
        ch_assembled = (UNICYCLER.out.scaffolds)
    }

    TAXONOMY(ch_input, ch_assembled, gambitdb, krakendb)

    ch_assembled.branch {meta, value ->
        short_polish: meta.polish == 'short'
        long_polish: meta.polish == 'long'
        no_polish: meta.polish == 'NA'
    }.set { polish_branch }

    // Also branch ch_polish the same way
    ch_polish_final.branch { meta, data ->
        short_polish: meta.polish == 'short'
        long_polish: meta.polish == 'long'
        no_polish: meta.polish == 'NA'
    }.set { polish_result }

    ILLUMINASHORTPOLISH(polish_branch.short_polish, polish_result.short_polish)
    ILLUMINALONGPOLISH(polish_branch.long_polish, polish_result.long_polish)

    ch_output.mix(ILLUMINASHORTPOLISH.out.polished)
    ch_output.mix(ILLUMINALONGPOLISH.out.polished)
    ch_output.mix(polish_branch.nopolish)
    emit:
    versions = ch_versions                     // channel: [ versions.yml ]
}
