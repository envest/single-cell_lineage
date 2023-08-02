# Download a VCF file from URL, then sort and index as BCF
#
# Steven Foltz
# 2023
#
# Usage: download_sort_index_vcf.sh --url [url] --output [path/to/sample.vcf.gz] --overwrite
# where --url (or -u) is the file's remote URL (required)
#       --output (or -o) is the path to the output file ending in vcf.gz (required)
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
sorted_dir="sorted_BCFs"

# create sorted file name
sample_basename=$(basename ${output_filename})
sample_filename_stem=${sample_basename%*.vcf.gz}
sorted_filename=${sorted_dir}/${sample_filename_stem}.sorted.bcf.gz

# download VCF
if [[ ! -f ${output_filename} | ${overwrite} = "true" ]]; then
	
 	mkdir -p ${output_dir}	
	wget -nc -O ${output_filename} "${url}"

else

	echo ${output_filename} already exists and was not overwritten.

fi

# sort and index BCF
if [[ ! -f ${sorted_filename} | ${overwrite} = "true" ]]; then

	mkdir -p ${sorted_dir}	
	# use --temp-dir ./ because the shared /tmp can be too small for some files
	bcftools sort --temp-dir ./ --output ${sorted_filename} --output-type b ${output_filename}
	bcftools index ${sorted_filename}

else

	echo ${sorted_filename} already exists and was not overwritten.

fi

