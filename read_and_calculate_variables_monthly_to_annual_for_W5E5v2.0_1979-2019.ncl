;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1979
Endyr=2019

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1
year@calendar = "standard"

month=ispan(1,12,1)
month_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nmonth=12

daysofmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

ntime=nyear*nmonth
time=ispan(1,ntime,1)

model=(/"W5E5v2.0"/)
nmodel=dimsizes(model)

 varname=(/"hurs","huss","prsn","ps","psl","rlds","rsds","sfcWind","tas","tasmax","tasmin"/)
 nvar=dimsizes(varname)

 do ivar= 0, nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

   Files=systemfunc("ls Monthly_197901-201912/Monthly_"+varname(ivar)+"_"+model(imodel)+"_*.nc")

   fin=addfiles(Files,"r")
   printVarSummary(fin)
   ListSetType (fin, "join")
   data=fin[:]->$varname(ivar)$  ;;; water in kg/m2/s = mm/s
   data!0="time"
   data&time=time
   printVarSummary(data)

   lat=data&lat
   lon=data&lon
   nlat=dimsizes(lat)
   nlon=dimsizes(lon)

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=(/data(ism:iem,:,:)/)
  data_cf!0="time"
  data_cf!1="lat"
  data_cf!2="lon"
  data_cf&time=ispan(1,(iem-ism+1),1)
  data_cf&lat=lat
  data_cf&lon=lon
  data_cf@units=data@units
  data_cf@_FillValue=data@_FillValue
  data_cf@missing_value=data@missing_value
  data_cf@long_name=data@long_name

  data_cf_ann=new((/nyear,nlat,nlon/),typeof(data))
  data_cf_ann!0="year"
  data_cf_ann!1="lat"
  data_cf_ann!2="lon"
  data_cf_ann&year=year
  data_cf_ann&lat=lat
  data_cf_ann&lon=lon
  data_cf_ann@units=data@units
  data_cf_ann@_FillValue=data_cf@_FillValue
  data_cf_ann@missing_value=data_cf@missing_value
  data_cf_ann@long_name=data_cf@long_name

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
   data_cf_ann(iyear,:,:)=dim_avg_n(data_cf(isy:iey,:,:),0)
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
