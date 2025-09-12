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
include {ILLUMINA_SUBWORKFLOW  } from '../subworkflows/local/illumina_subworkflow/main'
include {ASSEMBLED_SUBWORKFLOW } from '../subworkflows/local/assembled_subworkflow/main'


include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

include { PIGZ_UNCOMPRESS } from '../modules/nf-core/pigz/uncompress/main'
include { ANNOTATION } from '../subworkflows/local/annotation/main.nf'
include { ASSEMBLY_QA } from '../subworkflows/local/assembly_qa/main'
include { NEXTPOLISH} from '../modules/local/nextpolish/main'

include {MEDAKA} from '../modules/local/medaka/main'
include {FASTQC} from '../modules/nf-core/fastqc/main'
include { SAMTOOLS_BGZIP } from '../modules/nf-core/samtools/bgzip/main'
include {   TINYCOV                      } from '../modules/local/tinycov/main'
include { SAMTOOLS                       } from '../modules/local/samtools/main'


include { VISUALIZATIONS } from '../subworkflows/local/visualizations/main'
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
    
    //DATABASEDOWNLOAD()
    // def test = Channel.from([
    //      [
    //          [id: 'hello', basecaller: 'NA', single_end: false],
    //          [file('./testDatasetNfcore/evalData/illumina/SRR10074454_1.fastq.gz'),
    //           file('./testDatasetNfcore/evalData/illumina/SRR10074454_2.fastq.gz')]
    //      ]
    //  ])

    //  def assembled = Channel.from([
    //      [
    //      [id: 'hello', basecaller: 'NA', single_end: false],
    //      file('./test/Nanopore1/Assembly/FLYE/Nanopore1.assembly.fasta.gz')
    //      ]
    //  ])
    // PIGZ_UNCOMPRESS(assembled)
    // NEXTPOLISH(PIGZ_UNCOMPRESS.out.file, test)
    // MEDAKA(PIGZ_UNCOMPRESS.out.file, test)
    // def list = samplesheetToList(params.input, file("assets/schema_input.json"))
    // SAMPLESHEETFILTERING(list)

    def test = Channel.from([
        [
            [id: 'sam'],
            file('./TestDatasetNfcore/aligned_output.sam')
        ],        
        [
            [id: 'bam'],
            file('./TestDatasetNfcore/aligned_output.bam')
        ]
    ])

    
    def test_gfa = Channel.from([
        [
            [id: 'sam'],
            file('./TestDatasetNfcore/FLYE/Nanopore2.assembly_graph.gfa.gz')
        ]        
    ])
    VISUALIZATIONS([],test_gfa, [])
    // ch_combined.view()
    // PACBIO_SUBWORKFLOW(longpac_longpolish,[],[])
    //PARSE THE OUTPUT/SAMPLESHEET TO START THE PIPELINE
    ////---------------------------------------------------------
    ///----**************PACBIO WORKFLOW*************--------------
    ////---------------------------------------------------------

    // PACBIO_SUBWORKFLOW(SAMPLESHEETFILTERING.out.pacbio_reads, [],[])
    // ch_all_assembly = ch_all_assembly.mix(PACBIO_SUBWORKFLOW.out.output)


    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++

    ////---------------------------------------------------------
    ///----************** NANOPORE *************--------------
    ////---------------------------------------------------------
    // NANOPORE_SUBWORKFLOW(SAMPLESHEETFILTERING.out.nano_reads, [], [])
    // ch_all_assembly = ch_all_assembly.mix(NANOPORE_SUBWORKFLOW.out.output)
    // ch_all_assembly.view()
    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++


    ////---------------------------------------------------------
    ///----************** ILLUMINA **************--------------
    ////---------------------------------------------------------

    // ILLUMINA_SUBWORKFLOW(SAMPLESHEETFILTERING.out.illumina_reads, [],[])
    // ch_all_assembly = ch_all_assembly.mix(ILLUMINA_SUBWORKFLOW.out.outupt)
    // ch_all_assembly.view()
    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++

    ////---------------------------------------------------------
    ///----************** PRE-ASSEMBLED **************--------------
    ////---------------------------------------------------------
    // ASSEMBLED_SUBWORKFLOW(SAMPLESHEETFILTERING.out.assembled_convert, [])
    // ch_all_assembly = ch_all_assembly.mix(ASSEMBLED_SUBWORKFLOW.out.output)
    // ch_all_assembly = ch_all_assembly.mix(SAMPLESHEETFILTERING.out.assembled)
    ////++++++++++++++++++++++++++++++++++++
    ////++++++++++++++++++++++++++++++++++++


    // PACBIO_SUBWORKFLOW(ch_pac_input,ch_polishing, false, "short", DATABASEDOWNLOAD.out.gambitdb, [])


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
