#!/bin/ksh
#BSUB -J rap_htar
#BSUB -o rap_htar.%J.out
#BSUB -e rap_htar.%J.out
#BSUB -n 1
#BSUB -W 00:45
#BSUB -P GFS-T2O
#BSUB -q transfer
#BSUB -R "rusage[mem=1000]"
#BSUB -R "affinity[core]"

module use -a /u/Benjamin.Blake/modulefiles
module load anaconda2/latest


#==============================================  BEGIN CHANGES  ================================================

#CASE='Irma'
#CYCLE=2017090900

#FHR_START=0
#FHR_END=84
#FHR_INC=6

#GET_RAP=true
#CONUS_DOM=true  # set to true if using uszoom (CONUS) or any of 10 CONUS subdomains
#NA_DOM=true     # set to true if using us (N. America), nwatl (West Atlantic), or gom (Gulf of Mexico) domains

# /gpfs/gp2/... and /gpfs/tp2/... for Alicia
# /gpfs/gd1/... and /gpfs/td1/... for Geoff
# /gpfs/gd2/... and /gpfs/td2/... for Logan
# /gpfs/gd3/... and /gpfs/td3/... for Tracey

if [ $SITE = GYRE ]; then
   RETRO_DIR="/gpfs/gd2/ptmp/$USER/FV3_retros/${CASE}"
elif [ $SITE = TIDE ]; then
   RETRO_DIR="/gpfs/td2/ptmp/$USER/FV3_retros/${CASE}"
fi

#===============================================  END CHANGES  =================================================

REPO_DIR="/meso/save/Logan.Dawson/EMC_meg/Logan_MEG/FV3retro_scripts"

mkdir -p $RETRO_DIR

cd $RETRO_DIR

/bin/rm -rf htar_rap_done

YYYY=`echo $CYCLE | cut -c 1-4`
YYYYMM=`echo $CYCLE | cut -c 1-6`
YYYYMMDD=`echo $CYCLE | cut -c 1-8`
HH=`echo $CYCLE | cut -c 9-10`

file="${CYCLE}_valids.txt"
if [[ -e ${RETRO_DIR}/${file} ]] ; then
   echo ""
else
   python ${REPO_DIR}/valids.py $CYCLE $FHR_START $FHR_END $FHR_INC
fi

#===============================================  GET ANALYSES  =================================================
RAP_CHANGE_DATE1=2016082312
RAP_CHANGE_DATE2=2018071200

while IFS= read -r line ; do
   VALID="`echo $line`"
   YYYY=`echo $VALID | cut -c 1-4`
   YYYYMM=`echo $VALID | cut -c 1-6`
   YYYYMMDD=`echo $VALID | cut -c 1-8`
   HH=`echo $VALID | cut -c 9-10`

##### RAP
   if ((${VALID} < ${RAP_CHANGE_DATE1})) ; then
      RAP_TAR=rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com_rap_prod_rap

   elif (((${VALID} >= ${RAP_CHANGE_DATE1}) && (${VALID} < ${RAP_CHANGE_DATE2}))) ; then
      RAP_TAR=rh${YYYY}/${YYYYMM}/${YYYYMMDD}/com2_rap_prod_rap

   elif ((${VALID} >= ${RAP_CHANGE_DATE2})) ; then
      RAP_TAR=2year/rh${YYYY}/${YYYYMM}/${YYYYMMDD}/gpfs_hps_nco_ops_com_rap_prod_rap

   fi

   if $GET_RAP; then
      if (((${HH} >= 00) && (${HH} <=  05))) ; then
        RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}00-05.awp130.tar
        RAP_ARCHIVE2=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}00-05.awip32.tar

      elif (((${HH} >= 06) && (${HH} <=  11))) ; then
        RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}06-11.awp130.tar
        RAP_ARCHIVE2=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}06-11.awip32.tar

      elif (((${HH} >= 12) && (${HH} <=  17))) ; then
        RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}12-17.awp130.tar
        RAP_ARCHIVE2=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}12-17.awip32.tar

      elif (((${HH} >= 18) && (${HH} <=  23))) ; then
        RAP_ARCHIVE1=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}18-23.awp130.tar
        RAP_ARCHIVE2=/NCEPPROD/hpssprod/runhistory/${RAP_TAR}.${YYYYMMDD}18-23.awip32.tar
      fi


      # make temporary directory to download into
      mkdir -p $RETRO_DIR/rap.${CYCLE}
      cd $RETRO_DIR/rap.${CYCLE}

      if [[ -e ${RETRO_DIR}/rap.${YYYYMMDD}.t${HH}z.awp130pgrbf00.grib2 ]] ; then
         echo ${VALID}" RAP awp130 analysis exists"
      else
         if $CONUS_DOM; then
            echo "Extracting "${VALID}" RAP awp130 analysis"
            htar -xvf $RAP_ARCHIVE1 ./rap.t${HH}z.awp130pgrbf00.grib2 
            mv ./rap.t${HH}z.awp130pgrbf00.grib2 ${RETRO_DIR}/rap.${YYYYMMDD}.t${HH}z.awp130pgrbf00.grib2
         fi
      fi


      if [[ -e ${RETRO_DIR}/rap.${YYYYMMDD}.t${HH}z.awip32f00.grib2 ]] ; then
         echo ${VALID}" RAP awip32 analysis exists"
      else
         if $NA_DOM; then
            echo "Extracting "${VALID}" RAP awip32 analysis"
            htar -xvf $RAP_ARCHIVE2 ./rap.t${HH}z.awip32f00.grib2 
            mv ./rap.t${HH}z.awip32f00.grib2 ${RETRO_DIR}/rap.${YYYYMMDD}.t${HH}z.awip32f00.grib2
         fi
      fi

   fi # end of GET_RAP logical statement



done <"$file"
#==============================================================================================================


cd $RETRO_DIR
/bin/rm -fR $RETRO_DIR/rap.${CYCLE}

touch htar_rap_done

exit
