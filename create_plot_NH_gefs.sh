#!/bin/bash
# Author: Alicia Bentley
#####################################
# Script for submitting jobs on Hera
#   that download data from HPSS
#####################################

echo ${CYCLE}
echo ${DOMAIN}

mkdir -p ${IMAGES_PATH}'/'${CASE}'/images/'${CYCLE}
'cp' ${SCRIPTS_PATH}/plot*.ncl ${DATA_PATH}/${CASE}/${CYCLE}/.
cd ${DATA_PATH}/${CASE}/

##########################################

echo "submitting ${DOMAIN} domain script for ${CYCLE}"

cat > ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_${domain}_${CYCLE}.sh <<EOF
#!/bin/bash
#SBATCH --account=ovp
#SBATCH --job-name=${DOMAIN}_${CYCLE}
#SBATCH --output=gefs_plot_${DOMAIN}_${CYCLE}.%j.out
#SBATCH -q batch
#SBATCH --nodes=1
#SBATCH --time=6:00:00

cd ${DATA_PATH}/${CASE}/${CYCLE}/

/bin/rm -rf ../plot_${CYCLE}_${DOMAIN}_done

ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_10mu.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_10mv.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_250u.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_250v.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_2mt.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_500g.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_6hqpf.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_850t.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_850u.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_850v.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_cape.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_pw.ncl 
ncl 'scriptyyyymmddhh="${CYCLE}"' 'eventname="${CASE}"' 'scriptregion="${DOMAIN}"' 'fhr_inc="${FHR_INC}"' 'fhr_start="${FHR_START}"' 'fhr_end="${FHR_END}"' 'images_path="${IMAGES_PATH}"' ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_NH_slp.ncl 

touch ../plot_${CYCLE}_${DOMAIN}_done

exit

EOF

sbatch ${DATA_PATH}/${CASE}/${CYCLE}/plot_gefs_${REGIONNAME}_${CYCLE}.sh
sleep 5

exit

