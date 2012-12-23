#!/bin/sh

STARALLIANCE="A"
ONEWORLD="O"
SKYTEAM="S"

BASEDIR=$(dirname $0)
AIRLINE_CD_CSV=${BASEDIR}"/../ori_airlines.csv"
AIRLINE_ALLIANCE_CSV="./airline_alliance_121221.csv"

OUTPUT_FILE="ori_airlines.csv"

awk -F'[,^]' '
BEGIN{
         while((getline < "'"${AIRLINE_ALLIANCE_CSV}"'")>0){
            alliance[$3]=$1"^"$2
         }
         OFS="^"
     }

{
   if (NR==1) {print $0,"alliance_status"}
   else if ($3 in alliance) {print $0""alliance[$3]}  
   else {print $0"^"alliance[$3]}
}' ${AIRLINE_CD_CSV} > ${OUTPUT_FILE}



