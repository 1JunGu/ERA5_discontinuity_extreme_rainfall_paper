load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")

    day_list = (/"2023-07-29","2023-07-30", "2023-07-31"/)
    date_list = new((/24 * 3/),"string")
    do iday = 0,2
        do ihour = 0,23
            date_list(iday*24 + ihour) = day_list(iday) + "_" + sprinti("%02i.00.00",ihour)
        end do
    end do

    hour_interval = 24 ; in hour
    group_interval =  72 / hour_interval
    date_list_interval = new((/72/hour_interval, hour_interval/),"string")

    do i = 0, group_interval - 1
        date_list_interval(i,:) = date_list(i*hour_interval:i*hour_interval + hour_interval - 1)
    end do

    ;read maps static nc
    mpas_mesh_fi = addfile("$HOME/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/cell_fill.nc","r")
    latCell = mpas_mesh_fi->latCell
    lonCell = mpas_mesh_fi->lonCell
    latvoc  = mpas_mesh_fi->latvoc
    lonvoc  = mpas_mesh_fi->lonvoc

    ;read ERA5 data
    ERA5_path = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/cases/23.7/data/raw"
    ERA5_fi = addfile(ERA5_path + "/zuvq.nc","r")
    iso_levels_ERA5 = ERA5_fi->level
    ind_500hPa_ERA5 = ind(iso_levels_ERA5.eq.500)
    ind_850hPa_ERA5 = ind(iso_levels_ERA5.eq.850)
    geopotential_height_500hPa_ERA5 = ERA5_fi->z(:,ind_500hPa_ERA5,:,:) / 9.80665
    qv_850hPa_ERA5 = ERA5_fi->q(:,ind_850hPa_ERA5,:,:) ;convert to g/kg
    uReconstructZonal_850hPa_ERA5 = ERA5_fi->u(:,ind_850hPa_ERA5,:,:) ;unit: m/s
    uReconstructMeridional_850hPa_ERA5 = ERA5_fi->v(:,ind_850hPa_ERA5,:,:) ;unit: m/s

    ;read rain from CLDAS
    rain_path_ERA5 = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/cases/23.7/data/processed/CLDAS/CLDAS_rain_regrid_to_v4km_stod.nc"
    rain_fi_ERA5= addfile(rain_path_ERA5,"r")
    rain_hr_CLDAS = rain_fi_ERA5->rain ;unit: mm/hour


    minlat = 30.
    maxlat = 45.
    minlon = 106.
    maxlon = 129.

    system("mkdir -p ../outputs/figs/" + "good-ERA5/" + hour_interval + "_hour")

    ;rain hourly data path prefix
    rain_path = "../../01_rainfall/outputs/data/"
    ;circulation data path prefix; averaged over 30th July
    cir_path = "../outputs/data/"

    setvalues NhlGetWorkspaceObjectId() 
    "wsMaximumSize" : 300000000
    end setvalues 

    do idate =1, 1; 30th July
        print_clock("Start " + date_list_interval(idate,0) + " to " + date_list_interval(idate,hour_interval-1))
        start_ind = idate * hour_interval
        end_ind   = idate * hour_interval + hour_interval - 1

        ;average over good members
        rain_finame = rain_path + "pr_global_3day_hourly_mpas_good_mean.nc"
        print("----Reading " + rain_finame)
        rain_fi = addfile(rain_finame,"r")
        var_rain_mul = rain_fi->rain_hr(start_ind:end_ind,:) ;unit: mm/hour
        var_rain = dim_sum_n_Wrap(var_rain_mul, 0)

        var_rain_CLDAS = dim_sum_n_Wrap(rain_hr_CLDAS(start_ind:end_ind,:), 0)
        var_rain_diff = var_rain - var_rain_CLDAS
        printMinMax(var_rain_diff, 1)

        ;height
        height_finame = cir_path + "geopotential_height_50000Pa_global_good_mean-30th.nc"
        height_fi = addfile(height_finame,"r")
        var_height_500hPa = height_fi->geopotential_height;unit: m

        var_height_500hPa_ERA5 = dim_avg_n_Wrap(geopotential_height_500hPa_ERA5(start_ind:end_ind,:,:), 0)
        var_height_500hPa_diff = var_height_500hPa - var_height_500hPa_ERA5
        copy_VarCoords(var_height_500hPa, var_height_500hPa_diff)

        ;moisture flux at 850hPa
        qv_finame = cir_path + "qv_85000Pa_global_good_mean-30th.nc"
        qv_fi = addfile(qv_finame,"r")
        var_qv_850hPa = qv_fi->qv ;unit: kg/kg
        var_qv_850hPa_ERA5 = dim_avg_n_Wrap(qv_850hPa_ERA5(start_ind:end_ind,:,:), 0)

        uReconstructZonal_finame = cir_path + "uReconstructZonal_85000Pa_global_good_mean-30th.nc"
        uReconstructZonal_fi = addfile(uReconstructZonal_finame,"r")
        var_uReconstructZonal_850hPa = uReconstructZonal_fi->uReconstructZonal;unit: m/s
        var_uReconstructZonal_850hPa_ERA5 = dim_avg_n_Wrap(uReconstructZonal_850hPa_ERA5(start_ind:end_ind,:,:), 0)


        uReconstructMeridional_finame = cir_path + "uReconstructMeridional_85000Pa_global_good_mean-30th.nc"
        uReconstructMeridional_fi = addfile(uReconstructMeridional_finame,"r")
        var_uReconstructMeridional_850hPa = uReconstructMeridional_fi->uReconstructMeridional ;unit: m/s
        var_uReconstructMeridional_850hPa_ERA5 = dim_avg_n_Wrap(uReconstructMeridional_850hPa_ERA5(start_ind:end_ind,:,:), 0)

        var_q_u = var_qv_850hPa * var_uReconstructZonal_850hPa * 1e3
        var_q_v = var_qv_850hPa * var_uReconstructMeridional_850hPa * 1e3 ;convert to m/s g/kg
        var_q_u = where(var_q_u.lt.1000000,var_q_u, var_q_u@_FillValue)
        var_q_v = where(var_q_v.lt.1000000,var_q_v, var_q_v@_FillValue)

        var_q_u_ERA5 = var_qv_850hPa_ERA5 * var_uReconstructZonal_850hPa_ERA5 * 1e3
        var_q_v_ERA5 = var_qv_850hPa_ERA5 * var_uReconstructMeridional_850hPa_ERA5 * 1e3 ;convert to m/s g/kg

        var_q_u_diff = var_q_u - var_q_u_ERA5
        var_q_v_diff = var_q_v - var_q_v_ERA5   

        copy_VarCoords(var_qv_850hPa, var_q_u_diff)
        copy_VarCoords(var_qv_850hPa, var_q_v_diff)

        n_res = 1
        wks_type = "pdf"
        wks_type@wkWidth  = 1024*n_res;
        wks_type@wkHeight = 1024*n_res
        wks_name = "../outputs/figs/" + "good-ERA5/" + hour_interval + "_hour" + "/northChina_good-minus-ERA5_" + date_list_interval(idate,0)
        ;wks_name = "../outputs/figs/" + "good-ERA5/" + hour_interval + "_hour" + "/cellFill"
        wks = gsn_open_wks(wks_type, wks_name)

        ;rain_cnlevels = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 15, 20, 25, 30, 35/);16 colors
        ;rain_cnlevels = (/0.05, 0.1, 0.5, 1, 5, 10, 20, 30, 40, 50, 70, 100,150, 200/);16 colors
        ;rain_cmap = read_colormap_file("precip2_17lev")
        ;rain_colors = new((/15,4/),float)
        ;rain_colors(0,:) = rain_cmap(0,:)
        ;rain_colors(1:14,:) = rain_cmap(3:16,:)
        rain_diff_cmap =  read_colormap_file("MPL_BrBG")
        rain_colors = new((/22,4/),"float")
        rain_colors = rain_diff_cmap(0:126:6,:)
        rain_cnlevels = fspan(-250,250,21); rain difference

        res = True
        res@gsnDraw = False
        res@gsnFrame= False
        res@gsnMaximize  = False
        res@gsnAddCyclic = False

        res@gsnStringFont = 21
        res@gsnLeftString   = ""
        res@gsnRightString  = ""
        res@gsnCenterString = ""
        res@gsnLeftStringFontHeightF    = 0.018
        res@gsnCenterStringFontHeightF  = 0.018
        res@gsnRightStringFontHeightF   = 0.018
        res@gsnLeftStringOrthogonalPosF   = 0.05
        res@gsnCenterStringOrthogonalPosF = 0.035
        res@gsnRightStringOrthogonalPosF  = 0.02

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

        mpres@mpFillOn                 = False
        mpres@mpLandFillColor          = "white"
        mpres@mpInlandWaterFillColor   = "white"
        mpres@mpOceanFillColor         = "white"
        mpres@mpFillBoundarySets       = "NoBoundaries"

        mpres@mpDataSetName            = "$HOME/jungu/.config/ncl/database/Earth..4"
        mpres@mpDataBaseVersion        = "MediumRes"
        mpres@mpOutlineSpecifiers      = (/"China","China:Provinces"/)
        mpres@mpOutlineBoundarySets    = "Geophysical"
        mpres@mpNationalLineColor      = "black"
        mpres@mpProvincialLineColor    = "black"
        mpres@mpGeophysicalLineColor   = "black"
        mpres@mpNationalLineThicknessF = 2*n_res
        mpres@mpProvincialLineThicknessF = 1*n_res
        mpres@mpGeophysicalLineThicknessF= 1.5*n_res

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
        mpres@tmXBLabelFont = 25
        mpres@tmYLLabelFont = 25
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

        ;sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
        shres = res
        shres@cnFillDrawOrder = "PostDraw"
        shres@cnFillOn  = False
        shres@cnLinesOn = True
        shres@cnInfoLabelOn   = False
        shres@cnLineLabelsOn = True
        shres@cnLevelSelectionMode = "ExplicitLevels"
        shres@cnLevels = (/-20,-16,-12,-8,8,12,16,20/)
        shres@cnSmoothingOn = True
        shres@cnSmoothingTensionF = -0.01

        shres@cnMonoLineThickness   = False;Important
        thicknesses = (/3,2.5,2,1.5,1.5,2,2.5,3/)
        shres@cnLineThicknesses     = thicknesses
        shres@cnLineLabelFontHeightF=0.01
        shres@cnMonoLineColor  = False;Important
        Colors = (/"firebrick3","firebrick3","firebrick3"\
        ,"firebrick3","firebrick3","firebrick3","firebrick3"\
        ,"firebrick3"/)
        shres@cnLineColors     = Colors
        shres@cnMonoLineDashPattern = False
        patterns = (/2,2,2,2,0,0,0,0/)
        shres@cnLineDashPatterns = patterns
        shres@cnLineLabelFont = 25

        shres@cnExplicitLineLabesOn = True
        shres@cnLineLabelInterval = 1
        shres@cnLineLabelFontColor = Colors(0)
        shres@cnLineLabelBackgroundColor = -1
        shres@cnLineLabelPlacementMode = "Constant"

        vcres                       = res
        vcres@vcGlyphStyle          = "LineArrow"
        ;vcres@vcGlyphStyle          = "CurlyVector"
        vcres@vcRefLengthF          = 0.03
        vcres@vcLineArrowColor      = "dodgerblue"
        vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
        vcres@vcLineArrowThicknessF = 1.5*n_res       ; make the vectors thicker.
        vcres@vcVectorDrawOrder     = "PostDraw"

        vcres@vcRefAnnoOn               = True
        vcres@vcRefMagnitudeF           = 100.0
        vcres@vcRefAnnoString1          = "~F21~100"
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

        cnres@cnFillMode = "AreaFill"
        ;cnres@cnRasterSmoothingOn = True
        cnres@cnSmoothingOn = False
        ;cnres@cnSmoothingDistanceF = 1e-3
        ;cnres@cnSmoothingTensionF = -0.002
        cnres@cnLevelSelectionMode = "ExplicitLevels"
        cnres@cnLevels        = rain_cnlevels
        cnres@cnFillColors    = rain_colors
        cnres@lbLabelBarOn    = False
        cnres@trGridType = "TriangularMesh"
        cnres@sfXArray = lonCell
        cnres@sfYArray = latCell
        ;cnres@sfXCellBounds = lonvoc
        ;cnres@sfYCellBounds = latvoc

        cnres@gsnLeftString = ""
        cnres@gsnCenterString = ""
        plot = gsn_csm_contour_map(wks,var_rain_diff,cnres)
        printMinMax(var_height_500hPa_diff({minlat:maxlat},{minlon:maxlon}), 1)
        contour_gph = gsn_csm_contour(wks,var_height_500hPa_diff({minlat:maxlat},{minlon:maxlon}),shres)
        moisture_flux = gsn_csm_vector(wks,var_q_u_diff({minlat:maxlat},{minlon:maxlon}), var_q_v_diff({minlat:maxlat},{minlon:maxlon}),vcres)

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
        lbres@lbLabelFontAspectF    = 1.2
        lbres@lbLabelAlignment   = "InteriorEdges"
        lbres@lbOrientation      = "Horizontal"
        lbres@lbTitlePosition    = "Bottom"
        ;lbres@lbTitleJust = "TopCenter"
        lbres@lbTitleFontHeightF = 0.017
        lbres@lbTitleOffsetF = 0.2
        lbres@lbTitleExtentF = 0.25
        lbres@lbTitleString = "~F21~Precipitation difference (mm/day)";optional
        lbres@lbLabelStride = 1
        nboxes := dimsizes(rain_colors)
        labels := "~F21~"+rain_cnlevels
        lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
        draw(lbid_rain)

        box_lat = (/35,35,41,41,35/)
        box_lon = (/112.5,117.5,117.5,112.5,112.5/)
        plres   = True
        plres@gsLineDashPattern = 0
        plres@gsLineThicknessF  = 1.5
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
