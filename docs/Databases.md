---
layout: default
title: BactiSeq Databases
nav_order: 4
---


<link rel="stylesheet" href="custom.css">

BactiSeq: Databases

# Database Configuration

## Introduction
Databases are fundamental for genomic analysis, and Bactiseq's customizable database parameters provide critical flexibility that enhances the pipeline's applicability across diverse research contexts. This functionality enables researchers to:

- Utilize specific databases to maintain consistency with previously executed analyses
- Optimize database size and scope when computational resources are limited
- Customize analyses for specific organisms or research questions

The pipeline automatically downloads default databases and stores them in a the path specified --db_path or default, saves to the current directory under Databases/

## Default Database Versions
When no custom database paths are provided, Bactiseq downloads the following default versions:

1. **Bakta database** - v1.10.4
2. **AMRFinderPlus database** - v3.12.8
3. **CheckM2 database** - v14897628
4. **RGI database** - v6.0.3
5. **Busco database** - v5.8.3 (`eukaryota_odb10`)
6. **Kraken2 database** - 8GB standard database
7. **Gambit database** - v1.0

## Database Parameters

| Parameter | Description | Default Value | Resources |
|-----------|-------------|---------------|-----------|
| **db_path** | Database storage directory for databases downloaded through pipeline | `"./Databases"` | custom local path |
| **bakta_db** | Path to Bakta annotation database | `null` | [https://zenodo.org/records/14916843](https://zenodo.org/records/14916843) |
| **amr_db** | Path to AMRFinderPlus database | `null` | [https://github.com/ncbi/amr/wiki/AMRFinderPlus-database](https://github.com/ncbi/amr/wiki/AMRFinderPlus-database) |
| **card_db** | Path to RGI database for AMR genes | `null` | [https://github.com/arpcard/rgi/blob/master/docs/rgi_load.rst](https://github.com/arpcard/rgi/blob/master/docs/rgi_load.rst) |
| **checkm2_db** | Path to CheckM2 database | `null` | [https://zenodo.org/records/14897628](https://zenodo.org/records/14897628) |
| **checkm2_ver** | Version of database that will be downloaded if no path is given | `14897628` | [https://zenodo.org/records/14897628](https://zenodo.org/records/14897628) |
| **busco_db_type** | Type of database that the Busco database contains | `"eukaryota_odb10"` | [https://busco.ezlab.org/](https://busco.ezlab.org/) |
| **busco_db** | Path to Busco database | `null` | [https://busco.ezlab.org/](https://busco.ezlab.org/) |
| **kraken2_db** | Path to Kraken2 database | `null` | [https://benlangmead.github.io/aws-indexes/k2](https://benlangmead.github.io/aws-indexes/k2) |
| **gambit_db** | Path to gambit database | `null` | [https://gambit-genomics.readthedocs.io/en/latest/databases.html#database-releases](https://gambit-genomics.readthedocs.io/en/latest/databases.html#database-releases) |

If a different version fo the database is wanted, the path to the manually downaded database can be set in nextflow.config file of the pipeline. This allows researchers to utilize specific database to maintain consistency with potentially previously executed
analyses or optimize database size and scope if computational resources are limited.

> ⚠️ **WARNING:** If no basecaller mode is declared, medaka for polishing will default to the model `r1041_e82_400bps_sup_v5.2.0`.

> 💡 **TIP:** To ensure the long read data gets properly identified as either Nanopore or Pacbio. Bactiseq checks for certain file extensions, words within filenames, header data within the reads, and sample names. To ensure the data gets identified correctly - Putting Pacbio in the filename of reads/samplename or Nanopore in read file or samplename is suggested.
