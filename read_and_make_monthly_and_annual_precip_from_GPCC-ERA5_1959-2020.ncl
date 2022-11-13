;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1959
Endyr=2020

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1
year@calendar = "standard"

month=ispan(1,12,1)
month_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nmonth=12

daysofmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

model="GPCC-ERA5"
varname="precip"

 tst=(1959-1891)*12
 ted=(2020-1891+1)*12-1

 fin1=addfile("full_data_monthly_v2022_1891-2020_025.nc","r")
 pr_gpcc = fin1->precip(tst:ted,:,:)  ;; from 1959-2020 ,, lat 90 to -90,,lon -180 to 180
 printVarSummary(pr_gpcc)

 time= pr_gpcc&time
 lat = pr_gpcc&lat
 lon = pr_gpcc&lon
 ntime=dimsizes(pr_gpcc&time)
 nlat=dimsizes(pr_gpcc&lat)
 nlon=dimsizes(pr_gpcc&lon)


 tst=(1959-1959)*12
 ted=(2020-1959+1)*12-1

 fin2=addfile("Monthly_precip_ERA5_195901-202112_025.nc","r")
 pr_era = fin2->precip(tst:ted,:,:)  ;; from 1959-2020
 printVarSummary(pr_era)


  data_cf = where(ismissing(pr_gpcc),pr_era,pr_gpcc)
  copy_VarAtts(pr_gpcc,data_cf)
  data_cf@_FillValue=pr_gpcc@_FillValue
  data_cf@missing_value=pr_gpcc@missing_value
  data_cf@long_name="precipitation from GPCC on land and from ERA5 on ocean"

  data_cf_ann=new((/nyear,nlat,nlon/),typeof(data_cf))
  data_cf_ann!0="year"
  data_cf_ann!1="lat"
  data_cf_ann!2="lon"
  data_cf_ann&year=year
  data_cf_ann&lat=lat
  data_cf_ann&lon=lon
  data_cf_ann@units="mm/year"
  data_cf_ann@_FillValue=data_cf@_FillValue
  data_cf_ann@missing_value=data_cf@missing_value
  data_cf_ann@long_name=data_cf@long_name

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
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

   asciiwrite("Total_monthly_"+varname+"_"+model+"_"+Startyr+"01-"+Endyr+"12.txt",data_cf_wgt)
   asciiwrite("Total_annual_"+varname+"_"+model+"_"+Startyr+"-"+Endyr+".txt",data_cf_ann_wgt)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   OutFileName="Monthly_"+varname+"_"+model+"_"+Startyr+"01-"+Endyr+"12_025.nc"
   OutFileNameAnn="Annual_"+varname+"_"+model+"_"+Startyr+"-"+Endyr+"_025.nc"

   system("rm -f "+OutFileName)
   fout=addfile(OutFileName,"c")
   fout->$varname$=data_cf

   system("rm -f "+OutFileNameAnn)
   fout=addfile(OutFileNameAnn,"c")
   fout->$varname$=data_cf_ann

end

