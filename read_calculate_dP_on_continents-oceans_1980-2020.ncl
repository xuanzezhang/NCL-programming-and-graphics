;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

 nyear=2020-1980+1
 year=ispan(1980,2020,1)

 varname="dP"
 runner="GPCPv2.3";;"GPCPv2.3"

fin=addfile("P_annual_5x5_"+runner+"_1979-2021.nc","r")
latitude=fin->latitude
longitude=fin->longitude

data_in=tofloat(fin->P(1:41,:,:))

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

;;;;;
 fcmask=addfile("Cmask_5x5_for_land.nc","r")
 Cmask_lnd_5x5=fcmask->Cmask ;;;ocn,lat,lon
;;;;;
 fcmask=addfile("Omask_5x5_for_ocean.nc","r")
 Omask_ocn_5x5=fcmask->Omask ;;ocn,lat,lon
;;;;
 ;;;data_in, year,lat,lon
  nlnd=7
  nocn=5

  lnd=ispan(1,7,1)
  ocn=ispan(11,15,1)

  nlat=dimsizes(latitude)
  nlon=dimsizes(longitude)

  data_in_ocn_cf=new((/nyear,nocn,nlat,nlon/),typeof(data_in)) 
  data_in_lnd_cf=new((/nyear,nlnd,nlat,nlon/),typeof(data_in))

  data_in_ocn_cf=conform_dims(dimsizes(data_in_ocn_cf),data_in,(/0,2,3/))
  data_in_lnd_cf=conform_dims(dimsizes(data_in_lnd_cf),data_in,(/0,2,3/))
  printVarSummary(data_in_ocn_cf)

  area_omask_ocn=conform_dims(dimsizes(Omask_ocn_5x5),area_ocn,(/1,2/))
  area_cmask_lnd=conform_dims(dimsizes(Cmask_lnd_5x5),area_lnd,(/1,2/))

  area_omask_ocn_5x5=area_omask_ocn*Omask_ocn_5x5
  area_cmask_lnd_5x5=area_cmask_lnd*Cmask_lnd_5x5

  printVarSummary(area_omask_ocn_5x5)

  area_omask_ocn_cf=conform_dims(dimsizes(data_in_ocn_cf),area_omask_ocn_5x5,(/1,2,3/)) 
  area_cmask_lnd_cf=conform_dims(dimsizes(data_in_lnd_cf),area_cmask_lnd_5x5,(/1,2,3/))

  printVarSummary(area_omask_ocn_cf)

  area_omask_ocn_cf=where(ismissing(data_in_ocn_cf),area_ocn@_FillValue,area_omask_ocn_cf)
  area_cmask_lnd_cf=where(ismissing(data_in_lnd_cf),area_ocn@_FillValue,area_cmask_lnd_cf)

  data_omask_ocn_ann = dim_sum_n(data_in_ocn_cf*area_omask_ocn_cf,(/2,3/))/dim_sum_n(area_omask_ocn_cf,(/2,3/))
  data_cmask_lnd_ann = dim_sum_n(data_in_lnd_cf*area_cmask_lnd_cf,(/2,3/))/dim_sum_n(area_cmask_lnd_cf,(/2,3/))

  printVarSummary(data_omask_ocn_ann)


  data_omask_ocn_avg=dim_avg_n_Wrap(data_omask_ocn_ann(0:19,:),0)
  data_omask_ocn_avg@long_name="1980-1999 mean of P"

  data_cmask_lnd_avg=dim_avg_n_Wrap(data_cmask_lnd_ann(0:19,:),0)
  data_cmask_lnd_avg@long_name="1980-1999 mean of P"

  printVarSummary(data_omask_ocn_avg)

  data_omask_ocn_ano=new((/nyear,nocn/),float)  ;; 11,12
  data_cmask_lnd_ano=new((/nyear,nlnd/),float)

  do iy=0,nyear-1
     data_omask_ocn_ano(iy,:)= data_omask_ocn_ann(iy,:) - data_omask_ocn_avg(:)
     data_cmask_lnd_ano(iy,:)= data_cmask_lnd_ann(iy,:) - data_cmask_lnd_avg(:) 
  end do

;;;;;;;
data_omask_ocn_ano!0="year"
data_omask_ocn_ano!1="ocn"
data_omask_ocn_ano&year=year
data_omask_ocn_ano&ocn=ispan(1,nocn,1)
data_omask_ocn_ano@units="mm/year"
data_omask_ocn_ano@long_name="global mean precipitation change relative to 1980-1999 mean"
data_omask_ocn_ano@description="ocean: 11-Pacific Ocean, 12-Atlantic Ocean, 13-Indian Ocean, 14-Arctic Ocean,15-Southern Ocean"
printVarSummary(data_omask_ocn_ano)

  data_omask_ocn_pct=new((/nyear,nocn/),float)  ;; 
  do iy=0,nyear-1
  data_omask_ocn_pct(iy,:)= data_omask_ocn_ano(iy,:) / data_omask_ocn_avg(:)*100
  end do

data_omask_ocn_pct!0="year"
data_omask_ocn_pct!1="ocn"
data_omask_ocn_pct&year=year
data_omask_ocn_pct&ocn=ispan(1,nocn,1)
data_omask_ocn_pct@units="%"
data_omask_ocn_pct@long_name="P percent change relative to 1980-1999 mean"
data_omask_ocn_pct@description="ocean: 11-Pacific Ocean, 12-Atlantic Ocean, 13-Indian Ocean, 14-Arctic Ocean,15-Southern Ocean"
printVarSummary(data_omask_ocn_pct)

;;;;

data_cmask_lnd_ano!0="year"
data_cmask_lnd_ano!1="lnd"
data_cmask_lnd_ano&year=year
data_cmask_lnd_ano&lnd=ispan(1,nlnd,1)
data_cmask_lnd_ano@units="mm/year"
data_cmask_lnd_ano@long_name="global mean precipitation change relative to 1980-1999 mean"
data_cmask_lnd_ano@description="land: 1-Africa,2-Asia,3-Australia,4-Europe,5-North America,6-South America,7-Antarctica"
printVarSummary(data_cmask_lnd_ano)

  data_cmask_lnd_pct=new((/nyear,nlnd/),float)  ;; 0-land,1-ocean
  do iy=0,nyear-1
  data_cmask_lnd_pct(iy,:)= data_cmask_lnd_ano(iy,:) / data_cmask_lnd_avg(:)*100
  end do

data_cmask_lnd_pct!0="year"
data_cmask_lnd_pct!1="lnd"
data_cmask_lnd_pct&year=year
data_cmask_lnd_pct&lnd=ispan(1,nlnd,1)
data_cmask_lnd_pct@units="%"
data_cmask_lnd_pct@long_name="P percent change relative to 1980-1999 mean"
data_cmask_lnd_pct@description="land: 1-Africa,2-Asia,3-Australia,4-Europe,5-North America,6-South America,7-Antarctica"
printVarSummary(data_cmask_lnd_pct)

;;;;;;;;;;;;;;;;;;;;;

system("rm -f "+varname+"_annual_on_continents-oceans_relative_to_1980-1999_mean_from_"+runner+"_1980-2020.nc")
fout=addfile(varname+"_annual_on_continents-oceans_relative_to_1980-1999_mean_from_"+runner+"_1980-2020.nc","c")
fout->P_ocn_avg=data_omask_ocn_avg
fout->dP_ocn=data_omask_ocn_ano(0:40,:)
fout->dP_pct_ocn=data_omask_ocn_pct(0:40,:)

fout->P_lnd_avg=data_cmask_lnd_avg
fout->dP_lnd=data_cmask_lnd_ano(0:40,:)
fout->dP_pct_lnd=data_cmask_lnd_pct(0:40,:)

data_omask_ocn_avg_new=dim_avg_n_Wrap(data_omask_ocn_ano(20:40,:),0)
data_omask_ocn_avg_new@long_name="dP relative to 1980-1999 mean"

data_omask_ocn_avg_pct=dim_avg_n_Wrap(data_omask_ocn_pct(20:40,:),0)
data_omask_ocn_avg_pct@long_name="dP percent relative to 1980-1999 mean"

data_cmask_lnd_avg_new=dim_avg_n_Wrap(data_cmask_lnd_ano(20:40,:),0)
data_cmask_lnd_avg_new@long_name="dP relative to 1980-1999 mean"

data_cmask_lnd_avg_pct=dim_avg_n_Wrap(data_cmask_lnd_pct(20:40,:),0)
data_cmask_lnd_avg_pct@long_name="dP percent relative to 1980-1999 mean"

system("rm -f "+varname+"_pct_20-year_averaged_on_continents-oceans_for_2001-2020_from_"+runner+".nc")
fout=addfile(varname+"_pct_20-year_averaged_on_continents-oceans_for_2001-2020_from_"+runner+".nc","c")
fout->dP_ocn=data_omask_ocn_avg_new
fout->dP_ocn_pct=data_omask_ocn_avg_pct
fout->dP_lnd=data_cmask_lnd_avg_new
fout->dP_lnd_pct=data_cmask_lnd_avg_pct


end


