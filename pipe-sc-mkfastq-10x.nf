#!/usr/bin/env nextFlow

// Base params
runfolder = params.runfolder
basedir = params.basedir
metaid = params.metaid


// Output dirs
outdir = params.outdir
fqdir = params.fqdir
ctgqc = params.ctgqc

// Demux args
b2farg = params.bcl2fastqarg
index = params.index
demux = params.demux

// Read and process CTG samplesheet 
sheet = file(params.sheet)

// create new samplesheet in cellranger mkfastq IEM (--samplesheet) format. This will be used only for demultiplexing
newsheet = "$basedir/samplesheet.nf.sc-mkfastq-10x.csv"

println "============================="
println ">>> sc-mkfastq-10x pipeline for multiple projects / run >>>"
println ""
println "> INPUT: "
println ""
println "> runfolder		: $runfolder "
println "> sample-sheet		: $sheet "
println "> run-meta-id		: $metaid "
println "> basedir		: $basedir "
println ""
println " - demultiplexing arguments "
println "> bcl2fastq-arg        : '${b2farg}' "
println "> demux                : $demux " 
println "> index                : $index "
println ""
println "> - output directories "
println "> output-dir           : $outdir "
println "> fastq-dir            : $fqdir "
println "> ctg-qc-dir           : $ctgqc "
println "============================="


// all samplesheet info
Channel
    .fromPath(sheet)
    .splitCsv(header:true)
    .map { row -> tuple( row.Sample_ID, row.Sample_Project, row.Sample_Species ) }
    .tap{infoall}
    .set { mvfastq_csv }

// Projects
Channel
    .fromPath(sheet)
    .splitCsv(header:true)
    .map { row -> row.Sample_Project }
    .unique()
    .tap{infoProject}
    .set { mqc_cha_init_uniq }

println " > Samples to process: "
println "[Sample_ID,Sample_Name,Sample_Project,Sample_Species,nuclei]"
infoall.subscribe { println "Info: $it" }

println " > Projects to process : "
println "[Sample_Project]"
infoProject.subscribe { println "Info Projects: $it" }

// Parse samplesheet
process parsesheet {

	tag "$metaid"

	input:
	val sheet
	val index

	output:
	val newsheet into demux_sheet

	"""
python $basedir/bin/ctg-parse-samplesheet.10x.py -s $sheet -o $newsheet -i $index
	"""
}

	

// Run mkFastq
process mkfastq {

	tag "$metaid"

	input:
        val sheet from demux_sheet

	output:
	val 1 into moveFastq

	"""
cellranger mkfastq \\
	   --id=$metaid \\
	   --run=$runfolder \\
	   --samplesheet=$sheet \\
	   --jobmode=local \\
	   --localmem=100 \\
	   --output-dir $fqdir \\
	   $b2farg
"""

}

process moveFastq {

    tag "${sid}-${projid}"

    input:
    val x from moveFastq
    set sid, projid, ref from mvfastq_csv

    output:
    val "y" into crCount
    set sid, projid, ref into fqc_ch


    """
    mkdir -p ${outdir}/${projid}
    mkdir -p ${outdir}/${projid}/fastq

    mkdir -p ${outdir}/${projid}/fastq/$sid

    if [ -d ${fqdir}/${projid}/$sid ]; then
        mv ${fqdir}/${projid}/$sid ${outdir}/${projid}/fastq/
    else
	mv ${fqdir}/${projid}/${sid}_S* ${outdir}/${projid}/fastq/$sid/
    fi
    """

}

process fastqc {

	tag "${sid}-${projid}"

	input:
	set sid, projid, ref from fqc_ch	
        
        output:
        val projid into mqc_cha
	val "x" into mqc_cha_init

	"""

        mkdir -p ${outdir}/${projid}/qc
        mkdir -p ${outdir}/${projid}/qc/fastqc

        for file in ${outdir}/${projid}/fastq/${sid}/*fastq.gz
            do fastqc -t ${task.cpus} \$file --outdir=${outdir}/${projid}/qc/fastqc
        done
	"""
    
}

// Project specific multiqc 
process multiqc {

    tag "${projid}"

    input:
    val projid from mqc_cha.unique()
    
    output:
    val projid into multiqc_outch

    script:
    """
    
    cd $outdir/$projid
    multiqc -f ${outdir}/$projid  --outdir ${outdir}/$projid/qc/multiqc/ -n ${projid}_multiqc_report.html

    mkdir -p ${ctgqc}
    mkdir -p ${ctgqc}/$projid

    cp -r ${outdir}/$projid/qc ${ctgqc}/$projid/

    """
}

process multiqc_run {

    tag "${metaid}"

    input:
    val "x" from mqc_cha_init.collect()
        
    output:
    val "x" into summarized

    """
    cd $outdir 
    multiqc -f ${fqdir} --outdir ${ctgqc} -n ${metaid}_run_sc-rna-10x_summary_multiqc_report.html

    """

}

process md5sum {

	input:
	val projid from md5_proj.unique()
	val x from md5_wait.collect()
	
	"""
	cd ${outdir}/${projid}/
	find -type f -exec md5sum '{}' \\; > ctg-md5.${projid}.txt
        """ 

}