# Select targets from a BCF file and index the output
#
# Steven Foltz
# 2023
#
# Usage: select_targets_from_BCF.sh --input [path/to/sorted.bcf.gz] --targets [path/to/targets.tsv] --output [path/to/targets.bcf.gz] --overwrite
# where --input (or -i) is the path to the sorted and indexed input BCF file ending in .bcf.gz (required)
#       --targets (or -t) is the path to the genomic positions of targets to be selected (required)
#           the targets file should have two tab-separated columns (chromosome and position) and no column headers
#       --output (or -o) is the path to the output file ending in .bcf.gz (required)
#       --overwrite (or -w) overwrites existing output files (optional)

#!/bin/bash
set -euo pipefail

# set parameter defaults
overwrite="false"

# read command line parameters
while [ $# -gt 0 ] ; do

	case $1 in
	
		--input | -i)
			input_filename="$2"
			shift
			shift
			;;

		--targets | -t)
			targets_filename="$2"
			shift
			shift
			;;

	  	--output | -o)
			output_filename="$2"
			shift
			shift
			;;

		--overwrite | -w)
			overwrite="true"
			shift
			;;

		*)
			echo $1 does not match any input option.
			exit 1
			;;

  	esac

done

# set directory paths
output_dir=$(dirname ${output_filename})

# check that input file exist
if [[ ! -f ${input_filename} ]]; then

	echo ${input_filename} does not exist.
	exit 1

fi

# check that targets file exists
if [[ ! -f ${targets_filename} ]]; then

	echo ${targets_filename} does not exist.
	exit 1

fi

# select targets only
if [[ ! -f ${output_filename} || ${overwrite} = "true" ]]; then

	mkdir -p ${output_dir}
	bcftools view --output-type b --output ${output_filename} --targets-file ${targets_filename} ${input_filename}
        bcftools index ${output_filename}

else

	echo ${output_filename} already exists and was not overwritten.

fi

