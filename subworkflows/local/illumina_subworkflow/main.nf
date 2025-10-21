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
    def ch_gfa = Channel.empty()
    def ch_seqkit = Channel.empty()
    // def ch_input = ch_input_full.map{item -> [item[0], file(item[3])]}
    def ch_input = ch_input_full.map{meta, short1, short2, long_reads, assembly -> 
        if (short1 != 'short1NA'  && short2 != 'short2NA'){
            [meta, [file(short1), file(short2)]]
        }else {
            [meta, file(short1)]
        }
    }

    def ch_polish_final = ch_input_full.map { meta, short1, short2, long_reads, assembly ->
        if (meta.polish == 'short' && short2 != 'short2NA') {
            [meta, [file(short1), file(short2)]]  // Both short reads
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
    ch_seqkit = ch_seqkit.mix(SHORTREADQA.out.seqkit)
    ch_versions = ch_versions.mix(SHORTREADQA.out.versions)
    if (params.illumina_adapters == null){
        BBMAP_BBDUK(ch_input, [])
    }else {
        BBMAP_BBDUK(ch_input, params.illumina_adapters)
    }

    POST_FILTER_QA(BBMAP_BBDUK.out.reads)

    def ch_assembled = Channel.empty()
    if (params.hybrid_assembler == null){
        def ch_no_hybrid =  BBMAP_BBDUK.out.reads.map{meta, illumina_reads ->
            [meta, illumina_reads, [],[]]
        }
        SPADES(ch_no_hybrid, [],[])
        ch_gfa = ch_gfa.mix(SPADES.out.gfa)
        ch_assembled = (SPADES.out.scaffolds)
        ch_assembled_polish_joined = ch_assembled.join(ch_polish_final, by: 0)
        ch_versions = ch_versions.mix(SPADES.out.versions)
    } else if (params.hybrid_assembler == 'spades'){
        def ch_hybrid = BBMAP_BBDUK.out.reads.join(ch_long).map{meta, illumina, long_read ->
            if (meta.long == 'pac'){
                [meta, illumina, long_read, []]
            }else if (meta.long == 'nano') {
                [meta, illumina, [], long_read]
            }
        }
        ch_hybrid.view()
        SPADES(ch_hybrid, [],[])
        ch_gfa = ch_gfa.mix(SPADES.out.gfa)
        ch_assembled = (SPADES.out.scaffolds)
        ch_assembled_polish_joined = SPADES.out.scaffolds.join(ch_polish_final, by: 0)
        ch_versions = ch_versions.mix(SPADES.out.versions)
    }else if (params.hybrid_assembler == 'unicycler'){
        def ch_hybrid = BBMAP_BBDUK.out.reads.join(ch_long)
        UNICYCLER(ch_hybrid)
        ch_gfa = ch_gfa.mix(UNICYCLER.out.gfa)
        ch_assembled = (UNICYCLER.out.scaffolds)
        ch_assembled_polish_joined = ch_assembled.join(ch_polish_final, by: 0)
        ch_versions = ch_versions.mix(UNICYCLER.out.versions)
    }

    TAXONOMY(ch_input, ch_assembled, krakendb, gambitdb)
    ch_versions = ch_versions.mix(TAXONOMY.out.versions)
 // Join assemblies with polish data by metadata (position 0)
    
    // ch_polish_final.view()
    // ch_assembled_polish_joined.view()
    // Now branch the joined data
    ch_assembled_polish_joined.branch { meta, assembly, polish_data ->
        short_polish: meta.polish == 'short'
        long_polish: meta.polish == 'long'
        no_polish: meta.polish == 'NA'
    }.set { polish_branches }

    // Conditionally run polishing processes
    if (params.polish) {
        polish_branches.short_polish.view()
        ILLUMINASHORTPOLISH(
            polish_branches.short_polish.map { meta, assembly, polish_data -> [meta, assembly] },
            polish_branches.short_polish.map { meta, assembly, polish_data -> [meta, polish_data] }
        )
        ILLUMINALONGPOLISH(
            polish_branches.long_polish.map { meta, assembly, polish_data -> [meta, assembly] },
            polish_branches.long_polish.map { meta, assembly, polish_data -> [meta, polish_data] }
        )
        
        // Mix outputs from polishing processes
        ch_output = ch_output.mix(ILLUMINASHORTPOLISH.out.polished)
        ch_output = ch_output.mix(ILLUMINALONGPOLISH.out.polished)
        ch_versions = ch_versions.mix(ILLUMINASHORTPOLISH.out.versions)
        ch_versions = ch_versions.mix(ILLUMINALONGPOLISH.out.versions)
    } else {
        // If polishing is disabled, pass through the assembly data directly
        ch_output = ch_output.mix(polish_branches.short_polish.map { meta, assembly, polish_data -> [meta, assembly] })
        ch_output = ch_output.mix(polish_branches.long_polish.map { meta, assembly, polish_data -> [meta, assembly] })
    }

    // Always include the no_polish branch in output (just the assembly)
    ch_output = ch_output.mix(polish_branches.no_polish.map { meta, assembly, polish_data -> [meta, assembly] })

    emit:
    outupt = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
    seqkit = ch_seqkit
    gfa = ch_gfa
}
