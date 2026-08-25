load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")

    ;iso_levels = (/1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300/) ;hPa
    if(.not.isvar("iso_level"))then
        print("Please select , such as: iso_level = 500 or iso_level = 850")
        exit
    end if

    if(.not.isvar("init_time"))then
        print("Please select , such as: init_time = 1 or 2")
        exit
    end if

    data_path = "../outputs/data/ERA5_MSE/"
    finame = data_path + "ERA5.2023-07.nc"
    MSE_fi = addfile(finame,"r")

    var_MSE = MSE_fi->MSE
    iso_levels = MSE_fi->pressure_level
    valid_time = MSE_fi->valid_time
    time_str = valid_time(init_time)

    ind_iso = ind(iso_levels.eq.iso_level)

    var_MSE_iso = var_MSE(init_time, ind_iso,:,:)
    var_MSE_iso = var_MSE_iso/1e3

    var_MSE_iso_ref = var_MSE(init_time + 1, ind_iso,:,:)
    var_MSE_iso_ref = var_MSE_iso_ref/1e3

    var_MSE_diff = var_MSE_iso - var_MSE_iso_ref
    printMinMax(var_MSE_diff, 1)
    copy_VarCoords(var_MSE_iso, var_MSE_diff)
    var_MSE_diff&latitude@units = "degrees_north"
    var_MSE_diff&longitude@units= "degrees_east"
    var_MSE_diff_rl = abs(var_MSE_diff)
    copy_VarCoords(var_MSE_iso, var_MSE_diff_rl)
    printVarSummary(var_MSE_diff_rl)
    printMinMax(var_MSE_diff_rl, 1)

    threshold_fi = addfile("../outputs/data/dt_MSE/2023-07_global_threshold_dt-MSE_500hPa.nc","r")
    threshold_mse_dt = threshold_fi->threshold_mse_dt
    threshold_mse_dt!0 = "bounds"
    copy_VarCoords(var_MSE_diff, threshold_mse_dt(1,:,:))
    copy_VarCoords(var_MSE_diff, threshold_mse_dt(0,:,:))
    printMinMax(threshold_mse_dt, 1)


    n_res = 1

    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    system("mkdir -p " + "../outputs/figs/MSE_diff/" + iso_level)
    print("processing " + time_str + " at " + iso_level + " hPa")
    wks_name = "../outputs/figs/MSE_diff/" + iso_level +  "/map_MSE-dt_global_monthly_" + time_str + "_" + iso_level + "hPa_robinson"
    wks = gsn_open_wks(wks_type, wks_name)

    ;MSE_diff_cnlevels = fspan(-1.2,1.2,13) ;14 colors
    MSE_diff_cnlevels = (/-1.0, -0.8, -0.6, -0.4, -0.2, -0.1, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0/);15 colors
    ;MSE_diff_cmap = read_colormap_file("BlueYellowRed")
    ;MSE_diff_colors = new((/15,4/),float)
    ;MSE_diff_colors(0:6,:) = MSE_diff_cmap(2:122:20,:)
    ;MSE_diff_colors(7,:) = MSE_diff_cmap(0,:)
    ;MSE_diff_colors(7,3) = 0.0 ;set alpha
    ;MSE_diff_colors(8:14,:) = MSE_diff_cmap(133:253:20,:)
    MSE_diff_cmap = read_colormap_file("bluered_lowS")
    MSE_diff_colors = new((/13,4/),float)
    MSE_diff_colors = MSE_diff_cmap(:,:)
    MSE_diff_colors(6,3) = 0.0

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnAddCyclic = True
    res@vpWidthF = 0.5
    res@vpXF = 0.03
    ;res@vpYF = 0.35

    res@gsnStringFont = 21
    res@gsnLeftString   = ""
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF    = 0.018
    res@gsnCenterStringFontHeightF  = 0.018
    res@gsnRightStringFontHeightF   = 0.018
    res@gsnLeftStringOrthogonalPosF   = 0.05
    res@gsnCenterStringOrthogonalPosF = 0.035
    res@gsnRightStringOrthogonalPosF  = 0.02

    mpres = res
    mpres@mpProjection = "Robinson"

    mpres@mpFillOn                   = False
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"

    mpres@mpDataSetName            = "$HOME/jungu/.config/ncl/database/Earth..4"
    mpres@mpDataBaseVersion        = "LowRes"
    mpres@mpOutlineBoundarySets    = "Geophysical"
    mpres@mpGeophysicalLineColor   = "black"
    mpres@mpGeophysicalLineThicknessF= 0.8*n_res

    mpres@mpPerimOn = False

    mpres@mpGridAndLimbOn       = True ;important for robinson projection
    mpres@mpGridLatSpacingF     = 180.0
    mpres@mpGridLonSpacingF     = 180.0
    mpres@mpGridLineDashPattern = 0
    mpres@mpGridLineThicknessF  = 0.0001
    mpres@mpGridLineColor       = -1 ;transparent

    ;mpres@mpPerimLineColor = "Black"
    ;mpres@mpPerimLineThicknessF = 4.5*n_res

    ;mpres@pmTickMarkDisplayMode = "Always"
    mpres@tmXTOn = False
    mpres@tmYROn = False
    mpres@tmBorderThicknessF  = 4.5*n_res
    mpres@tmYLMajorThicknessF = 3.5*n_res
    mpres@tmYLMinorThicknessF = 3.5*n_res
    mpres@tmYLMajorLengthF    = 0.01
    mpres@tmYLMinorLengthF    = 0.006
    mpres@tmXBMajorThicknessF = 3.5*n_res
    mpres@tmXBMinorThicknessF = 3.5*n_res
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

    ;mpres@tmXBMode = "Explicit"
    ;mpres@tmXBValues = fspan(105,125,5)
    ;mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    ;mpres@tmXBMinorValues = ispan(105,129,1)

    ;mpres@tmYLMode = "Explicit"
    ;mpres@tmYLValues = fspan(30,45,4)
    ;mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    ;mpres@tmYLMinorValues = ispan(26,45,1)


    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn  = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    cnres@cnFillMode = "AreaFill" ; CellFill is too large for global data
    cnres@cnSmoothingOn = True
    cnres@cnSmoothingDistanceF = 1e-2
    ;cnres@cnSmoothingTensionF = 0.001
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = MSE_diff_cnlevels
    cnres@cnFillColors    = MSE_diff_colors
    cnres@lbLabelBarOn    = False
    ;cnres@trGridType = "TriangularMesh"
    ;cnres@sfXArray = lonCell
    ;cnres@sfYArray = latCell

    cnres@gsnLeftString = ""
    cnres@gsnCenterString = ""
    cnres@gsnRightString = ""
    plot = gsn_csm_contour_map(wks,var_MSE_diff,cnres)

    ;check_mse_dt = where(var_MSE_diff_rl.ge.threshold_mse_dt(1,:,:), 1., 0.)
    check_mse_dt = var_MSE_diff_rl - threshold_mse_dt(1,:,:)
    copy_VarCoords(var_MSE_diff, check_mse_dt)
    ;printMinMax(check_mse_dt, 1)
    ;num1  = sum(check_mse_dt)
    ;print("Number of points above upper threshold: " + num1)
    ;check_mse_dt@_FillValue = 0
    printMinMax(check_mse_dt,1)

    sdres = res
    sdres@cnFillOn = True
    sdres@cnFillMode = "AreaFill"
    sdres@cnLinesOn = False
    sdres@cnLineLabelsOn = False
    sdres@cnInfoLabelOn  = False
    sdres@lbLabelBarOn   = False
    sdres@cnLevelSelectionMode = "ExplicitLevels"
    sdres@cnLevels = (/0/)
    sdres@cnMonoFillPattern = False
    sdres@cnFillPatterns = (/-1, 17/)
    sdres@cnFillColors = (/-1,1/)
    sdres@cnFillDotSizeF = 0.001
    sdres@cnFillScaleF = 0.4
    sdres@cnFillOpacityF = 0.0

    sig_plot = gsn_csm_contour(wks,check_mse_dt, sdres)

    overlay(plot, sig_plot)


    lat_spacing  = 30
    lon_spacing  = 90
    robinson_map = add_robinson_labels(wks,plot,lat_spacing,lon_spacing)

    ;Create common label
    lbres = True
    lbres@vpXF = 0.2
    lbres@vpYF = 0.12
    lbres@vpWidthF = 0.6
    lbres@vpHeightF= 0.06

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 1.0*n_res
    lbres@lbFillColors  = MSE_diff_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.012
    lbres@lbLabelFontAspectF = 1.2
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation      = "Horizontal"
    lbres@lbTitlePosition    = "Bottom"
    ;lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.017
    lbres@lbTitleFontAspectF = 1.2
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "~F21~The time derivate of MSE (10~S~-3~N~ J/Kg/hour)";optional
    lbres@lbLabelStride = 1
    nboxes := dimsizes(MSE_diff_colors)
    labels := "~F21~" + MSE_diff_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_rain)

    ;resP = True
    ;resP@gsnFrame = False
    ;resP@gsnPanelLabelBar = False
    ;resP@gsnMaximize = True
    ;resP@gsnPanelRowSpec = True
    ;resP@gsnPanelCenter = True
    ;resP@gsnPanelXWhiteSpacePercent = 5
    ;resP@gsnPanelYWhiteSpacePercent = 2
    ;resP@gsnPanelBottom = 0.42
    ;resP@gsnPanelDebug = True
    ;gsn_panel(wks,plot(0:3),(/2,2/),resP)

    draw(plot)
    ;drawNDCGrid(wks)
    frame(wks)
    ;end do
    print_clock("end")
end
