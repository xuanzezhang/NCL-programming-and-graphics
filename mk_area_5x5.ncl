;*************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

latitude=fspan(-87.5,87.5,36)
longitude=fspan(-177.5,177.5,72)
nlat=dimsizes(latitude)
nlon=dimsizes(longitude)

dlat=abs(latitude(1)-latitude(0))
dlon=abs(longitude(1)-longitude(0))

print(latitude)
print(longitude)

LAT=new((/nlat,nlon,4/),typeof(latitude))
LON=new((/nlat,nlon,4/),typeof(longitude))

do j=0,nlon-1
LAT(0,j,:)=(/latitude(0),latitude(0),latitude(0)+0.5*dlat,latitude(0)+0.5*dlat/)
LAT(nlat-1,j,:)=(/latitude(nlat-1)-0.5*dlat,latitude(nlat-1)-0.5*dlat,latitude(nlat-1),latitude(nlat-1)/)
end do


do i=1,nlat-2
LAT(i,:,0)=latitude(i)-0.5*dlat
LAT(i,:,1)=latitude(i)-0.5*dlat
LAT(i,:,2)=latitude(i)+0.5*dlat
LAT(i,:,3)=latitude(i)+0.5*dlat
end do

do j=0,nlat-1
LON(j,0,:)=(/longitude(0),longitude(1),longitude(1),longitude(0)/)
LON(j,nlon-1,:)=(/longitude(nlon-2),longitude(nlon-1),longitude(nlon-1),longitude(nlon-2)/)
end do

do i=1,nlon-2
LON(:,i,0)=longitude(i)-0.5*dlon
LON(:,i,1)=longitude(i)+0.5*dlon
LON(:,i,2)=longitude(i)+0.5*dlon
LON(:,i,3)=longitude(i)-0.5*dlon
end do

;print(LAT)
 re = 6.37122e06 ; [m] average radius of earth 
 re2 = re^2 

area = re2*gc_qarea(LAT,LON)
area!0="latitude"
area!1="longitude"
area&latitude=latitude
area&longitude=longitude
printVarSummary(area)

;print(area)

system("rm -f HadCRU_area_36x72.nc")
fout=addfile("HadCRU_area_36x72.nc","c")
fout->area=area(:,:)



end
