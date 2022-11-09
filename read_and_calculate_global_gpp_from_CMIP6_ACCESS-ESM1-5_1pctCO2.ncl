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

varname=(/"gpp"/)
nvar=dimsizes(varname)

runner="1pctCO2"
nrun=1

daysofmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

 do ivar= 0,nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

 do irun=0,nrun-1

   run="r"+(irun+1)+"i1p1f1_gn" 
 
   FilePath="/mnt/f/CMIP6-C4MIP/"+model(imodel)+"/"+runner+"/"
   FileName=varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+"010101-"+"025012.nc"
   OutFileName="Monthly_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.nc"
   OutFileNameAnn="Annual_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".nc"

   OutFileName2="Monthly_"+varname(ivar)+"_area_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.nc"
   OutFileNameAnn2="Annual_"+varname(ivar)+"_area_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".nc"


   fin=addfile(FilePath+FileName,"r")
   printVarSummary(fin)
   latitude=fin->lat
   longitude=fin->lon
   latitude@units="degrees_north"
   longitude@units="degrees_east"
   time=fin->time
   data=fin->$varname(ivar)$  ;;; kgC/m2/s
   data@_FillValue=-99999.
   data@missing_value=-99999.
   printVarSummary(data)
   ntime=dimsizes(time)
   nlat=dimsizes(latitude)
   nlon=dimsizes(longitude)

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=(/data(ism:iem,:,:)/) ; *1.0e-3
  data_cf!0="time"
  data_cf!1="latitude"
  data_cf!2="longitude"
  data_cf&time=ispan(1,(iem-ism+1),1)
  data_cf&latitude=latitude
  data_cf&longitude=longitude
  data_cf@units="KgC/m2/month"
  data_cf@_FillValue=-99999. ;  data@_FillValue
  data_cf@missing_value=-99999.  ; data@missing_value

  data_cf_ann=new((/nyear,nlat,nlon/),typeof(data))
  data_cf_ann!0="year"
  data_cf_ann!1="latitude"
  data_cf_ann!2="longitude"
  data_cf_ann&year=year
  data_cf_ann&latitude=latitude
  data_cf_ann&longitude=longitude
  data_cf_ann@units="KgC/m2/year"
  data_cf_ann@_FillValue=data_cf@_FillValue
  data_cf_ann@missing_value=data_cf@missing_value

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
   data_cf(isy:iey,:,:)=data_cf(isy:iey,:,:)*conform(data_cf(isy:iey,:,:),daysofmonth,0)*24*3600
   data_cf_ann(iyear,:,:)=dim_sum_n(data_cf(isy:iey,:,:),0)
  end do

   system("rm -f "+OutFileName)
   fout=addfile(OutFileName,"c")
   fout->$varname(ivar)$=data_cf

   system("rm -f "+OutFileNameAnn)
   fout=addfile(OutFileNameAnn,"c")
   fout->$varname(ivar)$=data_cf_ann

   delete(fin)
   delete(data)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

   fx=addfile("/mnt/f/CMIP6-C4MIP/"+model(imodel)+"/areacella_fx_"+model(imodel)+"_historical_r1i1p1f1_gn.nc","r")
   area = fx->areacella

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   data_cf_area=data_cf
   data_cf_area=0.
   data_cf_area@units="PgC/month"  ;; from KgC/m2/month

   data_cf_ann_area=data_cf_ann
   data_cf_ann_area=0.
   data_cf_ann_area@units="PgC/year"

   area_cf=conform_dims(dimsizes(data_cf),area,(/1,2/))
   data_cf_area=data_cf*area_cf*1.0e-12 ;;PgC/month

   area_cf_ann=conform_dims(dimsizes(data_cf_ann),area,(/1,2/))
   data_cf_ann_area=data_cf_ann*area_cf_ann*1.0e-12 ;;PgC/month


   printVarSummary(area_cf)
   printVarSummary(data_cf)
   printVarSummary(data_cf_area)

   data_area_tot=dim_sum_n(data_cf_area,(/1,2/))
  ; print(data_area_tot)
   data_ann_area_tot=dim_sum_n(data_cf_ann_area,(/1,2/))
   print(data_ann_area_tot)

   asciiwrite("Total_monthly_"+varname(ivar)+"_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.txt",data_area_tot)
   asciiwrite("Total_annual_"+varname(ivar)+"_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".txt",data_ann_area_tot)

   system("rm -f "+OutFileName2)
   fout=addfile(OutFileName2,"c")
   fout->$varname(ivar)$=data_cf_area
   fout->area=area

   system("rm -f "+OutFileNameAnn2)
   fout=addfile(OutFileNameAnn2,"c")
   fout->$varname(ivar)$=data_cf_ann_area
   fout->area=area

   delete(latitude)
   delete(longitude)
   delete(time)
   delete(data_cf)
   delete(data_cf_area)
   delete(data_cf_ann)
   delete(data_cf_ann_area)

 end do
 end do
 end do 

end
