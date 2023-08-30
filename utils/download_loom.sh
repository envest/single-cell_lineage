# Download a loom file from URL
#
# Steven Foltz
# 2023
#
# Usage: download_loom.sh --url [url] --loom_output [path/to/sample.loom] --overwrite
# where --url (or -u) is the file's remote URL (required)
#       --loom_output is the path to the downloaded loom file ending in .loom
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

	  	--loom_output)
			loom_filename="$2"
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
output_dir=$(dirname ${loom_filename})

# download loom
if [[ ! -f ${loom_filename} || ${overwrite} = "true" ]]; then
	
 	mkdir -p ${output_dir}	
	wget -nc -O ${loom_filename} "${url}"

else

	echo ${loom_filename} already exists and was not overwritten.

fi

