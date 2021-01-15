#!/bin/bash
# Author: Alicia Bentley
#
######################################################
# Script to plot images from the data you downloaded #
######################################################

#==============================================  BEGIN CHANGES  ================================================

export SCRIPTS_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'
export DATA_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'
export IMAGES_PATH='/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs'

export CASE='bomb_cyclone'
export FHR_START=0
export FHR_END=240
export FHR_INC=6

export PLOT_FCST=true
export PLOT_DPROGDT=true
export VDATE=2018010500

for cycle in 2017122600 2017122700 2017122800 2017122900 2017123000 2017123100 2018010100 2018010200 2018010300 2018010400 2018010500
do

for domain in us nwatl
do

#echo ${cycle}
#echo ${domain}

export CYCLE=${cycle}
export DOMAIN=${domain}

#===============================================  END CHANGES  =================================================

if [ $PLOT_FCST = true ]; then
   echo "Create/submit script to plot multiple ${CYCLE} GEFS forecasts"
   ${SCRIPTS_PATH}/create_plot_gefs.sh
   sleep 3
fi


if [ $PLOT_DPROGDT = true ]; then
   echo "Create/submit script to plot ${CYCLE} probabilities, lows, spaghetti"
   ${SCRIPTS_PATH}/create_plot_members.sh
   sleep 3
fi

done
done

exit
