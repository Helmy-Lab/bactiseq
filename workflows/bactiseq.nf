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


include { CHECKM2_PREDICT } from '../modules/nf-core/checkm2/predict/main'

//Test bakta
include {BAKTA_BAKTA             } from '../modules/nf-core/bakta/bakta/main'
include { PROKKA                 } from '../modules/nf-core/prokka/main'

include { DATABASEDOWNLOAD       } from '../subworkflows/local/databasedownload/main.nf'
include { SAMPLESHEETFILTERING   } from '../subworkflows/local/samplesheetfiltering/main'

include { RGI_MAIN               } from '../modules/nf-core/rgi/main'
include { BAKTADB                } from '../modules/local/baktadb/main'
include { ABRICATE_RUN } from '../modules/nf-core/abricate/run/main'
include { MOBSUITE_RECON } from '../modules/nf-core/mobsuite/recon/main'
include { AMRFINDERPLUS_RUN } from '../modules/nf-core/amrfinderplus/run/main'
include { MLST } from '../modules/nf-core/mlst/main'

include { BUSCO       } from '../modules/local/busco/main'


include { DATACHECK } from '../modules/local/datacheck/main.nf'
include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'


include { ANY2FASTA } from '../modules/local/any2fasta/main'
/*


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTISEQ {
    main:
    // SAMPLESHEETFILTERING(params.input)
    // SAMPLESHEETFILTERING.out.view()

    // ch_input.view()
    // ch_input = Channel.fromList(samplesheetToList(params.input, file("assets/schema_input.json")))
    // ch_input.view()
    ch_input = Channel.fromPath("./TestDatasetNfcore/test_genomic.gbff") | map { fna ->
        [ [id: fna.baseName], fna ]  // meta + file
    }


    ANY2FASTA(ch_input)
    // def list = samplesheetToList(params.input, file("assets/schema_input.json"))
    // SAMPLESHEETFILTERING(list)



    // def string_list = DATACHECK(list)
    // string_list.view()
    // def l = Eval.me(string_list)
    // println("hello")
    // println(l)
    // Validate input parameters
    // validateParameters()
    // println(ch_input)
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // BUSCO_DOWNLOAD()
    // BUSCO_DOWNLOAD.out.download_dir.view()

    // Channel.fromPath(params.db_path + '/amrdb').view()

    // 2. Now proceed with your workflow
    // DATABASEDOWNLOAD()
    // DATABASEDOWNLOAD.out.buscodb.view()
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


    
    // // // ch_versions = ch_versions.mix(db_results.versions.virst())
    // // // db_results.db.view { "Database files: $it" }
    // // // 3. Run BAKTA analysis
    // BAKTA_BAKTA(
    //     ch_input,
    //     DATABASEDOWNLOAD.out.baktadb,
    //     [], // No proteins 
    //     []  // No prodigal-tf
    // )

    // RGI_MAIN(ch_input, DATABASEDOWNLOAD.out.carddb, [])
    // PROKKA(ch_input, [], [])
    // ABRICATE_RUN(ch_input, [])
    // MOBSUITE_RECON(ch_input)
    // AMRFINDERPLUS_RUN(ch_input, DATABASEDOWNLOAD.out.amrdb)
    // MLST(ch_input)
    // ch_db = DATABASEDOWNLOAD.out.checkm2db.map { db_path ->
    //     tuple(
    //         [id: 'checkm2db', version: params.checkm2_ver],  // dbmeta
    //         db_path                            // db path  
    //     )
    // }
    // CHECKM2_PREDICT(ch_input, ch_db)
    // DATABASEDOWNLOAD.out.buscodb.view()
    // BUSCO(ch_input, 'genome', params.busco_db_type, DATABASEDOWNLOAD.out.buscodb, [], true)

    // DATABASEDOWNLOAD.out.buscodb.view { "Value: $it (Type: ${it.getClass().simpleName})" }
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
