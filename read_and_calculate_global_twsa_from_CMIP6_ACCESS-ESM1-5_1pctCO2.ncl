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

;;;Calculate terrestrial water storage anomaly from dtws=P-ET-Q
varname=(/"twsa"/)
nvar=dimsizes(varname)

var1="dtws"         ;; in mm/month

runner="1pctCO2"
nrun=1

daysofmonth=(/31,28,31,30,31,30,31,31,30,31,30,31/)

 do ivar= 0,nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

 do irun=0,nrun-1

   run="r"+(irun+1)+"i1p1f1_gn" 
 
   FilePath1="./"
   FileName1="Monthly_"+var1+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.nc"

   OutFileName="Monthly_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"01-"+Endyr+"12.nc"
   OutFileNameAnn="Annual_"+varname(ivar)+"_Lmon_"+model(imodel)+"_"+runner+"_"+run+"_"+Startyr+"-"+Endyr+".nc"

   fin1=addfile(FilePath1+FileName1,"r")
   printVarSummary(fin1)
   latitude=fin1->latitude
   longitude=fin1->longitude
   time=fin1->time
   ntime=dimsizes(time)
   nlat=dimsizes(latitude)
   nlon=dimsizes(longitude)
   data_cf_1=fin1->$var1$ 

  ism=(Startyr-Startyr)*12
  iem=ntime-1

  data_cf=new((/ntime,nlat,nlon/),"float")
  data_cf!0="time"
  data_cf!1="latitude"
  data_cf!2="longitude"
  data_cf&time=ispan(1,(iem-ism+1),1)
  data_cf&latitude=latitude
  data_cf&longitude=longitude
  data_cf@units="mm/month"
  data_cf@_FillValue=-99999. ;  data@_FillValue
  data_cf@missing_value=-99999.  ; data@missing_value
  data_cf@long_name="differential terrestrial water storage (= pr - evspsbl - mrro)"

  data_cf_ann=new((/nyear,nlat,nlon/),"float")
  data_cf_ann!0="year"
  data_cf_ann!1="latitude"
  data_cf_ann!2="longitude"
  data_cf_ann&year=year
  data_cf_ann&latitude=latitude
  data_cf_ann&longitude=longitude
  data_cf_ann@units="mm/year"
  data_cf_ann@_FillValue=-99999.
  data_cf_ann@missing_value=-99999.
  data_cf_ann@long_name=data_cf@long_name

  ;;; calculate twsa  from dtws = pr - evspsbl - mrro
  data_cf = dim_cumsum_n_Wrap (data_cf_1, 2, 0)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do iyear=0,nyear-1
     isy=iyear*12
     iey=isy+11
   data_cf_ann(iyear,:,:)=dim_avg_n(data_cf(isy:iey,:,:),0)
  end do

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

   delete(fin1)
   delete(latitude)
   delete(longitude)
   delete(data_cf)
   delete(data_cf_wgt)
   delete(data_cf_ann)
   delete(data_cf_ann_wgt)

 end do
 end do
 end do 

end
