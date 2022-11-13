
begin

year=ispan(2002,2017,1)
month=(/"01","02","03","04","05","06","07","08","09","10","11","12"/)
doy=(/"001","009","017","025","033","041","049","057","065","073","081","089",\
      "097","105","113","121","129","137","145","153","161","169","177","185",\
      "193","201","209","217","225","233","241","249","257","265","273","281",\
      "289","297","305","313","321","329","337","345","353","361"/)
nyear=dimsizes(year)
nmon=dimsizes(month)

do iy=0,nyear-1

path="EC-LUE-GPP-Dawnload/"+year(iy)+"/"
files=systemfunc("ls "+path+"GPP.global.005D.*.hdf")
nfiles=dimsizes(files)
print(nfiles)

do im=0,nmon-1

if (im.lt.6) then  ;; for month 1 to 6 
  it=im*4
  files_a=files(it:(it+1))
  files_b=files((it+2):(it+3))
elseif (im.ge.6.and.im.lt.11)then ;;for month 7 to 11
  it=im*4-1
  files_a=files(it:(it+1))
  files_b=files((it+2):(it+3))
else ;; for month 12
  it=im*4-1
  files_a=files(it:(it+1))
  files_b=files((it+2):(nfiles-1))
end if

path_out="EC-LUE_GPP_0.05deg_15D/"+year(iy)+"/"
system("mkdir -p "+path_out)
fout_a=path_out+"EC-LUE_GPP_V01_15D_A"+year(iy)+month(im)+"a_0.05deg.nc"
fout_b=path_out+"EC-LUE_GPP_V01_15D_A"+year(iy)+month(im)+"b_0.05deg.nc" 

do ip=0,1

if (ip.eq.0) then
  f=addfiles(files_a,"r")
elseif (ip.eq.1) then
  f=addfiles(files_b,"r")
end if
print(f)
print(f[0])

data1_in=f[0]->GPP_005D
printVarSummary(data1_in)
data1=tointeger(data1_in)
nf=dimsizes(f)
do ifile=1,nf-1
data1=data1+tointeger(f[ifile]->GPP)
end do
data1=data1/nf
printVarSummary(data1)
delete(f)

longitude=fspan(-180,180,7200)
latitude=fspan(-90,90,3600)
longitude!0="longitude"
latitude!0="latitude"
longitude@units="degree_east"
latitude@units="degree_north"

;print(longitude)
;print(latitude)

data1@_FillValue=65535
data1@units="gC m-2 day-1"
data1!0="latitude"
data1!1="longitude"
data1&latitude=latitude(::-1)
data1&longitude=longitude
copy_VarAtts(data1_in,data1)
printVarSummary(data1)

data_out=data1*0.01
copy_VarAtts(data1,data_out)
copy_VarCoords(data1,data_out)

if (ip.eq.0)then
  system("rm -rf "+fout_a)
  fout=addfile(fout_a,"c")
elseif (ip.eq.1)then
  system("rm -rf "+fout_b)
  fout=addfile(fout_b,"c")
end if
print(fout)

fout->GPP=data_out

;************************************************
; create plot
;************************************************
if (ip.eq.0)then
  wks = gsn_open_wks("pdf",path_out+"EC-LUE_GPP_V01_15D.A"+year(iy)+month(im)+"a_0.05deg_test")
elseif (ip.eq.1)then
  wks = gsn_open_wks("pdf",path_out+"EC-LUE_GPP_V01_15D.A"+year(iy)+month(im)+"b_0.05deg_test")
end if

  cmap = read_colormap_file("BlAqGrYeOrReVi200")

  res                      = True               ; plot mods desired
  res@tiMainString         = "EC-LUE_GPP_V01_15D"    ; main title
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False                     ; Turn off contour lines
  res@cnFillMode           = "RasterFill"              ; Raster Mode 

  plot = gsn_csm_contour_map(wks,data_out(::10,::10), res)     ; create plot

end do

delete(files_a)
delete(files_b)

end do

delete(files)

end do


end
