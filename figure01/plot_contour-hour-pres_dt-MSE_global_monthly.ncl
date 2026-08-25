load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")
    data_path = "../outputs/data/dt_MSE/"
    finame = "2023-07_global_MAE_dt-MSE_all-level.nc"
    fi = addfile(data_path + finame,"r")
    MSE_dt = fi->MSE_dt
    pres_level = fi->level
    MSE_dt := transpose(MSE_dt)
    printVarSummary(MSE_dt)
    printMinMax(MSE_dt,1)
    ;calculate Interquartile Range (IQR)
    signi = new((/dimsizes(pres_level)/),logical)
    do ilevel = 0, dimsizes(pres_level)-1
        print("Processing level: " + pres_level(ilevel) + " hPa")
        sorted_dt_MSE = MSE_dt(ilevel,:)
        qsort(sorted_dt_MSE)
        x25 = round(0.25 * 23, 3) - 1
        x75 = round(0.75 * 23, 3) - 1
        IQR_dt_MSE = sorted_dt_MSE(x75) - sorted_dt_MSE(x25)
        IQR_dt_MSE_lower = sorted_dt_MSE(x25) - 3 * IQR_dt_MSE
        IQR_dt_MSE_upper = sorted_dt_MSE(x75) + 3 * IQR_dt_MSE
        print("IQR of dt_MSE: " + IQR_dt_MSE)
        print("Lower bound of dt_MSE: " + IQR_dt_MSE_lower)
        print("Upper bound of dt_MSE: " + IQR_dt_MSE_upper)
        signi(ilevel) = MSE_dt(ilevel,9) .ge. IQR_dt_MSE_upper .and. MSE_dt(ilevel,21) .ge. IQR_dt_MSE_lower
        print("significance at level " + pres_level(ilevel) + " hPa: " + signi(ilevel))
    end do

    ;plot 
    n_res = 1
    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    output_path = "../outputs/figs/dt_MSE/"
    wks_name = output_path + "contour-hour-pres_dt-MSE_global_monthly"
    wks = gsn_open_wks(wks_type, wks_name)

    diff_cnlevels = fspan(0.2, 2.2, 21); 22 colors
    diff_cmap = read_colormap_file("WhiteBlueGreenYellowRed")
    diff_cmap2 = read_colormap_file("helix"); red to black

    diff_colors = new((/22,4/),float)
    diff_colors(0:5,:) = diff_cmap(2:102:20,:)
    diff_colors(6:15,:) = diff_cmap(103:211:12,:)
    diff_colors(16:21,:) = diff_cmap2(160:220:-12,:)

    ;power_colors(0,3) = 0 ;set alpha

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnAddCyclic = False
    res@vpHeightF = 0.3
    res@vpWidthF  = 0.43
    res@vpXF = 0.5
    res@vpYF = 0.6

    res@gsnStringFont = 21
    res@gsnLeftString   = ""
    res@gsnCenterString = ""
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF    = 0.018
    res@gsnCenterStringFontHeightF  = 0.018
    res@gsnRightStringFontHeightF   = 0.018
    res@gsnLeftStringOrthogonalPosF   = 0.05
    res@gsnCenterStringOrthogonalPosF = 0.035
    res@gsnRightStringOrthogonalPosF  = 0.02

    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF  = 4.5*n_res
    res@tmYLMajorThicknessF = 3.5*n_res
    res@tmYLMinorThicknessF = 3.5*n_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMajorOutwardLengthF = 0.01
    res@tmYLMinorLengthF    = 0.006
    res@tmYLMinorOutwardLengthF = 0.006
    res@tmXBMajorThicknessF = 3.5*n_res
    res@tmXBMinorThicknessF = 3.5*n_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMinorLengthF    = 0.004
    res@tmXBMinorOutwardLengthF = 0.004
    res@tmXBLabelFont = 21
    res@tmYLLabelFont = 21
    res@tmXBLabelFontHeightF = 0.015
    res@tmXBLabelFontAspectF = 1.2
    res@tmYLLabelFontHeightF = 0.015
    res@tmYLLabelFontAspectF = 1.2

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(0, 22, 6)
    res@tmXBLabels = (/"00", "06", "12", "18"/)
    res@tmXBMinorValues = ispan(0,22,1)

    res@tmYLMode = "Explicit"
    ;res@trYAxisType = "LinearAxis"
    res@tmYLValues = (/900, 700 , 500, 300/)
    res@tmYLLabels = res@tmYLValues
    res@tmYLMinorValues = pres_level
    res@trYReverse = True
    ;cnres@tmYLMinorValues = ispan(26,45,1)
    ;res@tiYAxisFont = 25
    ;res@tiYAxisFontHeightF = 0.017
    ;res@tiYAxisString = "Period (hours)"

    ;res@tiXAxisFont = 25
    ;res@tiXAxisFontHeightF = 0.017
    ;res@tiXAxisString = "Date"

    cnres = res
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    ;cnres@cnFillMode = "RasterFill"
    ;cnres@sfXArray = x_coord
    ;cnres@sfYArray = y_coord
    ;cnres@sfXCellBounds = x_voc
    ;cnres@sfYCellBounds = y_voc
    ;cnres@cnRasterSmoothingOn = False
    ;cnres@cnRasterMinCellSizeF = 1e-4
    ;cnres@cnRasterSampleFactorF = 4
    cnres@cnFillMode = "AreaFill"
    cnres@cnSmoothingOn = True
    ;cnres@trGridType = "TriangularMesh"
    ;cnres@cnSmoothingDistanceF = 1e-3
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = diff_cnlevels
    cnres@cnFillColors    = diff_colors
    cnres@lbLabelBarOn    = False

    cnres@gsnLeftString = ""
    cnres@gsnCenterString = ""
    plot = gsn_csm_contour(wks,MSE_dt,cnres)

    ; significance
    shres = res
    shres@cnFillDrawOrder = "PostDraw"
    shres@cnFillOn  = False
    shres@cnLinesOn = True
    shres@cnInfoLabelOn   = False
    shres@cnLineLabelsOn = False
    shres@cnLevelSelectionMode = "ExplicitLevels"
    shres@cnLevels = (/1,2,3,4/)
    shres@cnMonoLineThickness   = False;Important
    thicknesses = (/2.5,2,2.5,3/)
    shres@cnLineThicknesses     = thicknesses
    shres@cnLineLabelFontHeightF = 0.01
    shres@cnMonoLineColor  = False;Important
    Colors = (/"Black","Black","Black","Black"/)
    shres@cnLineColors     = Colors
    shres@cnMonoLineDashPattern = False
    patterns = (/0,0,0,0/)
    shres@cnLineDashPatterns = patterns
    shres@cnLineLabelFont = 25
    ;shade = gsn_csm_contour(wks,SIG({3:32},:),shres)
    ;sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
    ;shres@cnLineThicknessF = 5*n_res
    ;shres@cnLineDashPattern = 0

    ;overlay(plot, shade)

    ;Create common label
    lbres = True
    lbres@vpXF = 0.15
    lbres@vpYF = 0.75
    lbres@vpWidthF = 0.35
    lbres@vpHeightF= 0.06

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 2.0*n_res
    lbres@lbFillColors  = diff_colors
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
    ;lbres@lbTitleString = "~F21~The time derivate of MSE (10~S~-3~N~ J~F34~W~F21~kg~S~-1~N~)";optional
    lbres@lbTitleString = "";optional
    lbres@lbLabelStride = 2
    nboxes := dimsizes(diff_colors)
    labels := "~F21~"+diff_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_rain)

    draw(plot)
    ;drawNDCGrid(wks)
    frame(wks)
    print_clock("end")
end
