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
'cp' ${SCRIPTS_PATH}/htar_members.ncl ${DATA_PATH}/${CASE}/${CYCLE}/.
cd ${DATA_PATH}/${CASE}/

cat > ${DATA_PATH}/${CASE}/${CYCLE}/htar_members.csh <<EOF
#!/bin/csh
#SBATCH --account=ovp
#SBATCH --job-name=mems_htar
#SBATCH --output=members_htar.%j.out
#SBATCH --ntasks=1
#SBATCH --partition=service
#SBATCH --time=3:10:00

cd ${DATA_PATH}/${CASE}/${CYCLE}/

/bin/rm -rf ../htar_members_${CYCLE}_done

echo ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' ${DATA_PATH}/${CASE}/${CYCLE}/htar_members.ncl 

ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' ${DATA_PATH}/${CASE}/${CYCLE}/htar_members.ncl
#sleep 5

touch ../htar_members_${CYCLE}_done

exit

EOF



sbatch ${DATA_PATH}/${CASE}/${CYCLE}/htar_members.csh
sleep 5

exit

