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

include { PACBIO_SUBWORKFLOW }  from '../subworkflows/local/pacbio_subworkflow/main'
include { NANOPORE_SUBWORKFLOW }  from '../subworkflows/local/nanopore_subworkflow/main'

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'


include { NANOPLOT                } from '../modules/nf-core/nanoplot/main'

include { ANNOTATION } from '../subworkflows/local/annotation/main.nf'
include { ASSEMBLY_QA } from '../subworkflows/local/assembly_qa/main'

include { BAKTA_BAKTA            } from '../modules/nf-core/bakta/bakta/main'
include { PROKKA                 } from '../modules/nf-core/prokka/main'
include { RGI_MAIN               } from '../modules/nf-core/rgi/main'
include { ABRICATE_RUN           } from '../modules/nf-core/abricate/run/main'
include { MOBSUITE_RECON         } from '../modules/nf-core/mobsuite/recon/main'
include { AMRFINDERPLUS_RUN      } from '../modules/nf-core/amrfinderplus/run/main'



include {FASTQC} from '../modules/nf-core/fastqc/main'
/*


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTISEQ {
    main:

    def ch_all_assembly = Channel.empty()
    // ch_input.view()
    // ch_input_test = Channel.fromList(samplesheetToList(params.input, file("assets/schema_input.json")))
    // ch_input_test.view()

    // ch_input = Channel.fromPath("./TestDatasetNfcore/test_genomic.gbff") | map { fna ->
    //     [ [id: fna.baseName], fna ]  // meta + file
    // }

    // ch_input = Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") | map { fna ->
    //     [ [id: fna.baseName], fna ]  // meta + file
    // }
    // Create two copies of the same file with different meta IDs
    // ch_input = Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
    //     | map { fna -> [ [id: "${fna.baseName}_copy1"], fna ] } \
    //     | mix( 
    //         Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
    //             | map { fna -> [ [id: "${fna.baseName}_copy2"], fna ] }
    // )
    // ch_input.view()
    ch_input2 = Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
    | map { fna -> [ [id: "${fna.baseName}_copy1"], 'hello' ] } \
    | mix( 
        Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
            | map { fna -> [ [id: "${fna.baseName}_copy2"], 'hello2' ] }
    )

    // ch_out = ch_input.join(ch_input2)

    // ch_out.view()
    // ch_input2.meta.view()
    // BUSCO_DOWNLOAD(params.busco_db_type)
    // ch_input.view()
    // Channel.fromList([]).ifEmpty('Hello').view()

    DATABASEDOWNLOAD()
    def list = samplesheetToList(params.input, file("assets/schema_input.json"))
    

    SAMPLESHEETFILTERING(list)

    //PARSE THE OUTPUT/SAMPLESHEET TO START THE PIPELINE
        ////---------------------------------------------------------
        ///----**************PACBIO WORKFLOW*************--------------
        ////---------------------------------------------------------
        //LONG POLISH
    def longpac_longpolish = SAMPLESHEETFILTERING.out.list_longpac_longPolish
    def flattened_result = longpac_longpolish
        .filter { value -> value instanceof List && !value.isEmpty() }
        .flatMap()
    flattened_result.view()
    // ch_input2.view()
    PACBIO_SUBWORKFLOW(flattened_result)

    //     //SHORT POLISH
    // def longpac_shortpolish = SAMPLESHEETFILTERING.out.list_longpac_shortPolish
    // longpac_shortpolish.branch { value ->
    //     empty: value instanceof List && value.isEmpty()  // Check if value is an empty list
    //     non_empty: value instanceof List && !value.isEmpty()  // Check if value is a non-empty list
    // }.set { result }
    // flattened_result = result.non_empty.flatMap()
    //     // Run your process only if channel has data
    // PACBIO_SUBWORKFLOW(flattened_result, false, 'short', DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    // ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)

    //     //NO POLISH
    // def longpac_nopolish = SAMPLESHEETFILTERING.out.list_longpac_noPolish
    // longpac_nopolish.branch { value ->
    //     empty: value instanceof List && value.isEmpty()  // Check if value is an empty list
    //     non_empty: value instanceof List && !value.isEmpty()  // Check if value is a non-empty list
    // }.set { result }
    // flattened_result = result.non_empty.flatMap()
    //     // Run your process only if channel has data
    // PACBIO_SUBWORKFLOW(flattened_result, false, 'NA', DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    // ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)

    // def longbam_longpolish = SAMPLESHEETFILTERING.out.list_longbam_longPolish
    // longbam_longpolish.branch { value ->
    //     empty: value instanceof List && value.isEmpty()  // Check if value is an empty list
    //     non_empty: value instanceof List && !value.isEmpty()  // Check if value is a non-empty list
    // }.set { result }
    // flattened_result = result.non_empty.flatMap()
    // // Check if channel is not empty
    //     // Run your process only if channel has data
    // PACBIO_SUBWORKFLOW(flattened_result, true, 'long', DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    // ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)

    //     //SHORT POLISH
    // def longbam_shortpolish = SAMPLESHEETFILTERING.out.list_longbam_shortPolish
    // longbam_shortpolish.branch { value ->
    //     empty: value instanceof List && value.isEmpty()  // Check if value is an empty list
    //     non_empty: value instanceof List && !value.isEmpty()  // Check if value is a non-empty list
    // }.set { result }
    // flattened_result = result.non_empty.flatMap()
    //     // Run your process only if channel has data
    // PACBIO_SUBWORKFLOW(flattened_result, true, 'short', DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    // ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)

    //     //NO POLISH
    // def longbam_nopolish = SAMPLESHEETFILTERING.out.list_longbam_noPolish
    // longbam_nopolish.branch { value ->
    //     empty: value instanceof List && value.isEmpty()  // Check if value is an empty list
    //     non_empty: value instanceof List && !value.isEmpty()  // Check if value is a non-empty list
    // }.set { result }
    // flattened_result = result.non_empty.flatMap()
    //     // Run your process only if channel has data
    // PACBIO_SUBWORKFLOW(flattened_result, true, 'NA', DATABASEDOWNLOAD.out.gambitdb, DATABASEDOWNLOAD.out.krakendb)
    // ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)

    //     ////---------------------------------------------------------
    //     ///----************** NANOPORE *************--------------
    //     ////---------------------------------------------------------
    // SAMPLESHEETFILTERING.out.list_longnano_longPolish.branch{value ->
    //     empty: value.isEmpty()
    //     non_empty: value.isEmpty()
    // }.set{result}

    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++
    // def channel_test = Channel.fromList(SAMPLESHEETFILTERING.out.list_longpac_shortPolish)
    // def channel_test = SAMPLESHEETFILTERING.out.list_longpac_shortPolish

    // channel_test
    //     .map { item -> [item[0], file(item[1])] } // Extract first and last for each list
    //     .set{ ch_polishing}

    // channel_test
    //     .map{item -> [item[0], file(item[3])]}
    //     .set{ch_pac_input}
    // ch_polishing.view()
    // ch_pac_input.view()


    // PACBIO_SUBWORKFLOW(ch_pac_input,ch_polishing, false, "short", DATABASEDOWNLOAD.out.gambitdb, [])
    // ch_all_assembly = ch_all_assembly.mix(PACBIO_SUBWORKFLOW.output)
    // ASSEMBLY_QA(ch_all_assembly, DATABASEDOWNLOAD.out.checkm2db,  DATABASEDOWNLOAD.out.buscodb )

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    // KRAKEN2_BUILDSTANDARD(true)

    // DATABASEDOWNLOAD()
    // DATABASEDOWNLOAD.out.gambitdb.view()
    // DATABASEDOWNLOAD.out.baktadb.view()
    // DATABASEDOWNLOAD.out.amrdb.view()
    // DATABASEDOWNLOAD.out.carddb.view()
    // DATABASEDOWNLOAD.out.checkm2db.view()

    // ANNOTATION(ch_input,
    // DATABASEDOWNLOAD.out.baktadb,
    // DATABASEDOWNLOAD.out.amrdb,
    // DATABASEDOWNLOAD.out.carddb,
    // DATABASEDOWNLOAD.out.checkm2db)
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
    // DATABASEDOWNLOAD.out.checkm2db.view()
    // ch_db = DATABASEDOWNLOAD.out.checkm2db.map { db_path ->
    //     tuple(
    //         [id: 'checkm2db', version: params.checkm2_ver],  // dbmeta
    //         db_path                            // db path  
    //     )
    // }

    // ch_db.view()
    // CHECKM2_PREDICT(ch_input, DATABASEDOWNLOAD.out.checkm2db)
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



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
