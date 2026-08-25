load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")

    exp_path = "../../../exps/sep_vars/"
    exp_list = "0728_" + sprinti("%02i", ispan(0,23,1))

    rain_data_path_prefix = "mpas_diag."
    iso_data_path_prefix  = "mpas_out."
    iso_levels = (/1000,975,950,925,900,875,850,825,800,775,750,700,650,600,550,500,450,400,350,300/)*100 ;Pa

    date_list = new((/24/),"string")
    do itime = 0,23
        date_list(itime) = "2023-07-28_" + sprinti("%02i.00.00",itime)
    end do

    if(.not.isvar("exp_order"))then
        print("Please selecet , such as: exp_order = 0")
        exit
    end if

    ref_order = exp_order + 1 ;previous time as reference
    exp_name = exp_list(exp_order)
    ref_name = exp_list(ref_order)
    ind_500hPa = ind(iso_levels.eq.50000)
    ind_850hPa = ind(iso_levels.eq.85000)

    minlat = 28.
    maxlat = 45.
    minlon = 105.
    maxlon = 130.

    system("mkdir -p ../outputs/figs/init_time_diff_from_MPAS")

    idate    = exp_order
    ref_date = ref_order
    print_clock("Start " + date_list(idate))

    height_finame = exp_path + exp_name + "/" + iso_data_path_prefix + date_list(idate) + "/ERA5/geopotential_height.nc"
    print("----Reading " + height_finame)
    height_fi = addfile(height_finame,"r")
    var_height_500hPa = height_fi->geopotential_height(ind_500hPa,:,:) ;unit: m

    qv_finame = exp_path + exp_name + "/" + iso_data_path_prefix + date_list(idate) + "/ERA5/qv.nc"
    print("----Reading " + qv_finame)
    qv_fi = addfile(qv_finame,"r")
    var_qv_850hPa = qv_fi->qv(ind_850hPa,:,:) ;unit: kg/kg

    uReconstructZonal_finame = exp_path + exp_name + "/" + iso_data_path_prefix + date_list(idate) + "/ERA5/uReconstructZonal.nc"
    print("----Reading " + uReconstructZonal_finame)
    uReconstructZonal_fi = addfile(uReconstructZonal_finame,"r")
    var_uReconstructZonal_850hPa = uReconstructZonal_fi->uReconstructZonal(ind_850hPa,:,:) ;unit: m/s

    uReconstructMeridional_finame = exp_path + exp_name + "/" + iso_data_path_prefix + date_list(idate) + "/ERA5/uReconstructMeridional.nc"
    print("----Reading " + uReconstructMeridional_finame)
    uReconstructMeridional_fi = addfile(uReconstructMeridional_finame,"r")
    var_uReconstructMeridional_850hPa = uReconstructMeridional_fi->uReconstructMeridional(ind_850hPa,:,:) ;unit: m/s

    var_q_u = var_qv_850hPa * var_uReconstructZonal_850hPa * 1e3
    var_q_v = var_qv_850hPa * var_uReconstructMeridional_850hPa * 1e3 ;convert to m/s g/kg
    copy_VarCoords(var_qv_850hPa, var_q_u)
    copy_VarCoords(var_qv_850hPa, var_q_v)
    var_q_u = where(var_q_u.lt.1000000,var_q_u, var_q_u@_FillValue)
    var_q_v = where(var_q_v.lt.1000000,var_q_v, var_q_v@_FillValue)

    ;reference time
    height_finame = exp_path + ref_name + "/" + iso_data_path_prefix + date_list(ref_order) + "/ERA5/geopotential_height.nc"
    print("----Reading " + height_finame)
    height_fi = addfile(height_finame,"r")
    var_height_500hPa_ref = height_fi->geopotential_height(ind_500hPa,:,:) ;unit: m

    qv_finame = exp_path + ref_name + "/" + iso_data_path_prefix + date_list(ref_order) + "/ERA5/qv.nc"
    print("----Reading " + qv_finame)
    qv_fi = addfile(qv_finame,"r")
    var_qv_850hPa_ref = qv_fi->qv(ind_850hPa,:,:) ;unit: kg/kg

    uReconstructZonal_finame = exp_path + ref_name + "/" + iso_data_path_prefix + date_list(ref_order) + "/ERA5/uReconstructZonal.nc"
    print("----Reading " + uReconstructZonal_finame)
    uReconstructZonal_fi = addfile(uReconstructZonal_finame,"r")
    var_uReconstructZonal_850hPa_ref = uReconstructZonal_fi->uReconstructZonal(ind_850hPa,:,:) ;unit: m/s

    uReconstructMeridional_finame = exp_path + ref_name + "/" + iso_data_path_prefix + date_list(ref_order) + "/ERA5/uReconstructMeridional.nc"
    print("----Reading " + uReconstructMeridional_finame)
    uReconstructMeridional_fi = addfile(uReconstructMeridional_finame,"r")
    var_uReconstructMeridional_850hPa_ref = uReconstructMeridional_fi->uReconstructMeridional(ind_850hPa,:,:) ;unit: m/s

    var_q_u_ref = var_qv_850hPa_ref * var_uReconstructZonal_850hPa_ref * 1e3
    var_q_v_ref = var_qv_850hPa_ref * var_uReconstructMeridional_850hPa_ref * 1e3 ;convert to m/s g/kg
    copy_VarCoords(var_qv_850hPa_ref, var_q_u_ref)
    copy_VarCoords(var_qv_850hPa_ref, var_q_v_ref)
    var_q_u_ref = where(var_q_u_ref.lt.1000000,var_q_u_ref, var_q_u_ref@_FillValue)
    var_q_v_ref = where(var_q_v_ref.lt.1000000,var_q_v_ref, var_q_v_ref@_FillValue)

    ;rain_diff = var_rain - var_rain_ref
    ;copy_VarCoords(var_rain_ref, rain_diff)
    height_500hPa_diff = var_height_500hPa_ref - var_height_500hPa
    copy_VarCoords(var_height_500hPa_ref, height_500hPa_diff)
    q_u_diff = var_q_u_ref - var_q_u
    copy_VarCoords(var_q_u_ref, q_u_diff)
    q_v_diff = var_q_v_ref - var_q_v
    copy_VarCoords(var_q_v_ref, q_v_diff)


    n_res = 1
    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    wks_name = "../outputs/figs/init_time_diff_from_MPAS/GPH500hPa_MF850hPa_northChina_" + date_list(idate) + "-minus-" + date_list(ref_order)
    wks = gsn_open_wks(wks_type, wks_name)

    rain_cnlevels = (/0.01, 0.05, 0.1, 0.2, 0.5, 1, 2, 5, 10, 15, 20, 25, 30, 35/);16 colors
    rain_cmap = read_colormap_file("precip2_17lev")
    rain_colors = new((/15,4/),float)
    rain_colors(0,:) = rain_cmap(0,:)
    rain_colors(1:14,:) = rain_cmap(3:16,:)

    gph_diff_cnlevels = fspan(-10,10,9); 14 colors
    gph_diff_cmap = read_colormap_file("BlueYellowRed")
    gph_diff_colors = new((/10,4/),float)
    gph_diff_colors(0:4,:)  = gph_diff_cmap(2:122:30,:)
    gph_diff_colors(5:9,:) = gph_diff_cmap(133:253:30,:)

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
    mpres@mpInlandWaterFillColor   = "white"
    mpres@mpOceanFillColor         = "white"
    mpres@mpFillBoundarySets       = "NoBoundaries"

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
    shres@cnLevels = (/576,578,580,582,584,586,588,590,592,594/)*10
    shres@cnMonoLineThickness   = False;Important
    thicknesses = (/5,5,5,5,5,7,5,5,5,5/)
    shres@cnLineThicknesses     = thicknesses
    shres@cnLineLabelFontHeightF=0.01
    shres@cnMonoLineColor  = False;Important
    Colors = (/"Black","Black","Black","Black"\
    ,"Black","Red","Black","Black","Black"\
    ,"Black"/)
    shres@cnLineColors     = Colors
    shres@cnMonoLineDashPattern = False
    patterns = (/2,2,2,2,2,0,0,0,0,0/)
    shres@cnLineDashPatterns = patterns
    shres@cnLineLabelFont = 25
    ;sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
    ;shres@cnLineThicknessF = 5*n_res
    ;shres@cnLineDashPattern = 0

    vcres                       = res
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.03
    vcres@vcLineArrowColor      = "dodgerblue"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 1.5*n_res            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "PostDraw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 50.0
    vcres@vcRefAnnoString1          = "~F21~50"
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
    cnres@cnRasterSmoothingOn = True
    cnres@cnSmoothingDistanceF = 1e-4
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = gph_diff_cnlevels
    cnres@cnFillColors    = gph_diff_colors
    cnres@lbLabelBarOn    = False
    ;cnres@trGridType = "TriangularMesh"
    ;cnres@sfXArray = lonCell
    ;cnres@sfYArray = latCell

    cnres@gsnLeftString = ""
    cnres@gsnCenterString = ""
    plot = gsn_csm_contour_map(wks,height_500hPa_diff,cnres)
    ;contour_gph = gsn_csm_contour(wks,var_height_500hPa({minlat:maxlat},{minlon:maxlon}),shres)

    ;var_q_u = where(var_q_u.lt.1000000,var_q_u, var_q_u@_FillValue)
    ;var_q_v = where(var_q_v.lt.1000000,var_q_v, var_q_v@_FillValue)
    moisture_flux = gsn_csm_vector(wks,q_u_diff({minlat:maxlat},{minlon:maxlon}), q_v_diff({minlat:maxlat},{minlon:maxlon}),vcres)

    ;overlay(plot,contour_gph)
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
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 2.0*n_res
    lbres@lbFillColors  = gph_diff_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.012
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation      = "Horizontal"
    lbres@lbTitlePosition    = "Bottom"
    ;lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.017
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "~F25~500-hPa geopotential height difference (m)";optional
    lbres@lbLabelStride = 1
    nboxes := dimsizes(gph_diff_colors)
    labels := "~F25~"+gph_diff_cnlevels
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
    ;end do
    print_clock("End")
end
