# ctg-sc-mkfastq-10x 
## Nextflow pipeline for demultiplexing and qc of 10x data with mkfastq. 

- Designed to handle multiple projects in one sequencing run (but also works with only one project)

## USAGE

1. Clone and build the Singularity container for this pipeline: https://github.com/perllb/ctg-sc-rna-10x/tree/master/container/sc-rna-10x.v6
2. Edit your samplesheet to match the example samplesheet. See section `SampleSheet` below
3. Edit the nextflow.config file to fit your project and system. 
4. Run pipeline 
```
nohup nextflow run pipe-sc-mkfastq-10x.nf > log.pipe-sc-mkfastq-10x.txt &
```

## Input

- Samplesheet (see `SampleSheet` section below)

### Pipeline steps:

Cellranger version: cellranger v6.0 

* `Demultiplexing` (cellranger mkfastq): Converts raw basecalls to fastq, and demultiplex samples based on index (https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/6.0/using/mkfastq).
* `FastQC`: FastQC calculates quality metrics on raw sequencing reads (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). MultiQC summarizes FastQC reports into one document (https://multiqc.info/).
* `multiQC`: Compile fastQC and demux metrics in multiqc report
* `md5sum`: md5sum of all generated files

### Output:
* ctg-PROJ_ID-output
    * `qc`: Quality control output. 
        * fastqc output (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
        * multiqc output: Summarizing FastQC output and demultiplexing (https://multiqc.info/)
    * `fastq`: Contains raw fastq files from cellranger mkfastq.
    * `ctg-md5.PROJ_ID.txt`: text file with md5sum recursively from output dir root    


### Samplesheet requirements:

Note: no header! only the rows shown below, starting with the column names.

 | Lane | Sample_ID | Sample_Name | index | Sample_Project | 
 | --- | --- | --- | --- | --- |  
 | | Si1 | Sn1 | SI-GA-D9 | proj_2021_012 | 
 | | Si2 | Sn2 | SI-GA-H9 | proj_2021_012 | 
 | | Sample1 | S1 | SI-GA-C9 | proj_2021_013 | 
 | | Sample2 | S23 | SI-GA-C9 | proj_2021_013 | 

```

The nf-pipeline takes the following Columns from samplesheet to use in channels:

- `Sample_ID` ('Sample_Name' will be ignored)
- `Index` (Must use index ID!)
- `Sample_Project` (Project ID)
```


### Container
https://github.com/perllb/ctg-sc-rna-10x/tree/master/container/sc-rna-10x.v6

