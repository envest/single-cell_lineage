# Convert files between zip formats
#
# Steven Foltz
# May 2023
#
# Usage: convert_zip_file.sh [-i input file] -o [output file] -w [overwrite]

#!/bin/bash
set -euo pipefail


overwrite=false
while getopts 'i:o:w' OPTION; do
  case "$OPTION" in
    i)
      input_file="$OPTARG"
      ;;
    o)
      output_file="$OPTARG"
      ;;
    w)
      overwrite=true
      ;;
    ?)
      echo "script usage: $(basename \$0) [-i input_file] [-o output_file] [-w overwrite]" >&2
      exit 1
      ;;
  esac
done


if [[ ! -f ${input_file} ]]; then
	
	echo Input file ${input_file} does not exist.
	exit 1

fi

if [[ -f ${output_file} && ${overwrite} = false ]]; then

	echo Output file ${output_file} already exists. Set the option -w to overwrite the output file.
	exit 1

fi	

input_filename=$(basename ${input_file})
input_format=${input_filename##*.}

output_filename=$(basename ${output_file})
output_format=${output_filename##*.}

if [[ ${input_format} = "gz" && ${output_format} = "bgz" ]]; then

	zcat ${input_file} | bgzip -c > ${output_file}

elif [[ ${input_format} = "bgz" && ${output_format} = "gz" ]]; then

	bgzip -cd ${input_file} | gzip -c > ${output_file}

else

	echo Check input and output file extensions. One should be gz and the other bgz.
	exit 1

fi


