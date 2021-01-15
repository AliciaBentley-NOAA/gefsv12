; ===========================================
; Plots 4-panel of GEFS mean/spread & diff.
; Created by: Alicia M. Bentley
; Last updated: 17 December 2019
; ===========================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; ===========================================
begin

print("======================")
print("Script has started!")
print("======================")

;==================================================================

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

; Obtaining the date of the forecast requested 
  startyear=toint(str_get_cols(beginyyyymmddhh,0,3))
  startmonth=toint(str_get_cols(beginyyyymmddhh,4,5))
  startday=toint(str_get_cols(beginyyyymmddhh,6,7))
  starthour=toint(str_get_cols(beginyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datestart=ut_inv_calendar(startyear,startmonth,startday,starthour,0,0,timeunits,0)

; =================================================================

; Obtaining the date of the forecast requested
  endyear=toint(str_get_cols(endyyyymmddhh,0,3))
  endmonth=toint(str_get_cols(endyyyymmddhh,4,5))
  endday=toint(str_get_cols(endyyyymmddhh,6,7))
  endhour=toint(str_get_cols(endyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  dateend=ut_inv_calendar(endyear,endmonth,endday,endhour,0,0,timeunits,0)

;==================================================================

; Obtaining the date of the valid time requested
  validyear=toint(str_get_cols(validyyyymmddhh,0,3))
  validmonth=toint(str_get_cols(validyyyymmddhh,4,5))
  validday=toint(str_get_cols(validyyyymmddhh,6,7))
  validhour=toint(str_get_cols(validyyyymmddhh,8,9))
  timeunits="hours since 1800-01-01 00:00"
  datevalid=ut_inv_calendar(validyear,validmonth,validday,validhour,0,0,timeunits,0)

;==================================================================

;;; Check to see if forecast hour increment was defined with command line argument
  if (isdefined("fhr_inc")) then
     print("Forecast hour increment defined on command line")
     fhri = toint(fhr_inc)
  else
     fhri=24
  end if

;==================================================================

; Define "plots" to move
  if (isdefined("plots")) then
        print("'plots' to move are defined on command line:")
        print("plots: "+plots)
        print(" ")
  else
        print("No plots to move defined on command line")
        print("Will try to move 'lows' and 'spag'")
        plots = (/"lows","spag"/)
  end if

;==================================================================

; Define "domains" to move
  if (isdefined("domains")) then
        print("'domains' to move are defined on command line:")
        print("domains: "+domains)
        print(" ")
  else
        print("No domains to move defined on command line")
        print("Will try to move 'us' and 'nwatl'")
        domains = (/"us","nwatl"/)
  end if

;==================================================================

  fhours=ispan(toint(datestart)-toint(datevalid),toint(dateend)-toint(datevalid),fhri)

print(fhours)

  new_nums = toint(fhours)
  new_nums = toint((fhours*-1)/24.)
;  new_nums = new_nums(::-1)

print(new_nums)

;===================================================================

sdate=tostring(ut_calendar(datestart,-3))
edate=tostring(ut_calendar(dateend,-3))
vdate=tostring(ut_calendar(datevalid,-3))
print(" ")
print("sdate: "+sdate)
print("edate: "+edate)
print("vdate: "+vdate)
print(" ")

counter=new_nums(0)

do x = datestart,dateend,toint(fhr_inc)

idate = tostring(ut_calendar(x,-3))
print("idate: "+idate)

endlistz = dimsizes(domains)
do z = 0,endlistz-1,1
   scriptregion = domains(z)
   endlist = dimsizes(plots)
   do y = 0,endlist-1,1
      fill = plots(y)
      system("'cp' "+image_dir+"/dprogdt/gefs_"+scriptregion+"_"+fill+"_"+casename+"_int"+idate+"_val"+vdate+".png "+image_dir+"/dprogdt/gefs_"+scriptregion+"_"+fill+"_"+casename+"_"+counter+".png")
   end do
end do

counter = counter - 1

end do


print("======================")
print("Script has finished!")
print("======================")


end



