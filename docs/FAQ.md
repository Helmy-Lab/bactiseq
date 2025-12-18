---
layout: default
title: FAQ
nav_order: 6
---

# Bactiseq potentail FAQ

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

# Frequently Asked Questions (FAQ)

## ❓ Bakta/AMRFinderPlus/RGI/Busco/Kraken2/Gambit didn’t run. What went wrong?
Ensure that the path to the required database is correct and accessible from your execution environment.

---

## ❓ The Custom Visualization didn't run?
If an annotation didn't run (Bakta/AMRFinderPlus/RGI), the custom visualization won't run as it can't find the necessary files.
You may have to re-run the analysis.

---

## ❓ The pipeline failed with an “Out of memory” error
This indicates insufficient allocated memory.  
Edit the `base.config` file to ensure resource requests (RAM and CPUs) do not exceed the available resources on your system or HPC allocation.

---

## ❓ How long will my analysis take?
Runtime depends on several factors, including:
- Input data type (Illumina, Nanopore, PacBio)
- Number of samples
- Assembly and polishing strategy
- Available computational resources  

As a result, runtimes may vary substantially between runs.

---

## ❓ What does the PLATO profile include?
The PLATO profile binds the pipeline to the system temporary directory.  
This is required to ensure proper access to intermediate files and prevent failures related to restricted filesystem access.

---

## ❓ I can’t run the custom visualization scripts
Ensure execution permissions are enabled for the visualization binaries:

```bash
chmod +x bin/*

Should I trim adapters before running?
 The pipeline includes trimming. Provide raw reads. When considering polishing though, the trimming or quality control step is not included unless a part of the assembly, i.e if polishing a short read illumina assembly with nanopore reads. you may want to trim or qualtiy control before polishing.
```
