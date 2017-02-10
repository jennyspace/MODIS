load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

;************************************************ begin 
;************************************************ ; open file and read 
;in data ;************************************************
  fin1 = "../2013_07_23/A-Train/MYD021KM.A2013204.0425.005.2013205024539.hdf"
  fin2 = "../2013_07_23/A-Train/MYD021KM.A2013204.0425.005.2013205024539.hdf"
  geo1 = "../2013_07_23/A-Train/MYD03.A2013204.0425.005.2013205023556.hdf"
  geo2 = "../2013_07_23/A-Train/MYD03.A2013204.0425.005.2013205023556.hdf"
  in1 = addfile(fin1,"r")
  in2 = addfile(fin2,"r")
  ingeo1 = addfile(geo1,"r")
  ingeo2 = addfile(geo2,"r")

   ctp1 = in1->EV_500_Aggr1km_RefSB
   ctt1 = (ctp1 - ctp1@radiance_offsets(2)) * ctp1@radiance_scales(2)
   printVarSummary(ctp1)
   Lat2d1 = ingeo1->Latitude
   printVarSummary(Lat2d1)
   Lon2d1 = ingeo1->Longitude
   printVarSummary(Lon2d1)
   Lon2d1=where(Lon2d1.lt.0, Lon2d1+360, Lon2d1)

   ctp2 = in2->EV_500_Aggr1km_RefSB
   ctt2 = (ctp2 - ctp2@radiance_offsets(2)) * ctp2@radiance_scales(2)
   printVarSummary(ctp2)
   Lat2d2 = ingeo2->Latitude
   printVarSummary(Lat2d2)
   Lon2d2 = ingeo2->Longitude
   printVarSummary(Lon2d2)
   Lon2d2=where(Lon2d2.lt.0, Lon2d2+360, Lon2d2)


;*****************************************************************************************************************
 
ctp1_1 = new( (/2030,1354/),float)
 do i = 0,2029
  do j = 0, 1353
    ctp1_1(i,j) = ctt1(2,i,j)
  end do
 end do

 ctp1_1@Lat2d = Lat2d1
 ctp1_1@Lon2d = Lon2d1

printVarSummary(ctp1_1)

ctp2_1 = new( (/2030,1354/),float)
 do i = 0,2029
  do j = 0, 1353
    ctp2_1(i,j) = ctt2(2,i,j)
  end do
 end do

 ctp2_1@Lat2d = Lat2d2
 ctp2_1@Lon2d = Lon2d2

 Lat_merged = array_append_record (Lat2d1, Lat2d2, 0)
 printVarSummary(Lat_merged)
 Lon_merged = array_append_record (Lon2d1, Lon2d2, 0)
 printVarSummary(Lon_merged)
 ctp_merged = array_append_record (ctp1_1, ctp2_1, 0)
 printVarSummary(ctp_merged)

 Lat_merged@units = "degrees_north"
 Lon_merged@units = "degrees_east"

 ;print(ctp_merged)
;********************************************** create plot ***************************************************8

  wks = gsn_open_wks("ps" ,"../2013_07_23/A-Train/modis_Vis_0723_merged")

  gsn_define_colormap(wks, "gsdtol")

  res = True ; plot mods desired
  res@gsnFrame = False
  res@gsnDraw = False
  res@gsnMaximize = False ; uncomment to maximize plot
  res@gsnAddCyclic = False ; data not cyclic

  res@cnFillOn = True ; turn on color fill
  res@cnLinesOn = False ; turn on contour lines
  res@cnFillMode = "CellFill" ; turn on raster mode

  res@trGridType = "TriangularMesh" ; *faster* graphic

  ;res@lbTitlePosition = "Bottom"
  ;res@lbTitleFontHeightF = 0.0125 ; default 0.025
  res@lbBoxLinesOn        = False

  res@mpProjection = "Mercator" ; choose map projection
  res@mpDataBaseVersion    = "Ncarg4_1"
  res@mpFillOn = False ; turn off map fill

  ;res@mpLimitMode = "LatLon" ; required
  ;res@mpMinLatF = min(Lat_merged)-1 ; min lat
  ;res@mpMaxLatF = max(Lat_merged)+1 ; max lat
  ;res@mpMinLonF = min(Lon_merged)-1 ; min lon
  ;res@mpMaxLonF = max(Lon_merged)+1 ; max lon

  res@mpLimitMode = "LatLon" ; required
  res@mpMinLatF = -46 ; min lat
  res@mpMaxLatF = -36 ; max lat
  res@mpMinLonF = 140 ; min lon
  res@mpMaxLonF = 150 ; max lon

  ;res@mpGeophysicalLineThicknessF = 3
  res@mpOutlineBoundarySets= "National"
  res@mpGridLonSpacingF = 5
  res@mpGridLatSpacingF = 5
  res@mpGeophysicalLineColor      = "Black"
  res@mpNationalLineColor         = "Black"
  res@mpUSStateLineColor          = "Black"
  res@mpGridLineColor             = "Black"
  res@mpLimbLineColor             = "Black"
  res@mpPerimLineColor            = "Black"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 2.0
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0

  res@pmTickMarkDisplayMode= "Always" ; turn on automatic
  ;res@xyDashPattern = 0               ; solid curve

  res@sfXArray = Lon_merged 
  res@sfYArray = Lat_merged
  res@tiMainString = "MODIS Ch4 Vis (04:25UTC July 23,2013)"
  res@tiMainFontHeightF   = 0.02
  res@gsnLeftString = "W m-2 sr-1"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       =  0
  res@cnMaxLevelValF       =  50
  res@cnLevelSpacingF      =  1
  res@lbBoxLinesOn         =  True
  res@gsnSpreadColors      = True               ; span full colormap
  res@gsnSpreadColorStart = 1
  res@lbOrientation        =  "horizontal"          ; vertical label bar  
  res@lbLabelPosition      =  "bottom"           ; label position 
  res@lbLabelFontHeightF   =  0.015


  opt = True
  opt@PrintStat = True
  statb = stat_dispersion(ctp_merged, opt)
  
  print(res)
  map = gsn_csm_contour_map(wks, ctp_merged, res) ; map

;************************************************************************************************************************

;******************************************************************************************************************* 
;DAYTIME
;*******************************************************************************************************************
   d_num1 = 1695
   d_lat1 = asciiread("../2013_07_23/A-Train/CAL_LID_L2_VFM-ValStage1-V3-30.2013-07-23T04-21-46ZD.hdf_lat_region_domainplot.dat",(/d_num1/),"float")   
   d_lon1 = asciiread("../2013_07_23/A-Train/CAL_LID_L2_VFM-ValStage1-V3-30.2013-07-23T04-21-46ZD.hdf_lon_region_domainplot.dat",(/d_num1/),"float") 

    mres = True 
    mres@gsMarkerSizeF = 2.
    mres@gsMarkerColor = "red"

    d_dum1 = gsn_add_polymarker(wks,map,d_lon1,d_lat1,mres)

;******************************************************************************************************************* 
;plot_flight_path
;*******************************************************************************************************************
   d_num2 = 8448
   d_lat2 = asciiread("../2013_07_23/aircraft/flight_path_lat.txt",(/d_num2/),"float")   
   d_lon2 = asciiread("../2013_07_23/aircraft/flight_path_lon.txt",(/d_num2/),"float") 

    mres = True 
    mres@gsMarkerSizeF = 1.
    mres@gsMarkerColor = "yellow"

    d_dum2 = gsn_add_polymarker(wks,map,d_lon2,d_lat2,mres)


   draw(map)
   frame(wks)
