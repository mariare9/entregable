# This script should index the genome file specified in the first argument ($1),
# creating the index in a directory specified by the second argument ($2).

# The STAR command is provided for you. You should replace the parts surrounded
# by "<>" and uncomment it.

#!/bin/bash

mkdir -p $2

input_fasta=$1
output_dir=$2

# Create output directory if it doesn't exist
echo "Indexing $input_fasta..."
# Generate index files
STAR \
	--runThreadN 4\
	--runMode genomeGenerate\
	--genomeDir $2 \
	--genomeFastaFiles $1\
	--genomeSAindexNbases 9

echo "Indexing complete. Results in $output_dir"

