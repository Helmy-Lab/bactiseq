/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
// include { FASTQC                 } from '../modules/nf-core/fastqc/main'
// include { MULTIQC                } from '../modules/nf-core/multiqc/main'
// include { paramsSummaryMap       } from 'plugin/nf-schema'
// include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
// include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_bactiseq_pipeline'

//Test bakta
include { DATABASEDOWNLOAD       } from '../subworkflows/local/databasedownload/main.nf'
include { SAMPLESHEETFILTERING   } from '../subworkflows/local/samplesheetfiltering/main.nf'


include { PACBIO_SUBWORKFLOW     }  from '../subworkflows/local/pacbio_subworkflow/main'
include { NANOPORE_SUBWORKFLOW   }  from '../subworkflows/local/nanopore_subworkflow/main'
include { ILLUMINA_SUBWORKFLOW   } from '../subworkflows/local/illumina_subworkflow/main'
include { ASSEMBLED_SUBWORKFLOW  } from '../subworkflows/local/assembled_subworkflow/main'

include { CUSTOMVIS              } from '../modules/local/customvis/main'
include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

include { GUNZIP as GUNZIP_FASTA } from '../modules/nf-core/gunzip/main'

include { ASSEMBLY_QA            } from '../subworkflows/local/assembly_qa/main.nf'
include { ANNOTATION             } from '../subworkflows/local/annotation/main.nf'
include { VISUALIZATIONS         } from '../subworkflows/local/visualizations/main'
/*


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTISEQ {
    main:
    def ch_versions = Channel.empty()
    def ch_all_assembly = Channel.empty()
    def ch_gfa = Channel.empty()

    DATABASEDOWNLOAD()

    //PARSE THE OUTPUT/SAMPLESHEET TO START THE PIPELINE
    def list = samplesheetToList(params.input, file("assets/schema_input.json"))
    SAMPLESHEETFILTERING(list)


    // ////---------------------------------------------------------
    // ///----**************PACBIO WORKFLOW*************--------------
    // ////---------------------------------------------------------
    PACBIO_SUBWORKFLOW(SAMPLESHEETFILTERING.out.pacbio_reads, DATABASEDOWNLOAD.out.gambitdb,DATABASEDOWNLOAD.out.krakendb)
    ch_all_assembly = ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)
    ch_gfa = ch_gfa.mix(PACBIO_SUBWORKFLOW.out.gfa)
    ch_versions = ch_versions.mix(PACBIO_SUBWORKFLOW.out.versions)
    // ////++++++++++++++++++++++++++++++++++++
    // ////++++++++++++++++++++++++++++++++++++

    // ////---------------------------------------------------------
    // ///----************** NANOPORE *************--------------
    // ////---------------------------------------------------------
    NANOPORE_SUBWORKFLOW(SAMPLESHEETFILTERING.out.nano_reads, DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    ch_all_assembly = ch_all_assembly.mix(NANOPORE_SUBWORKFLOW.out.output)
    ch_gfa = ch_gfa.mix(NANOPORE_SUBWORKFLOW.out.gfa)
    ch_versions = ch_versions.mix(NANOPORE_SUBWORKFLOW.out.versions)
    // ////++++++++++++++++++++++++++++++++++++
    // ////++++++++++++++++++++++++++++++++++++


    // ////---------------------------------------------------------
    // ///----************** ILLUMINA **************--------------
    // ////---------------------------------------------------------
    ILLUMINA_SUBWORKFLOW(SAMPLESHEETFILTERING.out.illumina_reads, DATABASEDOWNLOAD.out.gambitdb,DATABASEDOWNLOAD.out.krakendb)
    ch_all_assembly = ch_all_assembly.mix(ILLUMINA_SUBWORKFLOW.out.outupt)
    ch_gfa = ch_gfa.mix(ILLUMINA_SUBWORKFLOW.out.gfa)
    ch_versions = ch_versions.mix(ILLUMINA_SUBWORKFLOW.out.versions)
    // ////++++++++++++++++++++++++++++++++++++
    // ////++++++++++++++++++++++++++++++++++++

    // ////---------------------------------------------------------
    // ///----************** PRE-ASSEMBLED **************--------------
    // ////---------------------------------------------------------
    ASSEMBLED_SUBWORKFLOW(SAMPLESHEETFILTERING.out.assembled_con)
    ch_all_assembly = ch_all_assembly.mix(ASSEMBLED_SUBWORKFLOW.out.output)
    ch_all_assembly = ch_all_assembly.mix(SAMPLESHEETFILTERING.out.assembled_fin)
    ch_versions = ch_versions.mix(ASSEMBLED_SUBWORKFLOW.out.versions)
    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++
    ch_all_assembly.branch { file ->
        gz: file.extension == 'gz'
        normal: true
    }.set { branched }
    
    GUNZIP_FASTA(branched.gz)
    ch_versions = ch_versions.mix(GUNZIP_FASTA.out.versions)

    def fastas = branched.normal.mix(GUNZIP_FASTA.out.gunzip)
    ASSEMBLY_QA(fastas, DATABASEDOWNLOAD.out.checkm2db, DATABASEDOWNLOAD.out.buscodb)
    ch_versions = ch_versions.mix(ASSEMBLY_QA.out.versions)
    ANNOTATION(fastas, DATABASEDOWNLOAD.out.baktadb, DATABASEDOWNLOAD.out.amrdb, DATABASEDOWNLOAD.out.carddb)
    ch_versions = ch_versions.mix(ANNOTATION.out.versions)

    VISUALIZATIONS(ANNOTATION.out.embl,ch_gfa,PACBIO_SUBWORKFLOW.out.bams)
    ch_versions = ch_versions.mix(VISUALIZATIONS.out.versions)

    ///-----------------------------------------------------------------
    ///        RUN CUSTOM VISUALIZATION ONLY AFTER ALL ANNOTATIONS ARE DONE 
    ///                     uses .collect to get all outputs
    ////-----------------------------------------------------------------
    def ch_all_embl = ANNOTATION.out.embl.collect()
    def ch_out = Channel.fromPath(params.outdir)
    ch_all_embl = ch_all_embl.concat(ch_out) //add path to end of output after all annotations done
    CUSTOMVIS(ch_all_embl.last()) //get the path to the output dir
    

    softwareVersionsToYAML(ch_versions).collectFile(
        storeDir: "${params.outdir}/pipeline_info",
        name: 'software_versions.yml',
        sort: true,
        newLine: true)

    ch_multiqc_files = Channel.empty()

    emit:
    // Emit specific outputs individually
    // embl = BAKTA_BAKTA.out.embl
    // gff = BAKTA_BAKTA.out.gff
    // versions = BAKTA_BAKTA.out.versions
    multiqc_report = Channel.empty()

    }



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
