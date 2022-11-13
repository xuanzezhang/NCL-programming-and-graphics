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

model=(/"ERA5"/)
nmodel=dimsizes(model)


fin=addfile("ERA5-1959-2022/ERA5_total_precipitation_monthly_1959-2021.nc","r")
data=short2flt(fin->tp)  ;; in units of m/day
printVarSummary(data)

data = data * 1000  ;; convert to mm/day

lat=data&latitude
lon=data&latitude

 nlat=dimsizes(lat)
 nlon=dimsizes(lon)

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=(/data(ism:iem,:,:)/)
  data_cf!0="time"
  data_cf!1="lat"
  data_cf!2="lon"
  data_cf&time=time
  data_cf&lat=lat
  data_cf&lon=lon
  data_cf@units="mm/month"
  data_cf@_FillValue=data@_FillValue
  data_cf@missing_value=data@missing_value
  data_cf@long_name=data@long_name







system("rm -rf ERA5_climatology_and_anomaly_in_total_precipitation_monthly_1959-2021.nc")
fout=addfile("ERA5_climatology_and_anomaly_in_total_precipitation_monthly_1959-2021.nc","c")
fout->tpClm = tpClm




