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
# This script is used to generate annotation for the variants that have passed hard QC filters from gnomAD v3.1.2
# as well as fasta files using the Ensembl VEP ProteinSeqs plugin.
# You have to navigate to the directory where you have installed Ensembl VEP (it will be named /ensembl-vep/ by default)
# This script will then call the shell script that is part of this package to generate the annotation and fasta files.
# The arguments can be changed but in order to do so I recommend you read the Ensembl VEP documentation.
# The fasta output can then be used for downstream analyses, in this case they will be concatenated and fed as input for
# CD-HIT.
# Additionally, the fasta sequences will be used as input for InterProScan in order to annotate the protein product of these
# variants.
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

./vep --input_file ../Experiment_1/Experiment_1/chrX_PASS_protein_coding_rsID.vcf \
      --species homo_sapiens \
      --coding_only \
      --symbol \
      --canonical \
      --protein \
      --uniprot \
      --variant_class \
      --cache \
      --verbose \ 
      --output_file ../Experiment_1/ProteinSeqs_Output/chrX_gnomAD_v3_PASS_Variants.txt \
      --stats_file ../Experiment_1/ProteinSeqs_Output/chrX_gnomAD_v3_PASS_Variants.txt_summary.html \
      --warning_file ../Experiment_1/ProteinSeqs_Output/chrX_gnomAD_v3_PASS_Variants_STDERR.out \
      --plugin ProteinSeqs \

exit 0


      
# ProteinSeqs produces two files called reference.fa and mutated.fa by default. This makes it difficult to run multiple
# vcf files in parallel. In order to avoid overwritting it you should move/rename the output files to the directory
# where your experiment is contained as shown below:
# mv mutated.fa ../Experiment_1/ProteinSeqs_Output/"$va"_mutated.fa
# mv reference.fa ../Experiment_1/ProteinSeqs_Output/"$va"_reference.fa


