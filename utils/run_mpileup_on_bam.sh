# Run samtools mpileup on a bam at a list of coordinates
#
# Steven Foltz
# 2023
#
# Usage: run_mpileup_on_bam.sh --bam [path/to/sample.bam] --coordinates [path/to/coords.tsv] --output [path/to/output.tsv] --overwrite
# where --bam (or -b)  is the input bam file (required)
#       --coordinates (or -c) is a list of genomic coordinates (assembly must match bam) (required)
#         format: chromosome and position, tab separated, no column names
#       --output (or -o) is the path to the output tsv file (required)
#       --overwrite (or -w) overwrites existing output files (optional)

#!/bin/bash
set -euo pipefail

# set parameter defaults
overwrite="false"

# read command line parameters
while [ $# -gt 0 ] ; do

	case $1 in

		--bam | -b)
			bam_filename="$2"
			shift
			shift
			;;

		--coordinates | -c)
			coordinates_filename="$2"
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

# check that bam exists

[[ ! -f $bam_filename ]] && echo bam file ${bam_filename} does not exist. && exit 1

# check that coordinates exists

[[ ! -f $coordinates_filename ]] && echo Coordinates file ${coordinates_filename} does not exist. && exit 1

# select targets only
[[ -f ${output_filename} && ${overwrite} = "false" ]] && echo Output file ${output_filename} exists and will not be overwritten. && exit 0

# set up output directory
output_dir=$(dirname ${output_filename})
mkdir -p ${output_dir}

# run mpileup
while read chr pos; do
	
	samtools mpileup --region $chr:$pos-$pos --no-output-ins --no-output-ins --no-output-del --no-output-del --no-output-ends -aa ${bam_filename} 2> /dev/null
	
done < ${coordinates_filename} > ${output_filename}

