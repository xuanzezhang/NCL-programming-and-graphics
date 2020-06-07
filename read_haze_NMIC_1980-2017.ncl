
path="haze_NMIC_output_1980-2017/"
files=systemfunc("ls "+path+"SURF_CLI_CHN_DAY-WEP-HAZ-*.TXT")
nfile=dimsizes(files)
print(nfile)

ncol=4
nsite=1865
data_in=new((/nfile,nsite,ncol/),"float")

do im=0,nfile-1
data_in(im,:,:)=readAsciiTable(files(im),ncol,"float",0)
end do

;print(data_in(0,:,0))

siteID=ispan(1,nsite,1)
site=new(nsite,"float")
lon=new(nsite,"float")
lat=new(nsite,"float")

site=data_in(0,:,0)
lat=data_in(0,:,1)
lon=data_in(0,:,2)

site!0="siteID"
site&siteID=siteID
lat!0="siteID"
lat&siteID=siteID
lon!0="siteID"
lon&siteID=siteID

time=ispan(1,nfile,1)

data=new((/nfile,nsite/),"float")
data=data_in(:,:,3)
data!0="time"
data&time=time
data!1="siteID"
data&siteID=siteID

data_D=data(11::12,:)
data_J=data(12::12,:)
data_F=data(13::12,:)

printVarSummary(data_D)
printVarSummary(data_J)
printVarSummary(data_F)

data_DJF=data_D
data_DJF=(data_D+data_J+data_F)/3.

system("rm -rf SURF_CLI_CHN_DAY-WEP-HAZ-198001-201411.nc")
fout=addfile("SURF_CLI_CHN_DAY-WEP-HAZ-198001-201411.nc","c")
fout->data=data
fout->data_DJF=data_DJF
fout->lat=lat
fout->lon=lon
fout->site=site

;***************************************************** 
; create plot
;***************************************************** 
  system("rm -rf plot_haze_timeseries_of_Beijing_1982-2014") 
  wks = gsn_open_wks("pdf","plot_haze_timeseries_of_Beijing_1982-2014")             ; send graphics to PNG file

  res                    = True              ; plot mods desired
  res@gsnDraw            = True             ; don't draw yet
  res@gsnFrame           = True             ; don't advance frame yet

  res@vpHeightF 	 = 0.2               ; change aspect ratio of plot
  res@vpWidthF 	         = 0.8

  res@trYMaxF            = 30
  res@trYMinF	         = 0.            ; set x-axis minimum

  res@trXMaxF            = nfile
  res@trXMinF            = 1.            ; set x-axis minimum

  res@xyMonoLineColor    = False             ; want colored lines
  res@xyLineColors       = (/"Black"/) ; colors chosen
  res@xyLineThicknesses	 = (/3./)      ; line thicknesses
  res@xyDashPatterns	 = (/0./)      ; make all lines solid

  res@tiYAxisString	 = "day/month"      ; add an axis title    
  res@txFontHeightF	 = 0.0195            ; change title font heights
 
  a=ind(site.eq.54399)
  print(a)
  data_out=data({time|:},{siteID|a})
  plot = gsn_csm_xy (wks,time,data_out,res)       ; create line plot


  res@trXMaxF            = 34
  res@trXMinF            = 1            ; set x-axis minimum

  a=ind(site.eq.54399)
  print(a)
  data_DJF_out=data_DJF({time|:},{siteID|a})
  plot = gsn_csm_xy (wks,ispan(1,34,1),data_DJF_out,res)       ; create line plot

