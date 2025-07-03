include { BAKTADB             } from '../../../modules/local/baktadb/main'
include { AMRDB               } from '../../../modules/local/amrdb/main'
include { CARDDB              } from '../../../modules/local/carddb/main'
include { CHECKM2_DATABASEDOWNLOAD } from '../../../modules/local/checkm2db/main'
include {BUSCO_DOWNLOAD} from '../../../modules/local/buscodb/main'
workflow DATABASEDOWNLOAD {

    main:
    database_list =['baktadb', 'amrdb', 'checkm2db', 'carddb', 'buscodb'] as Set //All the databases we need
    // 1. First validate params.db_path exists or create it
    db_dir = new File(params.db_path)
    if (!db_dir.exists()) { // If database directory does not exist
        println "Creating directory: ${params.db_path}"
        if (!db_dir.mkdirs()) {
            error "Failed to create directory: ${params.db_path}"
        }
    }

    dir = new File(params.db_path)

    // Get all subdirectories (recursively) and store names in a Set
    allSubdirs = [] as Set
    dir.eachDirRecurse { subdir ->
        allSubdirs << subdir.name
    }

    downloadData = database_list - allSubdirs
    log.info "DBs to download: ${downloadData.join(', ')}"
    // 2. Conditionally run process

    //Initiate the AMR database if they exist already in the database folder (downloaded from previous run)

 
    // amr_ch = !downloadData.contains('amrdb') ? Channel.fromPath(params.db_path + '/amrdb'): Channel.empty()
    // amr_ch = params.amr_db != null ? Channel.fromPath(params.amr_db): downloadData.contains('amrdb') ? AMRDB() : amr_ch

    //TODO: MAKE IT SO IT CAN GET DB-LIGHT OR NORMAL SIZE DB PERMA'D LIGHT DATABASE IN THE MODULE 
    //Inititae the download of BAKTA LIGHT database
    // bakta_ch = !downloadData.contains('baktadb') ? Channel.fromPath(params.db_path + '/baktadb/db-light'): Channel.empty()
    // bakta_ch = params.bakta_db != null ? Channel.fromPath(params.bakta_db): downloadData.contains('baktadb') ? BAKTADB() : bakta_ch 

    //Inititae the download of BAKTA LIGHT database
    // card_ch = !downloadData.contains('carddb') ? Channel.fromPath(params.db_path + '/carddb'): "None"
    // card_ch = params.card_db != null ? Channel.fromPath(params.card_db): downloadData.contains('carddb') ? CARDDB() : card_ch

    //DOWNLOAD CARD/RGI DATABASE
    def card_ch = Channel.empty()
    if (params.card_db == null && downloadData.contains('carddb')){   
        CARDDB()
        card_ch = card_ch.mix(CARDDB.out)
    }else if (params.card_db != null){
        card_ch = Channel.fromPath(params.card_db)
    }else if (params.card_db == null && !downloadData.contains('carddb')){
        card_ch = Channel.fromPath(params.db_path + '/carddb')
    }
    //DOWNLOAD AMR FINDER PLUS DATABASE
    def amr_ch = Channel.empty()
    if (params.amr_db == null && downloadData.contains('amrdb')){   
        AMRDB()
        amr_ch = amr_ch.mix(AMRDB.out)
    }else if (params.amr_db != null){
        amr_ch = Channel.fromPath(params.card_db)
    }else if (params.amr_db == null && !downloadData.contains('amrdb')){
        amr_ch = Channel.fromPath(params.db_path + '/amrdb/amrfinderdb.tar.gz')
    }
    
    //DOWNLOAD BAKTA DATABASE IT IS PERMA DB-LIGHT RIGHT NOW
    def bakta_ch = Channel.empty()
    if (params.bakta_db == null && downloadData.contains('baktadb')){
        BAKTADB()
        bakta_ch = bakta_ch.mix(BAKTADB.out)
    }else if (params.bakta_db != null){
        bakta_ch = Channel.fromPath(params.bakta_db)
    }else if (params.bakta_db == null && !downloadData.contains("baktadb")){
        bakta_ch = Channel.fromPath(params.db_path + '/baktadb/db-light')
    }

    //DOWNLOAD CHECKM2 database
    def checmk2_ch = Channel.empty()
    if (params.checkm2_db == null && downloadData.contains('checkm2db')){
        CHECKM2_DATABASEDOWNLOAD(params.checkm2_ver)
        checmk2_ch = checmk2_ch.mix(CHECKM2_DATABASEDOWNLOAD.out)
    }else if (params.checkm2_db != null){
        checmk2_ch = Channel.fromPath(params.checkm2_db)
    }else if (params.checkm2_db == null && !downloadData.contains('checkm2db')){
        checmk2_ch = Channel.fromPath("${params.db_path}/checkm2db/*.dmnd")
    }

    def busco_ch = Channel.empty()
    if (params.buscodb == null && downloadData.contains('buscodb')){
        BUSCO_DOWNLOAD()
        busco_ch = busco_ch.concat(BUSCO_DOWNLOAD.out.download_dir)
    }else if (params.buscodb != null) {
        busco_ch = Channel.fromPath(params.buscodb)
    } else if (params.buscodb == null && !downloadData.contains('buscodb')){
        busco_ch = Channel.fromPath("${params.db_path}/buscodb/lineages")
    }

    // bakta_ch.view()
    // println(card_ch.out.stdout)
// println "All subdirectories: ${allSubdirs}"
//     new File(params.db_path).eachFileRecurse(groovy.io.FileType.FILES) {
//         if (database_list.contains(it)){
//             if (!it == 'baktdadb'){
//             }
//         }
//     }

    // card_ch.view()
        // Extract the common base directory
    // Extract the common base directory
    // base_dir = card_ch
    //     .flatMap { files -> files.collect { new File(it).parent } }  // Extract parent for each file
    //     .unique()                                                   // Deduplicate
    //     .view { "Base directory: $it" }
    // parent_dir = card_ch.first()
    //         .map { file -> 
    //         file.toString().substring(0, file.toString().lastIndexOf("/")) 
    //     }
    //     .view { "Parent directory: $it" }
    // bakta_ch.view()
    emit:
        baktadb = bakta_ch.first()
        amrdb = amr_ch.first()
        carddb = card_ch.last() //Get the last item, because if you downloaded the database, it will be last in channel, works too if already downloaded the channel will only have 1 item in the channel anyways
        checkm2db= checmk2_ch.first()
        buscodb = busco_ch.last()
}
