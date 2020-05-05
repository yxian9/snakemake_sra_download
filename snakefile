shell.prefix("set -eo pipefail; echo BEGIN at $(date); ")
shell.suffix("; exitstat=$?; echo END at $(date); echo exit status was $exitstat; exit $exitstat")

configfile: "config.yaml"

FILES = json.load(open(config['SAMPLES_JSON']))
SAMPLES = sorted(FILES.keys())

TARGETS = []
all_fq = expand("fastq/{sample}_L001_{read}_001.fastq.gz", sample = ALL_SAMPLES, read = ["R1", "R2"])
TARGETS.expand(all_fq)

localrules: all

rule all:
    input: TARGETS


rule sra_fetch:
    input:
        r1 = lambda wildcards: FILES[wildcards.sample] ## sra ID 
    output: temp("01_sra/{sample}.sra" 
    threads: 1
    params : jobname = "{sample}"
    message: "fastqc {input}: {threads}"
    log:   "00_log/{sample}_sra"
    shell:
        """
        module load fastqc
        prefetch  -o {output}  {input}  2> {log} 
        """


rule fastq_dump:
    input: "01_sra/{sample}.sra" 
    output: "fastq/{sample}_1.fastq", "fastq/{sample}_2.fastq"
    threads: 1
    params : jobname = "{sample}"
    message: "fastqc {input}: {threads}"
    log:   "00_log/{sample}_fastqc"
    shell:
        """
        module load fastqc
        fastq-dump -o 02_fqc -f fastq --noextract {input} {out}  2> {log}
        """


rule pigz_compress_r1:  
    input: "fastq/{sample}_1.fastq"
    output: "fastq/{sample}_1.fastq.gz"
    threads: 1
    params : jobname = "{sample}"
    message: "fastqc {input}: {threads}"
    log:   "00_log/{sample}_fastqc"
    shell:
        """
        pigz -o 02_fqc -f fastq --noextract {input}  2> {log}
        """

rule pigz_compress_r2:
    input: "fastq/{sample}_2.fastq"
    output: "fastq/{sample}_2.fastq.gz"
    threads: 1
    params : jobname = "{sample}"
    message: "fastqc {input}: {threads}"
    log:   "00_log/{sample}_fastqc"
    shell:
        """
        pigz -o 02_fqc -f fastq --noextract {input}  2> {log}
        """

rule rename:
    input: "fastq/{sample}_2.fastq", "fastq/{sample}_2.fastq.gz"
    output: "fastq/{sample}_L001_R1_001.fastq.gz" ,"fastq/{sample}_L001_R2_001.fastq.gz"
    shell:
        """
        mv {input} {output}
        """
