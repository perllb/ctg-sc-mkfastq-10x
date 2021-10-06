# ctg-sc-mkfastq-10x 
## Nextflow pipeline for demultiplexing and qc of 10x data with mkfastq. 

- Designed to handle multiple projects in one sequencing run (but also works with only one project)

## Pipeline steps:

Cellranger version: cellranger v6.0 

* `Demultiplexing` (cellranger mkfastq): Converts raw basecalls to fastq, and demultiplex samples based on index (https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/6.0/using/mkfastq).
* `FastQC`: FastQC calculates quality metrics on raw sequencing reads (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). MultiQC summarizes FastQC reports into one document (https://multiqc.info/).
* `multiQC`: Compile fastQC and demux metrics in multiqc report
* `md5sum`: md5sum of all generated files


## Input files

The following files must be in the runfolder to start pipeline successfully.

1. Samplesheet (`CTG_SampleSheet.sc-mkfastq-10x.csv`)

### Samplesheet requirements:

Note: no header! only the rows shown below, starting with the column names.

 | Sample_ID | index | Sample_Project | 
 |  --- | --- | --- |  
 |  Si1 | SI-GA-D9 | proj_2021_012 | 
 |  Si2 | SI-GA-H9 | proj_2021_012 | 
 |  Sample1 | SI-GA-C9 | proj_2021_013 | 
 |  Sample2 | SI-GA-C9 | proj_2021_013 | 

```

The nf-pipeline takes the following Columns from samplesheet to use in channels:

- `Sample_ID` : ID of sample. Sample_ID can only contain a-z, A-Z and "_".  E.g space and hyphen ("-") are not allowed! If 'Sample_Name' is present, it will be ignored. 
- `index` : Must use index ID (10x ID) if dual index. For single index, the index sequence works too.
- `Sample_Project` : Project ID. E.g. 2021_033, 2021_192.
```


### Samplesheet template (.csv)

#### Name : `CTG_SampleSheet.sc-mkfastq-10x.csv`
```
Sample_ID,index,Sample_Project
Si1,Sn1,SI-GA-D9,2021_012
Si2,Sn2,SI-GA-H9,2021_012
Sample3,S3_1,SI-GA-C9,2021_013
Sample4,S2_3,SI-GA-C9,2021_013
``` 


## USAGE NEXTFLOW

1. Clone and build the Singularity container for this pipeline: https://github.com/perllb/ctg-sc-rna-10x/tree/master/container/sc-rna-10x.v6
2. Edit your samplesheet to match the example samplesheet. See section `SampleSheet` below
3. Edit the nextflow.config file to fit your project and system. 
4. Run pipeline 
```
nohup nextflow run pipe-sc-mkfastq-10x.nf > log.pipe-sc-mkfastq-10x.txt &
```

## USAGE DRIVER
- Execute from within runfolder!

### Run with default 
Assumes
- `CTG_SampleSheet.sc-mkfastq-10x.csv` is in runfolder 
- Dual index
```
sc-mkfastq-10x-driver 
```

### Run with single index 
Assumes
- `CTG_SampleSheet.sc-mkfastq-10x.csv` is in runfolder 
```
sc-mkfastq-10x-driver -a
```
### Run with specific samplesheet 
```
sc-mkfastq-10x-driver -s /path/to/my_special_samplesheet.csv
```

## Output:
* ctg-PROJ_ID-output
    * `qc`: Quality control output. 
        * fastqc output (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
        * multiqc output: Summarizing FastQC output and demultiplexing (https://multiqc.info/)
    * `fastq`: Contains raw fastq files from cellranger mkfastq.
    * `ctg-md5.PROJ_ID.txt`: text file with md5sum recursively from output dir root    



## Container
https://github.com/perllb/ctg-sc-rna-10x/tree/master/container/sc-rna-10x.v6

