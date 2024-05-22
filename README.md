# Comprehensive Genomic Analysis Pipeline for Inherited Diseases

## Authors

Elia Covino & Arianna Rigamonti

## Introduction

Genomic data analysis is crucial for understanding the genetic basis of diseases, especially when dealing with inherited conditions. The `pipeline.sh` script is designed to streamline and automate the process of identifying genetic variants in familial case studies. Developed by Elia Covino & Arianna Rigamonti, this script facilitates the analysis of genomic data for both recessive and dominant diseases, offering a robust framework for researchers and clinicians.

The pipeline integrates several bioinformatics tools to perform tasks such as sequence alignment, variant calling, and quality control. By automating these steps, the script minimizes manual intervention, reduces potential errors, and ensures a consistent analysis workflow. This makes it an invaluable tool for genomic studies, particularly in a clinical or research setting where multiple cases need to be processed efficiently.

## Overview

The `pipeline.sh` script automates multiple steps in the genomic data analysis workflow:

1. **Data Input and Validation**:
   - The script accepts case numbers as input arguments and checks for the existence of corresponding sequencing files.
   - It ensures that the correct input format is used and provides error messages for invalid inputs or missing files.

2. **Alignment of Sequencing Data**:
   - The script utilizes `bowtie2` to align sequencing reads from child, father, and mother samples against a specified reference genome.
   - The alignment process generates SAM files, which are then converted to BAM files and sorted using `samtools` for further analysis.

3. **Variant Calling**:
   - The script employs `freebayes` to call genetic variants from the aligned BAM files.
   - It filters the resultant VCF files based on the inheritance pattern (recessive or dominant), ensuring only relevant variants are retained for further examination.

4. **Coverage Analysis**:
   - Using `bedtools genomecov`, the script generates coverage files to assess the sequencing depth across the genome.

5. **Quality Control**:
   - The script runs `fastqc` to evaluate the quality of raw sequencing reads.
   - It performs BAM file quality control using `qualimap`, providing detailed reports on the alignment quality.

6. **Aggregated Quality Control Reports**:
   - The script uses `multiqc` to compile and aggregate quality control reports, offering a comprehensive view of the data quality across all processed cases.

By automating these processes, the `pipeline.sh` script provides a reliable and efficient method for genomic data analysis, ensuring high-quality results and facilitating the discovery of genetic variants associated with inherited diseases.

## Usage

To execute the script, use the following command format:

```
./pipeline.sh [-AR recessive disease case numbers] [-AD dominant disease case numbers] [-h help]
```

### Example

```
./pipeline.sh -AR 452 453 454 -AD 703 704 705
```

This command will process cases 452, 453, and 454 for recessive diseases and cases 703, 704, and 705 for dominant diseases.

## Script Arguments

- `-AR` : Indicates that the following case numbers correspond to recessive diseases.
- `-AD` : Indicates that the following case numbers correspond to dominant diseases.
- `-h`  : Displays help information.

## Script Workflow

1. **Input Validation**:
   - Checks if any arguments are provided.
   - Displays an error message if no input arguments are found.

2. **Argument Parsing**:
   - Iterates over the provided arguments.
   - Sets the disease type based on the `-AR` or `-AD` flags.
   - Verifies the existence of the case files.

3. **Processing Each Case**:
   - Creates a directory for each case if it does not already exist.
   - Performs the following steps within each case directory:
     1. **Alignment**:
        - Aligns child, father, and mother sequence files using `bowtie2`.
        - Converts and sorts the alignment outputs to BAM files using `samtools`.
     2. **Variant Calling**:
        - Calls variants using `freebayes`.
        - Filters the VCF file based on the disease type (recessive or dominant).
     3. **Coverage Analysis**:
        - Generates coverage files using `bedtools genomecov`.
     4. **Quality Control**:
        - Runs `fastqc` on the raw sequence files.
        - Performs BAM quality control using `qualimap`.
     5. **Aggregated QC**:
        - Uses `multiqc` to compile QC reports.

4. **Error Handling**:
   - Provides error messages for invalid arguments or non-existent case files.

## Dependencies

Ensure the following software and tools are installed and accessible in your environment:

- `bowtie2`
- `samtools`
- `freebayes`
- `bcftools`
- `bedtools`
- `fastqc`
- `qualimap`
- `multiqc`

## File Structure

The script expects the input files to be in the following format:

- `case<case_number>_child.fq.gz`
- `case<case_number>_father.fq.gz`
- `case<case_number>_mother.fq.gz`

These files should be located in the directory specified by `cases_path` (`/home/BCG2024_genomics_exam/` by default).

## Notes

- Modify the `cases_path` variable at the beginning of the script if your input files are located in a different directory.
- The script assumes the existence of an alignment reference (`uni`) and a reference genome (`universe.fasta`) in the `cases_path` directory.
```
