#!/usr/bin/env python3
import seaborn as sns
import matplotlib.pyplot as plt
from collections import Counter
import numpy as np
import matplotlib.ticker as mticker
from matplotlib.ticker import FuncFormatter, ScalarFormatter
import pandas as pd
from matplotlib.table import Table
import matplotlib.colors as mcolors
import matplotlib.patches as mpatches
from matplotlib.colors import ListedColormap
import plotly.graph_objects as go


class showData():

    def showVirulence(self, sheet):
        # Flatten the list of virulence genes and create a unique set
        unique_genes = set(gene for sublist in sheet['Sorted Virulence genes'] for gene in sublist)
        unique_genes_list = list(unique_genes)

        # Initialize a DataFrame for the binary matrix
        binary_matrix = pd.DataFrame(0, index=sheet['Sample name'], columns=unique_genes_list)

        # Mark the presence of each virulence gene
        for idx, genes in enumerate(sheet['Sorted Virulence genes']):
            binary_matrix.loc[sheet['Sample name'][idx], genes] = 1

        # Create heatmap with black and white colors
        plt.figure(figsize=(max(12, len(unique_genes_list) * 0.5), len(binary_matrix) * 0.5))

        sns.heatmap(
            binary_matrix,
            cmap=['white', 'black'],  # 0=white, 1=black
            cbar=False,  # Remove color bar
            linewidths=0.5,
            linecolor='gray'
        )
        
        # Save as CSV
        binary_matrix.to_csv('virulence_presence_absence.csv')
        plt.title('Virulence Genes Presence/Absence')
        plt.tight_layout()
        plt.savefig('virulence_presence_absence.png', dpi=300, bbox_inches='tight')
        plt.close()
    def showReads(self, sheet):
    # Define a discrete color palette
        unique_qualities = sorted(sheet['AvgQual'].unique())
        palette = sns.color_palette("tab10", n_colors=len(unique_qualities))

        # Create a mapping from mean_qual to colors
        color_mapping = {qual: palette[i] for i, qual in enumerate(unique_qualities)}
        colors = sheet['AvgQual'].map(color_mapping)

        # Plot the bar graph
        fig, ax = plt.subplots(figsize=(12, 12))
        bars = ax.bar(sheet['file'], sheet['num_seqs'], color=colors)
        ax.set_xticklabels(sheet['file'], rotation=45, ha='right')
        # Create a legend for the discrete colors
        handles = [
            plt.Line2D([0], [0], marker='o', color='w', markerfacecolor=color_mapping[qual], markersize=10, label=qual)
            for
            qual in unique_qualities]
        ax.legend(handles=handles, title='Mean Quality')

        # Add labels and title
        ax.set_xlabel('Samples')
        ax.set_ylabel('Number of reads')
        ax.set_title('Number of Reads per Sample')
        plt.savefig("Number_Quality_reads_per_sample.png")
        plt.show()

    def amrcompare(self, sheet):
        # Plotting
        # Create figure
        fig = go.Figure()
        # print(sheet.columns)

        # Add bars for CARD DB
        fig.add_trace(go.Bar(
            x=sheet['Sample'],
            y=sheet['Number CARD amr genes'],
            name='CARD DB',
            hovertext=sheet['CARD genes'],  # Add genes data for hover info
            hoverinfo='text+y'
        ))

        # Add bars for AMR+ DB
        fig.add_trace(go.Bar(
            x=sheet['Sample'],
            y=sheet['Number AMRplus genes'],
            name='AMR+ DB',
            hovertext=sheet['AMR Genes'],  # Add genes data for hover info
            hoverinfo='text+y'
        ))

        # Update layout
        fig.update_layout(
            title='AMR database comparison',
            xaxis_title='Sample',
            yaxis_title='AMR genes',
            barmode='group',
            xaxis_tickangle=-45,
            hovermode='x',
            yaxis=dict(
                tickmode='linear',
                tick0=0,
                dtick=1  # Set tick interval to 1 to avoid .5 values
            )
        )


        # Save/Show plot
        # fig.show()

        fig.write_html("amr_database_comparison.html")
        def clean_gene_string(gene_str):
            try:
                # Remove outer quotes/brackets if they exist
                if isinstance(gene_str, str):
                    gene_str = gene_str.strip()
                    if gene_str.startswith('[') and gene_str.endswith(']'):
                        gene_str = gene_str[1:-1]
                    elif gene_str.startswith("'[") and gene_str.endswith("]'"):
                        gene_str = gene_str[2:-2]

                    # Split by commas and clean individual gene names
                    if gene_str:
                        genes = [g.strip().strip("'\"") for g in gene_str.split(',')]
                        return [g for g in genes if g]  # Remove empty strings
            except:
                pass
            return []  # Return empty list for any failures/empty inputs

        # Apply cleaning function
        sheet['CARD_genes_cleaned'] = sheet['CARD genes'].apply(clean_gene_string)
        sheet['AMRplus_genes_cleaned'] = sheet['AMR Genes'].apply(clean_gene_string)
        #Presence/absense matrix or binary heatmap
        # Create presence-absence matrices
        def create_pa_matrix(df, gene_col):
            """
            Creates presence absence table for amr genes
            :param df: dataframe of the amr genes
            :param gene_col: column index/name of gene names
            :return:
            """
            # Get all unique genes
            all_genes = set()
            for gene_list in df[gene_col]:
                    all_genes.update(gene_list)
            pa_matrix = pd.DataFrame(0, index=df['Sample'], columns=sorted(all_genes))
            for sample, gene_list in zip(df['Sample'], df[gene_col]):
                if isinstance(gene_list, list):
                    for gene in gene_list:
                        gene = gene.strip()
                        pa_matrix.loc[sample, gene] = 1
            return pa_matrix

        def plot_pa(matrix, title):
            """
            Plots the presence-absence table of AMR genes from RGI database and AMRFINDER database
            :param matrix: a PA matrix given by create_pa_matrix()
            :param title: title for the table
            :return:
            """
            plt.figure(figsize=(20, 20))
            sns.heatmap(matrix, cmap = ListedColormap(['white', 'black']), cbar=False,
                        linewidths=0.5, linecolor='gray')
            plt.title(f'Presence-Absence: {title} AMR genes')
            plt.xlabel('Genes')
            plt.ylabel('Samples')
            plt.savefig(title + '_database_genes.png')

        card_pa = create_pa_matrix(sheet, 'CARD_genes_cleaned')
        card_pa.to_csv('CARD_database_presence_absence.csv')
        amr_pa = create_pa_matrix(sheet, 'AMRplus_genes_cleaned')
        amr_pa.to_csv('AMRplus_database_presence_absence.csv')

        plot_pa(card_pa, 'CARD ')
        plot_pa(amr_pa, 'AMRplus ')

        # Replace "[]" with "-"
        sheet.replace("[]", "-", inplace=True)

        return
    def show_chromosome_and_plasmid_lengths(self, df):
        """
        Takes in the dataframe created from data from plasmid_recon()
        :param df: dataframe of plasmid data columns: SampleID, contigID, plasmid names tuple, total chromosome length, total plasmid lengths tuple, chromoomse contigs, chromotome contig legnths
        :return: Creates visualizations
        """
        expanded_data = []

        # Iterate over each row in the original DataFrame
        for index, row in df.iterrows():
            sample_id = row['sampleID']
            plasmid_names = row['plasmid_names']
            plasmid_lengths = row['total_plasmid_lengths']

            # Create a new entry for each plasmid name and its length
            for name, length in zip(plasmid_names, plasmid_lengths):
                expanded_data.append({'sampleID': sample_id, 'plasmid_name': name, 'plasmid_length': length})

        # Create a new DataFrame from the expanded data
        expanded_df = pd.DataFrame(expanded_data)
        # Pivot the DataFrame to get lengths with samples as rows and plasmids as columns
        pivot_df = expanded_df.pivot_table(index='sampleID', columns='plasmid_name', values='plasmid_length',
                                           fill_value=0)

        ###SAVE THE PLASMID DATA AS A CSV
        pivot_df.to_csv("Plasmid_length_per_sample.csv")

        # Get the sample IDs and plasmid names
        samples = pivot_df.index.tolist()
        plasmids = pivot_df.columns.tolist()

        x = np.arange(len(samples))
        width = 0.8  # Fixed width per sample group
        bar_width = 0.15  # Fixed width for each individual bar

        fig, ax = plt.subplots(figsize=(20, 10), layout='constrained')

        # Create a color map for all plasmids
        colors = plt.cm.tab20(np.linspace(0, 1, min(20, len(plasmids))))
        if len(plasmids) > 20:
            extra_colors = plt.cm.Set3(np.linspace(0, 1, len(plasmids) - 20))
            colors = np.concatenate([colors, extra_colors])
        color_map = {plasmid: color for plasmid, color in zip(plasmids, colors)}

        # Track which plasmids we've already added to legend
        legend_added = set()

        # For each sample, plot bars for its non-zero plasmids with fixed spacing
        for i, sample in enumerate(samples):
            sample_data = pivot_df.loc[sample]
            non_zero_data = sample_data[sample_data > 0]

            # Calculate starting position to center the bars within the sample group
            total_bars_width = len(non_zero_data) * bar_width
            start_pos = i + (width - total_bars_width) / 2

            # Plot each non-zero plasmid for this sample
            for j, (plasmid, length) in enumerate(non_zero_data.items()):
                pos = start_pos + (j * bar_width)
                label = plasmid if plasmid not in legend_added else ""
                legend_added.add(plasmid)
                ax.bar(pos, length, bar_width, color=color_map[plasmid], label=label)

        # Add labels, title, etc.
        ax.set_ylabel('Plasmid Length (base pairs)')
        ax.set_title('Plasmid Lengths per Sample')
        ax.set_xlabel('Sample ID')
        ax.set_xticks(x + width / 2, samples, rotation=45, ha='right')
        ax.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, _: f'{int(x):,}'))
        ax.legend(title='Plasmid Name', bbox_to_anchor=(1.05, 1), loc='upper left', ncol=2)

        #plt.show()
        plt.savefig("plasmids_per_sample.png")
    def show_heatmap_similar(self, df):
        """
        Heatmap visualization of genes in common by sample
        :param df: dataframe of the data needed
        :return: none
        """

        mask = np.zeros_like(df, dtype=bool)
        mask[np.triu_indices_from(mask, k=1)] = True  # Exclude the diagonal
        # Create a masked version of the dataframe
        masked_df = df.where(~mask)  # Replace masked values with NaN

        plt.figure(figsize=(20,20))
        # Save the masked dataframe as a CSV
        masked_df.to_csv("masked_jaccard_index.csv", index=True)
        ax = sns.heatmap(
            df,
            mask=mask,
            annot=True,  # Annotate with the actual values
            fmt=".2f",  # Format values to 2 decimal places
            cmap="Blues",  
            linewidths=0.5,  #
            annot_kws={"size": 8}, # Smaller font size for annotations
            cbar_kws={"label": "Jaccard Index"}  # Label for the color bar
        )
        # Force all x-axis labels to show
        ax.set_xticks(np.arange(len(df.columns)))
        ax.set_xticklabels(df.columns, rotation=45, ha='right', fontsize=8)

        # Force all y-axis labels to show
        ax.set_yticks(np.arange(len(df.index)))
        ax.set_yticklabels(df.index, rotation=0, fontsize=8)
        plt.title('Genes (gene names) in common')
        plt.savefig("Genes_in_common_all_samples(bakta).png")
        # plt.show()
    def mlst_pie(self, dict):
        # Create pie chart
        plt.figure(figsize=(20, 20))
        plt.pie(dict.values(), labels=dict.keys(), autopct='%1.1f%%')
        plt.title('Distribution of sequence types')
        # plt.show()
        plt.savefig("mlst_distribution.png")
