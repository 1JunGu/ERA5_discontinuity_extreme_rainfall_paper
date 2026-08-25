load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")

    exp_path = "../../../exps/sep_vars/"
    exp_list = "0728_" + sprinti("%02i", ispan(0,23,1))

    rain_data_path_prefix = "mpas_diag."
    iso_data_path_prefix  = "mpas_out."
    iso_levels = (/1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300/)*100 ;Pa

    day_list = (/"2023-07-29","2023-07-30", "2023-07-31"/)
    date_list = new((/24 * 3/),"string")
    do iday = 0,2
        do ihour = 0,23
            date_list(iday*24 + ihour) = day_list(iday) + "_" + sprinti("%02i.00.00",ihour)
        end do
    end do

    if(.not.isvar("exp_order"))then
        print("Please selecet , such as: exp_order = 0")
        exit
    end if

    exp_name = exp_list(exp_order);specify experiment name

    hour_interval = 12 ; in hour
    group_interval =  72 / hour_interval
    date_list_interval = new((/72/hour_interval, hour_interval/),"string")

    do i = 0, group_interval - 1
        date_list_interval(i,:) = date_list(i*hour_interval:i*hour_interval + hour_interval - 1)
    end do

    ind_500hPa = ind(iso_levels.eq.50000)
    ind_850hPa = ind(iso_levels.eq.85000)

    ;read maps static nc
    mpas_mesh_fi = addfile("$HOME/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/cell_fill.nc","r")
    latCell = mpas_mesh_fi->latCell
    lonCell = mpas_mesh_fi->lonCell
    latvoc  = mpas_mesh_fi->latvoc
    lonvoc  = mpas_mesh_fi->lonvoc

    minlat = 28.
    maxlat = 45.
    minlon = 105.
    maxlon = 130.

    output_path = "../outputs/figs/" + exp_name + "/" + hour_interval + "_hour/"
    system("mkdir -p " + output_path)

    do idate =0, group_interval - 1
        print_clock("Start " + date_list_interval(idate,0) + " to " + date_list_interval(idate,hour_interval-1))

        rain_finames = exp_path + exp_name + "/" + rain_data_path_prefix + date_list_interval(idate,:) + "/rain_hr.nc"
        ;print("----Reading " + rain_finame)
        rain_fi = addfiles(rain_finames,"r")
        ListSetType(rain_fi, "join")
        var_rain_mul = rain_fi[:]->rain_hr ;unit: mm/hour
        var_rain = dim_sum_n_Wrap(var_rain_mul, 0)

        height_finames = exp_path + exp_name + "/" + iso_data_path_prefix + date_list_interval(idate,:) + "/ERA5/geopotential_height.nc"
        height_fi = addfiles(height_finames,"r")
        ListSetType(height_fi, "join")
        var_height_500hPa_mul = height_fi[:]->geopotential_height(:,ind_500hPa,:,:) ;unit: m
        var_height_500hPa = dim_avg_n_Wrap(var_height_500hPa_mul, 0)

        qv_finames = exp_path + exp_name + "/" + iso_data_path_prefix + date_list_interval(idate,:) + "/ERA5/qv.nc"
        qv_fi = addfiles(qv_finames,"r")
        ListSetType(qv_fi, "join")
        var_qv_850hPa_mul = qv_fi[:]->qv(:,ind_850hPa,:,:) ;unit: kg/kg
        var_qv_850hPa = dim_avg_n_Wrap(var_qv_850hPa_mul, 0)

        uReconstructZonal_finames = exp_path + exp_name + "/" + iso_data_path_prefix + date_list_interval(idate,:) + "/ERA5/uReconstructZonal.nc"
        uReconstructZonal_fi = addfiles(uReconstructZonal_finames,"r")
        ListSetType(uReconstructZonal_fi, "join")
        var_uReconstructZonal_850hPa_mul = uReconstructZonal_fi[:]->uReconstructZonal(:,ind_850hPa,:,:) ;unit: m/s
        var_uReconstructZonal_850hPa = dim_avg_n_Wrap(var_uReconstructZonal_850hPa_mul, 0)

        uReconstructMeridional_finames = exp_path + exp_name + "/" + iso_data_path_prefix + date_list_interval(idate,:) + "/ERA5/uReconstructMeridional.nc"
        uReconstructMeridional_fi = addfiles(uReconstructMeridional_finames,"r")
        ListSetType(uReconstructMeridional_fi, "join")
        var_uReconstructMeridional_850hPa_mul = uReconstructMeridional_fi[:]->uReconstructMeridional(:,ind_850hPa,:,:) ;unit: m/s
        var_uReconstructMeridional_850hPa = dim_avg_n_Wrap(var_uReconstructMeridional_850hPa_mul, 0)

        var_q_u = var_qv_850hPa * var_uReconstructZonal_850hPa * 1e3
        var_q_v = var_qv_850hPa * var_uReconstructMeridional_850hPa * 1e3 ;convert to m/s g/kg
        copy_VarCoords(var_qv_850hPa, var_q_u)
        copy_VarCoords(var_qv_850hPa, var_q_v)

        n_res = 1
        wks_type = "pdf"
        ;wks_type@wkWidth  = 1024*n_res;
        ;wks_type@wkHeight = 1024*n_res
        wks_name = output_path + "/GPH500hPa_MF850hPa_rain_northChina_" + date_list_interval(idate,0)
        wks = gsn_open_wks(wks_type, wks_name)

        ;rain_cnlevels = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 15, 20, 25, 30, 35/);16 colors
        ;rain_cnlevels = (/0.01, 0.05, 0.1, 0.5, 1, 2, 5, 10, 15, 20, 25, 30, 40, 50/);3hour
        rain_cnlevels = (/0.1, 0.5, 1, 5, 10, 20, 30, 40, 50, 70, 100,150, 200, 250/);16 colors for 24hour
        rain_cmap = read_colormap_file("precip2_17lev")
        rain_colors = new((/15,4/),float)
        rain_colors(0,:) = rain_cmap(0,:)
        rain_colors(1:14,:) = rain_cmap(3:16,:)

        res = True
        res@gsnDraw = False
        res@gsnFrame= False
        res@gsnMaximize  = False
        res@gsnAddCyclic = False

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

        mpres = res
        mpres@mpProjection = "LambertConformal"
        mpres@mpLambertParallel1F = 35
        mpres@mpLambertParallel2F = 45
        mpres@mpLambertMeridianF = 117.5

        mpres@mpLimitMode   	= "LatLon"
        mpres@mpMinLatF = minlat
        mpres@mpMaxLatF = maxlat
        mpres@mpMinLonF = minlon
        mpres@mpMaxLonF = maxlon
        mpres@gsnMaskLambertConformal = True
        mpres@gsnMaskLambertConformalOutlineOn = True

        mpres@mpFillOn                 = False
        mpres@mpLandFillColor          = "white"
        mpres@mpInlandWaterFillColor     = "white"
        mpres@mpOceanFillColor           = "white"
        mpres@mpFillBoundarySets         = "NoBoundaries"

        mpres@mpDataSetName            = "$HOME/jungu/.config/ncl/database/Earth..4"
        mpres@mpDataBaseVersion        = "MediumRes"
        mpres@mpOutlineSpecifiers      = (/"China","China:Provinces"/)
        mpres@mpOutlineBoundarySets      = "Geophysical"
        mpres@mpNationalLineColor        = "black"
        mpres@mpProvincialLineColor      = "black"
        mpres@mpGeophysicalLineColor     = "black"
        mpres@mpNationalLineThicknessF   = 2*n_res
        mpres@mpGeophysicalLineThicknessF= 1.5*n_res
        mpres@mpProvincialLineThicknessF = 1*n_res

        mpres@mpGridAndLimbOn       = False
        mpres@mpGridSpacingF        = 5.0
        mpres@mpGridLineDashPattern = 2
        mpres@mpGridLineThicknessF  = 1.5*n_res

        ;mpres@mpPerimOn = True
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

        shres = res
        shres@cnFillDrawOrder = "PostDraw"
        shres@cnFillOn  = False
        shres@cnLinesOn = True
        shres@cnInfoLabelOn   = False
        shres@cnLineLabelsOn = False
        shres@cnLevelSelectionMode = "ExplicitLevels"
        shres@cnLevels = (/584,586,588,590,592/)*10
        shres@cnMonoLineThickness   = False;Important
        thicknesses = (/2,2,2.5,3,3.5/)
        shres@cnLineThicknesses     = thicknesses
        shres@cnLineLabelFontHeightF=0.01
        shres@cnMonoLineColor  = False;Important
        Colors = (/"Black","Black","Purple","Black","Black"/)
        shres@cnLineColors     = Colors
        shres@cnMonoLineDashPattern = False
        patterns = (/1,1,1,1,1/)
        shres@cnLineDashPatterns = patterns
        shres@cnLineLabelFont = 25
        ;shres@cnExplicitLineLabesOn = True
        ;shres@cnLineLabelInterval = 1
        ;shres@cnLineLabelFontColor = Colors(0)
        ;shres@cnLineLabelBackgroundColor = -1
        ;shres@cnLineLabelPlacementMode = "Constant"

        vcres                       = res
        vcres@vcGlyphStyle          = "LineArrow"
        ;vcres@vcGlyphStyle          = "CurlyVector"
        vcres@vcRefLengthF          = 0.03
        vcres@vcLineArrowColor      = "dodgerblue"
        vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
        vcres@vcLineArrowThicknessF = 1.5*n_res            ; make the vectors thicker.
        vcres@vcVectorDrawOrder     = "PostDraw"

        vcres@vcRefAnnoOn               = True
        vcres@vcRefMagnitudeF           = 200.0
        vcres@vcRefAnnoString1          = "~F21~200"
        vcres@vcRefLengthF              = 0.03   ; define length of vec ref
        vcres@vcRefAnnoFontHeightF      = 0.01
        vcres@vcRefAnnoFontThicknessF   = 1.
        vcres@vcRefAnnoSide             = "Top"
        ;vcres@vcRefAnnoJust             = "TopLeft"
        vcres@vcRefAnnoString2On        = True
        vcres@vcRefAnnoString2          = "~F21~g/kg m/s"
        vcres@vcRefAnnoPerimOn          = False
        vcres@vcRefAnnoOrthogonalPosF   = -0.17
        vcres@vcRefAnnoParallelPosF     = 0.9
        vcres@vcRefAnnoBackgroundColor  = "white"

        ;sdres@gsnLeftString = Leftstring_list(0) + "500-hPa moisture flux and vertical speed"
        ;plot(0) = gsn_csm_contour_map(wks,w_s,sdres)
        ;contour = gsn_csm_contour(wks,h_s({minlat:maxlat},{minlon:maxlon}),shres)
        ;vector  = gsn_csm_vector(wks,qu({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
        ;overlay(plot(0),vector)
        ;overlay(plot(0),contour)

        cnres = mpres
        cnres@cnFillDrawOrder = "Draw"
        cnres@cnFillOn = True
        cnres@cnLinesOn = False
        cnres@cnInfoLabelOn   = False
        cnres@cnLineLabelsOn  = False

        ;cnres@cnFillMode = "RasterFill"
        cnres@cnFillMode = "RasterFill"
        cnres@cnRasterSmoothingOn = True
        ;cnres@cnSmoothingOn = True
        cnres@cnSmoothingDistanceF = 1e-3
        ;cnres@cnSmoothingTensionF = 2.5
        cnres@cnLevelSelectionMode = "ExplicitLevels"
        cnres@cnLevels        = rain_cnlevels
        cnres@cnFillColors    = rain_colors
        cnres@lbLabelBarOn    = False
        cnres@trGridType = "TriangularMesh"
        cnres@sfXArray = lonCell
        cnres@sfYArray = latCell

        cnres@gsnLeftString = ""
        cnres@gsnCenterString = ""
        plot = gsn_csm_contour_map(wks,var_rain,cnres)
        contour_gph = gsn_csm_contour(wks,var_height_500hPa({minlat:maxlat},{minlon:maxlon}),shres)

        var_q_u = where(var_q_u.lt.1000000,var_q_u, var_q_u@_FillValue)
        var_q_v = where(var_q_v.lt.1000000,var_q_v, var_q_v@_FillValue)
        moisture_flux = gsn_csm_vector(wks,var_q_u({minlat:maxlat},{minlon:maxlon}), var_q_v({minlat:maxlat},{minlon:maxlon}),vcres)

        overlay(plot,contour_gph)
        overlay(plot,moisture_flux)

        lat_spacing  = 5
        lon_spacing  = 5
        add_lc_labels(wks,plot,minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing) ; Important

    ;Create common label
        lbres = True
        lbres@vpXF = 0.2
        lbres@vpYF = 0.18
        lbres@vpWidthF = 0.6
        lbres@vpHeightF= 0.06

        lbres@lbPerimOn = False
        lbres@lbBoxLinesOn = False
        lbres@lbBoxSeparatorLinesOn = False
        lbres@lbBoxLineThicknessF = 4.0*n_res
        lbres@lbFillColors  = rain_colors
        lbres@lbMonoFillPattern = True
        lbres@lbLabelFontHeightF = 0.012
        lbres@lbLabelAlignment   = "InteriorEdges"
        lbres@lbOrientation      = "Horizontal"
        lbres@lbTitlePosition    = "Bottom"
        ;lbres@lbTitleJust = "TopCenter"
        lbres@lbTitleFontHeightF = 0.017
        lbres@lbTitleOffsetF = 0.2
        lbres@lbTitleExtentF = 0.25
        ;lbres@lbTitleString = "~F25~Precipitation (mm/" + hour_interval +"hour)";optional
        lbres@lbTitleString = "~F25~Precipitation (mm/day)";optional
        lbres@lbLabelStride = 1
        nboxes := dimsizes(rain_colors)
        labels := "~F25~"+rain_cnlevels
        lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
        draw(lbid_rain)

        box_lat = (/35,35,41,41,35/)
        box_lon = (/112.5,117.5,117.5,112.5,112.5/)
        plres   = True
        plres@gsLineDashPattern = 0
        plres@gsLineThicknessF  = 2
        plres@gsLineColor = "Black"
        box = gsn_add_polyline(wks, plot, box_lon, box_lat, plres)

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
    end do
    print_clock("End")
end
