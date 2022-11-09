;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1850
Endyr=1999

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1

 model=(/"ACCESS-ESM1-5"/)
 nmodel=dimsizes(model)

varname=(/"tas"/)
nvar=dimsizes(varname)

runner="1pctCO2"
nrun=1

 do ivar= 0,nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

 do irun=0,nrun-1

   run="r"+(irun+1)+"i1p1f1_gn" 
 
   FilePath="/mnt/f/CMIP6-C4MIP/"+model(imodel)+"/"+runner+"/"
   FileName=varname(ivar)+"_Amon_"+model(imodel)+"_"+runner+"_"+run+"_"+"010101-"+"025012.nc"
   OutFileName="Monthly_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.nc"
   OutFileNameAnn="Annual_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".nc"

   fin=addfile(FilePath+FileName,"r")
   printVarSummary(fin)
   latitude=fin->lat
   longitude=fin->lon
   latitude@units="degrees_north"
   longitude@units="degrees_east"
   time=fin->time
   data=fin->$varname(ivar)$  ;;; Pa
   data@_FillValue=-99999.
   data@missing_value=-99999.
   printVarSummary(data)
   ntime=dimsizes(time)
   nlat=dimsizes(latitude)
   nlon=dimsizes(longitude)

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=(/data(ism:iem,:,:)/) ;*1.0e-2  ;; from Pa to hPa
  data_cf!0="time"
  data_cf!1="latitude"
  data_cf!2="longitude"
  data_cf&time=ispan(1,(iem-ism+1),1)
  data_cf&latitude=latitude
  data_cf&longitude=longitude
  data_cf@units="K"
  data_cf@_FillValue=-99999. ;  data@_FillValue
  data_cf@missing_value=-99999.  ; data@missing_value
  data_cf@long_name=data@long_name

  data_cf_ann=new((/nyear,nlat,nlon/),typeof(data))
  data_cf_ann!0="year"
  data_cf_ann!1="latitude"
  data_cf_ann!2="longitude"
  data_cf_ann&year=year
  data_cf_ann&latitude=latitude
  data_cf_ann&longitude=longitude
  data_cf_ann@units="K"
  data_cf_ann@_FillValue=data_cf@_FillValue
  data_cf_ann@missing_value=data_cf@missing_value
  data_cf_ann@long_name=data_cf@long_name

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
   data_cf_ann(iyear,:,:)=dim_avg_n(data_cf(isy:iey,:,:),0)
  end do

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   fx=addfile("/mnt/f/CMIP6-C4MIP/"+model(imodel)+"/sftlf_fx_"+model(imodel)+"_historical_r1i1p1f1_gn.nc","r")
   sftlf = fx->sftlf

   maskland=where(sftlf.gt.10,1,data_cf@_FillValue)
   maskland@_FillValue=data_cf@_FillValue
   mask_cf=conform_dims(dimsizes(data_cf),maskland,(/1,2/))
   mask_cf_ann=conform_dims(dimsizes(data_cf_ann),maskland,(/1,2/))

   data_cf = data_cf * mask_cf
   data_cf_ann = data_cf_ann * mask_cf_ann
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   wgt = cos(latitude*3.14159/180.)

   data_cf_wgt = dim_avg_n(dim_avg_wgt_n(data_cf,wgt,1,(/1/)),(/1/) )
   data_cf_wgt!0="time"
   data_cf_wgt&time=time

   data_cf_ann_wgt = dim_avg_n(dim_avg_wgt_n(data_cf_ann,wgt,1,(/1/)),(/1/) )
   data_cf_ann_wgt!0="year"
   data_cf_ann_wgt&year=year

   asciiwrite("Total_monthly_"+varname(ivar)+"_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.txt",data_cf_wgt)
   asciiwrite("Total_annual_"+varname(ivar)+"_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".txt",data_cf_ann_wgt)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   system("rm -f "+OutFileName)
   fout=addfile(OutFileName,"c")
   fout->$varname(ivar)$=data_cf

   system("rm -f "+OutFileNameAnn)
   fout=addfile(OutFileNameAnn,"c")
   fout->$varname(ivar)$=data_cf_ann


   delete(fin)
   delete(data)
   delete(latitude)
   delete(longitude)
   delete(time)
   delete(data_cf)
   delete(data_cf_wgt)
   delete(data_cf_ann)
   delete(data_cf_ann_wgt)

 end do
 end do
 end do 

end
