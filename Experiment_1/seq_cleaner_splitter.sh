#!/bin/bash
# seq_cleaner_splitter.sh
usage(){
    echo \
"
# ######################################################################################################################################################
#
# USAGE: ${0} \\
#                                                 -a chromosome -b number of lines
#
# INPUT01: -a FLAG Label (a single specific chromosome supplied as follows: chr1 or chrY for example)
# INPUT02: -b FLAG Parameter (number of desired number of lines/sequences per resulting file)
#
# This script removes sequences with empty headers to produce a suitable input for InterProScan.
# First your target FASTA file must be linearised before it can be processed. 
# The script prints all rows that meet a simple condition: rows must not contain an empty FASTA header on field 1.
# In addition to this it splits the output of this operation into multiple files. This makes it easier to dispatch multiple
# smaller jobs with InterProScan. The -l parameter can be adjusted if you wish the split to take place on a smaller number of lines.
# ######################################################################################################################################################
"
}

while getopts :a:b: option;do
    case $option in
        a) nameA=$OPTARG;;
        b) nameB=$OPTARG;;
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
vb=${nameB};

# Print all lines that do not possess an empty FASTA header and save to a new file
awk '$1!=">""" {print $0}' "$va"_linearized.out > "$va"_empty_headers_removed.out

# Split the output above, in this case 
split --verbose -l "$vb" "$va"_empty_headers_removed.out "$va"

exit 0
