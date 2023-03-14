#!/bin/bash
#amino_freq_counter.sh
usage(){
    echo \
"
# ######################################################################################################################################################
#
# USAGE: ${0} \\
#                                                 -a amino acid ONE letter code 
#
# INPUT01: -a FLAG Label (a single specific IUPAC letter code)
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

awk '{print $2}' ../cd_hit_run_03/H_sapiens_training_set_linearized.tsv | tr -c -d ""$va"\n" | cat -n | \
    { echo -e "Line" "\tCount"; while read num data; do printf "%d\t%d\n" $num ${#data}; done; } > "$va"_freq.out

exit 0
