#!/bin/bash
# cd_hit_H_sapiens.sh

#Command section

cd-hit -i ../ProteinSeqs_Output_Clean/H_sapiens_all.fa \
-o H_sapiens_all_100pc \
-c 1 \
-n 5 \
-s 1 \
-p 1 \
-g 1 \
-sc 1 \
-sf 1 \
-M 20000 \
-d 0 \
-T 10
