shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

FILES = json.load(open(config['SAMPLES_JSON']))
SAMPLES = sorted(FILES.keys())

TARGETS = []
all_fq = expand("fastq/{sample}_L001_{read}_001.fastq.gz", sample = SAMPLES, read = ["R1", "R2"])
TARGETS.extend(all_fq)

localrules: all

rule all:
    input: TARGETS

def get_sra(wildcards):
    return FILES[wildcards.sample]

rule sra_fetch:
    # input: r1 = lambda wildcards: FILES[wildcards.sample] ## sra ID   ## no input ,only ID is requried, provided via params
    output: ("01_sra/{sample}")
    threads: 1
    params : sraid = get_sra
    log:   "00_log/{sample}_sra"
    shell:
        """
        module load sratoolkit/2.9.6-gcb01
        prefetch  --max-size 60G {params.sraid} -o {output}  2> {log} 
        """


rule fasterq_dump:
    input: "01_sra/{sample}" 
    output: "fastq/{sample}_1.fastq", "fastq/{sample}_2.fastq"
    threads: 1
    params : jobname = "{sample}"
    log:   "00_log/{sample}_fasterq_dump"
    shell:
        """
        module load sratoolkit/2.9.6-gcb01
        fasterq-dump {input}  --split-files -O fastq  2> {log}
        """


rule pigz_compress_r1:  
    input: "fastq/{sample}_1.fastq"
    output: "fastq/{sample}_1.fastq.gz"
    threads: 5
    shell:
        """
        pigz -p 5  {input}
        """

rule pigz_compress_r2:
    input: "fastq/{sample}_2.fastq"
    output: "fastq/{sample}_2.fastq.gz"
    threads: 5
    shell:
        """
        pigz -p 5  {input}
        """

rule rename:
    input: "fastq/{sample}_1.fastq.gz", "fastq/{sample}_2.fastq.gz"
    output: "fastq/{sample}_L001_R1_001.fastq.gz" ,"fastq/{sample}_L001_R2_001.fastq.gz"
    params : sra = {sample}
    shell:
        """
        mv {input[0]} {output[0]}
        mv {input[1]} {output[1]}
        rm -f 01_sra/{params.sra}
        """
