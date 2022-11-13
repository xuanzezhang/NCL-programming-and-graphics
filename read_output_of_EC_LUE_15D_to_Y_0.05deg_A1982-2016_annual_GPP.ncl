
begin

year=ispan(2000,2017,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
ndayom=(/31,28,31,30,31,30,31,31,30,31,30,31/)
nyear=dimsizes(year)
nmon=dimsizes(month)

fgeoinfo=addfile("PMLV2-AVHRR_area_3600x7200.nc","r")
area=fgeoinfo->area

flandcover=addfile("IGBP_MODIS_MCD12C1_Majority_Land_Cover_Type_1_Percent_2001_0.05deg.nc","r")
frac_area=(flandcover->Majority_Land_Cover_Type_1_Percent)*0.01  ;;from percentage to fraction
area=area*frac_area

do iy=0,nyear-1
path="./monthly_output/"
fin=addfile(path+"GPP_of_EC_LUE_monthly_A"+year(iy)+"_0.05deg.nc","r")
GPP=fin->GPP

do im=0,nmon-1
GPP(im,:,:) = GPP(im,:,:)*ndayom(im)  ;;*86400*(12.*1.e-6)*ndayom(im)  ;;umol m-2 s-1 to gC m-2 d-1 to gC/m2/month
end do

GPP_y=dim_sum_n_Wrap(GPP,0)
GPP_y@units="gC m-2 year-1"

GPP_area=GPP_y*area  ;; 
GPP_area@units="gC year-1" 
copy_VarCoords(GPP_y,GPP_area)

tot_GPP_y=sum(GPP_area)*1.e-15
tot_GPP_y@units="PgC year-1"
print(tot_GPP_y)
;===================================================================
; explicitly declare file definition mode. Improve efficiency.
;===================================================================
;setfileoption("nc","Format","NetCDF4Classic")

system("rm -rf GPP_of_EC_LUE_annual_A"+year(iy)+"_0.05deg.nc")
fileout="GPP_of_EC_LUE_annual_A"+year(iy)+"_0.05deg.nc"
fout=addfile(fileout,"c")
fout->GPP=GPP_y
fout->GPP_area=GPP_area

end do

end
