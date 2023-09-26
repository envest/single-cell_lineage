# 1. Download, sort, index VCF files from Mission Bio website
# 2. Select SNPs and targets from BCFs
# 3. mpileup scRNA and scATAC bams
#
# Steven Foltz
# 2023
#
# Usage: bash process_VCFs_and_bams.sh --filenames [path/to/filenames.tsv] --hg19_snp_targets [path/to/hg19_snp_targets.tsv] --hg19_somatic_targets [path/to/hg19_somatic_targets.tsv] --hg38_somatic_targets [path/to/GRCh38_somatic_targets.tsv]
# where --filenames (or -f) includes output file names for each sample (required)
#           format (TSV, with header, fill missing data with NA): patient | sample | mb_url | raw_VCF | sorted_BCF | somatic_BCF | SNP_GT | somatic_GT | scRNA_bam | scRNA_mpileup | scATC_bam | scATAC_mpileup
#       --hg19_snp_targets are the SNPs used for pooled sample demultiplexing (optional)
#           format (TSV, no header): chromosome | position
#       --hg19_somatic_targets are the somatic events targeted by the scDNA MB sequencing panel (optional)
#	    format (TSV, no header): chromosome | position
#       --hg38_somatic_targets are lifted over coordinates from hg19_somatic_targets (optional)
#	    format (TSV, no header): chromosome | position

#!/bin/bash
set -euo pipefail

# utils directory
utils_dir="/mnt/isilon/tan_lab/foltzs/single-cell_lineage/utils"

# set default values for optional parameters
hg19_snp_targets="NA"
hg19_somatic_targets="NA"
GRCh38_somatic_targets="NA"

# read command line parameters
while [ $# -gt 0 ] ; do

        case $1 in

                --filenames | -f)
			filenames="$2"
                        shift
                        shift
                        ;;

                --hg19_snp_targets)
                        hg19_snp_targets="$2"
                        shift
                        shift
                        ;;

		--hg19_somatic_targets)
			hg19_somatic_targets="$2"
			shift
			shift
			;;

		--hg38_somatic_targets)
			hg38_somatic_targets="$2"
			shift
			shift
			;;

                *)
                        echo $1 does not match any input option.
                        exit 1
                        ;;

        esac

done

while read patient USI stage pool file_prefix vcf_filename vcf_url loom_filename loom_url scRNA_bam scATAC_bam loom_original_filename BCF_sorted_filename BCF_SNPs_filename BCF_somatic_filename SNP_GT_filename somatic_GT_filename scRNA_mpileup_filename scATAC_mpileup_filename; do

	[[ ${patient} =~ "patient" ]] && continue

	echo ${USI} ${stage}

	if [ ! ${vcf_url} = "NA" ]; then

		bash ${utils_dir}/download_sort_index_VCF.sh --url ${vcf_url} --vcf_output ${vcf_filename} --sorted_output ${BCF_sorted_filename}

	fi

	if [ ! ${hg19_snp_targets} = "NA" ]; then

		bash ${utils_dir}/select_targets_from_BCF.sh --input ${BCF_sorted_filename} --targets ${hg19_snp_targets} --output ${BCF_SNPs_filename}
                python ${utils_dir}/get_cell_GTs.py ${BCF_SNPs_filename} ${SNP_GT_filename}

        fi

	if [ ! ${hg19_somatic_targets} = "NA" ]; then
		
		bash ${utils_dir}/select_targets_from_BCF.sh --input ${BCF_sorted_filename} --targets ${hg19_somatic_targets} --output ${BCF_somatic_filename}
		python ${utils_dir}/get_cell_GTs.py ${BCF_somatic_filename} ${somatic_GT_filename}

	fi

	if [[ ! ${hg38_somatic_targets} = "NA" && ! ${scRNA_bam} = "NA" ]]; then

		bash ${utils_dir}/run_mpileup_on_bam.sh --bam ${scRNA_bam} --coordinates ${hg38_somatic_targets} --output ${scRNA_mpileup_filename}

	fi

	if [[ ! ${hg38_somatic_targets} = "NA" && ! ${scATAC_bam} = "NA" ]]; then

		bash ${utils_dir}/run_mpileup_on_bam.sh --bam ${scATAC_bam} --coordinates ${hg38_somatic_targets} --output ${scATAC_mpileup_filename}
	
	fi
	
done < ${filenames}

