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
include { SAMPLESHEETFILTERING   } from '../subworkflows/local/samplesheetfiltering/main'
include { PACBIO_SUBWORKFLOW }  from '../subworkflows/local/pacbio_subworkflow/main'

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'


include { ANY2FASTA } from '../modules/local/any2fasta/main'
include { NANOPLOT                } from '../modules/nf-core/nanoplot/main'

include { ANNOTATION } from '../subworkflows/local/annotation/main.nf'
include { ASSEMBLY_QA } from '../subworkflows/local/assembly_qa/main'

include { BAKTA_BAKTA            } from '../modules/nf-core/bakta/bakta/main'
include { PROKKA                 } from '../modules/nf-core/prokka/main'
include { RGI_MAIN               } from '../modules/nf-core/rgi/main'
include { ABRICATE_RUN           } from '../modules/nf-core/abricate/run/main'
include { MOBSUITE_RECON         } from '../modules/nf-core/mobsuite/recon/main'
include { AMRFINDERPLUS_RUN      } from '../modules/nf-core/amrfinderplus/run/main'

include { KRAKEN2_BUILDSTANDARD } from '../modules/nf-core/kraken2/buildstandard/main'


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
    ch_input = Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
        | map { fna -> [ [id: "${fna.baseName}_copy1"], fna ] } \
        | mix( 
            Channel.fromPath("./TestDatasetNfcore/OS0131AD_EA076372_bc2074.hifi.fq.gz") \
                | map { fna -> [ [id: "${fna.baseName}_copy2"], fna ] }
    )
    // BUSCO_DOWNLOAD(params.busco_db_type)
    // ch_input.view()
    // Channel.fromList([]).ifEmpty('Hello').view()
    def list = samplesheetToList(params.input, file("assets/schema_input.json"))

    // SAMPLESHEETFILTERING(list)
    // PACBIO_SUBWORKFLOW(ch_input, false, false)
    // ch_all_assembly = ch_all_assembly.mix(PACBIO_SUBWORKFLOW.output)
    // ASSEMBLY_QA(ch_all_assembly, DATABASEDOWNLOAD.out.checkm2db,  DATABASEDOWNLOAD.out.buscodb )

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()

    KRAKEN2_BUILDSTANDARD(true)

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
