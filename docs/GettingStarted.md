---
layout: default
title: Getting Started
nav_order: 2
---
<link rel="stylesheet" href="custom.css">


# Installation
{: .no_toc }

## Table of contents
{: .no_toc .text-delta }

## Prerequisites

Before running the BactiSeq pipeline, ensure you have the following installed:

### **Core Requirements**

| Software | Minimum Version | Installation Guide |
|----------|----------------|-------------------|
| **Java** | 8 or higher | [OpenJDK](https://openjdk.org/install/) or `sudo apt install openjdk-11-jre` |
| **Nextflow** | 22.10.0 | See installation methods below |

### **Optional (but recommended)**
- **Docker** or **Singularity** - for containerized execution
- **Conda/Mamba** - for dependency management
- **Git** - for cloning the repository

---

## **Installation**

### **1. Install Nextflow**
[Nextflow's official download and setup page](https://www.nextflow.io/docs/latest/install.html)
### **2. Install a Container engine (recommended)**
[Nextflow's Docker installation guide](https://www.nextflow.io/docs/latest/developer-env.html#:~:text=Select%20Install.-,Docker,that%20allows%20you%20to%20create%2C%20deploy%2C%20and%20manage%20applications%20within%20containers.,-Windows) <br />
[Singularity Official Documentation](https://docs.sylabs.io/guides/3.0/user-guide/installation.html#:~:text=Edit%20on%20GitHub-,Installation,versions%20of%20Singularity%20please%20see%20earlier%20versions%20of%20the%20docs.)

### **3. Install gitGit**
[Official Git Documentation](https://github.com/git-guides/install-git)


## **Running the Pipeline**

### **Using `nextflow run`**

The `nextflow run` command is the primary way to execute Nextflow pipelines. You have several options:

#### **A. From Cloned Repository**
The BactiSeq pipeline is hosted on GitHub at `sylvial-00/bactiseq`. You need to clone it first:
```bash
# Clone the repository to your local machine
git clone https://github.com/sylvial-00/bactiseq.git
# Navigate to your cloned pipeline directory
cd bactiseq

# Run the pipeline
nextflow run main.nf -profile docker or singularity --input samplesheet.csv

# Or specify the config file explicitly
nextflow run -c nextflow.config --input samplesheet.csv
```
#### **B. Directly from github**
```bash
nextflow run https://github.com/sylvial-00/bactiseq --input samplesheet.csv
```

## **Updating the pipeline**
```bash
# Navigate to your pipeline directory
cd /path/to/bactiseq

# Pull the latest changes from GitHub
git pull origin main

# If you're on a different branch
git pull origin develop  # or other branch name

# Then run with updates
nextflow run main.nf --profile docker --input samplesheet.csv
```


