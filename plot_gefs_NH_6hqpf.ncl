; ===========================================
; Plots 4-panel of GEFS mean/spread & diff.
; Created by: Alicia M. Bentley
; Last updated: 6 November 2019
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
        new_domain = True
     else
        print("Domain defined on command line: "+scriptregion)
        scriptregion=str_lower(scriptregion)
        new_domain = False
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

;===================================================================

;;; Check to see if starting forecast hour was defined with command line argument
  if (isdefined("fhr_start")) then
     print("Starting forecast defined on command line")
     fhrb = toint(fhr_start)
     startdate1=datemodel+fhrb
     startdate1@units=timeunits
     startints=ut_calendar(startdate1,0)
     datestart=ut_inv_calendar(toint(startints(:,0)),toint(startints(:,1)),toint(startints(:,2)),toint(startints(:,3)),0,0,timeunits,0)
  else
     datestart=ut_inv_calendar(scriptyear,scriptmonth,scriptday,scripthour,0,0,timeunits,0)
  end if




;;; Check to see if ending forecast hour was defined with command line argument
  if (isdefined("fhr_end")) then
     print("Ending forecast defined on command line")
     fhr_diff = toint(fhr_end) - toint(fhr_start) 
     fhre = toint(fhr_diff)
  else
     fhre=toint(0)
  end if

  enddate1=datestart+fhre
  enddate1@units=timeunits
  endints=ut_calendar(enddate1,0)

  dateend=ut_inv_calendar(toint(endints(:,0)),toint(endints(:,1)),toint(endints(:,2)),toint(endints(:,3)),0,0,timeunits,0)
  datemodel@units=timeunits




;;; Check to see if forecast hour increment was defined with command line argument
  if (isdefined("fhr_inc")) then
     print("Forecast hour increment defined on command line")
     fhri = toint(fhr_inc)
  else
     fhri=6
  end if

  fdates=ispan(toint(datestart),toint(dateend),fhri)
  fhours=ispan(toint(datestart)-toint(datemodel),toint(dateend)-toint(datemodel),fhri)


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
       parafile_geavg ="geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 mean file found (it was already downloaded)...")
       else
          print("GEFSv12 mean file is missing...")
          system("pwd")
       end if

       para_geavg=addfile("geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

; Obtaining GEFSv12 spread file
       parafile_geavg ="gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 spread file found (it was already downloaded)...")
       else
          print("GEFSv12 spread file is missing...")
          system("pwd")
       end if

       para_gespr=addfile("gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

; ----------------------------------------------------------------------------------

;Obtaining GEFSv11 mean file
       prodfile_geavg ="geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_geavg)) then
          print("GEFSv11 mean file found (it was already downloaded)...")
       else
          print("GEFSv11 mean file is missing...")
          system("pwd")
       end if

       prod_geavg=addfile("geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

;Obtaining GEFSv11 spread file
       prodfile_gespr ="gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_gespr)) then
          print("GEFSv11 spread file found (it was already downloaded)...")
       else
          print("GEFSv11 spread file is missing...")
          system("pwd")
       end if

       prod_gespr=addfile("gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")

;-----------------------------------------------------------------------------------

;  if (scriptregion .eq. "epac" .or. scriptregion .eq. "wpac" .or. scriptregion .eq. "spac" .or. scriptregion .eq. "us" .or. new_domain .eq. True)
  if (scriptregion .eq. "nh" .or. scriptregion .eq. "NH" .or. scriptregion .eq. "sh")
     CONUS_dom = False
  else
     CONUS_dom = True
  end if

print("scriptregion: "+scriptregion+" | CONUS_dom: "+CONUS_dom(0))


;;;;; Look for Stage-IV analysis file on WCOSS.
;;;;; If not found, pull file from HPSS.

if (CONUS_dom .eq. True) then

    ;;; define start and end dates for changing ST4 tarfile naming conventions on HPSS
    st4_date = cd_inv_calendar(2017,4,27,00,00,00,timeunits,0)      ; Specify date when HPSS changed

    if (thisdate .ge. st4_date) then
       st4tar = "com2_pcpanl_prod_pcpanl"
    else if (thisdate .lt. st4_date) then
       st4tar = "com_hourly_prod_nam_pcpn_anal"
    end if
    end if

    anlfile="/com2/pcpanl/prod/gfs."+ymdm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile("/gpfs/hps/nco/ops/com/gfs/prod/gfs."+ymdm+"/gfs.t"+hourm+"z.pgrb2.0p25.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    else
       if (scriptregion .eq. "pr" .or. scriptregion .eq. "ak")
          anlfile ="../analyses/st4_"+scriptregion+"."+modelstrings+".06h.grb"
       else
          anlfile ="../analyses/ST4."+modelstrings+".06h.grb"
       end if

       if (isfilepresent(anlfile)) then
          print("Stage-IV analysis file found (data was already downloaded)...")
       else
          print("Stage-IV analysis file is missing...")
       end if

   anl=addfile(anlfile,"r")
 end if

else if (CONUS_dom .eq. False) then
;;;;; Look for 1.0 GFS analysis file on WCOSS.
;;;;; If not found, pull file from HPSS.

;print("thisdate: "+thisdate)
thisdate_m6h = thisdate
thisdate_m6h = thisdate - 6
;print("thisdate_m6h: "+thisdate_m6h)

;    thisdate@units=timeunits
    newstrings=tostring(ut_calendar(thisdate_m6h,-3))
    ; GFS precip analysis date (6h forecast from 6 hours before)
    nyear=str_get_cols(newstrings,0,3)
    nmonth=str_get_cols(newstrings,4,5)
    nday=str_get_cols(newstrings,6,7)
    nhour=str_get_cols(newstrings,8,9)
    nmdh=str_get_cols(newstrings,4,9)
    nymd=str_get_cols(newstrings,0,7)
    nmonthind=toint(nmonth)

  print(" ")
  print("Analysis Date: YYYYMMDDHH (FXXX): "+nymd+nhour+" (F006))")

    anlfile="/gpfs/hps/nco/ops/com/gfs/prod/gfs."+nymd+"/"+nhour+"/gfs.t"+nhour+"z.pgrb2.1p00.f006.grib2"

    if (isfilepresent(anlfile)) then
       anl=addfile(anlfile,"r")
    else
       anlfile ="../analyses/gfs."+nymd+".t"+nhour+"z.pgrb2.1p00.f006.grib2"
       print("anlfile: "+anlfile)

       if (isfilepresent(anlfile)) then
          print("GFS analysis file found (data was already downloaded)...")
       else
          print("GFS analysis file is missing...")
       end if

       anl=addfile("../analyses/gfs."+nymd+".t"+nhour+"z.pgrb2.1p00.f006.grib2","r")
    end if

end if
end if


; ============================================================================
; ======================= Download data ======================================
; ============================================================================ 

   if (fhours(h) .eq. 0) then
      precipprod_mean=prod_geavg->TMP_P2_L103_GLL0
      precippara_mean=para_geavg->TMP_P2_L103_GLL0
      precipprod_mean=precipprod_mean*0.0
      precippara_mean=precippara_mean*0.0

      precipprod_spread=prod_gespr->TMP_P2_L103_GLL0
      precippara_spread=para_gespr->TMP_P2_L103_GLL0
      precipprod_spread=precipprod_spread*0.0
      precippara_spread=precippara_spread*0.0

   else if (fhours(h).eq. 6) then
      precipprod_mean=prod_geavg->APCP_P12_L1_GLL0_acc
      precippara_mean=para_geavg->APCP_P12_L1_GLL0_acc
      precipprod_mean=precipprod_mean*.03937
      precippara_mean=precippara_mean*.03937

      precipprod_spread=prod_gespr->APCP_P12_L1_GLL0_acc
      precippara_spread=para_gespr->APCP_P12_L1_GLL0_acc
      precipprod_spread=precipprod_spread*.03937
      precippara_spread=precippara_spread*.03937

   else
      precipprod_mean=prod_geavg->APCP_P12_L1_GLL0_acc6h
      precippara_mean=para_geavg->APCP_P12_L1_GLL0_acc6h
      precipprod_mean=precipprod_mean*.03937
      precippara_mean=precippara_mean*.03937

      precipprod_spread=prod_gespr->APCP_P12_L1_GLL0_acc6h
      precippara_spread=para_gespr->APCP_P12_L1_GLL0_acc6h
      precipprod_spread=precipprod_spread*.03937
      precippara_spread=precippara_spread*.03937

   end if
   end if

   dif = precipprod_mean
   dif = precippara_mean - precipprod_mean

if (CONUS_dom .eq. True) then
      precip_anl = anl->A_PCP_GDS5_SFC_acc6h(:,:)
      precip_anl=precip_anl*.03937
      lat2d = anl->g5_lat_0
      lon2d = anl->g5_lon_1
      precip_anl@lat2d = lat2d
      precip_anl@lon2d = lon2d
else if (CONUS_dom .eq. False) then
      precip_anl=anl->APCP_P8_L1_GLL0_acc(:,:)
      precip_anl=precip_anl*.03937
end if
end if


;printMinMax(precipprod_mean,True)
;printMinMax(precipprod_spread,True)
;printMinMax(precip_anl,True)

   precip_anl_dif = precipprod_mean
   precip_anl_dif(:,:) = 1.5

;   slpprod_mean = smth9_Wrap(slpprod_mean,0.50,0.25,False)
;   slppara_mean = smth9_Wrap(slppara_mean,0.50,0.25,False)

;do smoother = 0,5,1
;   slp_anl = smth9_Wrap(slp_anl,0.50,0.25,False)
;end do


; ============================================================================
; ======================= Make plot ==========================================
; ============================================================================

if (CONUS_dom .eq. True) then
  print("Plotting (this may take a while with hi-res Stage-IV)...")
end if

  plot_dir = image_dir+"/"+casename+"/images/"+scriptyyyymmddhh+"/"

  wks  = gsn_open_wks("png", plot_dir+"/gefs_"+scriptregion+"_6hqpf_"+casename+"_"+sprinti("%0.1i",(h)))  
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
  res@gsnRightString="6hqpf"
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
  res@cnLevels := (/0.01,0.1,0.25,0.5,0.75,1.0,1.25,1.5,1.75,2,2.5,3,3.5,4,4.5,5,5.5,6/)
  res@cnFillColors := (/-1,11,12,13,14,16,18,19,20,35,37,38,24,25,26,27,28,29,0/)
  res@cnLinesOn=False
  res@mpLimitMode="LatLon"
  res@gsnDraw=False
  ;res@mpProjection="Mercator"
  ;res@mpProjection="LambertConformal"

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
  plot(0) = gsn_csm_contour_map(wks,precipprod_spread,res)       ; create a default plot

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
  hres@cnLevels=(/0.01,0.1,0.25,0.75,1,1.5,2.0,2.5,3.0,3.5,4.0,4.5,5,5.5,6.0,6.5,7.0,7.5,8.0/)
  hres@gsnDraw=False
  hres@cnLabelMasking=True
  hres@cnLineLabelBackgroundColor=-1
  hres@cnLineLabelAngleF=0.0
  hres@cnLineThicknessF=4.0
  hres@cnLineLabelFontHeightF=.009
  hres@cnLineLabelsOn=True
  hres@cnLineColor="black"
  hres@cnLowLabelsOn=True
  hres@cnLowLabelBackgroundColor=-1
  hres@cnLowLabelFontColor="black"
  hres@cnHighLabelFontHeightF=.019
  hres@cnHighLabelFont = "helvetica-bold"
  hres@cnLowLabelFont = "helvetica-bold"
  hres@gsnFrame=False

  ;print("plotting height")
  plot_heightprod=gsn_csm_contour(wks,precipprod_mean,hres)

;-------------------------------------------------

  res@gsnLeftString="GEFSv12 Forecast initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(1) = gsn_csm_contour_map(wks,precippara_spread,res)       ; create a default plot

  ;print("plotting height")
  plot_heightpara=gsn_csm_contour(wks,precippara_mean,hres)

;-------------------------------------------------

  resdif=True
  resdif=res
  resdif@cnFillPalette=("BlueWhiteOrangeRed")
  delete(resdif@cnFillColors)
  delete(resdif@cnLevels)
  resdif@cnLevels:=(/-1.5,-1.0,-0.5,-0.25,-0.1,-0.01,0,0.01,0.1,0.25,0.5,1.0,1.5/)
  resdif@gsnLeftString="GEFSv12 Forecast minus GEFSv11 Forecast valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h))+")"
  plot(2) = gsn_csm_contour_map(wks,dif,resdif)       ; create a default plot

; -----------------------------------------------


  if (CONUS_dom .eq. True) then
     analysis_model = "Stage-IV"
  else if (CONUS_dom .eq. False) then
     analysis_model = "GFS"
  end if
  end if

  print("analysis_model: "+analysis_model)

  resanl=True
  resanl=res
  delete(resanl@cnFillColors)
  delete(resanl@cnLevels)
  resanl@cnFillColors=(/"transparent","lawngreen","green3","green4","blue1","dodgerblue1","cyan1","mediumpurple3","darkorchid3","darkorchid4","red4","red3","darkorange2","darksalmon","yellow1","sienna4","magenta2","lightpink2","mistyrose","oldlace","black"/)
  resanl@cnLevels=(/.01,0.10,0.25,0.50,0.75,1.0,1.25,1.5,1.75,2.0,2.5,3.00,4.00,5.00,6.00,7.00,7.50,8.00,9.00,10.0/)

  resanl@gsnLeftString=analysis_model+" Analysis valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F000)"
  plot(3) = gsn_csm_contour_map(wks,precip_anl,resanl)       ; create a default plot

;  plot_heightanl=gsn_csm_contour(wks,precip_anl,hres)

; -----------------------------------------------

  resP=True
  resP@gsnMaximize=True
  resP@txFontHeightF=.012
  resP@gsnPanelLabelBar=False
  ;resP@txString="initialized "+hourm+"Z "+daym+" "+months(toint(monthm))+ " " +yearm+" valid "+hour+"Z "+day+ " "+months(monthind)+ " " +year+ " (F"+sprinti("%0.2i",fhours(h-1))+")"
  resP@gsnFrame=False
  overlay(plot(0),plot_heightprod)
  overlay(plot(1),plot_heightpara)
;  overlay(plot(3),plot_heightanl)
  gsn_panel(wks,plot,(/2,2/),resP)
 
print("Framing figure")
frame(wks)
print("Deleting workstation")
delete(wks)

system("convert "+plot_dir+"/gefs_"+scriptregion+"_6hqpf_"+casename+"_"+sprinti("%0.1i",(h))+".png -trim +repage "+plot_dir+"/gefs_"+scriptregion+"_6hqpf_"+casename+"_"+sprinti("%0.1i",(h))+".png")              

end do


print("======================")
print("Script has finished!")
print("======================")


end



