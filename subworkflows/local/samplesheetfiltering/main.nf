// include { samplesheetToList } from 'plugin/nf-schema'
def file_name(String string){
    /**
    */
    def last_item = string.split('/')[-1]
    return last_item
}
def check_header(String path) {
    /**
    */
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

def check_long(file_name, header){
    /**
    Checks filename from long fastq column in samplesheet in string form
    returns: 
    */
     if (header.contains('runid') || header.contains('basecall_model') || file_name.contains('nanopore')){
            //What type of polishing do we need to do?

    } else if (header.contains('ccs') || header.contains('@m') || file_name.contains('hifi.')){

    } else if (file_name.contains('bam') || file_name.contains('sam')){

    }
}


workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //Path to the sample sheet, should be csv


    main:
    def longnano_noPolish = []
    def longnano_longPolish = []

    def longpac_noPolish = []
    def longpac_longPolish = []

    def longbam_noPolish = []
    def longbam_longPolish = []

    def hybrid_longPolish = []
    def hybrid_shortPolish = []
    def hybrid_noPolish = []
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

        //Check meta data: [sample_name:Sample2,  polish:false]
        def polishInput = list_string[1].split(':')[1].replace(']', '')

        //Check the long read data, what type of read data is it? Nanopore, Pacbio, BAM?
        if (file_long != "longNA" && file_short1 == "short1NA" && file_short2 == "short2NA"){
            //Extract header from fastq file to check type of reads
            def header = check_header(list_string[4])
            if (header.contains('runid') || header.contains('basecall_model') || file_long.contains('nanopore')){
                //What type of polishing do we need to do?
                if (polishInput == 'false'){
                    longnano_noPolish.add(item)
                }else{
                    longnano_longPolish.add(item)
                }
            } else if (header.contains('ccs') || header.contains('@m') || file_long.contains('hifi.')){
                if (polishInput == 'false'){
                    longpac_noPolish.add(item)
                }else{
                    longpac_longPolish.add(item)
                }
            } else if (file_long.contains('bam') || file_long.contains('sam')){
                if (polishInput == 'false'){
                    longbam_noPolish.add(item)
                }else{
                    longbam_longPolish.add(item)
                }
            } else{
                println(item)
                throw new Exception("Long read file: Read type (Nanopore or Pacbio cannot be determined from filename or headers. Nanopore data: filename has nanopore within, header has runid or basecall_model inside) Pacbio data: Filename has hifi/Bam/Sam within, or header has ccs or @m in the line")
            }
        
        //Given long reads, and short reads, what type of assembly and polish are we doing
        }else if (file_long != "longNA" && (file_short1 != "short1NA" || file_short2 != "short2NA") && params.hybrid_assembler == null ){
            if (polishInput == 'short'){ //If we are polishing by short, we assemble long

            }
        }

        // // if (list_string)
        // item.each { second ->
        //     //Second is the item in each row (sample, shortfastq1, shortfastq2, longfastq..etc)
        //     // println(sample)
        //     // if (sample == 1){
        //     //     //short fastq we are parsing
        //     //     def path = second.toString()
        //     //     println(file_name(path))
        //     // }
        //     // if (!(second instanceof LinkedHashMap)){
        //     //     println(second.getClass())
        //     //     println("not meta data")
        //     // } else if (second instanceof ){

        //     // } 
        //     // else { //Else it is a linked hashmap, it is meta data
        //     //     println(second.getClass())
        //     //     println(second)
        //     //     println("META DATA")
        //     // }
        //     // sample += 1
        // }
    }
    

    // emit:
    // input_samples_ch
}
