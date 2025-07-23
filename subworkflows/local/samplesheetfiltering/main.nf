// include { samplesheetToList } from 'plugin/nf-schema'
def file_name(String string){
    def last_item = string.split('/')[-1]
    return last_item
}
def check_header(String path) {
    try {
        // Use ProcessBuilder to run zca
        def pb = new ProcessBuilder("sh", "-c", "zcat ${path} | grep -m 1 '^@'")
        // pb.redirectErrorStream(true)  // Combine stdout and stderr
        def process = pb.start()
        
        // Read only the first line of output
        def output = process.inputStream.withReader { r -> 
            r.readLine()?.trim()
        }
        
        return output ?: null
    } catch (Exception e) {
        println "Error processing ${path}: ${e.message}"
        return null
    }
}


workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //Path to the sample sheet, should be csv


    main:
    def ch_longnano_noPolish = []
    def ch_longpac_noPolish = []
    def ch_longbam_noPolish = []
    println("List below")
    println(samplesheet)
    samplesheet.each{item ->
        //Item is the row in the sample sheet
        def sample = 0
        // println(item)
        def list_string = item.join(',').split(',')
        println(list_string)
        // println(list_string[1])

        def file_long = file_name(list_string[4]) //Grab filename for 
        def file_short1 = file_name(list_string[2])
        def file_short2 = file_name(list_string[3])
        def assemble_file = file_name(list_string[5])

        //Check the long read data, what type of read data is it? Nanopore, Pacbio, BAM?
        if (file_long != "longNA" && file_short1 == "short1NA" && file_short2 == "short2NA"){
            //What type of long read data is being inputted?
            println(check_header(list_string[4]))
            println("header above")
            // if (file_long.contains('hifi') ||){
            // }
        }
        // if (list_string)
        item.each { second ->
            //Second is the item in each row (sample, shortfastq1, shortfastq2, longfastq..etc)
            // println(sample)
            // if (sample == 1){
            //     //short fastq we are parsing
            //     def path = second.toString()
            //     println(file_name(path))
            // }
            // if (!(second instanceof LinkedHashMap)){
            //     println(second.getClass())
            //     println("not meta data")
            // } else if (second instanceof ){

            // } 
            // else { //Else it is a linked hashmap, it is meta data
            //     println(second.getClass())
            //     println(second)
            //     println("META DATA")
            // }
            // sample += 1
        }
    }
    

    // emit:
    // input_samples_ch
}
