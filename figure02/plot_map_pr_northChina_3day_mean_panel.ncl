load "$HOME/jungu/.config/ncl/nclscripts/io.ncl"
load "$HOME/jungu/.config/ncl/nclscripts/plot.ncl"
;----------------------------------------------------------------------
;main program starts here
;----------------------------------------------------------------------
begin
    wcStart = systemfunc("date")
;---read locations 
    RAD2DEG    = get_r2d("double")      ; Radian to Degree

    case_list = "0728_" + sprinti("%02d",ispan(4,9,1))
    path_prefix = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/cases/2305Doksuri/v4km/sep_vars/"
    path_suffix = "/daily_avg/3day/"
    file_path = path_prefix + case_list + path_suffix

    fi_rain_hr = addfiles(file_path + "rain_hr.nc","r")
    ListSetType(fi_rain_hr, "join")
    rain_hr    = fi_rain_hr[:]->rain_hr
    rain_3day  = rain_hr*72

    obs_path = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/cases/23.7/data/raw/CLDAS/CLDAS_rain.nc"
    fi_obs    = addfile(obs_path,"r")
    rain_obs  = fi_obs->rain_3day
    
    ;read static mesh file
    static_fi = addfile("$HOME/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/init_static.nc","r")
    latCell = static_fi->latCell*RAD2DEG
    lonCell = static_fi->lonCell*RAD2DEG

    minlat = 30.
    maxlat = 45.
    minlon = 106.
    maxlon = 129.

    N_res = 2.5
    wks_type = "png"
    ;wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    ;wks_type@wkOrientation = "Portrait"
    ;wks_type@wkDeviceLowerX = 36; points
    ;wks_type@wkDeviceLowerY = 126; points
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    ;wks_type@wkPDFResolution = 6000
    wks_name = "../outputs/figs/"  + "map_pr_northchina_3day_mean_panel_early-side_1"
    wks = gsn_open_wks(wks_type, wks_name)

    rain_cnlevels = (/.1,1,5,10,25,50,75,100,150,200,300,400,500,600,700/);16 colors
    rain_cmap = read_colormap_file("precip2_17lev")
    rain_colors = new((/16,4/),float)
    rain_colors(0,:) = rain_cmap(0,:)
    rain_colors(1:15,:) = rain_cmap(3:17,:)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 22
    res@gsnLeftString = ""
    res@gsnRightString  = ""
    res@gsnLeftStringOrthogonalPosF = 0.03 ; higher value for higher position
    res@gsnRightStringOrthogonalPosF = 0.02

    ;res@vpHeightF = 0.8
    ;res@vpWidthF  = 0.8
    ;res@vpXF = 0.1
    ;res@vpYF = 0.95

    mpres = res
    mpres@mpProjection = "LambertConformal"
    mpres@mpLambertParallel1F = 30
    mpres@mpLambertParallel2F = 45
    mpres@mpLambertMeridianF = 117.5

    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon
    mpres@gsnMaskLambertConformal = True
    mpres@gsnMaskLambertConformalOutlineOn = True

    mpres@mpDataSetName              = "$HOME/jungu/.config/ncl/database/Earth..4"
    mpres@mpDataBaseVersion          = "MediumRes"
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineBoundarySets      = "Geophysical"
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpNationalLineThicknessF   = 2*N_res
    mpres@mpGeophysicalLineThicknessF= 1.5*N_res
    mpres@mpProvincialLineThicknessF = 1*N_res

    mpres@mpGridAndLimbOn       = False
    mpres@mpGridSpacingF        = 5.0
    mpres@mpGridLineDashPattern = 2
    mpres@mpGridLineThicknessF  = 2.*N_res

    ;mpres@pmTickMarkDisplayMode = "Always"
    mpres@tmXTOn = False
    mpres@tmYROn = False
    mpres@tmBorderThicknessF  = 4.5*N_res
    mpres@tmYLMajorThicknessF = 3.5*N_res
    mpres@tmYLMinorThicknessF = 3.5*N_res
    mpres@tmYLMajorLengthF    = 0.01
    mpres@tmYLMinorLengthF    = 0.006
    mpres@tmXBMajorThicknessF = 3.5*N_res
    mpres@tmXBMinorThicknessF = 3.5*N_res
    mpres@tmXBMajorLengthF    = 0.01
    mpres@tmXBMinorLengthF    = 0.006
    mpres@tmXBLabelFont = 21
    mpres@tmYLLabelFont = 21
    mpres@tmXBLabelFontHeightF = 0.015
    mpres@tmYLLabelFontHeightF = 0.015

    mpres@tmXBMinorOn = True
    mpres@tmYLMinorOn = True
    ;mpres@tmXBLabelDeltaF = -0.5
    ;mpres@tmYLLabelDeltaF = -0.5

    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn        = True
    cnres@cnLinesOn       = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False
    cnres@cnFillMode      = "RasterFill"
    cnres@cnRasterSmoothingOn = True
    ;cnres@cnSmoothingOn   = True
    cnres@cnSmoothingDistanceF = 1e-2
    cnres@cnSmoothingTensionF = 0.001
    ;cnres@trGridType      = "TriangularMesh"
    ;cnres@sfXCellBounds   = lonvoc
    ;cnres@sfYCellBounds   = latvoc
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels             = rain_cnlevels
    cnres@cnFillColors         = rain_colors
    cnres@lbLabelBarOn         = False

    ;-------Plot---------
    contour = new(6, graphic)
    box     = new(6, graphic)
    box_south = new(6, graphic)
    box_north = new(6, graphic)
    lat_spacing = 5
    lon_spacing = 5
    box_lat = (/35,35,41,41,35/)
    box_lon = (/112.5,117.5,117.5,112.5,112.5/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineThicknessF  = 1.5*N_res
    plres@gsLineColor       = "Black"
    ;south box
    polygon_lat_south := (/35,35,38.5,38.5,35/)
    polygon_lon_south := (/113,115,115,113,113/)
    plres_s = plres
    plres_s@gsLineThicknessF  = 2*N_res
    plres_s@gsLineColor       = "maroon1"
    ;north box
    polygon_lat_north := (/38.5,38.5,40.5,40.5,38.5/)
    polygon_lon_north := (/113.5,116,117,114.5,113.5/)
    plres_n = plres
    plres_n@gsLineThicknessF  = 2*N_res 
    plres_n@gsLineColor       = "darkviolet"

    ;no observation
    ;contour(0) = gsn_csm_contour_map(wks,rain_obs,cnres)
    ;add_lc_labels(wks, contour(0), minlat, maxlat, minlon, maxlon, lat_spacing, lon_spacing)
    ;box(0) = gsn_add_polyline(wks, contour(0), box_lon, box_lat, plres)
    ;box_south(0) = gsn_add_polyline(wks, contour(0), polygon_lon_south, polygon_lat_south, plres_s)
    ;box_north(0) = gsn_add_polyline(wks, contour(0), polygon_lon_north, polygon_lat_north, plres_n)

    center_string = "member" + sprinti("%02d",ispan(4,9,1))
    cnres@gsnCenterStringFontHeightF = 0.02
    do i = 0, 5
        cnres@sfXArray        = lonCell
        cnres@sfYArray        = latCell
        ;cnres@gsnCenterString = "~F21~" + case_list(i)
        cnres@gsnCenterString = "~F21~" + center_string(i)
        contour(i) = gsn_csm_contour_map(wks,rain_3day(i,:),cnres)
        ;contour(i) = gsn_csm_map(wks,cnres)
        add_lc_labels(wks, contour(i), minlat, maxlat, minlon, maxlon, lat_spacing, lon_spacing)
        box(i) = gsn_add_polyline(wks, contour(i), box_lon, box_lat, plres)
        box_south(i) = gsn_add_polyline(wks, contour(i), polygon_lon_south, polygon_lat_south, plres_s)
        box_north(i) = gsn_add_polyline(wks, contour(i), polygon_lon_north, polygon_lat_north, plres_n)
    end do

;Create customized label
    lbres = True
    lbres@vpXF = 0.2
    lbres@vpYF = 0.06
    lbres@vpWidthF = 0.6
    lbres@vpHeightF= 0.05

    lbres@lbPerimOn             = False
    lbres@lbBoxLinesOn          = True
    lbres@lbBoxLineThicknessF   = 4.0*N_res
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF   = 1.2*N_res
    lbres@lbOrientation         = "Horizontal"
    lbres@lbFillColors          = rain_colors
    lbres@lbMonoFillPattern     = True
    lbres@lbLabelFontHeightF    = 0.012
    lbres@lbLabelFontAspectF    = 1.2
    lbres@lbLabelAlignment      = "InteriorEdges"
    lbres@lbTitleJust           = "TopCenter"
    lbres@lbTitleFontHeightF    = 0.014
    lbres@lbTitleOffsetF        = 0.2
    lbres@lbTitleExtentF        = 0.25
    lbres@lbTitleString         = "~F21~3-day accumulated rainfall (mm)";optional
    lbres@lbTitlePosition       = "Bottom"
    lbres@lbLabelStride         = 1
    nboxes = dimsizes(rain_colors)
    labels = "~F21~"+rain_cnlevels
    lbid_mslp = gsn_create_labelbar(wks,nboxes,labels,lbres)
    print("draw label bar")
    draw(lbid_mslp)

    ;draw plots in panel
    resP = True
    resP@gsnFrame = False
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec  = True
    resP@gsnPanelCenter   = True
    resP@gsnPanelXWhiteSpacePercent = 5
    resP@gsnPanelYWhiteSpacePercent = 5
    resP@gsnPanelBottom   = 0.1
    resP@gsnPanelDebug    = True
    gsn_panel(wks, contour, (/2,2,2/), resP)
    ;drawNDCGrid(wks)
    frame(wks)
end
