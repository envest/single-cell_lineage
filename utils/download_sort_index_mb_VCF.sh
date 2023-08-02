# Download VCF files from Mission Bio website
# Sort and index BCFs
# Select SNPs and targeted variants
#
# Steven Foltz
# 2023
#
# Usage: download_mb_vcf_files.sh --links_file mb_vcf_download_links.tsv --snps_file SNPs.tsv --targets_file targets.tsv --n_cells_file vcf_n_cells.tsv
# where --links_file is a TSV file with patient, stage, mrd_pool, mb_filename, and mb_link columns
#       --snps_file is a single column input file (no header) of SNP positions (chr:pos)
#       --targets_file is a single column input file (no header) of target positions (chr:pos)
#       --n_cells_file is an output file tracking the number of cells associated with each sample
#	--fasta reference file

#!/bin/bash
set -euo pipefail

# set directory paths
raw_dir="VCF_raw"
sorted_dir="BCF_sorted"
snps_dir="BCF_SNPs"
targets_dir="BCF_targets"

mkdir -p ${raw_dir} ${sorted_dir} ${snps_dir} ${targets_dir}

# set default input file paths
links_file="mb_vcf_download_links.tsv"
snps_file="SNPs.tsv"
targets_file="targets.tsv"
fasta="/mnt/isilon/tan_lab/foltzs/reference/genome/hg19.fa"

# set default output file paths
n_cells_file="vcf_n_cells.tsv"

# allow for alternative input file paths
while [ $# -gt 0 ]; do
    if [[ $1 == *'--'* ]]; then
        v="${1/--/}"
        declare $v="$2"
    fi
    shift
done

if [[ ! -f ${links_file} ]]; then

  echo Input links_file ${links_file} does not exist.
  exit 1

fi

echo patient stage mrd_pool n_cells | tr ' ' '\t' > ${n_cells_file}

n=0
n_total=$(wc -l ${links_file} | cut -f1 -d' ')

while read patient stage mrd_pool mb_filename mb_link; do

	n=$((n+1))
	echo ${n} out of ${n_total}

	# skip over column name row
	[[ ${patient} =~ ^patient ]] && continue

	# skip if mb_filename is NA
	[[ ${mb_filename} =~ NA ]] && continue

	# download VCF from Mission Bio
	if [[ ! -f ${raw_dir}/${mb_filename} ]]; then
	       
		wget -nc -O ${raw_dir}/${mb_filename} "${mb_link}"

	fi

	sample_basename=$(basename ${mb_filename})
	sample_filename_stem=${sample_basename%*.vcf.gz}
	sorted_filename=${sample_filename_stem}.sorted.bcf.gz
	snps_filename=${sample_filename_stem}.SNPs_only.bcf.gz
	targets_filename=${sample_filename_stem}.targets_only.bcf.gz

	# sort and index VCF --> VCF
	if [[ ! -f ${sorted_dir}/${sorted_filename} ]]; then
	
		echo Sorting and indexing ${sample_filename_stem}
		bcftools sort --temp-dir ./ --output ${sorted_dir}/${sorted_filename} --output-type b ${raw_dir}/${mb_filename}
		bcftools index ${sorted_dir}/${sorted_filename}

	fi

	# select SNPs only
	if [[ ! -f ${snps_dir}/${snps_filename} ]]; then

		bcftools view --output-type b --output ${snps_dir}/${snps_filename} --targets-file SNP_regions.tsv ${sorted_dir}/${sorted_filename}
		bcftools index ${snps_dir}/${snps_filename}

	fi

	# select targets only
	if [[ ! -f ${targets_dir}/${targets_filename} ]]; then

		bcftools view --output-type b --output ${targets_dir}/${targets_filename} --targets-file target_regions.tsv ${sorted_dir}/${sorted_filename}
	        bcftools index ${targets_dir}/${targets_filename}

	fi

	# get n_cells
	n_cells=$(bcftools view -h ${snps_dir}/${snps_filename} | grep CHROM | cut -f10- | tr '\t' '\n' | wc -l)
	echo ${patient} ${stage} ${mrd_pool} ${n_cells} | tr ' ' '\t' >> ${n_cells_file}

done < ${links_file}

