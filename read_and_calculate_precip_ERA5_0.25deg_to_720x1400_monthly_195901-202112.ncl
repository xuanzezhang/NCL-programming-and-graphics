;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin


 fin1=addfile("full_data_monthly_v2022_1891-2020_025.nc","r")
 lat = fin1->lat
 lon = fin1->lon

 fin2=addfile("Monthly_precip_ERA5_195901-202112.nc","r")
 data_in = fin2->precip
 printVarSummary(data_in)

 ntime=dimsizes(data_in&time)
 nlat=dimsizes(data_in&latitude)
 nlon=dimsizes(data_in&longitude)

 data=new((/ntime,nlat,nlon/),"float")
 data!0="time"
 data!1="lat"
 data!2="lon"
 data&time=data_in&time
 data&lat=data_in&latitude
 data&lon=data_in&longitude-180

 data(:,:,0:(nlon/2-1))=(/data_in(:,:,(nlon/2):(nlon-1))/)
 data(:,:,(nlon/2):(nlon-1))=(/data_in(:,:,0:(nlon/2-1))/)

 data_out=linint2_Wrap(data&lon,data&lat(::-1),data(time|:,lat|::-1,lon|:),True,lon,lat(::-1),0)
 data_out!0="time"
 data_out!1="lat"
 data_out!2="lon"
 data_out&time=data_in&time
 data_out&lat=lat(::-1)
 data_out&lon=lon
 data_out@units=data_in@units
 data_out&lat@units="degree_north"
 data_out&lon@units="degree_east"
 printVarSummary(data_out)

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   wgt = cos(lat*3.14159/180.)

   data_cf_wgt = dim_avg_n(dim_avg_wgt_n(data_out,wgt,1,(/1/)),(/1/) )

   asciiwrite("Total_monthly_precip_ERA5_195901-202112.txt",data_cf_wgt)

 setfileoption("nc", "Format",  "NetCDF4Classic")

 system("rm -rf Monthly_precip_ERA5_195901-202112_025.nc")
 fout=addfile("Monthly_precip_ERA5_195901-202112_025.nc","c")
 fout->precip=data_out(:,::-1,:)


end

