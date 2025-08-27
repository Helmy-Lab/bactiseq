include { CGVIEW } from './modules/local/cgview/main.nf'

params.sequence = null 
params.format = 'png'
params.extra = ""

// 
workflow {
    CGVIEW (params.sequence, params.format, params.extra)
}


//  nextflow run scriptcgview.nf -profile docker --sequence /mnt/c/Users/liv_u/Desktop/GitHub/bactiseq/test_files/Ecol_J53.fasta --format jpg

