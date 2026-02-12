
include {HIFIADAPTERFILT               } from '../../../modules/local/hifiadapterfilt/main'

include {  FLYE                        } from '../../../modules/nf-core/flye/main'
include {  SAMTOOLS_FASTQ              } from '../../../modules/local/fastqsamtools/main'
include { GATK4_SAMTOFASTQ            } from '../../../modules/nf-core/gatk4/samtofastq/main'
include { CHOPPER                           } from '../../../modules/nf-core/chopper/main'
include { ANNOTATION                   } from '../../../subworkflows/local/annotation/main.nf'
include { TAXONOMY                     } from '../../../subworkflows/local/taxonomy/main.nf'
include { ASSEMBLY_QA                  } from '../../../subworkflows/local/assembly_qa/main'
include {LONGREADS_QA as POST_FILTER_QA} from '../../../subworkflows/local/longreads_qa/main'
include {LONGREADS_QA                  } from '../../../subworkflows/local/longreads_qa/main'
include {PACSHORTPOLISH             } from '../../../subworkflows/local/pacshortpolish/main'
include {PACLONGPOLISH             } from '../../../subworkflows/local/paclongpolish/main'

include { FASTQC                  } from '../../../modules/nf-core/fastqc/main'



include { PILON } from '../../../modules/nf-core/pilon/main'
include {RACON  } from '../../../modules/local/racon/main'
include { MINIMAP2_ALIGN } from '../../../modules/nf-core/minimap2/align/main'
workflow PACBIO_SUBWORKFLOW {

    take:
    ch_input_full // channel: [ val(meta), files/data, files/data, files/data..etc ]
    gambitdb
    krakendb

    main:
    def ch_seqkit = Channel.empty()
    def ch_gfa = Channel.empty()
    def ch_output = Channel.empty()
    def ch_versions = Channel.empty()

    def ch_input_initial = ch_input_full.map{item -> [item[0], file(item[3])]}


    //Make channel if bam/sam files are given
    def bam_files = ch_input_initial.filter { meta, long1 ->
        meta.long == 'bam'
    }
    //If the inputs are bam  OR sam files, make them into fastq files, else, 
    GATK4_SAMTOFASTQ(bam_files)
    //filter out non-bams
    def non_bam_files = ch_input_initial.filter { meta, file ->
        meta.long != 'bam'
    }

    ch_versions = ch_versions.mix(GATK4_SAMTOFASTQ.out.versions)
    //If no conversions were done, take the normal ch_input
    def ch_input = GATK4_SAMTOFASTQ.out.fastq.mix(non_bam_files)

    def ch_polish_final = ch_input_full.map { meta, short1, short2, long_reads, assembly ->
        if (meta.polish == 'short' && short2 != 'short2NA') {
            [meta, [file(short1), file(short2)]]  // Both short reads
        } else if (meta.polish == 'long' && meta.long != 'bam') {
            [meta, file(long_reads)]  // Long reads
        }else if (meta.polish == 'long' && meta.long == 'bam'){
            [meta, GATK4_SAMTOFASTQ.out.fastq]
        } 
        else {
            [meta, file(short1)]  // Default: first short read
        }
    }

    LONGREADS_QA(ch_input)
    ch_seqkit = ch_seqkit.mix(LONGREADS_QA.out.stats)
    ch_versions = ch_versions.mix(LONGREADS_QA.out.versions)

    HIFIADAPTERFILT(ch_input)
    ch_versions.mix(HIFIADAPTERFILT.out.versions)

    HIFIADAPTERFILT.out.filt
        .filter {meta, filt -> filt.size() > 0 && filt.countFastq() > 0}
        .set{qc_reads}
    CHOPPER(HIFIADAPTERFILT.out.filt, [])
    ch_versions = ch_versions.mix(CHOPPER.out.versions)
    POST_FILTER_QA(CHOPPER.out.fastq)

    FLYE(CHOPPER.out.fastq, "--pacbio-hifi")
    ch_versions = ch_versions.mix(FLYE.out.versions)
    ch_gfa = ch_gfa.mix(FLYE.out.gfa)

    TAXONOMY(qc_reads, FLYE.out.fasta, krakendb, gambitdb)
    ch_versions = ch_versions.mix(TAXONOMY.out.versions)


    FLYE.out.fasta.branch {meta, value ->
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
    
    if (params.polish){
        PACSHORTPOLISH(polish_branch.short_polish, polish_result.short_polish)
        PACLONGPOLISH(polish_branch.long_polish, polish_result.long_polish)

        ch_output = ch_output.mix(PACSHORTPOLISH.out.polished)
        ch_output = ch_output.mix(PACLONGPOLISH.out.polished)


        ch_versions = ch_versions.mix(PACSHORTPOLISH.out.versions)
        ch_versions = ch_versions.mix(PACLONGPOLISH.out.versions)
    } else {
        // If polishing is disabled, pass through the short and long polish branches directly
        ch_output = ch_output.mix(polish_branch.short_polish)
        ch_output = ch_output.mix(polish_branch.long_polish)
    }
    
    ch_output = ch_output.mix(polish_branch.no_polish)

    emit:
    gambitout = TAXONOMY.out.gambitreport
    kraken2out = TAXONOMY.out.kraken2report
    output = ch_output
    versions = ch_versions                     // channel: [ versions.yml ]
    bams = bam_files
    gfa = ch_gfa
    seqkit = ch_seqkit
}
