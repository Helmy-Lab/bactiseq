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
include {BAKTA_BAKTA             } from '../modules/nf-core/bakta/bakta/main'
include { DATABASEDOWNLOAD       } from '../subworkflows/local/databasedownload/main.nf'
include { RGI_MAIN               } from '../modules/nf-core/rgi/main'
include { BAKTADB             } from '../modules/local/baktadb/main'
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTISEQ {

    take:
    ch_samplesheet // channel: samplesheet read in from --input
    // ch_samplesheet // channel: samplesheet read in from --input
    main:

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // Channel.fromPath(params.db_path + '/amrdb').view()

    // 2. Now proceed with your workflow
    DATABASEDOWNLOAD()
    // 2. Debug the database outputs
    // DATABASEDOWNLOAD.out.baktadb.view { "BAKTA DB PATH: $it" }
    // DATABASEDOWNLOAD.out.view { "CARD DB PATH: $it" }

    // // DATABASEDOWNLOAD.out.amrdb
    // //     .view()
    // //     .count()
    // //     .set { amr_count }
    
    // // log.info "AMR database items found: $amr_count"
    // //
    // // MODULE: Run FastQC
    // //
    // // Run BAKTA database download first

    // // BAKTA_BAKTADBDOWNLOAD()
    // // ch_versions = ch_versions.mix(BAKTA_BAKTADBDOWNLOAD.out.versions.first())
    // // db_results = DATABASEDOWNLOAD()
    // // 2. Create hardcoded input channel
    ch_input = Channel.fromPath("./TestDatasetNfcore/GCA_040556925.1_ASM4055692v1_genomic.fna") | map { fna ->
        [ [id: fna.baseName], fna ]  // meta + file
    }
    // // // ch_versions = ch_versions.mix(db_results.versions.virst())
    // // // db_results.db.view { "Database files: $it" }
    // // // 3. Run BAKTA analysis
    BAKTA_BAKTA(
        ch_input,
        DATABASEDOWNLOAD.out.baktadb,
        [], // No proteins 
        []  // No prodigal-tf
    )

    RGI_MAIN(ch_input, DATABASEDOWNLOAD.out.carddb, [])
    emit:
    // Emit specific outputs individually
    // embl = BAKTA_BAKTA.out.embl
    // gff = BAKTA_BAKTA.out.gff
    // versions = BAKTA_BAKTA.out.versions
    multiqc_report = Channel.empty()

    }

        // }
    // FASTQC (
    //     ch_samplesheet
    // )
    // ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    // ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    // //
    // // Collate and save software versions
    // //
    // softwareVersionsToYAML(ch_versions)
    //     .collectFile(
    //         storeDir: "${params.outdir}/pipeline_info",
    //         name: 'nf_core_'  +  'bactiseq_software_'  + 'mqc_'  + 'versions.yml',
    //         sort: true,
    //         newLine: true
    //     ).set { ch_collated_versions }

        // Add this output declaration:
    // //
    // // MODULE: MultiQC
    // //
    // ch_multiqc_config        = Channel.fromPath(
    //     "$projectDir/assets/multiqc_config.yml", checkIfExists: true)
    // ch_multiqc_custom_config = params.multiqc_config ?
    //     Channel.fromPath(params.multiqc_config, checkIfExists: true) :
    //     Channel.empty()
    // ch_multiqc_logo          = params.multiqc_logo ?
    //     Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
    //     Channel.empty()

    // summary_params      = paramsSummaryMap(
    //     workflow, parameters_schema: "nextflow_schema.json")
    // ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))
    // ch_multiqc_files = ch_multiqc_files.mix(
    //     ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))
    // ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
    //     file(params.multiqc_methods_description, checkIfExists: true) :
    //     file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)
    // ch_methods_description                = Channel.value(
    //     methodsDescriptionText(ch_multiqc_custom_methods_description))

    // ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    // ch_multiqc_files = ch_multiqc_files.mix(
    //     ch_methods_description.collectFile(
    //         name: 'methods_description_mqc.yaml',
    //         sort: true
    //     )
    // )



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
