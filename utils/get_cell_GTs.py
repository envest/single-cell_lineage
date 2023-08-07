# Return genotype info per cell for each record in a BCF
#
# Steven Foltz
# 2023
#
# Usage: get_cell_GTs.py [path/to/sample.bcf.gz] [path/to/output.tsv]
import os
import sys
from pysam import VariantFile

bcf_filename = sys.argv[1]
output_filename = sys.argv[2]

# check bcf file exists

if os.path.isfile(bcf_filename):

    bcf_in = VariantFile(bcf_filename)
    cell_barcodes = list(bcf_in.header.samples)

else:

    sys.exit("BCF file " + bcf_filename + " does not exist.")

#check output file does not exist

if os.path.isfile(output_filename):

    sys.exit("GT file " + output_filename + " already exists and was not overwritten.")

else:

    column_headers = ["chr", "pos", "ref", "alt1", "alt2", "cell_barcode", "genotype", "quality", "alleles", "ref_depth", "alt1_depth", "alt2_depth", "total_depth"]
    output_file = open(output_filename, 'w')
    output_file.write("\t".join(column_headers) + "\n")

# process each variant record

for record in bcf_in.fetch():

    gt_tuples = [sample['GT'] for sample in record.samples.values()]

    tot_depth_list = ["NA" if sample['DP'] is None else sample['DP'] for sample in record.samples.values()]

    if 'AD' in record.samples.values()[0]:
        
        ref_depth_list = [sample['AD'][0] for sample in record.samples.values()]
        alt1_depth_list = [sample['AD'][1] for sample in record.samples.values()]

        if len(record.alts) > 1:
        
            alt2_depth_list = [sample['AD'][2] for sample in record.samples.values()]

        else:

            alt2_depth_list = ["NA"]*len(record.samples.values())

    else:
        
        ref_depth_list = ["NA"]*len(record.samples.values())
        alt1_depth_list = ["NA"]*len(record.samples.values())
        alt2_depth_list = ["NA"]*len(record.samples.values())

    if 'GQ' in record.samples.values()[0]:

        gq_list = [str(sample['GQ']) for sample in record.samples.values()]

    elif 'RGQ' in record.samples.values()[0]:

        gq_list = [str(sample['RGQ']) for sample in record.samples.values()]

    else:

        gq_list = ["NA"]*len(record.samples.values())

    gq_list_na = [gq.replace("None", "NA") for gq in gq_list]

    if record.alts == None:

        ref_alts_list = [record.ref]
        ref_allele = record.ref
        alt1_allele = alt2_allele = "NA"

    else:

        ref_alts_list = [record.ref] + list(record.alts)
        ref_allele = record.ref
        alt1_allele = record.alts[0]

        if len(record.alts) > 1:
            
            alt2_allele = record.alts[1]
        
        else:

            alt2_allele = "NA"

    gt_list = []
    allele_list = []

    for gt_tup in gt_tuples:

        if gt_tup == (None, None):

            gt_list.append("NA")
            allele_list.append("NA")

        else:

            gt_list.append('/'.join([str(g) for g in gt_tup]))

            a1 = ref_alts_list[gt_tup[0]]
            a2 = ref_alts_list[gt_tup[1]]

            # left align ABC/DBC -> A/D
            if len(a1) == len(ref_allele) and a1[1:] == ref_allele[1:]:

                a1 = a1[0]

            if len(a2) == len(ref_allele) and a2[1:] == ref_allele[1:]:

                a2 = a2[0]

            alleles = a1 + "/" + a2
            allele_list.append(alleles)

    variant = str(record.contig) + ":" + str(record.pos)

    for cb,gt,gq,al,rd,ad1,ad2,pd in zip(cell_barcodes, gt_list, gq_list_na, allele_list, ref_depth_list, alt1_depth_list, alt2_depth_list, tot_depth_list):

        output_file.write("\t".join([str(record.contig), str(record.pos), ref_allele, alt1_allele, alt2_allele, cb, gt, gq, al, str(rd), str(ad1), str(ad2), str(pd)]) + "\n")

output_file.close()

