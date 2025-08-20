include { DNAPLOTTER } from './modules/local/dnaplotter/main.nf'

params.seq = null // $pwd/test_files/Ecol_J53.gb

workflow {
    DNAPLOTTER(params.seq)
}