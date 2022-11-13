;********************************************
; These files are loaded by default in NCL V6.2.0 and newer
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;********************************************

begin

Startyr=1996
Endyr=2008

year=ispan(Startyr,Endyr,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
nyear=dimsizes(year)
nmon=dimsizes(month)

varname="surfacePrecipitation"
platform="F13"
instrument="SSMI"  ;; SSMIS

do iy=0,nyear-1

path="GPM_L3/GPM_3GPROF"+platform+instrument+"_CLIM.07/"+year(iy)+"/"
files=systemfunc("ls "+path+"3A-CLIM-MO.*.HDF5")
print(files)
nfiles=dimsizes(files)
print(nfiles)

fileout=varname+"_monthly_GPM_3GPORF_"+platform+"_"+instrument+"_GRID2021R1_V07A_"+year(iy)+".nc"

system("rm -rf "+fileout) 
system("ncecat -v "+varname+" "+path+"3A-CLIM-MO.*.HDF5"+" -o "+fileout)

end do

fileout_ann=varname+"_monthly_GPM_3GPORF_"+platform+"_"+instrument+"_V07A_"+Startyr+"-"+Endyr+".nc"
system("rm -rf "+fileout_ann)
system("ncrcat "+varname+"_monthly_GPM_3GPORF_"+platform+"_"+instrument+"_GRID2021R1_V07A_*.nc"+" -o "+fileout_ann)

end
