---
layout: default
title: BactiSeq Output
nav_order: 5
---

# Bactiseq Output

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

## Introduction

This document describes the output produced by the pipeline. Output includes csv, html, and pngs/svgs/jpeg files.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

## Bactiseq Pipeline Workflow: Processes and Modules per Entry Data Type

| Input Data Type | Module | Software Tool(s) | Version |
|-----------------|--------|------------------|---------|
| **Pacbio HiFi** | **Assembly Module** | | |
| | *if SAM/BAM file* Convert to Fastq | GATK4 SamToFastq | 4.6.2.0 |
| | 1. Quality Assessment (Raw) | FastQC, Nanoplot, Seqkit stats | 0.12.1, 1.46.1, 2.9.0 |
| | 2. Quality Control & Trimming | HiFiAdaptFilt, Chopper | 3.0.0, 0.9.0 |
| | 3. Quality Assessment (Trimmed) | FastQC, Nanoplot, Seqkit stats | 0.12.1, 1.46.1, 2.9.0 |
| | 4. Assembly | Flye | 2.9.5 |
| | 5. Taxonomy Identification | Gambit, Kraken2 | 1.1.0, 2.1.5 |
| | 6. Polishing (Optional) | Pilon, Racon | 1.24, 1.5.0 |
| | | | |
| **Nanopore reads** | **Assembly Module** | | |
| | 1. Quality Assessment (Raw) | FastQC, Nanoplot, Seqkit stats | 0.12.1, 1.46.1, 2.9.0 |
| | 2. Quality Control & Trimming | HiFiAdaptFilt, Chopper | 3.0.0, 0.9.0 |
| | 3. Quality Assessment (Trimmed) | FastQC, Nanoplot, Seqkit stats | 0.12.1, 1.46.1, 2.9.0 |
| | 4. Assembly | Flye | 2.9.5 |
| | 5. Taxonomy Identification | Gambit, Kraken2 | 1.1.0, 2.1.5 |
| | 6. Polishing (Optional) | Nextpolish, Medaka | 1.4.1, 1.8.0 |
| | | | |
| **Illumina reads** | **Assembly Module** | | |
| | 1. Quality Assessment (Raw) | FastQC, Seqkit stats | 0.12.1, 2.9.0 |
| | 2. Quality Control & Trimming | bbduk | 39.18 |
| | 3. Quality Assessment (Trimmed) | FastQC, Seqkit stats | 0.12.1, 2.9.0 |
| | 4. Assembly | Unicycler, Spades | 0.5.1, 4.1.0 |
| | 5. Taxonomy Identification | Gambit, Kraken2 | 1.1.0, 2.1.5 |
| | 6. Polishing (Optional) | Pilon, Racon | 1.24, 1.5.0 |
| | | | |
| **Assembled Genome** | **Conversion Module** | | |
| | Convert file formats to FASTA | Any2fasta | 0.4.2 |
| | | | |
| **All Data** | **Assembly Quality Assessment Module** | | |
| | Quality assessment | CheckM2, BUSCO, QUAST | 1.1.0, 5.8.3, 5.3.0 |
| | | | |
| | **Annotation Module** | | |
| | 1. Genome annotation | Bakta, Prokka | 1.10.4, 1.14.6 |
| | 2. AMR gene detection | RGI, AMRFinderPlus | 6.0.3, 3.12.8 |
| | 3. Virulence gene detection | Abricate | 1.0.1 |
| | 4. Plasmid detection | Mobsuite | 3.1.9 |
| | 5. MLST detection | tseemann/MLST | 2.23.0 |
| | | | |
| | **Visualization Module** | | |
| | 1. Circular genome view | Cgview | 2.0.3 |
| | 2. Assembly graph view | Bandage | 0.9.0 |
| | *If SAM file, convert to BAM* | SAMTOOLS | 1.21 |
| | 3. Read alignment coverage | tinycov | 0.4.0 |
| | 4. MLST distribution (pie chart) | Custom Python script | Python v3.12 |
| | 5. Heatmap of genes in common | Custom Python script | Biopython v1.81 |
| | 6. Plasmids and their lengths | Custom Python script | Pandas v2.0.0 |
| | 7. Number of reads and Average read quality | Custom Python script | Seaborn v0.12.0 |
| | 8. Binary heatmap of AMR/virulence genes | Custom Python scripts | Pandas v2.0.0 |
| | | | |
| | **Database Download Module** | | |
| | 1. Bakta database | | 1.10.4 |
| | 2. AMRFinderPlus database | | 3.12.8 |
| | 3. CheckM2 database | | 14897628 |
| | 4. RGI database | | 6.0.3 |
| | 5. Busco database | | 5.8.3 (eukaryota_odb10) |
| | 6. Kraken2 database | | 8gb standard Kraken2 database |
| | 7. Gambit database | | 1.0 |

### Output directory organization
Upon successful completion of the pipeline, the resutls will be stored, per sample, within the output directory set by --outputdir
**Output directory structure for one sample (polish enabled and performed)**

```
customVisualizations
├── heatmaps/bar graphs/pie charts/.csv's of the data
NANOPORE08720179/
├── Annotation/
│   ├── AbricateVFDB/          # *.txt
│   ├── AmrfinderPlus/         # *.tsv
│   ├── Bakta/                 # *.embl, *.faa
│   ├── MLST/                  # *.tsv
│   ├── Mobsuite/              # *.fasta, *.txt
│   ├── Prokka/                # *.faa, *.gbk
│   └── RGI/                   # *.json, *.txt
├── Assembly/
│   └── FLYE/                  # *.fasta.gz, *.gfa.gz
├── AssemblyQA/
│   ├── Busco/                 # *.json, *.txt
│   ├── Checkm2/               # *.tsv
│   └── quast/                 # *.html, *.pdf
├── filteredreadQA/
│   ├── fastqc/                # *.html, *.zip
│   ├── nanoplot/              # *.html, *.png
│   └── seqkit/                # *.tsv
├── polished/
│   └── nextpolish/            # *.fasta, *.stat
├── readQA/
│   ├── fastqc/                # *.html, *.zip
│   ├── nanoplot/              # *.html, *.png
│   └── seqkit_stats/          # *.tsv
├── readQC/
│   ├── chopper/               # *.fastq.gz
│   └── porechop/              # *.fastq.gz, *.log
├── taxonomy/
│   ├── gambit/                # *.csv
│   └── kraken2/               # *.txt, *.fastq.gz
└── visualizations/
    ├── bandage/               # *.png, *.svg
    ├── cgview/                # *.svg
    └── tinycov/               # *.png
```

Custom visualizations are stored at the same level as per-sample directories. These custom visualizations are cross-sample comparisons between all samples. Custom visualizations also come with a csv containing all the same data for further analysis and flexibility in creating visualizations for the user. 

### Visual outputs of the pipeline: Visualization Module
This pipeline generates multiple visual outputs to support analysis and quality control of genomic, assembly, and coverage data. Visualizations are produced using both custom Python scripts and pre‑existing bioinformatics tools. Our custom Python-based visualizations focus on cross-sample comparative analysis, enabling multi-sample insights that pre-made tools cannot easily provide. The pipeline generates eight complementary cross-sample visualizations:

<img alt="image" src="https://raw.githubusercontent.com/Sylvial-00/bactiseq/refs/heads/dev/docs/images/customVisuals.png" />

**(A) Plasmid Distribution** - Bar graph showing plasmids per sample, colored by plasmid type with plasmid length on y-axis

**(B) AMR Gene Counts** - Interactive bar graph of antimicrobial resistance genes detected per sample (hover reveals gene lists)

**(C) Sequencing Quality Overview** - Bar graph showing average nucleotide quality and read count per sample

**(D) MLST Distribution** - Pie chart displaying sequence type frequencies across the sample set

**(E) RGI AMR Presence Matrix** - Binary heatmap showing presence/absence of AMR genes detected by RGI

**(F) AMRFinderPlus AMR Presence Matrix** - Binary heatmap showing presence/absence of AMR genes detected by AMRFinderPlus

**(G) Virulence Factor Matrix** - Binary heatmap showing presence/absence of virulence genes

**(H) Gene Similarity Clustering** - Heatmap showing gene content similarity between all samples

The visualizatoin module also incorporates pre-made tools to generate visualizations. These tools, CGview, Tinycov, and Bandage are wrapped within our pipeline.

<img alt="image" src="https://raw.githubusercontent.com/Sylvial-00/bactiseq/refs/heads/dev/docs/images/visualizations.png" />

**(A) Circular Genome Maps: CGview** - Annotated circular genome visualization created by CGview with gene labels enabled, saved as zoomable SVG files

**(B) Coverage Plots: Tinycov** - Coverage visualization of BAM files using Tinycov, showing average coverage and window distribution for each reference sequence

**(C) Assembly Graphs Bandage** - De novo assembly graph visualization created by SPAdes and rendered with Bandage, depicting contig connectivity and assembly structure

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
