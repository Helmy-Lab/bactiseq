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
include { RGI_MAIN               } from '../modules/nf-core/rgi/main'
include { BAKTADB                } from '../modules/local/baktadb/main'
include { ABRICATE_RUN } from '../modules/nf-core/abricate/run/main'
include { MOBSUITE_RECON } from '../modules/nf-core/mobsuite/recon/main'
include { AMRFINDERPLUS_RUN } from '../modules/nf-core/amrfinderplus/run/main'
include { MLST } from '../modules/nf-core/mlst/main'

include { BUSCO       } from '../modules/local/busco/main'

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'
/*


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow BACTISEQ {
    main:

    ch_input = Channel.fromPath("./TestDatasetNfcore/GCA_040556925.1_ASM4055692v1_genomic.fna") | map { fna ->
        [ [id: fna.baseName], fna ]  // meta + file
    }
    // ch_input.view()


    // CHECKM2_PREDICT(ch_input, ch_db)

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
