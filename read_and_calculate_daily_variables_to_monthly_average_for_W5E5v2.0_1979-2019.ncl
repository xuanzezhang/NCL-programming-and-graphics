;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=2011
Endyr=2019

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1
year@calendar = "standard"

month=ispan(1,12,1)
month_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nmonth=12

 model=(/"W5E5v2.0"/)
 nmodel=dimsizes(model)

varname=(/"hurs","huss","pr","prsn","ps","psl","rlds","rsds","sfcWind","tas","tasmax","tasmin"/)
nvar=dimsizes(varname)

 do ivar= 0, nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

   FilePath="raw/"
   FileName=varname(ivar)+"_"+model(imodel)+"_"+Startyr+"0101-"+Endyr+"1231.nc"

   fin=addfile(FilePath+FileName,"r")
   printVarSummary(fin)
   latitude=fin->lat
   longitude=fin->lon
   latitude@units="degrees_north"
   longitude@units="degrees_east"
   time=fin->time
   data=fin->$varname(ivar)$
  ; data@_FillValue=-99999.
  ; data@missing_value=-99999.
   printVarSummary(data)
   ntime=dimsizes(time)
   nlat=dimsizes(latitude)
   nlon=dimsizes(longitude)

  sumdays=0

  do iyear=0,nyear-1
    do imonth=0,nmonth-1

    ndays = days_in_month(year(iyear),month(imonth))

    ids = sumdays
    ide = ids + ndays -1

    data_avg = dim_avg_n_Wrap(data(ids:ide,:,:),0)

    OutFileName="Monthly_"+varname(ivar)+"_"+model(imodel)+"_"+year(iyear)+month_str(imonth)+".nc"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   system("rm -f "+OutFileName)
   fout=addfile(OutFileName,"c")
   fout->$varname(ivar)$=data_avg


    sumdays = sumdays + ndays

    print(sumdays)
    end do

  end do

  delete(fin)
  delete(data)
  delete(data_avg)

 end do

 end do


end 
