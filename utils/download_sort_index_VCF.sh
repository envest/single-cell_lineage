# Download a VCF file from URL, then sort and index as BCF
#
# Steven Foltz
# 2023
#
# Usage: download_sort_index_vcf.sh --url [url] --vcf_output [path/to/sample.vcf.gz] --sorted_output [path/to/sorted.bcf.gz] --overwrite
# where --url (or -u) is the file's remote URL (required)
#       --vcf_output is the path to the downloaded VCF output file ending in .vcf.gz (required)
#       --sorted_output is the path to the sorted BCF output file ending in .bcf.gz (required)
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

	  	--vcf_output)
			vcf_filename="$2"
			shift
			shift
			;;

		--sorted_output)
			sorted_filename="$2"
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
output_dir=$(dirname ${vcf_filename})
sorted_dir=$(dirname ${sorted_filename})

# download VCF
if [[ ! -f ${vcf_filename} || ${overwrite} = "true" ]]; then
	
 	mkdir -p ${output_dir}	
	wget -nc -O ${vcf_filename} "${url}"

else

	echo ${vcf_filename} already exists and was not overwritten.

fi

# sort and index BCF
if [[ ! -f ${sorted_filename} || ${overwrite} = "true" ]]; then

	mkdir -p ${sorted_dir}	
	# use --temp-dir ./ because the shared /tmp can be too small for some files
	bcftools sort --temp-dir ./ --output ${sorted_filename} --output-type b ${vcf_filename}
	bcftools index ${sorted_filename}

else

	echo ${sorted_filename} already exists and was not overwritten.

fi

