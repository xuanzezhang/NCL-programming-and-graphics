;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1959
Endyr=2021

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1
year@calendar = "standard"

month=ispan(1,12,1)
month_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nmonth=12

daysofmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

model=(/"ERA5"/)
nmodel=dimsizes(model)

 varname=(/"precip"/)
 nvar=dimsizes(varname)

 do ivar= 0, nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

    fin=addfile("ERA5-1959-2022/ERA5_total_precipitation_monthly_1959-2021.nc","r")
    data=short2flt(fin->tp)  ;; in units of m/day
    printVarSummary(data)

   data = data * 1000  ;; convert to mm/day

   time=data&time
   lat=data&latitude
   lon=data&longitude
   nlat=dimsizes(lat)
   nlon=dimsizes(lon)
   ntime=dimsizes(time)

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=(/data(ism:iem,:,:)/)
  data_cf!0="time"
  data_cf!1="latitude"
  data_cf!2="longitude"
  data_cf&time=time
  data_cf&latitude=lat
  data_cf&longitude=lon
  data_cf@units="mm/month"
  data_cf@_FillValue=data@_FillValue
  data_cf@missing_value=data@missing_value
  data_cf@long_name=data@long_name

  data_cf_ann=new((/nyear,nlat,nlon/),typeof(data))
  data_cf_ann!0="year"
  data_cf_ann!1="latitude"
  data_cf_ann!2="longitude"
  data_cf_ann&year=year
  data_cf_ann&latitude=lat
  data_cf_ann&longitude=lon
  data_cf_ann@units="mm/year"
  data_cf_ann@_FillValue=data_cf@_FillValue
  data_cf_ann@missing_value=data_cf@missing_value
  data_cf_ann@long_name=data_cf@long_name

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
   data_cf(isy:iey,:,:)=data_cf(isy:iey,:,:)*conform(data_cf(isy:iey,:,:),daysofmonth,0)
   data_cf_ann(iyear,:,:)=dim_sum_n(data_cf(isy:iey,:,:),0)
  end do

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   wgt = cos(lat*3.14159/180.)

   data_cf_wgt = dim_avg_n(dim_avg_wgt_n(data_cf,wgt,1,(/1/)),(/1/) )
   data_cf_wgt!0="time"
   data_cf_wgt&time=time

   data_cf_ann_wgt = dim_avg_n(dim_avg_wgt_n(data_cf_ann,wgt,1,(/1/)),(/1/) )
   data_cf_ann_wgt!0="year"
   data_cf_ann_wgt&year=year

   asciiwrite("Total_monthly_"+varname(ivar)+"_"+model(imodel)+"_"+Startyr+"01-"+Endyr+"12.txt",data_cf_wgt)
   asciiwrite("Total_annual_"+varname(ivar)+"_"+model(imodel)+"_"+Startyr+"-"+Endyr+".txt",data_cf_ann_wgt)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   OutFileName="Monthly_"+varname(ivar)+"_"+model(imodel)+"_"+Startyr+"01-"+Endyr+"12.nc"
   OutFileNameAnn="Annual_"+varname(ivar)+"_"+model(imodel)+"_"+Startyr+"-"+Endyr+".nc"

   setfileoption("nc", "Format",  "NetCDF4Classic")

   system("rm -f "+OutFileName)
   fout=addfile(OutFileName,"c")
   fout->$varname(ivar)$=data_cf

   system("rm -f "+OutFileNameAnn)
   fout=addfile(OutFileNameAnn,"c")
   fout->$varname(ivar)$=data_cf_ann

   delete(fin)
   delete(data)
   delete(lat)
   delete(lon)
   delete(data_cf)
   delete(data_cf_wgt)
   delete(data_cf_ann)
   delete(data_cf_ann_wgt)

 end do

 end do


end 
