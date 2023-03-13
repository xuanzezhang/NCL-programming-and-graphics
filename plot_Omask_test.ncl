 fcmask=addfile("Omask_CMIP6_EC-Earth3-Veg.nc","r")
 Omask=fcmask->Omask

;;;;plot test

; fcmask=addfile("Omask_5x5.nc","r")
; Omask_5x5=fcmask->Omask


 fcmask=addfile("Omask_5x5_for_ocean.nc","r")
 Omask_ocn_5x5=fcmask->Omask

;************************************************
; create plot
;************************************************
  system("rm -rf plot_Omask_test")
  wks = gsn_open_wks("pdf","plot_Omask_test")

  res                      = True               ; plot mods desired
  res@gsnMaximize          = False
  res@mpMinLatF=-90
  res@mpMaxLatF=90
  res@mpMinLonF=-180
  res@mpMaxLonF=180
  res@cnFillOn             = True               ; turn on color fill
  res@cnLinesOn            = False                     ; Turn off contour lines
  res@cnFillMode           = "RasterFill"
  plot = gsn_csm_contour_map(wks,Omask, res)
;  plot = gsn_csm_contour_map(wks,Omask_5x5, res)

  Omask_ocn_5x5@_FillValue=-1
  Omask_ocn_5x5=where(ismissing(Omask_ocn_5x5),0,Omask_ocn_5x5)

  plot = gsn_csm_contour_map(wks,Omask_ocn_5x5(0,:,:), res)
  plot = gsn_csm_contour_map(wks,Omask_ocn_5x5(1,:,:), res) 
  plot = gsn_csm_contour_map(wks,Omask_ocn_5x5(2,:,:), res) 
  plot = gsn_csm_contour_map(wks,Omask_ocn_5x5(3,:,:), res) 
  plot = gsn_csm_contour_map(wks,Omask_ocn_5x5(4,:,:), res) 

