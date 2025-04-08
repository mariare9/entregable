# This script should merge all files from a given sample (the sample id is
# provided in the third argument ($3)) into a single file, which should be
# stored in the output directory specified by the second argument ($2).
#
# The directory containing the samples is indicated by the first argument ($1).

mkdir -p $2
cat $1/$3-*.1s* $1/$3-*.2s* > $2/$3.fastq.gz

