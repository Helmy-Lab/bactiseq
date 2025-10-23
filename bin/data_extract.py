#!/usr/bin/env python3
import os
import pandas as pd
import re
import csv
global total_time
from Bio import SeqIO
import json
from data_vis import showData
from collections import Counter
import sys
import numpy as np
from pathlib import Path

def tsv2json(input_file):
    arr = []
    file = open(input_file, 'r')
    a = file.readline()

    # The first line consist of headings of the record
    # so we will store it in an array and move to
    # next line in input_file.
    titles = [t.strip() for t in a.split('\t')]
    for line in file:
        d = {}
        for t, f in zip(titles, line.split('\t')):
            # Convert each row into dictionary with keys as titles
            d[t] = f.strip()

            # we will use strip to remove '\n'.
        arr.append(d)

    return arr
def extract_number(sample_name):
    match = re.search(r'(\d+)', sample_name)
    return int(match.group(1)) if match else float('inf')
def parse_number(e):
    try:
        # Try converting to float
        return float(e)
    except ValueError:
        # Return the original string if it cannot be converted to float
        return e
def process_sample_directories(dir_bakta, dir_rgi, dir_amr, dir_mob, dir_virulence, dir_mlst, dir_seqkit):
    amrcomp = []
    annocomp = []
    insertData = []
    baktaInsert = []
    assemblyData = []
    seqkitdata = []

    #-----iterate through all files with Bakta  info
    for filename in os.listdir(dir_bakta):
        Annotated_assembly_compare_reference(dir_bakta, filename)

    #------Iterate through all DIRECTORIES with plasmid info
    plasmid_recon(dir_mob)
    
    #------iterate through all files from AMRfinderplus and RGI
    txt_files = os.listdir(dir_rgi)
    tsv_files = os.listdir(dir_amr)

    # Create sets of basenames
    txt_basenames = {Path(f).stem for f in txt_files if f.endswith('.txt')}
    tsv_basenames = {Path(f).stem for f in tsv_files if f.endswith('.tsv')}

    # Find common basenames
    common_basenames = txt_basenames.intersection(tsv_basenames)

    # Create pairs, as in match the AMRfinder plus files with the RGI file
    file_pairs = []
    for basename in common_basenames:
        txt_file = basename + '.txt'  #RGI file
        tsv_file = basename + '.tsv'  #AMRFinderPLus file
        file_pairs.append((basename, txt_file, tsv_file))
    for sample_name, rgi, amr in file_pairs:    
        amrcomp = AMR_compare(dir_rgi, dir_amr, amr, rgi, sample_name)

    mlst_compare(dir_mlst)

    for filename in os.listdir(dir_virulence):
        virulence_calculation(dir_virulence, filename)
    for filename in os.listdir(dir_seqkit):
        seqkitdata = seqkitstats(dir_seqkit, filename, seqkitdata)

    #####################------------------------------------#####################
    #####################      P L A S M I D S               #####################
    #####################------------------------------------#####################
    outdata = {'sampleID': sample_name,
               'contigID': contig_name,
               'plasmid_names': plasmid_name,
               'total_chromosome_length': total_length,
               'total_plasmid_lengths': plasmid_lengths,
               'chromosome_contigs': contigs_per_chromosome,
               'chromosome_contig_lengths': chromosome_contig_lengths
               }
    outdf = pd.DataFrame(outdata)
    datavis.show_chromosome_and_plasmid_lengths(outdf)


    #####################------------------------------------#####################
    #####################      SEQKIT READS                  #####################
    #####################------------------------------------#####################
    seqkit = pd.DataFrame(seqkitdata, columns=['file', 'num_seqs', 'sum_len', 'min_len', 'avg_len',
       'max_len', 'Q1', 'Q2', 'Q3', 'sum_gap', 'N50', 'Q20(%)', 'Q30(%)',
       'AvgQual', 'GC(%)'])
    datavis.showReads(seqkit)

    #####################------------------------------------#####################
    #####################      AMR (AMRFINDERPLUS OR RGI)    #####################
    #####################------------------------------------#####################
    amrcompdata = pd.DataFrame(amrcomp, columns = ['Sample', 'Number CARD amr genes', 'CARD genes', 'Number AMRplus genes', 'AMR Genes'])
    datavis.amrcompare(amrcompdata)

    #####################------------------------------------#####################
    #####################      GENOME ANNOTATION  COMPARE    #####################
    #####################------------------------------------#####################

    outdata = {'SampleID': sample_names,
               'Common_between_themselves': num_common,
               'Contig_name_product': contig_names,
               'total_genes': total_genes}

    # outdf = pd.DataFrame(outdata)
    heatmap, heatmap2 = compute_common_genes_heatmap(gene_sets,sample_names)

    datavis.show_heatmap_similar(heatmap)

    #####################------------------------------------#####################
    #####################             MLST                   #####################
    #####################------------------------------------#####################
    datavis.mlst_pie(mlst_count)

    #####################------------------------------------#####################
    #####################             VIRULENCE               #####################
    #####################------------------------------------#####################
    virulenceData = pd.DataFrame(list(zip(virulence_genes.keys(), virulence_genes.values())))
    virulenceData.columns = ['Sample name', 'Sorted Virulence genes']
    virulenceData['Numeric order'] = virulenceData['Sample name'].apply(extract_number)

    virulenceData_sorted = virulenceData.sort_values(by='Numeric order').drop(columns='Numeric order')

    datavis.showVirulence(virulenceData_sorted)



def virulence_calculation(dir_virulence, filename):
    name = Path(filename).stem
    samples.append(str(name))

    text_file_path = os.path.join(dir_virulence, filename)
    if os.path.isfile(text_file_path):
        data = pd.read_csv(text_file_path, sep='\t')

        virulence_genes[str(name)] = []
        for i in data['GENE']:
            virulence_genes[str(name)].append(i)
        virulence_genes[str(name)].sort()
    else:
        print(f"No text file found in {dir_virulence}")

def sampleSheetSize(sampleSheet_dir_path, samplesheetdata):
    '''
    Prints latex table of all the sample sequences in a sample sheet
    :param sampleSheet_dir_path: directory to a samplesheet with all the sequence data
    :param samplesheetdata:
    :return:
    '''
    sizes = []
    sample = []
    file = []
    for item in os.listdir(sampleSheet_dir_path):
        data = pd.read_csv(sampleSheet_dir_path + '/' + item)
        file_name = data['long_fastq'].values[0]
        file_stats = os.stat('.' + file_name)
        sizes.append(file_stats.st_size / (1024 * 1024 * 1024))
        sample.append(data['sample'].values[0])
        file.append(data['long_fastq'].values[0].split('/')[-1])

    df = pd.DataFrame(list(zip(sample,sizes)), columns=['Sample file', 'Size Of file GB'])
    df2 = pd.DataFrame(list(zip(file,sample, sizes)), columns=['Sequenced data file', 'Sample file name','Size Of file GB'])
    df2['Numeric order'] = df2['Sample file name'].apply(extract_number)

    df2_sorted = df2.sort_values(by='Numeric order').drop(columns='Numeric order')
    print(df2_sorted.to_latex(index = False,
                      column_format="|c|c|c|c|",
                      float_format="{:0.2f}".format))

#-------------- COMPARE TOOLS ------------#
def AMR_compare(dir_rgi, dir_amr, amr_filename, rgi_filename, sample_name):
    """
    Compiles the amrfinderplus and RGI amr gene annotations for a pandas dataframe
    :param dir_rgi: directory containing ALL rgi analysis files
    :param dir_amr: directory containing ALL AMRfinderplus files
    :param amr_filename: the specific file we are using amrfinderplus file
    :param rgi_filename: the specific file we are using amrfinderplus file
    :param sample_name: the specific sample we are analyzing
    :return:
    """

    text_CARD = os.path.join(dir_rgi, rgi_filename)
    text_amrplus = os.path.join(dir_amr, amr_filename)
    new = []
    cardgenes = []
    amrgenes = []
    new.append(sample_name)
    with open(text_CARD) as file:
        data = csv.reader(file, delimiter='\t')
        next(data)
        for row in data:
            cardgenes.append(row[8])
        new.append(len(cardgenes))
        new.append(str(cardgenes))

    with open(text_amrplus) as file:
        data = csv.reader(file, delimiter='\t')
        next(data)
        for row in data:
            amrgenes.append(row[5])
        new.append(len(amrgenes))
        new.append(str(amrgenes))
    comp.append(new)
    # print(comp)
    return comp
def seqkitstats(dir_seqkit, filename, data):
    text_porechop = open(filename)
    df = pd.read_csv(text_porechop, sep='\t')
    sample = df[['file','num_seqs', 'sum_len', 'min_len', 'avg_len', 'max_len', 'Q1', 'Q2', 'Q3', 'sum_gap', 'N50', 'Q20(%)', 'Q30(%)','AvgQual', 'GC(%)']].values
    for i in sample:
        data.append(i)
    return data
def plasmid_recon(mob_dir):
    """
    Gets plamid data if available for each sample
        Prepares data for visualization of plasmid data
    :param mob_dir: folder for the specific samples plasmid data (mobsuite)
    :param filename: FIlename with the output analysis
    :return: Doesn't return anything, just edits lists
    """
    for root, dirs, files in os.walk(mob_dir):
        print(f"\nCurrent directory: {root}")
        print(f"Subdirectories: {dirs}")
        for filename in files:
            file_path = os.path.join(root, filename)
            print(f"  File: {file}")
            if 'contig_report.txt' in filename:

                name = root
                # name = p.parents[2].name

                sample_name.append(name)
                data = pd.read_csv(file_path, sep='\t')
                chromosome_data = data[data['molecule_type'] == 'chromosome']
                contigs_per_chromosome.append(len(chromosome_data['contig_id'].unique()))
                chromosome_contig_lengths.append(list(chromosome_data['size']))
                print(chromosome_data)
                data = data[data['primary_cluster_id'] != '-']
                plasmid_set.append(data['primary_cluster_id']) #set of plasmids per genome
                plasmid_name.append(tuple(data['primary_cluster_id'])) #append a tuple of data comprising of all the plasmids found in a single genome
                contig_name.append(tuple(data['contig_id']))
            if 'chromosome.fasta' in filename:
                total_count = 0
                for record in SeqIO.parse(file_path, "fasta"):
                    # Add the length of the sequence to the total count
                    total_count += len(record.seq)
                total_length.append(total_count)
            if 'mobtyper_results' in filename:
                plasmid_df = pd.read_csv(file_path, sep='\t')
                plasmid_df['extracted_name'] = plasmid_df['sample_id'].str.split(':').str[1]
                plasmid_lengths.append(tuple(data['size']))


def Annotated_assembly_compare_reference(directory, filename):
    """
    Takes in every annotated file, one at a time
    """
    def find_common_products_among_all(gene_sets):
        """
        Find common genes (names or produict, depending on what you change below) between samples
        :param gene_sets: set of all genes
        :return:
        """
        # Start with the set of products from the first gene set
        if not gene_sets:
            print("No gene sets available.")
            return
        # Initialize common products with the first gene set
        common_products = set()
        # Collect all unique products from all gene sets
        for df in gene_sets:
            common_products.update(df['Gene'])

        for df in gene_sets:
            # Create a set of products for the current gene set
            current_products = set(df['Gene'])
            # Keep only products that are present in both common_products and current_products
            common_products.intersection_update(current_products)

        # Print common products and their count
        # print(f"Common Products: {common_products}")
        # print(f"Number of common products AMONG ALL SETS: {len(common_products)}")

        # Print results
        # print(f"Common Products among all gene sets: {common_products}")
        # print(f"Number of common products among ALL SETS: {num_common_products}")
        # Print differences
        for index, gene_set in enumerate(gene_sets):
            products_current_set = set(gene_set['Gene'])
            # Calculate and print the difference from common products
            unique_products = products_current_set - common_products
            # print(f"Differences for gene set {index + 1}: {unique_products}")
        return len(common_products)

    remade_file_path = 'Remade_annotation_file.tsv'
    if '.tsv' in filename and 'hypothetical' not in filename:
        name = Path(filename).stem

        sample_names.append(name)
        with open(os.path.join(directory, filename), 'r') as file:
            lines = file.readlines()[5:]  # Skip the first 5 lines

        # Write the remaining lines back to the remade file
        with open(remade_file_path, 'w') as file:
            file.writelines(lines)

        # Create the DataFrame using the processed data
        df = pd.read_csv(remade_file_path, sep='\t')

        # Filter the DataFrame to remove rows with NaN in 'Gene' or 'Product'
        # and rows where 'Product' contains 'hypothetical'
        total_genes.append(len(df))
        filtered_df = df
        filtered_df1 = df.dropna(subset=['Gene'])  # Remove NaNs a separate filter

        filtered_df = filtered_df[~filtered_df['Product'].str.contains('hypothetical', case=False, na=False)] #filter out hypothetical proteins
        # Append the filtered DataFrame to gene_sets
        gene_sets.append(filtered_df[['Gene', 'Product']])
        contig_names.append(filtered_df[['#Sequence Id', 'Product']])
        removed_Nan_gene_names.append(filtered_df1[['Gene', 'Product']])


    Number_common_genes = find_common_products_among_all(gene_sets)
    num_common.append([Number_common_genes] * len(sample_names),)
def compute_common_genes_heatmap(gene_sets, genome_names):
    # Initialize an empty matrix for the number of common genes
    n = len(gene_sets)
    common_genes_matrix = np.zeros((n, n), dtype=int)
    jaccard_matrix = np.zeros((n, n), dtype=float)
    jaccard_with_duplicates_matrix = np.zeros((n, n), dtype=float)
    # Calculate pairwise common genes
    for i in range(n): # for index for each genome
        for j in range(n): #for index for each genome
            # Find intersection of genes between genome i and genome j
            genes_i = set(gene_sets[i]['Gene'])
            genes_j = set(gene_sets[j]['Gene'])
            # Convert to sets for standard operations
            genes_i_set = set(genes_i)
            genes_j_set = set(genes_j)
            # Standard Jaccard index the set of genes shared between 2 genomes (intersect), divided by the total number of genes in either of the genomes (union)
            intersection_size = len(genes_i_set.intersection(genes_j_set))
            union_size = len(genes_i_set.union(genes_j_set))
            jaccard_matrix[i, j] = intersection_size / union_size if union_size > 0 else 0

            # Jaccard index considering duplicates
            combined = Counter(genes_i) + Counter(genes_j)
            intersection_with_duplicates = sum((Counter(genes_i) & Counter(genes_j)).values())
            union_with_duplicates = sum(combined.values())

            jaccard_with_duplicates_matrix[i, j] = (
                intersection_with_duplicates / union_with_duplicates if union_with_duplicates > 0 else 0
            )

            # Convert matrices to DataFrames for visualization
        jaccard_df = pd.DataFrame(jaccard_matrix, index=genome_names, columns=genome_names)
        jaccard_with_duplicates_df = pd.DataFrame(
            jaccard_with_duplicates_matrix, index=genome_names, columns=genome_names
        )
    return jaccard_df, jaccard_with_duplicates_df

def mlst_compare(MLST_folder):
    """
    Counts MLST types for each sample given the specific samples MLST directory
    :param MLST_folder: folder with all files
    :return:
    """
    for filename in os.listdir(MLST_folder):
        if '.tsv' in filename:
            data = pd.read_csv(MLST_folder + '/' + filename, sep='\t', header = None)

            entry = str(data.iloc[0, 1]) + "_ST" + str(data.iloc[0, 2])  # First row, columns 1 and 2
            if entry in mlst_count:
                mlst_count[entry] += 1
            else:
                mlst_count[entry] = 1



if __name__ == "__main__":
    samples = []
    plasmid_set = []
    plasmid_name = []
    contig_name = []
    sample_name = []
    total_length = []
    contigs_per_chromosome = []
    chromosome_contig_lengths = []
    plasmid_lengths = []
    virulence_genes = {}



    sample_names = []
    removed_Nan_gene_names = []
    gene_sets = []
    total_genes = []
    contig_names = []
    num_common = []

    mlst_count = {}
    # #
    datavis = showData()

    dir_bakta = sys.argv[1]
    dir_rgi = sys.argv[2]
    dir_amr = sys.argv[3]
    dir_mob = sys.argv[4]
    dir_virulence = sys.argv[5]
    dir_mlst = sys.argv[6]
    dir_seqkit = sys.argv[7]
    process_sample_directories(dir_bakta, dir_rgi, dir_amr, dir_mob, dir_virulence, dir_mlst, dir_seqkit)

