#!/bin/bash

# List of the name file indecies of the form ‘SRR264/040/SRR26419340/SRR26419340’ as input. 
# The file was made in excel based on data from ENA  

# Create salmon index file beforehand with
# wget ftp://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/cdna/Homo_sapiens.GRCh38.cdna.all.fa.gz
# salmon index -t Homo_sapiens.GRCh38.cdna.all.fa.gz -i human_index

names_file="$1"


mkdir -p quants

while IFS= read -r samp; do
	short_name=$(echo "$samp" | cut -d'/' -f4)

    echo "Sample ${short_name} in progress"

    # Downloading paired-end reads
    curl -C - -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${samp}_1.fastq.gz" -o "${short_name}_1.fastq.gz"
    curl -C - -L "ftp://ftp.sra.ebi.ac.uk/vol1/fastq/${samp}_2.fastq.gz" -o "${short_name}_2.fastq.gz"

    # Checking that the files have been successfully downloaded
    if [[ -f "${short_name}_1.fastq.gz" && -f "${short_name}_2.fastq.gz" ]]; then
	
        # Executing salmon
        salmon quant -i ./human_index_salmon/human_index -l A \
            --softclip \
            -1 "${short_name}_1.fastq.gz" \
            -2 "${short_name}_2.fastq.gz" \
            -p 35 --validateMappings -o "quants/${short_name}_quant"
        
        # Deleting paired fastq.gz files after processing
        rm "${short_name}_1.fastq.gz"
        rm "${short_name}_2.fastq.gz"
    else
        echo 'Error: Failed to download files for sample ${short_name}. Skip.'
    fi

done < "$names_file"

