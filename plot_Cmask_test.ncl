 fcmask=addfile("Cmask_CMIP6_EC-Earth3-Veg.nc","r")
 Cmask=fcmask->Cmask

 ;;;redefine to land: 1-Africa,2-Asia,3-Australia,4-Europe,5-North America,6-South America,7-Antarctica

 Cmask=where(Cmask.eq.7,3,Cmask)
 Cmask=where(Cmask.eq.8,7,Cmask)

;;;;plot test

 fcmask=addfile("Cmask_5x5.nc","r")
 Cmask_5x5=fcmask->Cmask


 fcmask=addfile("Cmask_5x5_for_land.nc","r")
 Cmask_lnd_5x5=fcmask->Cmask

;************************************************
; create plot
;************************************************
  system("rm -rf plot_Cmask_test")
  wks = gsn_open_wks("pdf","plot_Cmask_test")

  res                      = True               ; plot mods desired
  res@gsnMaximize          = False
  res@mpMinLatF=-90
  res@mpMaxLatF=90
  res@mpMinLonF=-180
  res@mpMaxLonF=180
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = True                     ; Turn off contour lines
  res@cnFillMode           = "RasterFill"
  plot = gsn_csm_contour_map(wks,Cmask, res)
  plot = gsn_csm_contour_map(wks,Cmask_5x5, res)

;  Cmask_lnd_5x5@_FillValue=-1
  Cmask_lnd_5x5=where(ismissing(Cmask_lnd_5x5),0,Cmask_lnd_5x5)

  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(0,:,:), res)
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(1,:,:), res) 
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(2,:,:), res) 
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(3,:,:), res) 
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(4,:,:), res) 
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(5,:,:), res) 
  plot = gsn_csm_contour_map(wks,Cmask_lnd_5x5(6,:,:), res) 

