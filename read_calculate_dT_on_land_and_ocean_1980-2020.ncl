;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

 nyear=2021-1980+1
 year=ispan(1980,2021,1)

 varname="dT"
 runner="HadCRUT5";;"BerkeleyEarth" ;;"NOAAGlobalTemp" ;; "GISTEMP" ;;"HadCRUT5"

fin=addfile("T_annual_5x5_1980-2021_from_"+runner+".nc","r")
latitude=fin->latitude
longitude=fin->longitude

data_in=tofloat(fin->T)

if (any(isnan_ieee(data_in))) then
      value=-9999.
      replace_ieeenan (data_in, value, 0)
      data_in@_FillValue = -9999.
      data_in@missing_value=-9999.
end if
 
data_in@_FillValue=-9999.
data_in@missing_value=-9999.

;;;;;;;;;;;;;;
 flsmask=addfile("lsmask.nc","r")
 frac_area=flsmask->lsmask(0,:,:)  ;;; 0-land, 1-ocean,

 farea=addfile("HadCRU_area_36x72.nc","r")
 area=farea->area

; area=area*1.e-6 ;; from m2 to km2

 area_ocn=area*frac_area
 area_lnd=area*(1-frac_area)

 area_ocn=where(area_ocn.eq.0,area_ocn@_FillValue,area_ocn)
 area_lnd=where(area_lnd.eq.0,area_lnd@_FillValue,area_lnd)

 area_ocn@missing_value=area_ocn@_FillValue
 area_lnd@missing_value=area_lnd@_FillValue

  area_ocn_ann=conform_dims(dimsizes(data_in),area_ocn,(/1,2/))
  area_lnd_ann=conform_dims(dimsizes(data_in),area_lnd,(/1,2/))

  area_ocn_ann=where(ismissing(data_in),area_ocn@_FillValue,area_ocn_ann)
  area_lnd_ann=where(ismissing(data_in),area_ocn@_FillValue,area_lnd_ann)

  data_ocn_ann = dim_sum_n(data_in*area_ocn_ann,(/1,2/))/dim_sum_n(area_ocn_ann,(/1,2/))
  data_lnd_ann = dim_sum_n(data_in*area_lnd_ann,(/1,2/))/dim_sum_n(area_lnd_ann,(/1,2/))

  print(data_ocn_ann)
  print(data_lnd_ann)

  data=new((/nyear,2/),float)  ;; 0-land,1-ocean
  data(:,0) = data_lnd_ann
  data(:,1) = data_ocn_ann 

  data_avg=dim_avg_n_Wrap(data(0:19,:),0)
  data_avg@long_name="1980-1999 mean of T"

  data_ano=new((/nyear,2/),float)  ;; 0-land,1-ocean
  do iy=0,nyear-1
  data_ano(iy,:)= data(iy,:) - data_avg(:)
  end do

data_ano!0="year"
data_ano!1="region"
data_ano&year=year
data_ano&region=ispan(1,2,1)
data_ano@units="K"
data_ano@long_name="global mean temperature change relative to 1980-1999 mean"
data_ano@description="region: 0-land,1-ocean"
printVarSummary(data_ano)

system("rm -f "+varname+"_annual_on_land-ocean_relative_to_1980-1999_mean_from_"+runner+"_1980-2020.nc")
fout=addfile(varname+"_annual_on_land-ocean_relative_to_1980-1999_mean_from_"+runner+"_1980-2020.nc","c")
fout->$varname$=data_ano(0:40,:)

data_avg_new=dim_avg_n_Wrap(data_ano(20:40,:),0)
data_avg_new@long_name="dT relative to 1980-1999 mean"

system("rm -f "+varname+"_20-year_averaged_on_land-ocean_for_2001-2020_from_"+runner+".nc")
fout=addfile(varname+"_20-year_averaged_on_land-ocean_for_2001-2020_from_"+runner+".nc","c")
fout->$varname$=data_avg_new

end


