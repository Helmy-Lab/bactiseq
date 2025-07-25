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
        return 'nanopore'
    } else if (header.contains('ccs') || header.contains('@m') || file_name.contains('hifi.')){
        return 'pacbio'
    } else if (file_name.contains('bam') || file_name.contains('sam')){
        return 'bam'
    }else{
        return 'none'
    }
}


workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //Path to the sample sheet, should be csv


    main:
    def assembled = [] //Assembled genomes that are in fasta format
    def assembled_convert = [] //assembled genomes that arent fasta format

    def longnano_noPolish = []
    def longnano_longPolish = []
    def longnano_shortPolish = []

    def longpac_noPolish = []
    def longpac_longPolish = []
    def longpac_shortPolish = []

    def longbam_noPolish = []
    def longbam_longPolish = []
    def longbam_shortPolish = []

    def hybrid_longPolish = []
    def hybrid_shortPolish = []
    def hybrid_noPolish = []

    def short_longPolish = []
    def short_noPolish = []
    def short_shortPolish = []
    // println("List below")
    // println(samplesheet)
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
        def header = check_header(list_string[4])

        //Check the long read data, what type of read data is it? Nanopore, Pacbio, BAM?
        if (file_long != "longNA" && file_short1 == "short1NA" && file_short2 == "short2NA"){
            //Extract header from fastq file to check type of reads
            
            if (check_long(file_long, header) == 'nanopore'){
                //What type of polishing do we need to do?
                if (polishInput == 'false'){
                    longnano_noPolish.add(item)
                }else{
                    longnano_longPolish.add(item)
                }
            } else if (check_long(file_long, header) == 'pacbio'){
                if (polishInput == 'false'){
                    longpac_noPolish.add(item)
                }else{
                    longpac_longPolish.add(item)
                }
            } else if (check_long(file_long, header) == 'bam'){
                println('bam')
                if (polishInput == 'false'){
                    longbam_noPolish.add(item)
                }else{
                    longbam_longPolish.add(item)
                }
            } else if (check_long(file_long, header) == 'none'){
                println(item)
                throw new Exception("Long read file: Read type (Nanopore or Pacbio cannot be determined from filename or headers. Nanopore data: filename has nanopore within, header has runid or basecall_model inside) Pacbio data: Filename has hifi/Bam/Sam within, or header has ccs or @m in the line")
            }
        
        //Given long reads, and short reads, what type of assembly and polish are we doing. NO HYBRID ASSEMBLY
        }else if (file_long != "longNA" && (file_short1 != "short1NA" || file_short2 != "short2NA") && params.hybrid_assembler == null ){
            if (polishInput == 'short' && check_long(file_long, header) == 'nanopore'){ //If we are polishing by short, we assemble long
                longnano_shortPolish.add(item)
            }else if (polishInput == 'short' && check_long(file_long, header) == 'pacbio'){
                longpac_shortPolish.add(item)
            }else if (polishInput == 'short' && check_long(file_long, header) == 'bam'){
                longbam_shortPolish.add(item)

            }else if (polishInput == 'long'){ //If we are polishing by long, we assemble short
                short_longPolish.add(item)
            }
        //Given long reads, and short reads, what type of assembly and polish are we doing. HYBRID ASSEMBLY
        }else if (file_long != "longNA" && (file_short1 != "short1NA" || file_short2 != "short2NA") && params.hybrid_assembler != null){
            if (polishInput == 'short'){ //If we are polishing by short, we assemble long
                hybrid_shortPolish.add(item)
            }else if (polishInput == 'long'){
                hybrid_longPolish.add(item)
            }else if (polishInput == 'false'){
                hybrid_noPolish.add(item)
            }

        //Illumina reads only
        }else if (file_long == 'longNA' && (file_short1 != "short1NA" || file_short2 != "short2NA")){
            if (polishInput == 'short'){
                short_shortPolish.add(item)
            }else if (polishInput == 'long'){
                throw new Exception("Cannot polish long if only given short reads for the sample")
            }else if (polishInput == 'false'){
                short_noPolish.add(item)
            }
        //Assembled files put in
        }else if (assemble_file != 'assemblyNA'){
            if (!assemble_file.contains('.fasta')){
                assembled_convert.add(item)
            }else{
                assembled.add(item)
            }
        }

    }
    

    emit:
    ch_longnano_noPolish = Channel.fromList(longnano_noPolish)
    ch_longnano_longPolish = Channel.fromList(longnano_longPolish)
    ch_longnano_shortPolish = Channel.fromList(longnano_shortPolish)

    ch_longpac_noPolish = Channel.fromList(longpac_noPolish)
    ch_longpac_longPolish = Channel.fromList(longpac_longPolish)
    ch_longpac_shortPolish = Channel.fromList(longpac_shortPolish)

    ch_longbam_noPolish = Channel.fromList(longbam_noPolish)
    ch_longbam_longPolish = Channel.fromList(longbam_longPolish)
    ch_longbam_shortPolish = Channel.fromList(longbam_shortPolish)

    ch_hybrid_longPolish = Channel.fromList(hybrid_longPolish)
    ch_hybrid_shortPolish = Channel.fromList(hybrid_shortPolish)
    ch_hybrid_noPolish = Channel.fromList(hybrid_noPolish)

    ch_short_longPolish = Channel.fromList(short_longPolish)
    ch_short_noPolish = Channel.fromList(short_noPolish)
    ch_short_shortPolish = Channel.fromList(short_shortPolish)

    ch_assembled_convert = Channel.fromList(assembled_convert)
    ch_assembled = Channel.fromList(assembled)
}
