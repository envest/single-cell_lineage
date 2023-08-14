# Download a bam file from URL and index it
#
# Steven Foltz
# 2023
#
# Usage: download_index_bam.sh --url [url] --output [path/to/sample.bam] --overwrite
# where --url (or -u) is the bam file's remote URL (required)
#       --output (or -o) is the path to the output file ending in .bam (required)
#       --overwrite (or -w) overwrites existing output files (optional)

#!/bin/bash
set -euo pipefail

# set parameter defaults
overwrite="false"

# read command line parameters
while [ $# -gt 0 ] ; do

	case $1 in
	
		--url | -u)
			url="$2"
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

# download bam
if [[ ! -f ${output_filename} || ${overwrite} = "true" ]]; then
	
 	mkdir -p ${output_dir}	
	wget -nc -O ${output_filename} "${url}"

else

	echo ${output_filename} already exists and was not overwritten.

fi

# create bam index
if [[ ! -f ${output_filename}.bai || ${overwrite} = "true" ]]; then

	samtools index ${output_filename}

else

	echo ${output_filename}.bai already exists and was not overwritten.

fi

