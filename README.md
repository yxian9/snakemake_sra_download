# snakemake_sra_download

download using the  fasterq-dump and pigz for faster process. 


snakemake -j 10 --cluster-config cluster.json --cluster "sbatch -p common,scaverger -J {cluster.job} --mem={cluster.mem} -N 1 -n {threads} -o {cluster.out} -e {cluster.err} " &> log & 
