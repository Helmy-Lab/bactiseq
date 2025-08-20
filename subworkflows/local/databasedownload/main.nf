
//Nf-core modules
include { AMRFINDERPLUS_UPDATE  } from '../../../modules/nf-core/amrfinderplus/update/main'
include { BUSCO_DOWNLOAD        } from '../../../modules/nf-core/busco/download/main'
include { BAKTA_BAKTADBDOWNLOAD } from '../../../modules/nf-core/bakta/baktadbdownload/main'


//Local made modules to download
include { CHECKM2_DATABASEDOWNLOAD}  from '../../../modules/local/checkm2Download/main'
include { CARDDB                  } from '../../../modules/local/carddb/main'
include { WGET_GAMBITDB           } from  '../../../modules/local/wget_gambitdb/main'
include { WGETKRAKEN2DB           } from '../../../modules/local/wgetkraken2db/main'

workflow DATABASEDOWNLOAD {

    main:
    database_list =['baktadb', 'amrdb', 'checkm2db', 'carddb', 'buscodb', 'kraken2', 'gambitdb'] as Set //All the databases we need
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
        AMRFINDERPLUS_UPDATE()
        amr_ch = amr_ch.mix(AMRFINDERPLUS_UPDATE.out.db)
    }else if (params.amr_db != null){
        amr_ch = Channel.fromPath(params.amr_db)
    }else if (params.amr_db == null && !downloadData.contains('amrdb')){
        amr_ch = Channel.fromPath(params.db_path + '/amrdb/amrfinderdb.tar.gz')
    }
    
    //TODO: MAKE IT SO IT CAN GET DB-LIGHT OR NORMAL SIZE DB PERMA'D LIGHT DATABASE IN THE MODULE 
    def bakta_ch = Channel.empty()
    if (params.bakta_db == null && downloadData.contains('baktadb')){
        BAKTA_BAKTADBDOWNLOAD()
        bakta_ch = bakta_ch.mix(BAKTA_BAKTADBDOWNLOAD.out.db)
    }else if (params.bakta_db != null){
        bakta_ch = Channel.fromPath(params.bakta_db)
    }else if (params.bakta_db == null && !downloadData.contains("baktadb")){
        bakta_ch = Channel.fromPath(params.db_path + '/baktadb/db-light')
    }

    //DOWNLOAD CHECKM2 database
    def checmk2_ch = Channel.empty()
    if (params.checkm2_db == null && downloadData.contains('checkm2db')){
        CHECKM2_DATABASEDOWNLOAD(params.checkm2_ver)
        checmk2_ch = checmk2_ch.mix(CHECKM2_DATABASEDOWNLOAD.out.database)
    }else if (params.checkm2_db != null){
        checmk2_ch = Channel.fromPath(params.checkm2_db)
        .map { file -> tuple([id: "user_downloaded_checkm2db"], file) }
    }else if (params.checkm2_db == null && !downloadData.contains('checkm2db')){
        checmk2_ch = Channel.fromPath("${params.db_path}/checkm2db/*.dmnd")
        .map { file -> tuple([id: "pre_downloaded_checkm2db"], file) }
    }

    //Download BUSCO database
    def busco_ch = Channel.empty()
    if (params.buscodb == null && downloadData.contains('buscodb')){
        BUSCO_DOWNLOAD(params.busco_db_type)
        busco_ch = busco_ch.concat(BUSCO_DOWNLOAD.out.download_dir)
    }else if (params.buscodb != null) {
        busco_ch = Channel.fromPath(params.buscodb)
    } else if (params.buscodb == null && !downloadData.contains('buscodb')){
        busco_ch = Channel.fromPath("${params.db_path}/buscodb/busco_downloads/lineages")
    }

    //Download gambit database
    def gambit_ch = Channel.empty()
    if (params.gambit_db == null && downloadData.contains('gambitdb')){
        WGET_GAMBITDB(
        "https://storage.googleapis.com/jlumpe-gambit/public/databases/refseq-curated/1.0/gambit-refseq-curated-1.0.gdb",
        "https://storage.googleapis.com/jlumpe-gambit/public/databases/refseq-curated/1.0/gambit-refseq-curated-1.0.gs" )
        gambit_ch = gambit_ch.concat(WGET_GAMBITDB.out.database_dir)
    }else if (params.gambit_db != null){
        gambit_ch = Channel.fromPath(params.gambit_db)
    }else if (params.gambit_db == null && !downloadData.contains('gambitdb')){
        gambit_ch = Channel.fromPath("${params.db_path}/gambitdb")
    }

    def kraken2_ch = Channel.empty()
    if (params.kraken2_db == null && downloadData.contains('kraken2')){
        WGETKRAKEN2DB('https://genome-idx.s3.amazonaws.com/kraken/k2_standard_08_GB_20250714.tar.gz')
        kraken2_ch = kraken2_ch.concat(WGETKRAKEN2DB.out.database_dir)
    }else if (params.kraken2_db != null){
        kraken2_ch = Channel.fromPath(params.kraken2_db)
    }else if (params.kraken2_db == null && !downloadData.contains('kraken2')){
        kraken2_ch = Channel.fromPath("${params.db_path}/kraken2db")
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
        gambitdb = gambit_ch.first()
        krakendb = kraken2_ch.first()
}
