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

       parafile_mem = mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(parafile_mem)) then
          print("GEFSv12 "+mem_name+" file found (it was already downloaded)...")
       else
          print("Downloading GEFSv12 "+mem_name+" file from HPSS...")
          cmd = "htar -xvf "+archive_dir+"/"+ymm+"/"+ymdm+"/gefs."+ymdm+"_"+hourm+".pgrb2a1p0.tar"  + \
                " pgrb2a1p0/"+mem_name+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))
;          print(cmd)
          system(cmd)

          cmd = "mv pgrb2a1p0/"+mem_name+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h)) + \
                " ./"+mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a1p0/"
          system(cmd)
       end if

end do

; ----------------------------------------------------------------------------------

print(" ")
; Obtaining GEFSv11 ensmeble member files

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

       prodfile_mem = mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
       if (isfilepresent(prodfile_mem)) then
          print("GEFSv11 "+mem_name+" file found (it was already downloaded)...")
       else
          print("Downloading GEFSv11 "+mem_name+" file from HPSS...")
          cmd = "htar -xvf "+prod_dir+"/"+ymm+"/"+ymdm+"/"+gefstar+"."+ymdm+"_"+hourm+".pgrb2a.tar"  + \
                " ./pgrb2a/"+mem_name+".t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h))
          ;print(cmd)
          system(cmd)

          cmd = "mv pgrb2a/"+mem_name+".t"+hourm+"z.pgrb2af"+sprinti("%0.2i",fhours(h)) + \
                " ./"+mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhours(h))+".grib2"
          system(cmd)

          cmd = "rm -fR pgrb2a/"
          system(cmd)
       end if

end do

end do  ; end do of forecast hour

;-------------------------------------------------------------------------------

cmd = "mkdir -p ../members/"
print(cmd)
system(cmd)

cmd2 = "'mv' gec00*.grib2 ../members/."
print(cmd2)
system(cmd2)

cmd3 = "'mv' gep*.grib2 ../members/."
print(cmd3)
system(cmd3)


;-------------------------------------------------------------------------------

print("======================")
print("Script has finished!")
print("======================")


end



