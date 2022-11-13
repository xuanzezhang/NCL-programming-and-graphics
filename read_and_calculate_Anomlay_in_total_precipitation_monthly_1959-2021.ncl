

fin=addfile("ERA5-1959-2022/ERA5_total_precipitation_monthly_1959-2021.nc","r")
tp=short2flt(fin->tp)
printVarSummary(tp)

;---Compute the climatology using a function in contributed.ncl
tpClm=clmMonTLL(tp)

;---Compute the anomalies from the climatology just computed
tpAnom = calcMonAnomTLL (tp,tpClm)

setfileoption("nc", "Format",  "NetCDF4Classic")
system("rm -rf ERA5_climatology_and_anomaly_in_total_precipitation_monthly_1959-2021.nc")
fout=addfile("ERA5_climatology_and_anomaly_in_total_precipitation_monthly_1959-2021.nc","c")
fout->tpClm = tpClm
fout->tpAnom = tpAnom




