#!/bin/bash
# grace_vcf_parse_for_VEP.sh
usage(){
    echo \
"
# ######################################################################################################################################################
#
# USAGE: ${0} \\
#                                                 -a chromosome 
#
# INPUT01: -a FLAG Label (a single specific chromosome supplied as follows: chr1 or chrY for example)
# This script is used to generate a vcf file which contains only the variants that pass gnomADv3.1.2 hard QC filters without the
# additional INFO field. This field is not required for Ensembl VEP to generate fasta sequences for the variants which is the
# objective of this process.
# ######################################################################################################################################################
"
}

while getopts :a: option;do
    case $option in
        a) nameA=$OPTARG;;
        :) echo -e "\nInvalid option: $OPTARG requires an argument" 1>&2;;
        \?)echo -e "\nInvalid option: $OPTARG requires an argument" 1>&2;;
        *) usage && exit 1;;
    esac
done

if [[ $# -eq 0 ]];then
    usage;
    exit 0;
fi

va=${nameA};

# Make .gz copies of the original gnomADv3.1.2 variation files. You could simply rename them to .gz
# However, if you need to work with Hail or vcftools you might prefer to work with the .bgz files.
cp gnomad.genomes.v3.1.2.sites.{$va}.vcf.bgz gnomad.genomes.v3.1.2.sites.{$va}.vcf.gz

# Use the nohup command to stop your processes coming to stop when working on a super computer cluster.
# Using zgrep to operate on compressed files and save on disk space as well.

nohup zgrep "PASS" gnomad.genomes.v3.1.2.sites.{$va}.vcf.gz |\
    zgrep "protein_coding" |\
    zgrep -E "rs[0-9]++" |\
    awk '{print $1, $2, $3, $4, $5, $6, $7}' >> {$va}_PASS_protein_coding_rsID.vcf

exit 0

# The output file becomes the input file for Ensembl VEP. Rather than simply annotating the variants, fasta files of
# the variants will be generated. These in turn become the input for InterProScan annotation and for clustering
# with CD-HIT.
