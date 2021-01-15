; ===========================================
; Plots 4-panel of GEFS mean/spread & diff.
; Created by: Alicia M. Bentley
; Last updated: 12 November 2019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ===========================================
begin

print("======================")
print("Script has started!")
print("======================")

;================================================================

; Define casename
  if (isdefined("eventname")) then
        print("Eventname defined on command line: "+eventname)
        casename = eventname
  else
        print("No eventname defined on command line")
        casename = "eventname"
  end if

;==================================================================

; Define data_directory
  if (isdefined("images_path")) then
        print("images_path defined on command line: "+images_path)
        image_dir = images_path
  else
        print("No images_path defined on command line")
        image_dir = "images_path"
  end if

;==================================================================

; Pre-defined domain definitions
  minlatlist=(/15.0,35.0,25.0,31.0,40.0,25.5,35.0,42.0,41.0,34.0,40.0,34.0,24.5,12.5,10,20,1,-40,15/)
  maxlatlist=(/60.0,75.0,50.0,43.0,50.0,37.5,44.0,50.0,49.5,43.0,48.0,42.5,35.0,35,27,47.5,60,-1,62.5/)
  minlonlist=(/-135.0,160.0,-120,-125.0,-125.0,-108.0,-108.0,-110.0,-97.0,-97.0,-81.0,-86.0,-92.0,-105,-81,-95,110,137.5,-167.5/)
  maxlonlist=(/-60.0,250.0,-72.5,-105.0,-107.0,-90.0,-92.0,-95.0,-80.5,-83.0,-66.5,-72.0,-76.0,-72.5,-55,-57.5,179,192.5,-115/)
  regionlist=(/"us","ak","uszoom","sw","nw","t","cp","np","mw","ov","ne","ma","se","gom","pr","nwatl","wpac","spac","epac"/)
  if (isdefined("scriptregion")) then
     if (scriptregion .eq. "new")
        print("New domain requested. Script will fail if the following variables are not defined with command line arguments: regionname, minlat, minlon, maxlat, maxlon.")
        scriptregion=regionname
     else
        print("Domain defined on command line: "+scriptregion)
        scriptregion=str_lower(scriptregion)
     end if
  else
     scriptregion="us"
  end if
 
; =================================================================

; Obtaining the date of the forecast requested 
  scriptyear=toint(str_get_cols(scriptyyyymmddhh,0,3))
  scriptmonth=toint(str_get_cols(scriptyyyymmddhh,4,5))
  scriptday=toint(str_get_cols(scriptyyyymmddhh,6,7))
  scripthour=toint(str_get_cols(scriptyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datemodel=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)


; Define start and end dates for changing GEFS tarfile naming conventions on HPSS
  gefs_cdate = cd_inv_calendar(2019,8,20,00,00,00,timeunits,0)      ; Specify date formating changed
  if (datemodel .ge. gefs_cdate) then
        print("idate is after GEFS moved to Dell")
        gefstar = "gpfs_dell2_nco_ops_com_gens_prod_gefs"
  else if (datemodel .lt. gefs_cdate) then
        print("idate is before GEFS moved to Dell")
        gefstar = "com2_gens_prod_gefs"
  end if
  end if


;;; Define start and end dates of retro streams so HPSS directories are named correctly
  retro1_sdate  = cd_inv_calendar(2017,1,1,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro1_edate = cd_inv_calendar(2017,12,31,18,00,00,timeunits,0)       ; Specify end date of date range (edate)

  retro2_sdate = cd_inv_calendar(2018,1,1,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro2_edate = cd_inv_calendar(2018,12,31,18,00,00,timeunits,0)      ; Specify end date of date range (edate)

  retro3_sdate = cd_inv_calendar(2019,1,1,00,00,00,timeunits,0)      ; Specify start date of date range (sdate)
  retro3_edate = cd_inv_calendar(2019,12,31,18,00,00,timeunits,0)      ; Specify end date of date range (edate)

  if (datemodel .ge. retro1_sdate) .and. (datemodel .le. retro1_edate) then
     prod_dir = "/NCEPPROD/hpssprod/runhistory/rh2017"
     archive_dir = "/NCEPDEV/emc-ensemble/2year/emc.enspara/fv3gefs/RETRO/2017"
     WCOSS_dir = "/gpfs/hps2/nco/storage/fv3gefs/RETRO/2017"

  else if (datemodel .ge. retro2_sdate) .and. (datemodel .le. retro2_edate) then
     prod_dir = "/NCEPPROD/hpssprod/runhistory/rh2018"
     archive_dir = "/NCEPDEV/emc-ensemble/2year/emc.enspara/fv3gefs/RETRO/2018"
     WCOSS_dir = "/gpfs/hps2/nco/storage/fv3gefs/RETRO/2018"

  else if (datemodel .ge. retro3_sdate) .and. (datemodel .le. retro3_edate) then
     prod_dir = "/NCEPPROD/hpssprod/runhistory/rh2019"
     archive_dir = "/NCEPDEV/emc-ensemble/2year/emc.enspara/fv3gefs/RETRO/2019"
     WCOSS_dir = "/gpfs/hps2/nco/storage/fv3gefs/RETRO/2019"

  end if
  end if
  end if

;==================================================================

; Obtaining the date of the valid time requested
  validyear=toint(str_get_cols(validyyyymmddhh,0,3))
  validmonth=toint(str_get_cols(validyyyymmddhh,4,5))
  validday=toint(str_get_cols(validyyyymmddhh,6,7))
  validhour=toint(str_get_cols(validyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datevalid=ut_inv_calendar(validyear,validmonth,validday,validhour,0,0,timeunits,0)

  fhours = toint(datevalid)
  fhours = toint(datevalid - datestart)
  fdates = datevalid


;===================================================================

  do h=0,dimsizes(fdates)-1
    ;print((/fhours(h)/))
    thisdate=fdates(h)
    thisdate@units=timeunits
    modelstrings=tostring(ut_calendar(thisdate,-3))
    ms=tostring(ut_calendar(datemodel,-3))
    ;model date
    yearm=str_get_cols(ms,0,3)
    monthm=str_get_cols(ms,4,5)
    daym=str_get_cols(ms,6,7)
    hourm=str_get_cols(ms,8,9)
    mdhm=str_get_cols(ms,4,9)
    ymm=str_get_cols(ms,0,5)
    ymdm=str_get_cols(ms,0,7)
    ;date of forecast hour
    year=str_get_cols(modelstrings,0,3)
    month=str_get_cols(modelstrings,4,5)
    day=str_get_cols(modelstrings,6,7)
    hour=str_get_cols(modelstrings,8,9)
    mdh=str_get_cols(modelstrings,4,9)
    ymd=str_get_cols(modelstrings,0,7)
    monthind=toint(month)
    months=(/"","January","February","March","April","May","June","July","August","September","October","November","December"/)

  print(" ")
  print("Int: YYYYMMDDHH (FXXX): "+ymdm+hourm+" (F"+sprinti("%0.3i",fhours(h))+")")
; ==========================================================================

;;;;; Look for GEFSv12 mean file on WCOSS...
;;;;; If not found, pull file from HPSS.

;Obtaining GEFSv12 mean file
       parafile_geavg ="../"+ymdm+hourm+"/geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 mean file found (it was already downloaded)...")
       else
          print("GEFSv12 mean file is missing...")
          system("pwd")
       end if

       para_geavg=addfile("../"+ymdm+hourm+"/geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

; Obtaining GEFSv12 spread file
       parafile_geavg ="../"+ymdm+hourm+"/gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 spread file found (it was already downloaded)...")
       else
          print("GEFSv12 spread file is missing...")
          system("pwd")
       end if

       para_gespr=addfile("../"+ymdm+hourm+"/gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

; Obtaining GEFSv12 ensmeble member files

do member = 0,30,1

;       print("member: "+member)
       if member .eq. 0 then
          mem_name = "gec00"
       else
          if member .le. 9 then
             mem_name = "gep0"+member
          else if member .ge. 10 then
             mem_name = "gep"+member
          end if
          end if
;          print("mem_name: "+mem_name)
       end if

       parafile_mem = "../members/"+mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_mem)) then
          print("GEFSv12 "+mem_name+" file found (it was already downloaded)...")
       else
          print("GEFSv12 "+mem_name+" file is missing...")
          system("pwd ../members/")
       end if

end do

; ----------------------------------------------------------------------------------

;Obtaining GEFSv11 mean file
       prodfile_geavg ="../"+ymdm+hourm+"/geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_geavg)) then
          print("GEFSv11 mean file found (it was already downloaded)...")
       else
          print("GEFSv11 mean file is missing...")
          system("pwd")
       end if

       prod_geavg=addfile("../"+ymdm+hourm+"/geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

;Obtaining GEFSv11 spread file
       prodfile_gespr ="../"+ymdm+hourm+"/gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_gespr)) then
          print("GEFSv11 spread file found (it was already downloaded)...")
       else
          print("GEFSv11 spread file is missing...")
          system("pwd")
       end if

       prod_gespr=addfile("../"+ymdm+hourm+"/gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

; Obtaining GEFSv11 ensemble member files

do member = 0,20,1

;       print("member: "+member)
       if member .eq. 0 then
          mem_name = "gec00"
       else
          if member .le. 9 then
             mem_name = "gep0"+member
          else if member .ge. 10 then
             mem_name = "gep"+member
          end if
          end if
;          print("mem_name: "+mem_name)
       end if

       prodfile_mem = "../members/"+mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_mem)) then
          print("GEFSv11 "+mem_name+" file found (it was already downloaded)...")
       else
          print("GEFSv11 "+mem_name+" file is missing...")
          system("pwd ../members/")
       end if

end do

;-----------------------------------------------------------------------------------

;;;;; Look for 1.0 GFS analysis file on WCOSS...
;;;;; If not found, pull file from HPSS.
    anlfile="/gpfs/hps/nco/ops/com/gfs/prod/gfs."+ymd+"/"+hourm+"/gfs.t"+hour+"z.pgrb2.0p25.f000.grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile(anlfile,"r")
    else
       anlfile ="../analyses/gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f000.grib2"
       if (isfilepresent(anlfile)) then
          print("GFS analysis file found (data was already downloaded)...")
       else
          print("GFS analysis file is missing...")
       end if

       anl=addfile("../analyses/gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f000.grib2","r")
    end if


; ============================================================================
; ======================= Download data ======================================
; ============================================================================ 


   ; print(prod)
   vnames:=getfilevarnames(prod_geavg)
   slpprod_mean = prod_geavg->HGT_P2_L100_GLL0({50000},:,:)
   slppara_mean = para_geavg->HGT_P2_L100_GLL0({50000},:,:)
   slpprod_spread = prod_gespr->HGT_P2_L100_GLL0({50000},:,:)
   slppara_spread = para_gespr->HGT_P2_L100_GLL0({50000},:,:)
   slp_anl = anl->HGT_P0_L100_GLL0({50000},:,:)

   slpprod_mean = slpprod_mean/10.
   slppara_mean = slppara_mean/10.
   slpprod_spread = slpprod_spread/10.
   slppara_spread = slppara_spread/10.
   slp_anl=slp_anl/10.

   dif = slpprod_mean
   dif = slppara_mean - slpprod_mean

   dif_anl = slp_anl
   dif_anl = slppara_mean - slp_anl


  mslpv12 := new((/31,181,360/),"float")

  do e = 0,30
        if (e .eq. 0) then
                a := addfile("../members/gec00v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
                ens_mslp := a->HGT_P1_L100_GLL0({50000},:,:)
                ens_mslp = ens_mslp/10.
                mslpv12(e,:,:) = ens_mslp
        else
                if (e .lt. 10) then
                    ensv12 = "0"+e
                else if (e .ge. 10) then
                    ensv12 = e
                end if
                end if
                      a := addfile("../members/gep"+ensv12+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
                      ens_mslp := a->HGT_P1_L100_GLL0({50000},:,:)
                      ens_mslp = ens_mslp/10.
                      mslpv12(e,:,:) = ens_mslp
        end if
  end do ; e



  mslpv11 := new((/21,181,360/),"float")

  do e = 0,20
        if (e .eq. 0) then
                a := addfile("../members/gec00v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
                ens_mslp := a->HGT_P1_L100_GLL0({50000},:,:)
                ens_mslp = ens_mslp/10.
                mslpv11(e,:,:) = ens_mslp
        else
                if (e .lt. 10) then
                    ensv11 = "0"+e
                else if (e .ge. 10) then
                    ensv11 = e
                end if
                end if
                      a := addfile("../members/gep"+ensv11+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
                      ens_mslp := a->HGT_P1_L100_GLL0({50000},:,:)
                      ens_mslp = ens_mslp/10.
                      mslpv11(e,:,:) = ens_mslp
        end if
  end do ; e

; ============================================================================
; ======================= Make plot ==========================================
; ============================================================================
plot_dir = image_dir+"/"+casename+"/images/dprogdt"
system("mkdir -p "+plot_dir)

  wks  = gsn_open_wks("png", plot_dir+"/gefs_"+scriptregion+"_spag_"+casename+"_int"+ymdm+hourm+"_val"+ymd+hour)                 ; open a png file
  ;gsn_define_colormap(wks,"BlueWhiteOrangeRed") 
  gsn_define_colormap(wks,"alicia") 
  ;gsn_define_colormap(wks,"MPL_jet") 

  plot=new(4,"graphic")

  res  = True

  ;res@mpOutlineBoundarySets="AllBoundaries"
  res@mpOutlineBoundarySets="GeophysicalAndUSStates"
  res@mpDataBaseVersion="MediumRes"
  res@gsnMaximize=True
  res@tmXBLabelFontHeightF=.008
  res@tmYLLabelFontHeightF=.008
  res@gsnRightString="500g"
  res@gsnAddCyclic=False
  res@gsnLeftString="GEFSv11 Forecast initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  res@mpOutlineDrawOrder="PostDraw"
  res@mpFillColor="grey75"
  res@cnInfoLabelOn=False
  res@mpFillDrawOrder="PreDraw"
  res@cnLabelMasking=True
  res@mpGeophysicalLineColor="black"
  res@mpGeophysicalLineThicknessF=2.0
  res@mpNationalLineThicknessF=2.0
  ;res@cnFillMode="RasterFill"
  ;res@cnRasterSmoothingOn=True
  res@mpUSStateLineThicknessF=1.0
  res@mpCountyLineThicknessF=.5
  ;res@mpUSStateLineThicknessF=3.0
  res@mpNationalLineColor="black"
  res@mpUSStateLineColor="black"
  res@cnLineLabelsOn=False
  res@pmLabelBarHeightF=.05
  res@lbLabelFontHeightF=.008
  res@gsnLeftStringFontHeightF=.01
  res@gsnRightStringFontHeightF=.01
  res@cnFillOn=True
  res@mpFillOn=True
  res@cnFillMode="RasterFill"
  res@cnRasterSmoothingOn=True
  res@cnLevelSelectionMode="ExplicitLevels"
  res@cnLevels := (/1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18/)
  res@cnFillColors := (/-1,11,12,13,14,16,18,19,20,35,37,38,24,25,26,27,28,29,0/)
  res@cnLinesOn=False
  res@mpLimitMode="LatLon"
  res@gsnDraw=False
  ;res@mpProjection="Mercator"

  if scriptregion.eq."nh" then
     res@gsnPolar = "NH"
     res@mpCenterLonF = -90.
     res@mpMinLatF    = 10
     res@mpMaxLatF    = 90
  else if scriptregion.eq."sh" then
     res@gsnPolar = "SH"
     res@mpCenterLonF = -90.
     res@mpMinLatF    = -90
     res@mpMaxLatF    = -10
  else if scriptregion.eq."NH" then
     res@gsnPolar = "NH"
     res@mpCenterLonF = -90.
     res@mpMinLatF    = 10
     res@mpMaxLatF    = 90
  end if
  end if
  end if

  ;res@lbLabelStride=1
  res@cnLinesOn=False
  res@lbLabelAutoStride=True
  res@gsnFrame=False
   res@lbLabelBarOn=True
  if scriptregion.eq."us" then
    res@mpNationalLineThicknessF=2.0
    res@mpGeophysicalLineThicknessF=2.0
  end if


  res@cnLineLabelInterval=1
  res@cnLineLabelDensityF=1.5
  plot(0) = gsn_csm_contour_map(wks,slpprod_spread,res)       ; create a default plot

;---------------------------------------------------------------------

  hres=True
  hres@cnLinesOn=True
  hres@cnFillOn=False
  hres@cnInfoLabelOn=False
  hres@cnLevelSelectionMode="ExplicitLevels"
  hres@gsnMaximize=True
  hres@cnLineLabelInterval=1
  hres@gsnLeftString=""
  hres@gsnRightString=""
  hres@cnLevels=(/534,576/)
  hres@gsnDraw=False
  hres@cnLabelMasking=True
  hres@cnLineLabelBackgroundColor=-1
  hres@cnLineLabelAngleF=0.0
  hres@cnLineThicknessF=5.0
  hres@cnLineLabelFontHeightF=.017
  hres@cnLineLabelsOn=True
  hres@cnLineColor="red3"
  hres@cnLowLabelsOn=False
  hres@cnLowLabelBackgroundColor=-1
  hres@cnLineLabelFontColor=hres@cnLineColor
  hres@cnHighLabelFontHeightF=.019
  hres@cnHighLabelFont = "helvetica-bold"
  hres@cnLowLabelFont = "helvetica-bold"
  hres@gsnFrame=False

  ;print("plotting height")
  plot_heightprod=gsn_csm_contour(wks,slpprod_mean,hres)

;---------------------------------------------------

  ares = True
  ares = hres
  ares@cnLineColor="black"
  ares@cnLineLabelFontColor=ares@cnLineColor
  ares@cnLineThicknessF=8.0

  ;print("plotting height")
  plot_heightanl=gsn_csm_contour(wks,slp_anl,ares)
  plot_heightanl2=gsn_csm_contour(wks,slp_anl,ares)

;----------------------------------------------------


  lres = True
  lres = hres
  lres@cnLineLabelsOn = False
  lres@cnLineColor="blue"
  lres@cnLineLabelFontColor=lres@cnLineColor
  lres@cnLineThicknessF=3.0


lows0_v11 = gsn_csm_contour(wks, mslpv11(0,:,:), lres)
lows1_v11 = gsn_csm_contour(wks, mslpv11(1,:,:), lres)
lows2_v11 = gsn_csm_contour(wks, mslpv11(2,:,:), lres)
lows3_v11 = gsn_csm_contour(wks, mslpv11(3,:,:), lres)
lows4_v11 = gsn_csm_contour(wks, mslpv11(4,:,:), lres)
lows5_v11 = gsn_csm_contour(wks, mslpv11(5,:,:), lres)
lows6_v11 = gsn_csm_contour(wks, mslpv11(6,:,:), lres)
lows7_v11 = gsn_csm_contour(wks, mslpv11(7,:,:), lres)
lows8_v11 = gsn_csm_contour(wks, mslpv11(8,:,:), lres)
lows9_v11 = gsn_csm_contour(wks, mslpv11(9,:,:), lres)
lows10_v11 = gsn_csm_contour(wks, mslpv11(10,:,:), lres)
lows11_v11 = gsn_csm_contour(wks, mslpv11(11,:,:), lres)
lows12_v11 = gsn_csm_contour(wks, mslpv11(12,:,:), lres)
lows13_v11 = gsn_csm_contour(wks, mslpv11(13,:,:), lres)
lows14_v11 = gsn_csm_contour(wks, mslpv11(14,:,:), lres)
lows15_v11 = gsn_csm_contour(wks, mslpv11(15,:,:), lres)
lows16_v11 = gsn_csm_contour(wks, mslpv11(16,:,:), lres)
lows17_v11 = gsn_csm_contour(wks, mslpv11(17,:,:), lres)
lows18_v11 = gsn_csm_contour(wks, mslpv11(18,:,:), lres)
lows19_v11 = gsn_csm_contour(wks, mslpv11(19,:,:), lres)
lows20_v11 = gsn_csm_contour(wks, mslpv11(20,:,:), lres)

;-------------------------------------------------

  res@gsnLeftString="GEFSv12 Forecast initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(1) = gsn_csm_contour_map(wks,slppara_spread,res)       ; create a default plot

  ;print("plotting height")
  plot_heightpara=gsn_csm_contour(wks,slppara_mean,hres)

lows0_v12 = gsn_csm_contour(wks, mslpv12(0,:,:), lres)
lows1_v12 = gsn_csm_contour(wks, mslpv12(1,:,:), lres)
lows2_v12 = gsn_csm_contour(wks, mslpv12(2,:,:), lres)
lows3_v12 = gsn_csm_contour(wks, mslpv12(3,:,:), lres)
lows4_v12 = gsn_csm_contour(wks, mslpv12(4,:,:), lres)
lows5_v12 = gsn_csm_contour(wks, mslpv12(5,:,:), lres)
lows6_v12 = gsn_csm_contour(wks, mslpv12(6,:,:), lres)
lows7_v12 = gsn_csm_contour(wks, mslpv12(7,:,:), lres)
lows8_v12 = gsn_csm_contour(wks, mslpv12(8,:,:), lres)
lows9_v12 = gsn_csm_contour(wks, mslpv12(9,:,:), lres)
lows10_v12 = gsn_csm_contour(wks, mslpv12(10,:,:), lres)
lows11_v12 = gsn_csm_contour(wks, mslpv12(11,:,:), lres)
lows12_v12 = gsn_csm_contour(wks, mslpv12(12,:,:), lres)
lows13_v12 = gsn_csm_contour(wks, mslpv12(13,:,:), lres)
lows14_v12 = gsn_csm_contour(wks, mslpv12(14,:,:), lres)
lows15_v12 = gsn_csm_contour(wks, mslpv12(15,:,:), lres)
lows16_v12 = gsn_csm_contour(wks, mslpv12(16,:,:), lres)
lows17_v12 = gsn_csm_contour(wks, mslpv12(17,:,:), lres)
lows18_v12 = gsn_csm_contour(wks, mslpv12(18,:,:), lres)
lows19_v12 = gsn_csm_contour(wks, mslpv12(19,:,:), lres)
lows20_v12 = gsn_csm_contour(wks, mslpv12(20,:,:), lres)
lows21_v12 = gsn_csm_contour(wks, mslpv12(21,:,:), lres)
lows22_v12 = gsn_csm_contour(wks, mslpv12(22,:,:), lres)
lows23_v12 = gsn_csm_contour(wks, mslpv12(23,:,:), lres)
lows24_v12 = gsn_csm_contour(wks, mslpv12(24,:,:), lres)
lows25_v12 = gsn_csm_contour(wks, mslpv12(25,:,:), lres)
lows26_v12 = gsn_csm_contour(wks, mslpv12(26,:,:), lres)
lows27_v12 = gsn_csm_contour(wks, mslpv12(27,:,:), lres)
lows28_v12 = gsn_csm_contour(wks, mslpv12(28,:,:), lres)
lows29_v12 = gsn_csm_contour(wks, mslpv12(29,:,:), lres)
lows30_v12 = gsn_csm_contour(wks, mslpv12(30,:,:), lres)


;-------------------------------------------------

  resdif=True
  resdif=res
  resdif@cnFillPalette=("BlueWhiteOrangeRed")
  delete(resdif@cnFillColors)
  delete(resdif@cnLevels)
  resdif@cnLevels:=ispan(-14,14,2)
  resdif@gsnLeftString="GEFSv12 Forecast minus GEFSv11 Forecast valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

; -----------------------------------------------
fres = True
fres = lres
fres@cnLowLabelFontColor = "black"
fres@cnHighLabelFontColor = fres@cnLowLabelFontColor 
fres@cnLowLabelFontHeightF = 0.023
fres@cnHighLabelFontHeightF = fres@cnLowLabelFontHeightF 

  resdif@gsnLeftString="GEFSv12 Forecast minus GFS Analysis (contoured) valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(3) = gsn_csm_contour_map(wks,dif_anl,resdif)       ; create a default plot
  plot_heightfin=gsn_csm_contour(wks,slp_anl,ares)

; -----------------------------------------------

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  ;resP@txString="initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h-1))+")"
  resP@gsnFrame=False


overlay(plot(0),lows0_v11)
overlay(plot(0),lows1_v11)
overlay(plot(0),lows2_v11)
overlay(plot(0),lows3_v11)
overlay(plot(0),lows4_v11)
overlay(plot(0),lows5_v11)
overlay(plot(0),lows6_v11)
overlay(plot(0),lows7_v11)
overlay(plot(0),lows8_v11)
overlay(plot(0),lows9_v11)
overlay(plot(0),lows10_v11)
overlay(plot(0),lows11_v11)
overlay(plot(0),lows12_v11)
overlay(plot(0),lows13_v11)
overlay(plot(0),lows14_v11)
overlay(plot(0),lows15_v11)
overlay(plot(0),lows16_v11)
overlay(plot(0),lows17_v11)
overlay(plot(0),lows18_v11)
overlay(plot(0),lows19_v11)
overlay(plot(0),lows20_v11)

  overlay(plot(0),plot_heightanl)
  overlay(plot(0),plot_heightprod)


overlay(plot(1),lows0_v12)
overlay(plot(1),lows1_v12)
overlay(plot(1),lows2_v12)
overlay(plot(1),lows3_v12)
overlay(plot(1),lows4_v12)
overlay(plot(1),lows5_v12)
overlay(plot(1),lows6_v12)
overlay(plot(1),lows7_v12)
overlay(plot(1),lows8_v12)
overlay(plot(1),lows9_v12)
overlay(plot(1),lows10_v12)
overlay(plot(1),lows11_v12)
overlay(plot(1),lows12_v12)
overlay(plot(1),lows13_v12)
overlay(plot(1),lows14_v12)
overlay(plot(1),lows15_v12)
overlay(plot(1),lows16_v12)
overlay(plot(1),lows17_v12)
overlay(plot(1),lows18_v12)
overlay(plot(1),lows19_v12)
overlay(plot(1),lows20_v12)
overlay(plot(1),lows21_v12)
overlay(plot(1),lows22_v12)
overlay(plot(1),lows23_v12)
overlay(plot(1),lows24_v12)
overlay(plot(1),lows25_v12)
overlay(plot(1),lows26_v12)
overlay(plot(1),lows27_v12)
overlay(plot(1),lows28_v12)
overlay(plot(1),lows29_v12)
overlay(plot(1),lows30_v12)

  overlay(plot(1),plot_heightanl2)
  overlay(plot(1),plot_heightpara)


  overlay(plot(3),plot_heightfin)


  gsn_panel(wks,plot,(/2,2/),resP)
 
print("Framing figure")
frame(wks)
print("Deleting workstation")
delete(wks)

system("convert "+plot_dir+"/gefs_"+scriptregion+"_spag_"+casename+"_int"+ymdm+hourm+"_val"+ymd+hour+".png -trim +repage "+plot_dir+"/gefs_"+scriptregion+"_spag_"+casename+"_int"+ymdm+hourm+"_val"+ymd+hour+".png")              

end do


print("======================")
print("Script has finished!")
print("======================")


end



