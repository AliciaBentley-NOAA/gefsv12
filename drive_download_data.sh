#!/bin/bash
# Author: Alicia Bentley
#
###################################################
# Script to get download necessary data from HPSS #
###################################################

#==============================================  BEGIN CHANGES  ================================================

export SCRIPTS_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'
export DATA_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'

export CASE='bomb_cyclone'
export FHR_START=0
export FHR_END=240
export FHR_INC=6

export GET_GEFS=true
export GET_GFS=true
export GET_RAP=true
export GET_ST4=true   
export GET_DPROGDT=true
export VDATE=2018010500

for cycle in 2017122600 2017122700 2017122800 2017122900 2017123000 2017123100 2018010100 2018010200 2018010300 2018010400 2018010500
do

export CYCLE=${cycle}

#===============================================  END CHANGES  =================================================

if [ $GET_GEFS = true ]; then
   echo "Create/submit script to download ${CYCLE} GEFS forecast data"
   ${SCRIPTS_PATH}/create_htar_gefs.sh
   sleep 5
fi


if [ $GET_GFS = true ]; then
   echo "Create/submit script to download GFS analysis data"
   ${SCRIPTS_PATH}/create_htar_gfs.sh
   sleep 5
fi


if [ $GET_RAP = true ]; then
   echo "Create/submit script to download RAP analysis data"
   ${SCRIPTS_PATH}/create_htar_rap.sh
   sleep 5
fi


if [ $GET_ST4 = true ]; then
   echo "Create/submit script to download Stage-IV analysis data"
   ${SCRIPTS_PATH}/create_htar_st4.sh
   sleep 5
fi


if [ $GET_DPROGDT = true ]; then
   echo "Create/submit script to download GEFS ensemble member data"
   ${SCRIPTS_PATH}/create_htar_members.sh
   sleep 5
fi

done

exit
