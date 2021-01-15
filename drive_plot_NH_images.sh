#!/bin/bash
# Author: Alicia Bentley
#
###################################################
# Script to get download necessary data from HPSS #
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
#   Make sure you edit the requested walltime     #
#            in the 5 htar scripts                #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  #
#
###################################################

#==============================================  BEGIN CHANGES  ================================================

export SCRIPTS_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'
export DATA_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'
export IMAGES_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'

export CASE='Florence2018'
export FHR_START=0
export FHR_END=240
export FHR_INC=6

export PLOT_FCST=true
export PLOT_DPROGDT=true
export VDATE=2018091412

for cycle in 2018090412 2018090512 2018090612 2018090712 2018090812 2018090912 2018091012 2018091112 2018091212 2018091312 2018091412
do

for domain in nh
do

#echo ${cycle}
#echo ${domain}

export CYCLE=${cycle}
export DOMAIN=${domain}

                     # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
                     #   Make sure you edit the requested walltime     #
                     #            in the 5 htar scripts                #
                     # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

#===============================================  END CHANGES  =================================================

if [ $PLOT_FCST = true ]; then
   echo "Create/submit script to plot multiple ${CYCLE} GEFS forecasts for nh"
   ${SCRIPTS_PATH}/create_plot_NH_gefs.sh
   sleep 3
fi


if [ $PLOT_DPROGDT = true ]; then
   echo "Create/submit script to plot ${CYCLE} probabilities, lows, spaghetti for nh"
   ${SCRIPTS_PATH}/create_plot_NH_members.sh
   sleep 3
fi

done
done

exit
