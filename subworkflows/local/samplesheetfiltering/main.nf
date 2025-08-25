// include { samplesheetToList } from 'plugin/nf-schema'
def file_name(String string){
    /**
    checks file name
    */
    def last_item = string.split('/')[-1]
    return last_item
}
def check_header(String path) {
    /**
    checks header line in the faastq file
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
def parseBasecallModelVersion(String input) {
    //pattern to match the basecall_model_version_id
    def pattern = ~/basecall_model_version_id=dna_([^@]+)@(.+)/
    
    // Find the match in the input string
    def matcher = pattern.matcher(input)
    
    if (matcher.find()) {
        // Get the parts (now excluding dna_ prefix) before and after @
        def beforeAt = matcher.group(1)
        def afterAt = matcher.group(2)
        
        // Remove all periods before the @
        def cleanedBefore = beforeAt.replaceAll(/\./, '')
        
        // Combine with . instead of @
        return "${cleanedBefore}_${afterAt}"
    }
    return null
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
    } else if (file_name.contains('bam') || file_name.contains('sam') || header.contains('@SQ')){
        return 'bam'
    }else{
        return 'none'
    }
}


workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //samplesheet turned into a list, via samplesheetToList()


    main:
    
    def assembled = [] //Assembled genomes that are in fasta format
    def assembled_convert = [] //assembled genomes that arent fasta format

    // def longpac_polishing_order = []
    // def long_nano_polishing_order = []
    // def long_bam_polishing_order = []
    // def hybrid_polishing_order = []
    // def short_polishing_order = []

    def longnano = []

    def longpac= []
    

    def longbam = []

    def hybrid=[]

    def short_reads = []

    samplesheet.each{item ->
    
        //Item is the row in the sample sheet
        def sample = 0

        def list_string = item.join(',').split(',')
        // println(list_string)
        // println(list_string[1])

         //Grab filename for 
        def file_short1 = file_name(list_string[3])
        def file_short2 = file_name(list_string[4])
        def file_long = file_name(list_string[5])
        def assemble_file = file_name(list_string[6])

        //Check meta data: [sample_name:Sample2,  polish:false, basecaller:AUTO]
        def polishInput = list_string[1].split(':')[1].replace(']', '')
        def base_caller = list_string[2].split(':')[1].replace(']', '')
        def header = check_header(list_string[5]) //Grabs header of the FIRST fastq read


       
        //Check the long read data, what type of read data is it? Nanopore, Pacbio, BAM?
        if (file_long != "longNA" && file_short1 == "short1NA" && file_short2 == "short2NA"){
            //Extract header from fastq file to check type of reads
            if (check_long(file_long, header) == 'nanopore'){
                item[0]['long'] = 'nano'
                //What basecaller was used (if not given)
                if (base_caller == 'AUTO' && parseBasecallModelVersion(header) != null){
                    item[0]['basecaller'] = parseBasecallModelVersion(header)
                }
                longnano.add(item)
                //What type of polishing do we need to do?
            } else if (check_long(file_long, header) == 'pacbio'){
                item[0]['long'] = 'pac'
                longpac.add(item)
            } else if (check_long(file_long, header) == 'bam'){
                item[0]['long'] = 'bam'
                longbam.add(item)
                longpac.add(item)
            } else if (check_long(file_long, header) == 'none'){
                println(item)
                throw new Exception("Long read file: Read type (Nanopore or Pacbio cannot be determined from filename or headers. Nanopore data: filename has nanopore within, header has runid or basecall_model inside) Pacbio data: Filename has hifi/Bam/Sam within, or header has ccs or @m in the line")
            }
        
        //Given long reads, and short reads, what type of assembly and polish are we doing. NO HYBRID ASSEMBLY
        }else if (file_long != "longNA" && (file_short1 != "short1NA" || file_short2 != "short2NA") && params.hybrid_assembler == null ){
            if (polishInput == 'short' && check_long(file_long, header) == 'nanopore'){ //If we are polishing by short, we assemble long
                //BASECALLER MODE GET IT
                if (base_caller == 'AUTO' && parseBasecallModelVersion(header) != null){
                    item[0]['basecaller'] = parseBasecallModelVersion(header) //Set meta data for basecaller mode
                }
                longnano.add(item)

            }else if (polishInput == 'short' && check_long(file_long, header) == 'pacbio'){
                item[0]['long'] = 'pac'
                longpac.add(item)
            }else if (polishInput == 'short' && check_long(file_long, header) == 'bam'){
                item[0]['long'] = 'bam'
                longbam.add(item)
                longpac.add(item)
            }else if (polishInput == 'long'){ //If we are polishing by long, we assemble short
                if (file_short1 != "short1NA" && file_short2 != "short2NA"){
                    //We are paired end reads
                    item[0]['single_end'] = false
                }else{
                    //else we are single end
                    item[0]['single_end'] = true
                }            
                short_reads.add(item)
            }
        
        //Given long reads, and short reads, what type of assembly and polish are we doing. HYBRID ASSEMBLY
        }else if (file_long != "longNA" && (file_short1 != "short1NA" || file_short2 != "short2NA") && params.hybrid_assembler != null){

            //What type of long read did we input? spades needs to know
            if (check_long(file_long, header) == 'nanopore'){
                item[0]['long'] = 'nano'
            }else if (check_long(file_long, header) == 'pacbio'){
                item[0]['long'] = 'pac'
            }else if (check_long(file_long, header) == 'bam'){
                item[0]['long'] = 'bam'
            }
            //Are we single ended or paired end short reads? (illumina reads)
            if (file_short1 != "short1NA" && file_short2 != "short2NA"){
                //We are paired end reads
                item[0]['single_end'] = false
            }else{
                //else we are single end
                item[0]['single_end'] = true
            }
            hybrid.add(item)
        //Illumina reads only
        }else if (file_long == 'longNA' && (file_short1 != "short1NA" || file_short2 != "short2NA")){
            if (file_short1 != "short1NA" && file_short2 != "short2NA"){
                //We are paired end reads
                item[0]['single_end'] = false
            }else{
                //else we are single end
                item[0]['single_end'] = true
            }            
        
            short_reads.add(item)
            if (polishInput == 'long'){
                throw new Exception("Cannot polish long if only given short reads for the sample")
            }
        //Assembled files put in
        }else if (assemble_file != 'assemblyNA'){
            println("fifth else")
            if (!assemble_file.contains('.fasta')){
                assembled_convert.add(item)
            }else{
                assembled.add(item)
            }
        }

    }
    

    emit:
    pacbio_reads = Channel.fromList(longpac)
    nano_reads = Channel.fromList(longnano)
    bam_reads = Channel.fromList(longbam)
    hybrid_reads = Channel.fromList(hybrid)
    illumina_reads = Channel.fromList(short_reads)

    // pac_polish = Channel.fromList(longpac_polishing_order)
    // nano_polish = Channel.fromList(long_nano_polishing_order)
    // bam_polish = Channel.fromList(long_bam_polishing_order)
    // hyrid_polish = Channel.fromList(hybrid_polishing_order)
    // short_polish = Channel.fromList(short_polishing_order)

    list_assembled_convert = (assembled_convert)
    list_assembled = (assembled)
}
