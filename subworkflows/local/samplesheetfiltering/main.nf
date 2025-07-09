// include { samplesheetToList } from 'plugin/nf-schema'
workflow SAMPLESHEETFILTERING {

    take:
    samplesheet //Path to the sample sheet, should be csv

    main:
    input_samples_ch = Channel.fromList(samplesheetToList(params.input, "schemas/samplesheet_check.json"))
    

    emit:
    input_samples_ch
}
