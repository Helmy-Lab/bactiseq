// include { samplesheetToList } from 'plugin/nf-schema'
workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //Path to the sample sheet, should be csv

    main:
    
    

    emit:
    input_samples_ch
}
