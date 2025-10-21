include { BAKTA_BAKTA            } from '../../../modules/nf-core/bakta/bakta/main'
include { PROKKA                 } from '../../../modules/nf-core/prokka/main'
include { RGI_MAIN               } from '../../../modules/nf-core/rgi/main'
include { ABRICATE_RUN           } from '../../../modules/nf-core/abricate/run/main'
include { MOBSUITE_RECON         } from '../../../modules/nf-core/mobsuite/recon/main'
include { AMRFINDERPLUS_RUN      } from '../../../modules/nf-core/amrfinderplus/run/main'
include { MLST                   } from '../../../modules/nf-core/mlst/main'

workflow ANNOTATION {

    take:
    ch_input // channel: [ val(meta), path(assembly) ]
    bakta_db
    amrdb
    carddb
    
    main:
    //Running genome annotation
    ch_versions = Channel.empty()
    def ch_embl = Channel.empty()
    //For the custom visualization
    def ch_mob = Channel.empty()
    def ch_bakta = Channel.empty()
    def ch_rgi = Channel.empty()
    def ch_amr = Channel.empty()
    def ch_mlst = Channel.empty()
    def ch_virulence = Channel.empty()

    BAKTA_BAKTA(
    ch_input,
    bakta_db,
    [], // No proteins 
    []  // No prodigal-tf
    )
    ch_embl = ch_embl.mix(BAKTA_BAKTA.out.embl)
    ch_bakta = ch_bakta.mix(BAKTA_BAKTA.out.tsv)
    ch_versions = ch_versions.mix(BAKTA_BAKTA.out.versions)
    PROKKA(ch_input, 
    [],  //proteins file NONE
    [] //Training file use for prodigal NONE
    )
    ch_versions = ch_versions.mix(PROKKA.out.versions)
    
    //Running AMR detection
    RGI_MAIN(ch_input, 
    carddb, 
    [] //wildcard database NONE
    )
    ch_rgi = ch_rgi.mix(RGI_MAIN.out.tsv)
    AMRFINDERPLUS_RUN(ch_input, amrdb)
    ch_amr = ch_amr.mix(AMRFINDERPLUS_RUN.out.report)

    ch_versions = ch_versions.mix(AMRFINDERPLUS_RUN.out.versions)
    ch_versions = ch_versions.mix(RGI_MAIN.out.versions)

    //Running VFDB detection (virulence factors)
    ABRICATE_RUN(ch_input, 
    []
    )
    ch_virulence = ch_virulence.mix(ABRICATE_RUN.out.report)
    ch_versions = ch_versions.mix(ABRICATE_RUN.out.versions)
    //Detecting plasmids
    MOBSUITE_RECON(ch_input)
    ch_mob = ch_mob.mix(MOBSUITE_RECON.out.contig_report)
    ch_versions = ch_versions.mix(MOBSUITE_RECON.out.versions)

    //MLST detection
    MLST(ch_input)
    ch_mlst = ch_mlst.mix(MLST.out.tsv)
    ch_versions = ch_versions.mix(MLST.out.versions)


    emit:
    embl = ch_embl
    mobsuite = ch_mob
    bakta = ch_bakta
    rgi = ch_rgi
    amr = ch_amr
    mlst = ch_mlst
    virulence = ch_virulence
    versions = ch_versions

}
