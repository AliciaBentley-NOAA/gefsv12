#!/bin/bash
# Author: Alicia Bentley
#####################################
# Script for submitting jobs on Hera
#   that download data from HPSS
#####################################

echo ${DATA_PATH}/${CASE}/${CYCLE}
echo ${FHR_INC}
echo ${FHR_START}
echo ${FHR_END}

mkdir -p ${DATA_PATH}/${CASE}/${CYCLE}
'cp' ${SCRIPTS_PATH}/htar_gefs.ncl ${DATA_PATH}/${CASE}/${CYCLE}/.
cd ${DATA_PATH}/${CASE}/

cat > ${DATA_PATH}/${CASE}/${CYCLE}/htar_gefs.csh <<EOF
#!/bin/csh
#SBATCH --account=ovp
#SBATCH --job-name=gefs_htar
#SBATCH --output=gefs_htar.%j.out
#SBATCH --ntasks=1
#SBATCH --partition=service
#SBATCH --time=1:00:00

cd ${DATA_PATH}/${CASE}/${CYCLE}/

/bin/rm -rf ../htar_gefs_${CYCLE}_done

echo ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' ${DATA_PATH}/${CASE}/${CYCLE}/htar_gefs.ncl 

ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' ${DATA_PATH}/${CASE}/${CYCLE}/htar_gefs.ncl
#sleep 5

touch ../htar_gefs_${CYCLE}_done

exit

EOF



sbatch ${DATA_PATH}/${CASE}/${CYCLE}/htar_gefs.csh
sleep 5

exit

