---
layout: default
title: Home
nav_order: 1
description: "BactiSeq - Bacterial whole genome analysis pipeline"
permalink: /
---
# BactiSeq: Introduction
Bactiseq is a bacterial isolate whole genome sequence analysis pipeline. Bactiseq delivers analysis from Read quality analysis all the way through to gene comparision between samples. BactiSeq accepts reads from PacBio HiFi in the form of Fastq and BAM files, Nanopore reads, and Illumina reads. BactiSeq is capabale of Hybrid assembly or Long read/Short read only assembly.

![bactiseq workflow visualization](https://raw.githubusercontent.com/Sylvial-00/bactiseq/refs/heads/dev/docs/images/Bacterial%20Genomics%20Pipeline.png)

# BactiSeq: Documentation

BactiSeq documentation is split into the following pages:
- [Getting started](GettingStarted.md)
  - An overview on the pre-requisites, and how to install and use the pipeline
- [BactiSeq Databases](Databases.md)
  - An overview on the type of databases necessary for the pipeline to run 
- [Usage](usage.md)
  - An overview of how the pipeline works, how to run it and a description of all of the different command-line flags.
- [Output](output.md)
  - An overview of the different results produced by the pipeline and how to interpret them.

You can find a lot more documentation about installing, configuring and running nf-core pipelines on the website: [https://nf-co.re](https://nf-co.re)
