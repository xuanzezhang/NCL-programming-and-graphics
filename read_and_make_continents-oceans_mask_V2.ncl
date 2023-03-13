;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

 flsmask=addfile("lsmask.nc","r")
 frac_area=flsmask->lsmask(0,:,:)  ;;; 0-land, 1-ocean,

 farea=addfile("HadCRU_area_36x72.nc","r")
 latitude=farea->latitude
 longitude=farea->longitude
 latitude@units="degrees_north"
 longitude@units="degree_east"


 area=farea->area

 area_ocn=area*frac_area
 area_lnd=area*(1-frac_area)

 fcmask=addfile("Cmask_CMIP6_EC-Earth3-Veg.nc","r")
 Cmask=fcmask->Cmask

 ;;;redefine to land: 1-Africa,2-Asia,3-Australia,4-Europe,5-North America,6-South America,7-Antarctica

 Cmask=where(Cmask.eq.7,3,Cmask)
 Cmask=where(Cmask.eq.8,7,Cmask)
 ;;;;;;;;;;;;;;;;;;
lat2=fcmask->latitude
lon2=fcmask->longitude

lon2=lon2-180
nlon=dimsizes(lon2)
nlat=dimsizes(lat2)

;;;change from lon 0~360 to -180~180
Cmask_data = Cmask
Cmask_data(:,0:(nlon/2-1)) = (/Cmask(:,(nlon/2):(nlon-1))/)
Cmask_data(:,(nlon/2):(nlon-1)) = (/Cmask(:,0:(nlon/2-1))/)

Cmask_data!0="latitude"
Cmask_data!1="longitude"
Cmask_data&latitude=lat2
Cmask_data&longitude=lon2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lnd=ispan(1,7,1)
nlnd=7

Cmask_lnd=new((/nlnd,nlat,nlon/),typeof(Cmask_data))

do ireg=0,nlnd-1
   Cmask_lnd(ireg,:,:)=where(Cmask_data.eq.lnd(ireg),1,0)
end do

;;;;;;;;;;;;;;;;;

  opt = True
  opt@critpc = 10                ; require only 50% of the values to be present

 Cmask_lnd_5x5 = area_hi2lores_Wrap (lon2, lat2, Cmask_lnd,True, 1,longitude, latitude, opt)

 Cmask_lnd_5x5 = where(Cmask_lnd_5x5.lt.0,Cmask_lnd_5x5@_FillValue,Cmask_lnd_5x5)

 system("rm -rf Cmask_5x5_for_land.nc")
 fout=addfile("Cmask_5x5_for_land.nc","c")
 fout->Cmask = Cmask_lnd_5x5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ;;;redefine to ocean: 11-Pacific Ocean, 12-Atlantic Ocean, 13-Indian Ocean, 14-Arctic Ocean,15-Southern Ocean
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ocn=ispan(11,15,1)
nocn=5

Omask_ocn=new((/nocn,nlat,nlon/),typeof(Cmask_data))

Omask_data=new((/nlat,nlon/),typeof(Cmask_data))
copy_VarCoords(Cmask_data,Omask_data)

Omask_data=where(ismissing(Cmask_data),0,Cmask_data@_FillValue)
Omask_data=where(Omask_data.ge.1,Omask_data@_FillValue,0)
Omask_data({latitude|-90:-60},{longitude|:})=15
Omask_data({latitude|65:90},{longitude|:})=14
Omask_data({latitude|-60:30},{longitude|20:100})=13
Omask_data({latitude|-60:-10},{longitude|100:130})=13 
Omask_data({latitude|-60:-30},{longitude|130:146})=13
Omask_data({latitude|-10:0},{longitude|100:110})=13
Omask_data({latitude|-60:10},{longitude|-70:20})=12
Omask_data({latitude|10:16},{longitude|-85:0})=12
Omask_data({latitude|16:65},{longitude|-100:36})=12
Omask_data({latitude|40:50},{longitude|30:50})=12 
Omask_data=where(Omask_data.eq.0,11,Omask_data)
Omask_data=where(ismissing(Cmask_data),Omask_data,Omask_data@_FillValue)

 system("rm -rf Omask_CMIP6_EC-Earth3-Veg.nc")
 fout=addfile("Omask_CMIP6_EC-Earth3-Veg.nc","c")
 fout->Omask = Omask_data


do ireg=0,nocn-1
   Omask_ocn(ireg,:,:)=where(Omask_data.eq.ocn(ireg),1,0)
end do

;;;;;;;;;;;;;;;;;

 opt = True
 opt@critpc = 10                ; require only 50% of the values to be present

 Omask_ocn_5x5 = area_hi2lores_Wrap (lon2, lat2, Omask_ocn,True, 1,longitude, latitude, opt)

 Omask_ocn_5x5 = where(Omask_ocn_5x5.lt.0,Omask_ocn_5x5@_FillValue,Omask_ocn_5x5)

 system("rm -rf Omask_5x5_for_Ocean.nc")
 fout=addfile("Omask_5x5_for_Ocean.nc","c")
 fout->Omask = Omask_ocn_5x5 

;;;

end
