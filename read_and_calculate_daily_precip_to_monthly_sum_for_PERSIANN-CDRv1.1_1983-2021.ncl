;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin

Startyr=1985
Endyr=2021

year=ispan(Startyr,Endyr,1)
nyear=Endyr-Startyr+1
year@calendar = "standard"

month=ispan(1,12,1)
month_str=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nmonth=12

 model=(/"PERSIANN-CDRv1.1"/)
 nmodel=dimsizes(model)

varname=(/"precipitation"/)
nvar=dimsizes(varname)

 do ivar= 0, nvar-1
   print(varname(ivar))

 do imodel= 0, nmodel -1

  do iyear=0,nyear-1

    do imonth=0,nmonth-1

   ;;PERSIANN-CDR_v01r01_19830101_c20140523.nc

   path="access/"+year(iyear)+"/"
   files=systemfunc("ls "+path+"PERSIANN-CDR_v01r01_"+year(iyear)+month_str(imonth)+"*.nc")
   print(files)
   nfiles=dimsizes(files)
   print(nfiles)

   fin=addfiles(files,"r")
   print(fin)

   ListSetType (fin, "cat") ;; "cat" or "join" 

   data=fin[:]->$varname$
   printVarSummary(data)


   data_sum = dim_sum_n_Wrap(data(:,:,:),0)
   data_sum@units="mm/month"
   data_sum@long_name="NOAA Climate Data Record of PERSIANN-CDR monthly precipitation"


   OutPath="Monthly_1982-2021/"
   OutFileName="Monthly_"+varname(ivar)+"_"+model(imodel)+"_"+year(iyear)+month_str(imonth)+".nc"

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   system("rm -f "+OutPath+OutFileName)
   fout=addfile(OutPath+OutFileName,"c")
   fout->$varname(ivar)$=data_sum

  delete(files)
  delete(fin)
  delete(data)
  delete(data_sum)

  end do

  end do

 end do

 end do


end 
