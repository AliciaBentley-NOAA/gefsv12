; ===========================================
; Download data for GEFS retrospectives
; Created by: Alicia M. Bentley
; Last updated: 4 December 2019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ===========================================
begin

print("======================")
print("Forecast script has started!")
print("======================")

; Define casename
  if (isdefined("eventname")) then
        print("Eventname defined on command line: "+eventname)
        casename = eventname
  else
        print("No eventname defined on command line")
        casename = "eventname"
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
        print("Domain defined on command line")
        scriptregion=str_lower(scriptregion)
     end if
  else
     scriptregion="us"
  end if
  do c=0,dimsizes(regionlist)-1
    if (regionlist(c).eq.scriptregion) then
      minlat=minlatlist(c)
      minlon=minlonlist(c)
      maxlat=maxlatlist(c)
      maxlon=maxlonlist(c)
    end if
  end do
 
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
    parafile_geavg=WCOSS_dir+"/"+ymm+"/"+ymdm+"/geavg.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
    if (isfilepresent(parafile_geavg)) then
       para_geavg=addfile(parafile_geavg,"r")
       print("Found GEFSv12 mean file on WCOSS")
    else
       parafile_geavg ="geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 mean file found (it was already downloaded)...")
       else
          print("Downloading GEFSv12 mean file from HPSS...")
          cmd = "htar -xvf "+archive_dir+"/"+ymm+"/"+ymdm+"/gefs."+ymdm+"_"+hourm+".pgrb2a1p0.tar"  + \
                " pgrb2a1p0/geavg.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
          ;print(cmd) 
          system(cmd)

          cmd = "mv pgrb2a1p0/geavg.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h)) + \
                " ./geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a1p0/"
          system(cmd)
       end if

       para_geavg=addfile("geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if

;-----------------------------------------------------------------------------------

; Obtaining GEFSv12 spread file
    parafile_gespr=WCOSS_dir+"/"+ymm+"/"+ymdm+"/gespr.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
    if (isfilepresent(parafile_gespr)) then
       para_gespr=addfile(parafile_gespr,"r")
       print("Found GEFSv12 spread file on WCOSS")
    else
       parafile_geavg ="gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_geavg)) then
          print("GEFSv12 spread file found (it was already downloaded)...")
       else
          print("Downloading GEFSv12 spread file from HPSS...")
          cmd = "htar -xvf "+archive_dir+"/"+ymm+"/"+ymdm+"/gefs."+ymdm+"_"+hourm+".pgrb2a1p0.tar"  + \
                " pgrb2a1p0/gespr.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
          ;print(cmd)
          system(cmd)

          cmd = "mv pgrb2a1p0/gespr.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h)) + \
                " ./gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a1p0/"
          system(cmd)
       end if

       para_gespr=addfile("gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if

; ----------------------------------------------------------------------------------

;Obtaining GEFSv11 mean file
    prodfile_geavg=WCOSS_dir+"/"+ymm+"/"+ymdm+"/geavg.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
    if (isfilepresent(prodfile_geavg)) then
       prod_geavg=addfile(prodfile_geavg,"r")
       print("Found GEFSv11 mean file on WCOSS")
    else
       prodfile_geavg ="geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_geavg)) then
          print("GEFSv11 mean file found (it was already downloaded)...")
       else
          print("Downloading GEFSv11 mean file from HPSS...")
          cmd = "htar -xvf "+prod_dir+"/"+ymm+"/"+ymdm+"/"+gefstar+"."+ymdm+"_"+hourm+".pgrb2a.tar"  + \
                " ./pgrb2a/geavg.t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h))
          ;print(cmd)
          system(cmd)

          cmd = "mv pgrb2a/geavg.t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h)) + \
                " ./geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a/"
          system(cmd)
       end if

       prod_geavg=addfile("geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if

;-----------------------------------------------------------------------------------

;Obtaining GEFSv11 spread file
    prodfile_geapr=WCOSS_dir+"/"+ymm+"/"+ymdm+"/geapr.t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
    if (isfilepresent(prodfile_geapr)) then
       prod_geapr=addfile(prodfile_geapr,"r")
       print("Found GEFSv11 spread file on WCOSS")
    else
       prodfile_gespr ="gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_gespr)) then
          print("GEFSv11 spread file found (it was already downloaded)...")
       else
          print("Downloading GEFSv11 spread file from HPSS...")
          cmd = "htar -xvf "+prod_dir+"/"+ymm+"/"+ymdm+"/"+gefstar+"."+ymdm+"_"+hourm+".pgrb2a.tar"  + \
                " ./pgrb2a/gespr.t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h))
          ;print(cmd)
          system(cmd)

          cmd = "mv pgrb2a/gespr.t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h)) + \
                " ./gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a/"
          system(cmd)
       end if

       prod_gespr=addfile("gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2","r")
    end if

end do

print("=============================")
print("Forecast script has finished!")
print("=============================")


end



