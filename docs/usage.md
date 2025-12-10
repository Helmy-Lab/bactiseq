---
layout: default
title: BactiSeq Usage
nav_order: 4
---


<link rel="stylesheet" href="custom.css">

# BactiSeq: Usage
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

## Introduction

BactiDeq is a Nextflow-based bioinformatics pipeline for bacterial whole-genome sequencing analysis. It provides end-to-end processing from raw sequencing reads to annotated variants and quality reports, following best practices for reproducibility and scalability.
**Basic Command**
```bash
nextflow run main.nf -profile plato/docker/conda/mamba/singularity/arm/podman/shifter/apptainer/charliecloud/wave --input samplesheet.csv --outdir /path/to/output/directory/
```
<img  height="2000" alt="image" src="https://raw.githubusercontent.com/Sylvial-00/bactiseq/refs/heads/dev/docs/images/CLI_run_nextflow.png" />

  The profile used depends on the avilable environments available to your device.

**Pipeline arguments**

| Argument | Description | Example |
|----------|-------------|---------|
| `--input` | Path to the input samplesheet (CSV/TSV) | `samplesheet.csv` |
| `--aligned` | (optional) Whether given BAM/SAM files have alignment information | `true or false, default false`
| `--hyrbid_assembler` | (optional) Which assembler to use for hybrid assmebly | `spades or unicycler, default null`
| `--illumina_adapters` | (optional) path to file of adapters for bbduk | `path to file, default null`
| `--polish` | (optional) Whether to polish at all despite what's set in the samplesheet | `true or false, default true`

## Samplesheet input

You will need to create a samplesheet with information about the samples you would like to analyse before running the pipeline. Use this parameter to specify its location. It has to be a comma-separated file with 7 columns, and a header row as shown in the examples below.

```bash
--input '[path to samplesheet file]'
```

### Full samplesheet

The pipeline will auto-detect whether a sample is single- or paired-end using the information provided in the samplesheet. As well as attempt to auto-detect whether they long reads are Nanopore, or PacBio long reads or pre-assembled genome files. 
However, there is a strict requirement for certain inputs and certain types of valid file extensions. Examples below of the rules for input
### **Quick Reference: One-line Rules**
1. **Hybrid:** `short_fastq1 + long_fastq`, no assembly
2. **Illumina:** `short_fastq1 + short_fastq2`, no long, no assembly  
3. **Long-read:** `long_fastq` only, no short, no assembly
4. **Pre-assembled:** `assembly` only, no reads


## Input Data Types & Requirements

### **Table 1: Input Combinations**

| Type | Description | Required Fields | Disallowed Fields |
|------|-------------|-----------------|-------------------|
| **Hybrid Assembly** | Short + long reads for hybrid assembly | `sample`, `short_fastq1`, `long_fastq` | `assembly` (must be `"assemblyNA`/`empty"`) |
| **Illumina-only** | Paired-end short read assembly | `sample`, `short_fastq1`, `short_fastq2` | `assembly` (must be `"assemblyNA`/`empty"`), `long_fastq` (must be `"longNA`/`empty"`) |
| **Long-read-only** | Long read assembly (Nanopore/PacBio) | `sample`, `long_fastq` | `assembly` (must be `"assemblyNA`/`empty"`), `short_fastq1`, `short_fastq2` (must be `"short1NA"`/`"short2NA"`/`empty`) |
| **Pre-assembled** | Already assembled genome | `sample`, `assembly` | `short_fastq1`, `short_fastq2`, `long_fastq` (must be `NA`/`empty` values) |

### **Table 2: Valid File Extensions**

| Field | Required Extensions | Example Files |
|-------|---------------------|---------------|
| `short_fastq1`, `short_fastq2` | `.fastq.gz`, `.fq.gz` | `sample_R1.fastq.gz`, `reads.fq.gz` |
| `long_fastq` | `.fastq.gz`, `.fq.gz` | `ont_reads.fastq.gz` |
| `assembly` | `.fasta`, `.fa`, `.fna`, `.gbk`, `.gb`, `.gbff`, `.genbank`, `.embl`, `.gff`, `.gff3` | `genome.fasta`, `annotation.gff`, `assembly.gbff` |


### **Table 3: Example Valid Configurations**

| Type | Sample Row Example |
|------|-------------------|
| **Hybrid** | `sample01,reads_R1.fq.gz,reads_R2.fq.gz,ont.fq.gz,,short,` |
| **Illumina-only** | `sample02,ill_R1.fastq.gz,ill_R2.fastq.gz,,,,` |
| **Long-read-only** | `sample03,short1NA,short2NA,pacbio.fq.gz,,long,` |
| **Pre-assembled** | `sample04,short1NA,short2NA,longNA,genome.fasta,,` |

### Example of a csv file

```csv
sample,short_fastq1,short_fastq2,long_fastq,assembly,polish,ONT_basecaller
pacbio1,,,./testPac/OS0131AD_EA076372_bc2074.hifi.fq.gz,,long,
pacbio37,,,./testPac/SRR33769408.fastq.gz,,,
NANOPORE08720179,SRR29751147_1.fastq.gz,SRR29751147_2.fastq.gz,,,short,
NANOPORE08720180,SRR29751252_1.fastq.gz,SRR29751252_2.fastq.gz,,,, 
Nanopore2,,,nanoporeSRR10074455.fastq.gz,,long,
Illumina087201792,SRR29751147_1.fastq.gz,SRR29751147_2.fastq.gz,,,,
Illumina087201802,SRR29751252_1.fastq.gz,SRR29751252_2.fastq.gz,,,,
```

> ⚠️ **WARNING:** If no basecaller mode is declared, medaka for polishing will default to the model `r1041_e82_400bps_sup_v5.2.0`.

> 💡 **TIP:** To ensure the long read data gets properly identified as either Nanopore or Pacbio. Bactiseq checks for certain file extensions, words within filenames, header data within the reads, and sample names. To ensure the data gets identified correctly - Putting Pacbio in the filename of reads/samplename or Nanopore in read file or samplename is suggested.

| Column | Description |
| ------ | ----------- |
| `sample` | Sample identifier (no spaces allowed). |
| `short_fastq1` | Path to gzipped R1 Illumina reads (`*.fastq.gz`). |
| `short_fastq2` | Path to gzipped R2 Illumina reads (`*.fastq.gz`). |
| `long_fastq` | Path to gzipped long reads (`*.fastq.gz`). |
| `assembly` | Path to pre-assembled genome file (multiple formats supported).  |
| `polish` | Polishing method: `"short"`, `"long"`, or `"NA/Empty"`. |
| `ONT_basecaller` | Nanopore basecaller metadata (optional). Default for the tool Medaka is `r1041_e82_400bps_sup_v5.2.0` |

<!-- An [example samplesheet](../assets/samplesheet.csv) has been provided with the pipeline. -->
## Running the pipeline

The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf -profile plato/docker/conda/mamba/singularity/arm/podman/shifter/apptainer/charliecloud/wave --input samplesheet.csv --outdir /path/to/output/directory/
```

This will launch the pipeline with the `docker` configuration profile. See below for more information about profiles.

Note that the pipeline will create the following files in your working directory:

```bash
work                # Directory containing the nextflow working files
<OUTDIR>            # Finished results in specified location (defined with --outdir)
.nextflow_log       # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

If you wish to repeatedly use the same parameters for multiple runs, rather than specifying each flag in the command, you can specify these in a params file.

Pipeline settings can be provided in a `yaml` or `json` file via `-params-file <file>`.

> Do not use `-c <file>` to specify parameters as this will result in errors. Custom config files specified with `-c` must only be used for [tuning process resource specifications](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources), other infrastructural tweaks (such as output directories), or module arguments (args).

The above pipeline run specified with a params file in yaml format:

```bash
nextflow run main.nf -profile docker -params-file params.yaml
```

with:

```yaml title="params.yaml"
input: './samplesheet.csv'
outdir: './results/'
polish: false
<...>
```

You can also generate such `YAML`/`JSON` files via [nf-core/launch](https://nf-co.re/launch).

### Updating the pipeline

When you run the above command, Nextflow automatically pulls the pipeline code from GitHub and stores it as a cached version. When running the pipeline after this, it will always use the cached version if available - even if the pipeline has been updated since. To make sure that you're running the latest version of the pipeline, make sure that you regularly update the cached version of the pipeline:

```bash
nextflow pull Sylvial-00/bactiseq
```

### Reproducibility

It is a good idea to specify the pipeline version when running the pipeline on your data. This ensures that a specific version of the pipeline code and software are used when you run your pipeline. If you keep using the same tag, you'll be running the same version of the pipeline, even if there have been changes to the code since.

First, go to the [nf-core/bactiseq releases page](https://github.com/nf-core/bactiseq/releases) and find the latest pipeline version - numeric only (eg. `1.3.1`). Then specify this when running the pipeline with `-r` (one hyphen) - eg. `-r 1.3.1`. Of course, you can switch to another version by changing the number after the `-r` flag.

This version number will be logged in reports when you run the pipeline, so that you'll know what you used when you look back in the future. For example, at the bottom of the MultiQC reports.

To further assist in reproducibility, you can use share and reuse [parameter files](#running-the-pipeline) to repeat pipeline runs with the same settings without having to write out a command with every single parameter.

> [!TIP]
> If you wish to share such profile (such as upload as supplementary material for academic publications), make sure to NOT include cluster specific paths to files, nor institutional specific profiles.

## Core Nextflow arguments

> [!NOTE]
> These options are part of Nextflow and use a _single_ hyphen (pipeline parameters use a double-hyphen)

### `-profile`

Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments.

Several generic profiles are bundled with the pipeline which instruct the pipeline to use software packaged using different methods (Docker, Singularity, Podman, Shifter, Charliecloud, Apptainer, Conda) - see below.

> [!IMPORTANT]
> We highly recommend the use of Docker or Singularity containers for full pipeline reproducibility, however when this is not possible, Conda is also supported.

The pipeline also dynamically loads configurations from [https://github.com/nf-core/configs](https://github.com/nf-core/configs) when it runs, making multiple config profiles for various institutional clusters available at run time. For more information and to check if your system is supported, please see the [nf-core/configs documentation](https://github.com/nf-core/configs#documentation).

Note that multiple profiles can be loaded, for example: `-profile test,docker` - the order of arguments is important!
They are loaded in sequence, so later profiles can overwrite earlier profiles.

If `-profile` is not specified, the pipeline will run locally and expect all software to be installed and available on the `PATH`. This is _not_ recommended, since it can lead to different results on different machines dependent on the computer environment.

- `test`
  - A profile with a complete configuration for automated testing
  - Includes links to test data so needs no other parameters
- `docker`
  - A generic configuration profile to be used with [Docker](https://docker.com/)
- `singularity`
  - A generic configuration profile to be used with [Singularity](https://sylabs.io/docs/)
- `podman`
  - A generic configuration profile to be used with [Podman](https://podman.io/)
- `shifter`
  - A generic configuration profile to be used with [Shifter](https://nersc.gitlab.io/development/shifter/how-to-use/)
- `charliecloud`
  - A generic configuration profile to be used with [Charliecloud](https://hpc.github.io/charliecloud/)
- `apptainer`
  - A generic configuration profile to be used with [Apptainer](https://apptainer.org/)
- `wave`
  - A generic configuration profile to enable [Wave](https://seqera.io/wave/) containers. Use together with one of the above (requires Nextflow ` 24.03.0-edge` or later).
- `conda`
  - A generic configuration profile to be used with [Conda](https://conda.io/docs/). Please only use Conda as a last resort i.e. when it's not possible to run the pipeline with Docker, Singularity, Podman, Shifter, Charliecloud, or Apptainer.
- `plato`
  - A generic configuration profile to be used within PLATO at the University of Sasktchewan. Allows proper binding of the temporary directory 

### `-resume`

Specify this when restarting a pipeline. Nextflow will use cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously. For input to be considered the same, not only the names must be identical but the files' contents as well. For more info about this parameter, see [this blog post](https://www.nextflow.io/blog/2019/demystifying-nextflow-resume.html).

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

### `-c`

Specify the path to a specific config file (this is a core Nextflow command). See the [nf-core website documentation](https://nf-co.re/usage/configuration) for more information.

### Resource requests

Whilst the default requirements set within the pipeline will hopefully work for most people and with most input data, you may find that you want to customise the compute resources that the pipeline requests. Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the pipeline steps, if the job exits with any of the error codes specified [here](https://github.com/nf-core/rnaseq/blob/4c27ef5610c87db00c3c5a3eed10b1d161abf575/conf/base.config#L18) it will automatically be resubmitted with higher resources request (2 x original, then 3 x original). If it still fails after the third attempt then the pipeline execution is stopped.

To change the resource requests, please see the [max resources](https://nf-co.re/docs/usage/configuration#max-resources) and [tuning workflow resources](https://nf-co.re/docs/usage/configuration#tuning-workflow-resources) section of the nf-core website.

### Custom Containers

In some cases, you may wish to change the container or conda environment used by a pipeline steps for a particular tool. Often Nextflow pipelines use containers and software from the [biocontainers](https://biocontainers.pro/) or [bioconda](https://bioconda.github.io/) projects. However, in some cases the pipeline specified version maybe out of date.

To use a different container from the default container or conda environment specified in a pipeline, please see the [updating tool versions](https://nf-co.re/docs/usage/configuration#updating-tool-versions) section of the nf-core website.

### Custom Tool Arguments

A pipeline might not always support every possible argument or option of a particular tool used in pipeline. Fortunately, Nextflow pipelines provide some freedom to users to insert additional parameters that the pipeline does not include by default.

To learn how to provide additional arguments to a particular tool of the pipeline, please see the [customising tool arguments](https://nf-co.re/docs/usage/configuration#customising-tool-arguments) section of the nf-core website.

##Below are the possible modules within BactiSeq that allow additional parameters.

| Process | Description | Resource for Options |
|---------|-------------|----------------------|
| **Fastqc** | Quality assessment of reads | [https://www.bioinformatics.babraham.ac.uk/projects/fastqc/](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) |
| **Seqkit_stats** | Quality assessment of reads | [https://bioinf.shenwei.me/seqkit/usage/#stats](https://bioinf.shenwei.me/seqkit/usage/#stats) |
| **Nanoplot** | Quality assessment of reads | [https://github.com/wdecoster/NanoPlot](https://github.com/wdecoster/NanoPlot) |
| **HiFiAdapterFilt** | Adapter removal on PacBio HiFi reads | [https://github.com/sheinasim-USDA/HiFiAdapterFilt](https://github.com/sheinasim-USDA/HiFiAdapterFilt) |
| **Porechop** | Adapter removal on Nanopore reads | [https://github.com/rrwick/Porechop](https://github.com/rrwick/Porechop) |
| **Chopper** | Quality control on Long reads | [https://github.com/wdecoster/chopper](https://github.com/wdecoster/chopper) |
| **bbduk** | Quality control on Illumina reads | [https://github.com/bbushnell/BBTools](https://github.com/bbushnell/BBTools) |
| **Flye** | Long reads assembler | [https://github.com/mikolmogorov/Flye](https://github.com/mikolmogorov/Flye) |
| **Unicycler** | Short/Hybrid read assembler | [https://github.com/rrwick/Unicycler](https://github.com/rrwick/Unicycler) |
| **Spades** | Short/Hybrid read assembler | [https://github.com/ablab/spades](https://github.com/ablab/spades) |
| **Kraken2** | Taxonomic identification of assembly | [https://github.com/DerrickWood/kraken2/wiki/Manual](https://github.com/DerrickWood/kraken2/wiki/Manual) |
| **Gambit** | Taxonomic identification of reads | [https://github.com/gambit/gambit](https://github.com/gambit/gambit) |
| **Pilon** | Polisher using short reads | [https://github.com/broadinstitute/pilon/wiki](https://github.com/broadinstitute/pilon/wiki) |
| **Racon** | Polisher using long reads | [https://github.com/isovic/racon](https://github.com/isovic/racon) |
| **Nextpolish** | Polisher with short reads | [https://nextpolish.readthedocs.io/en/latest/QSTART.html](https://nextpolish.readthedocs.io/en/latest/QSTART.html) |
| **Medaka** | Polisher with long reads | [https://github.com/nanoporetech/medaka](https://github.com/nanoporetech/medaka) |
| **CheckM2** | Assembly quality assessment | [https://github.com/chklovski/CheckM2](https://github.com/chklovski/CheckM2) |
| **BUSCO** | Assembly quality assessment | [https://github.com/metashot/busco](https://github.com/metashot/busco) |
| **Quast** | Assembly quality assessment | [https://github.com/ablab/quast](https://github.com/ablab/quast) |
| **Bakta** | Genome annotation | [https://github.com/oschwengers/bakta](https://github.com/oschwengers/bakta) |
| **Prokka** | Genome annotation | [https://github.com/tseemann/prokka](https://github.com/tseemann/prokka) |
| **RGI** | AMR gene identification | [https://github.com/arpcard/rgi/blob/master/docs/rgi_help.rst](https://github.com/arpcard/rgi/blob/master/docs/rgi_help.rst) |
| **Abricate** | Virulence gene identification | [https://github.com/tseemann/abricate](https://github.com/tseemann/abricate) |
| **Mobsuite** | Plasmid identification | [https://github.com/phac-nml/mob-suite](https://github.com/phac-nml/mob-suite) |
| **AMRFinderplus** | AMR gene identification | [https://github.com/ncbi/amr/wiki](https://github.com/ncbi/amr/wiki) |
| **MLST** | MLST identification | [https://github.com/tseemann/mlst](https://github.com/tseemann/mlst) |

### Custom tool/module configuration
Nextflow pipelines allow users to customize the parameters used by specific tools/modules through the configuration folder.

*** steps to customize ***
1. Navigate to the pipeline directory and edit the file: pipeline_directory/conf/modules.config, the pipeline directory is where you pulled the pipeline into.
2. Locate or add the module configuration section
3. Insert custom arguments in the `ext.args` parameter
### Example Configuration:
```nextflow
withName: CGVIEW {
 ext.args = '-feature_labels T '
 publishDir = [
     path: { "${params.outdir}/${meta.id}/visualizations/cgview" },
     mode: params.publish_dir_mode,
     saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
 ]
}
```


### nf-core/configs

In most cases, you will only need to create a custom config as a one-off but if you and others within your organisation are likely to be running nf-core pipelines regularly and need to use the same settings regularly it may be a good idea to request that your custom config file is uploaded to the `nf-core/configs` git repository. Before you do this please can you test that the config file works with your pipeline of choice using the `-c` parameter. You can then create a pull request to the `nf-core/configs` repository with the addition of your config file, associated documentation file (see examples in [`nf-core/configs/docs`](https://github.com/nf-core/configs/tree/master/docs)), and amending [`nfcore_custom.config`](https://github.com/nf-core/configs/blob/master/nfcore_custom.config) to include your custom profile.

See the main [Nextflow documentation](https://www.nextflow.io/docs/latest/config.html) for more information about creating your own configuration files.

If you have any questions or issues please send us a message on [Slack](https://nf-co.re/join/slack) on the [`#configs` channel](https://nfcore.slack.com/channels/configs).

## Running in the background

Nextflow handles job submissions and supervises the running jobs. The Nextflow process must run until the pipeline is finished.

The Nextflow `-bg` flag launches Nextflow in the background, detached from your terminal so that the workflow does not stop if you log out of your session. The logs are saved to a file.

Alternatively, you can use `screen` / `tmux` or similar tool to create a detached session which you can log back into at a later time.
Some HPC setups also allow you to run nextflow within a cluster job submitted your job scheduler (from where it submits more jobs).

## Nextflow memory requirements

In some cases, the Nextflow Java virtual machines can start to request a large amount of memory.
We recommend adding the following line to your environment to limit this (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
