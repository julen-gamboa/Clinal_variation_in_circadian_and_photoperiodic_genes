#!/bin/bash                                                                                                                                                                                  
# ProteinSeqs_VEP.sh                                                                                                                                                                         
usage(){
    echo \
"                                                                                                                                                                                            
# ######################################################################################################################################################                                    
#                                                                                                                                                                                            
# USAGE: ${0} \\                                                                                                                                                                             
#                                                 -a chromosome                                                                                                                              
#                                                                                                                                                                                            
# INPUT01: -a FLAG Label (a single specific chromosome supplied as follows: chr1 or chrY for example)                                                                                        
# This script removes all [*] characters introduced by the Ensembl VEP ProteinSeqs plugin before putting them back together into a "clean" FASTA file 
# The ProteinSeqs plugin introduces an asterisk/star at the location where
# a stop codon has been gained. The remainder of the sequence is left unaffected, therefore, the asterisk and the rest of the sequence would correspond
# to the prospective truncation introduced by a stop codon associated with a given variant.
# Tools like CD-HIT and InterProScan do not process FASTA files where asterisks are present, hence the necessity for this step.                                               
#######################################################################################################################################################                                      
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

# First linearise FASTA file
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' < "$va"_mutated.fa > "$va"_linearized.out

# Create a file with all sequences that have not gained a stop codon
awk '!/*[A-Z]*$/' "$va"_linearized.out | tr "\t" "\n" > "$va"_no_stop_gain.fa

# Find the [*] character and delete everything from that point to the end of line, then return output to fasta format and width
grep "*" "$va"_linearized.out | sed 's/*[A-Z]*$//g' | tr "\t" "\n" > "$va"_stop_gain.fa

# concatenate both files into a single chromosome file.
cat "$va"_no_stop_gain.fa "$va"_stop_gain.fa > "$va"_gnomAD_v3_clean_file.fa

# Remove the intermediate files
rm "$va"_linearized.out
rm "$va"_no_stop_gain.fa
rm "$va"_stop_gain.fa

exit 0
