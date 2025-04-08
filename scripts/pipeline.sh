#PIPELINE

#Download all the files specified in data/filenames
for url in $(cat /home/vant/Escritorio/Linux/entregablelinux/data/urls)
do
   bash scripts/download.sh $url data
done

#Download the md5 for the data files
for url_md5 in $(cat /home/vant/Escritorio/Linux/entregablelinux/data/urls_md5)
do
   bash scripts/download.sh $url_md5 data
done


# Download the contaminants fasta file, uncompress it, and
# filter to remove all small nuclear RNAs
bash scripts/download.sh $(cat /home/vant/Escritorio/Linux/entregablelinux/data/contaminant_url) res yes "small nuclear"
bash scripts/download.sh $(cat /home/vant/Escritorio/Linux/entregablelinux/data/contaminant_md5) res yes "small nuclear"

# Index the contaminants file
bash scripts/index.sh res/contaminants.fasta res/contaminants_idx

# MD5SUM

find res -type f -exec md5sum {} + > test/testcont.md5
find data -type f -exec md5sum {} + > test/test.md5


# Merge the samples into a single file
for sid in $(ls data/*s_sRNA.fastq.gz | awk -F/ '{print $2}' | awk -F- '{print $1}' | uniq) #TODO
do
   bash scripts/merge_fastqs.sh data out/merged $sid
done

# TODO: run cutadapt for all merged files
mkdir -p out/trimmed

for sid in $(ls out/merged)
do
	cutadapt -m 18 -a TGGAATTCTCGGGTGCCAAGG --discard-untrimmed \
     	-o out/trimmed/"$sid"_trimmed.fastq.gz out/merged/"$sid" > log/"$sid"_log 2>&1
done

# TODO: run STAR for all trimmed files
for fname in out/trimmed/*.fastq.gz
do
    # you will need to obtain the sample ID from the filename
    sid=$(basename "$fname" .fastq.gz)
    mkdir -p out/star/$sid
    STAR --runThreadN 4 --genomeDir res/contaminants_idx \
	--outReadsUnmapped Fastx --readFilesIn "$fname" \
        --readFilesCommand gunzip -c --outFileNamePrefix out/star/$sid
done

# TODO: create a log file containing information from cutadapt and star logs
# (this should be a single log file, and information should be *appended* to it on each run)
# - cutadapt: Reads with adapters and total basepairs
# - star: Percentages of uniquely mapped reads, reads mapped to multiple loci, and to too many loci
# tip: use grep to filter the lines you're interested in

# LOG CUTADAPT

logfile_total="log/log.final"

echo -e "---------- CUTADAPT RESULTS ----------" >> "$logfile_total"
for log in log/*_log
do
	sid=$(basename "$log" _log)
	echo -e "Sample: $sid\n" >> "$logfile_total"
	grep "Reads with adapters" "$log" >> "$logfile_total"
	grep "Total basepairs processed" "$log" >> "$logfile_total"
done

# LOG STAR

echo -e "---------- STAR RESULTS ----------" >> "$logfile_total"

for log in out/star/*_trimmedLog.final.out
do
	sid=$(basename "$log" _trimmedLog.final.out)
	echo -e "Sample: $sid\n" >> "$logfile_total"
	grep "Uniquely mapped reads %" "$log" >> "$logfile_total"
	grep "% of reads mapped to multiple loci" "$log" >> "$logfile_total"
	grep "% of reads mapped to too many loci" "$log" >> "$logfile_total"
done
