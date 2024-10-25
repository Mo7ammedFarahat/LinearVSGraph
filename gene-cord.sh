GName = 'your gene name'
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.chrom.sizes
wget https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_47/gencode.v47.basic.annotation.gff3.gz
zgrep $GName gencode.v47.basic.annotation.gff3.gz |
    awk '$1 == "chr2" && $3 == "gene"' |
    grep gene_type=protein |
    awk -F'\t' '{split($9,a,";"); for(i in a) if(a[i]~/gene_name/) {split(a[i],b,"="); name=b[2]} print $1"\t"$4"\t"$5"\t"name}' | bedtools merge -d 15000 |
  sed 's/chr2/grch38#chr2/g' > hg38.ncbiRefSeq.NEB.coordinates.bed
