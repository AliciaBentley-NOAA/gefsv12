; ===========================================
; Plots 4-panel of GEFS mean/spread & diff.
; Created by: Alicia M. Bentley
; Last updated: 28 October 2019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ===========================================
begin

print("======================")
print("Script has started!")
print("======================")

;==================================================================
;=======================START CHANGES==============================
;==================================================================

data_path = "/scratch2/NCEPDEV/stmp3/Alicia.Bentley/scripts/gefs/bomb_cyclone/"
beginyyyymmddhh = "2017122600"
endyyyymmddhh = "2018010500"
int_inc = 24
fcst_inc = 6

beginyyyymmddhh_anl = "2017122600"   
endyyyymmddhh_anl = "2018011500"    ;Trick: Add 10 days to endyyyymmddhh

beginyyyymmddhh_dprogdt = "2017122600"
endyyyymmddhh_dprogdt = "2018010500" 
dprogdt_inc = 24

data_to_check = (/"gefs","gfs","rap","st4","dprogdt"/)

;==================================================================
;=======================END CHANGES================================
;==================================================================

; Obtaining the date of the first forecast requested
  startyear=toint(str_get_cols(beginyyyymmddhh,0,3))
  startmonth=toint(str_get_cols(beginyyyymmddhh,4,5))
  startday=toint(str_get_cols(beginyyyymmddhh,6,7))
  starthour=toint(str_get_cols(beginyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datestart=ut_inv_calendar(startyear,startmonth,startday,starthour,0,0,timeunits,0)

; Obtaining the date of the last forecast requested
  endyear=toint(str_get_cols(endyyyymmddhh,0,3))
  endmonth=toint(str_get_cols(endyyyymmddhh,4,5))
  endday=toint(str_get_cols(endyyyymmddhh,6,7))
  endhour=toint(str_get_cols(endyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  dateend=ut_inv_calendar(endyear,endmonth,endday,endhour,0,0,timeunits,0)

; Obtaining the date of the first analysis requested
  astartyear=toint(str_get_cols(beginyyyymmddhh_anl,0,3))
  astartmonth=toint(str_get_cols(beginyyyymmddhh_anl,4,5))
  astartday=toint(str_get_cols(beginyyyymmddhh_anl,6,7))
  astarthour=toint(str_get_cols(beginyyyymmddhh_anl,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datestart_anl=ut_inv_calendar(astartyear,astartmonth,astartday,astarthour,0,0,timeunits,0)

; Obtaining the date of the last analysis requested
  aendyear=toint(str_get_cols(endyyyymmddhh_anl,0,3))
  aendmonth=toint(str_get_cols(endyyyymmddhh_anl,4,5))
  aendday=toint(str_get_cols(endyyyymmddhh_anl,6,7))
  aendhour=toint(str_get_cols(endyyyymmddhh_anl,8,9))
  timeunits="hours since 1800-01-01 00:00"
  dateend_anl=ut_inv_calendar(aendyear,aendmonth,aendday,aendhour,0,0,timeunits,0)

; Obtaining the date of the first dprogdt requested
  dstartyear=toint(str_get_cols(beginyyyymmddhh_dprogdt,0,3))
  dstartmonth=toint(str_get_cols(beginyyyymmddhh_dprogdt,4,5))
  dstartday=toint(str_get_cols(beginyyyymmddhh_dprogdt,6,7))
  dstarthour=toint(str_get_cols(beginyyyymmddhh_dprogdt,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datestart_dprogdt=ut_inv_calendar(dstartyear,dstartmonth,dstartday,dstarthour,0,0,timeunits,0)

; Obtaining the date of the last dprogdt requested
  dendyear=toint(str_get_cols(endyyyymmddhh_dprogdt,0,3))
  dendmonth=toint(str_get_cols(endyyyymmddhh_dprogdt,4,5))
  dendday=toint(str_get_cols(endyyyymmddhh_dprogdt,6,7))
  dendhour=toint(str_get_cols(endyyyymmddhh_dprogdt,8,9))
  timeunits="hours since 1800-01-01 00:00"
  dateend_dprogdt=ut_inv_calendar(dendyear,dendmonth,dendday,dendhour,0,0,timeunits,0)

  sdate=tostring(ut_calendar(datestart,-3))
  edate=tostring(ut_calendar(dateend,-3))
  sdate_anl=tostring(ut_calendar(datestart_anl,-3))
  edate_anl=tostring(ut_calendar(dateend_anl,-3))
  sdate_dprogdt=tostring(ut_calendar(datestart_dprogdt,-3))
  edate_dprogdt=tostring(ut_calendar(dateend_dprogdt,-3))

  print(" ")
  print("Date of first initialized forecast: "+sdate)
  print("Date of last initialized forecast:  "+edate)
  print(" ")
  print("Date of first analysis file: "+sdate_anl)
  print("Date of last analysis file:  "+edate_anl)
  print(" ")
  print("Date of first dprogdt file: "+sdate_dprogdt)
  print("Date of last dprogdt file:  "+edate_dprogdt)
  print(" ")


;================================================================

do y = 0,dimsizes(data_to_check)-1,1

model = data_to_check(y)




if model .eq. "gefs" then
  print("********************************************************************************")
  print("Looking for "+model+" data files initialized")
  print("between "+sdate+" and "+edate)

  do x = datestart,dateend,toint(int_inc)

  idate = tostring(ut_calendar(x,-3))
  print("--------------------------------------------------------------------------------")
  print("Checking GEFS forecasts (F000-F240) from initialization date: "+idate)

; Obtaining initialization date information
  hourm=str_get_cols(idate,8,9)
  ymdm=toint(str_get_cols(idate,0,7))

     do fhour = 0,240,fcst_inc
;--------------------------------------------------------------
       parafile_geavg = data_path+idate+"/geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2"
;       print("parafile_geavg: "+parafile_geavg)

       if (isfilepresent(parafile_geavg)) then
;          print("GEFSv12 mean file geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2 found!")
       else
          print("GEFSv12 mean file geavgv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2")
          print("is missing from "+data_path+idate+"/")
	  print("*******")
          system("sleep 3")
       end if
;----------------------------------------------------------------
       prodfile_geavg = data_path+idate+"/geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2"
;       print("prodfile_geavg: "+prodfile_geavg)

       if (isfilepresent(prodfile_geavg)) then
;          print("GEFSv11 mean file geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2 found!")
       else
          print("GEFSv11 mean file geavgv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2")
          print("is missing from "+data_path+idate+"/")
          print("*******")
          system("sleep 3")
       end if
;--------------------------------------------------------------
       parafile_gespr = data_path+idate+"/gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2"
;       print("parafile_gespr: "+parafile_gespr)

       if (isfilepresent(parafile_gespr)) then
;          print("GEFSv12 spread file gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2 found!")
       else
          print("GEFSv12 spread file gesprv12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2")
          print("is missing from "+data_path+idate+"/")
          print("*******")
          system("sleep 3")
       end if
;----------------------------------------------------------------
       prodfile_gespr = data_path+idate+"/gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2"
;       print("prodfile_gespr: "+prodfile_gespr)

       if (isfilepresent(prodfile_gespr)) then
;          print("GEFSv11 spread file gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2 found!")
       else
          print("GEFSv11 spread file gesprv11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhour)+".grib2")
          print("is missing from "+data_path+idate+"/")
          print("*******")
          system("sleep 3")
       end if

     end do
  end do
end if







;*****************************************************************

if (model .eq. "gfs")
  print("********************************************************************************")
  print("Looking for "+model+" data files initialized")
  print("between "+sdate_anl+" and "+edate_anl)

  do x = datestart_anl,dateend_anl,toint(fcst_inc)

  adate = tostring(ut_calendar(x,-3))
  print("--------------------------------------------------------------------------------")
  print("Checking GFS analysis date: "+adate)

; Obtaining analysis date information
  hour=str_get_cols(adate,8,9)
  ymd=toint(str_get_cols(adate,0,7))

;--------------------------------------------------------------
       gfs_anl_f000 = data_path+"analyses/gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f000.grib2"
;       print("gfs_anl_f000: "+gfs_anl_f000)

       if (isfilepresent(gfs_anl_f000)) then
;          print("GFS analysis file gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f000.grib2 found!")
       else
          print("GFS analysis file gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f000.grib2")
          print("is missing from "+data_path+"/analyses/")
          print("*******")
          system("sleep 3")
       end if
;--------------------------------------------------------------
if x .lt. dateend_anl then
       gfs_anl_f006 = data_path+"analyses/gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f006.grib2"
;       print("gfs_anl_f006: "+gfs_anl_f006)

       if (isfilepresent(gfs_anl_f006)) then
;          print("GFS analysis file gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f006.grib2 found!")
       else
          print("GFS analysis file gfs."+ymd+".t"+hour+"z.pgrb2.1p00.f006.grib2 is missing")
          print("from "+data_path+"analyses/")
          print("*******")
          system("sleep 3")
       end if
end if

  end do

end if







;*****************************************************************

if (model .eq. "rap")
  print("********************************************************************************")
  print("Looking for "+model+" data files initialized")
  print("between "+sdate_anl+" and "+edate_anl)

  do x = datestart_anl,dateend_anl,toint(fcst_inc)

  adate = tostring(ut_calendar(x,-3))
  print("--------------------------------------------------------------------------------")
  print("Checking RAP analysis date: "+adate)

; Obtaining analysis date information
  hour=str_get_cols(adate,8,9)
  ymd=toint(str_get_cols(adate,0,7))

;--------------------------------------------------------------
       rap_anl = data_path+"analyses/rap."+ymd+".t"+hour+"z.awip32f00.grib2"
;       print("rap_anl: "+rap_anl)

       if (isfilepresent(rap_anl)) then
;          print("RAP analysis file rap."+ymd+".t"+hour+"z.awip32f00.grib2 found!")
       else
          print("RAP analysis file rap."+ymd+".t"+hour+"z.awip32f00.grib2 is missing")
          print("from "+data_path+"/analyses/")
          print("*******")
          system("sleep 3")
       end if

  end do

end if





;*****************************************************************

if (model .eq. "st4")
  print("********************************************************************************")
  print("Looking for "+model+" data files initialized")
  print("between "+sdate_anl+" and "+edate_anl)

  do x = datestart_anl,dateend_anl,toint(fcst_inc)

  adate = tostring(ut_calendar(x,-3))
  print("--------------------------------------------------------------------------------")
  print("Checking Stage-IV analysis date: "+adate)

; Obtaining analysis date information
  hour=str_get_cols(adate,8,9)
  ymd=toint(str_get_cols(adate,0,7))

;--------------------------------------------------------------
       st4_anl = data_path+"analyses/ST4."+ymd+hour+".06h.grb"
;       print("st4_anl: "+st4_anl)

       if (isfilepresent(st4_anl)) then
;          print("Stage-IV analysis file ST4."+ymd+hour+".06h.grb found!")
       else
          print("Stage-IV analysis file ST4."+ymd+hour+".06h.grb is missing")
          print("from "+data_path+"/analyses/")
          print("*******")
          system("sleep 3")
       end if

  end do

end if






if model .eq. "dprogdt" then
  print("********************************************************************************")
  print("Looking for "+model+" data files initialized")
  print("between "+sdate_dprogdt+" and "+edate_dprogdt)

  fhr = toint(240)

  do x = datestart_dprogdt,dateend_dprogdt,toint(dprogdt_inc)

  idate = tostring(ut_calendar(x,-3))
  print("--------------------------------------------------------------------------------")
  print("Checking for dprogdt GEFS members from initialization date: "+idate+" (F"+sprinti("%0.3i",fhr)+")")

; Obtaining initialization date information
  hourm=str_get_cols(idate,8,9)
  ymdm=toint(str_get_cols(idate,0,7))

;-------------------------------------------------------------
     do member = 0,30,1  ; ensemble members

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

if member .le. 30 then
       prodfile_mem = data_path+"members/"+mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2"
;       print("prodfile_mem: "+prodfile_mem)

       if (isfilepresent(prodfile_mem)) then
;          print(Ensemble member file "+mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2 found!")
       else
          print("Ensemble member file "+mem_name+"v12."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2")
          print("is missing from "+data_path+"members/")
          print("*******")
       end if
end if

if member .le. 20 then
       prodfile_mem = data_path+"members/"+mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2"
;       print("prodfile_mem: "+prodfile_mem)

       if (isfilepresent(prodfile_mem)) then
;          print(Ensemble member file "+mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2 found!")
       else
          print("Ensemble member file "+mem_name+"v11."+ymdm+".t"+hourm+"z.pgrb2a.1p00.f"+sprinti("%0.3i",fhr)+".grib2")
          print("is missing from "+data_path+"members/")
          print("*******")
       end if
end if

     end do     ; end member
;-------------------------------------------------------------

  fhr = fhr - toint(24)

  end do
end if






end do


print("======================")
print("Script has finished!")
print("======================")


end



