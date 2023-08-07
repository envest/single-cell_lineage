# Run samtools mpileup on a bam at a list of coordinates
#
# Steven Foltz
# 2023
#
# Usage: run_mpileup_on_bam.sh --bam [path/to/sample.bam] --coordinates --output [path/to/output.tsv] --overwrite
# where --bam (or -b)  is the input bam file (required)
#       --coordinates (or -c) is a list of genomic coordinates (assembly must match bam) (required)
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
			coord_filename="$2"
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


