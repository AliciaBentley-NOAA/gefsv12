#!/bin/bash
# Author: Alicia Bentley
#####################################
# Script for submitting jobs on Hera
#   that download data from HPSS
#####################################

echo ${DOMAIN}
echo ${CYCLE}
echo ${VDATE}
sleep 3

mkdir -p ${IMAGES_PATH}'/'${CASE}'/images/'${CYCLE}
'cp' ${SCRIPTS_PATH}/plot*.ncl ${DATA_PATH}/${CASE}/${CYCLE}/.
cd ${DATA_PATH}/${CASE}/

##########################################

echo "Submitting ${DOMAIN} domain script initialized at ${CYCLE} for valid date ${VDATE}"

cat > ${DATA_PATH}/${CASE}/${CYCLE}/plot_mems_${domain}_${VDATE}.sh <<EOF
#!/bin/bash
#SBATCH --account=ovp
#SBATCH --job-name=mems_${DOMAIN}_${VDATE}
#SBATCH --output=mems_plot_${DOMAIN}_${VDATE}.%j.out
#SBATCH -q batch
#SBATCH --nodes=1
#SBATCH --time=6:00:00

cd ${DATA_PATH}/${CASE}/${CYCLE}/

/bin/rm -rf ../plot_mems_${VDATE}_${DOMAIN}_done

ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_lows.ncl
ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_spag.ncl
ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_prob2mt.ncl
ncl 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_prob850t.ncl
ncl 'values=(/1000,2000/)' 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_probcape.ncl
ncl 'values=(/0.25,1/)' 'scriptyyyymmddhh="${CYCLE}"' 'validyyyymmddhh="${VDATE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_prob6hqpf.ncl 

touch ../plot_mems_${VDATE}_${DOMAIN}_done

exit

EOF

sbatch ${DATA_PATH}/${CASE}/${CYCLE}/plot_mems_${REGIONNAME}_${VDATE}.sh
sleep 5

exit

