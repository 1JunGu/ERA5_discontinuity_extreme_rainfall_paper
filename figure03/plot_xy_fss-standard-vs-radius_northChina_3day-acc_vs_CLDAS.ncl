load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    ;read fss data
    fss_data_path = "../outputs/data/"
    fss_fi = addfile(fss_data_path + "fss_standard_pr_northChina_3day-acc_vs_CLDAS_halo100km.nc", "r")
    fss_all = fss_fi->fss

    fss_southbox_fi = addfile(fss_data_path + "fss_standard_pr_northChina-southbox_3day-acc_vs_CLDAS_halo100km.nc", "r")
    fss_southbox    = fss_southbox_fi->fss

    fss_northbox_fi = addfile(fss_data_path + "fss_standard_pr_northChina-northbox_3day-acc_vs_CLDAS_halo100km.nc", "r")
    fss_northbox    = fss_northbox_fi->fss

    radius_km = fss_fi->radius_km
    threshold = fss_fi->threshold
    dims_fss = dimsizes(fss_all)
    ncases   = dims_fss(1)
    print("ncases: " + ncases)
    print("radius_km: " + radius_km)
    print("threshold: " + threshold)


    ;plot
    n_res = 1
    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    ;system("mkdir -p " + "../outputs/figs/soundings/z_700-300hPa/")
    wks_name = "../outputs/figs/xy_fss-standard-vs-radius_pr_northChina_3day-acc_vs_CLDAS"
    wks = gsn_open_wks(wks_type, wks_name)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False

    ;viewport
    res@vpWidthF  = 0.42
    res@vpHeightF = 0.2
    res@vpXF       = 0.1
    res@vpYF       = 0.9

    res@gsnStringFont = 21
    res@gsnLeftString   = ""
    res@gsnRightString  = ""
    res@gsnCenterString = ""
    res@gsnLeftStringFontHeightF    = 0.018
    res@gsnCenterStringFontHeightF  = 0.017
    res@gsnRightStringFontHeightF   = 0.018
    res@gsnLeftStringOrthogonalPosF   = 0.01
    res@gsnCenterStringOrthogonalPosF = 0.01
    res@gsnRightStringOrthogonalPosF  = 0.02

    res@tiMainString = ""
    res@tiMainFontHeightF = 0.018

    ;tickmark
    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF  = 2.5*n_res
    res@tmYLMajorThicknessF = 2.5*n_res
    res@tmYLMinorThicknessF = 2.5*n_res
    res@tmYLMajorLengthF    = 0.008
    res@tmYLMajorOutwardLengthF = 0.008
    res@tmYLMinorLengthF    = 0.006
    res@tmYLMinorOutwardLengthF = 0.006
    res@tmXBMajorThicknessF = 2.5*n_res
    res@tmXBMinorThicknessF = 2.5*n_res
    res@tmXBMajorLengthF    = 0.008
    res@tmXBMajorOutwardLengthF = 0.008
    res@tmXBMinorLengthF    = 0.006
    res@tmXBMinorOutwardLengthF = 0.006

    res@tmXBLabelFont = 21
    res@tmYLLabelFont = 21
    res@tmXBLabelFontHeightF = 0.011
    res@tmYLLabelFontHeightF = 0.011
    res@tmXBLabelFontAspectF = 1.2
    res@tmYLLabelFontAspectF = 1.2

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(10,100,10)
    res@tmXBLabels = sprinti("%02i", res@tmXBValues)
    res@tmXBMinorValues = ispan(10,100,10)

    res@tmYLMode = "Explicit"
    res@tmYLValues = fspan(0,1,11)
    res@tmYLLabels = sprintf("%3.1f", res@tmYLValues)
    res@tmYLMinorValues = fspan(0,1,21)
    res@trYMinF = 0
    res@trYMaxF = 1
    res@trXMinF = 9
    res@trXMaxF = 101

    ;bres = res
    ;bres@gsnLeftString = ""
    ;bres@gsnYRefLine  = 0.0 ;very important for xyline colors
    ;bres@xyLineColor = "transparent" ;
    ;bres@xyLineThicknesses = 2.0
    ;bres@gsnXYBarChart     = True
    ;bres@gsnXYBarChartBarWidth = 0.4
    ;bres@gsnXYBarChartColors = "Black"
    ;bres@gsnXYBarChartPatterns = 0
    ;;bres@gsnXYBarChartFillLineThicknessF = 1
    ;bres@gsnXYBarChartFillOpacityF = 0.8
    ;;bres@gsnXYBarChartOutlineOnly = True
    ;;bres@gsnXYBarChartOutlineThicknessF = 0


    xyres = res
    xyres@tiYAxisString = "~F21~FSS"
    xyres@tiYAxisSide ="Left"
    xyres@tiYAxisFontHeightF = 0.015

    xyres@tiXAxisString = "~F21~Horizontal scale (length of radius) (km)"
    xyres@tiXAxisFontAspectF = 1.2 ;render the font in proper aspect ratio
    xyres@tiXAxisSide ="Bottom"
    xyres@tiXAxisFontHeightF = 0.013

    first_window_pattern = 5
    second_window_pattern = 0
    third_window_pattern = 5

    first_window_color = "grey"
    second_window_color = "black"
    third_window_color = "darkviolet"

    first_window_thickness = 2
    second_window_thickness = 3
    third_window_thickness = 3

    dash_patterns = new(24, integer)
    dash_patterns(0:9) = first_window_pattern
    dash_patterns(10:21) = second_window_pattern
    dash_patterns(22:23) = third_window_pattern

    line_colors = new(24, string)
    line_colors(0:9)   = first_window_color
    line_colors(10:21) = second_window_color
    line_colors(22:23) = third_window_color

    line_thickness = new(24, integer)
    line_thickness(0:9) = first_window_thickness
    line_thickness(10:21) = second_window_thickness
    line_thickness(22:23) = third_window_thickness

    xyres@xyDashPatterns = dash_patterns
    xyres@xyMarkLineMode = "Lines"
    xyres@xyLineColors = line_colors
    xyres@xyLineThicknesses = line_thickness

    plot_xy = gsn_csm_xy(wks, radius_km, fss_all(1,:,:), xyres)

    ;lnres = True
    ;lnres@gsLineDashPattern = 11
    ;lnres@gsLineThicknessF = 2*n_res
    ;lnres@tfPolyDrawOrder = "PostDraw"
    ;lnres@gsLineColor = "black"
    ;anno_11 = gsn_add_polyline(wks, plot_xy, (/9.5,9.5/), (/0,1/), lnres)
    ;anno_21 = gsn_add_polyline(wks, plot_xy, (/21.5,21.5/), (/0,1/), lnres)

    draw(plot_xy)

    lgLabels = "~F21~" + (/"   00-09H UTC ","   10-21H UTC ", "   22-23H UTC "/)
    lgres = True
    lgres@tfPolyDrawOrder = "PostDraw"

    lgres@vpWidthF = 0.12
    lgres@vpHeightF = 0.05
    lgres@lgAutoManage = False

    lgres@lgMonoDashIndex = False
    lgres@lgDashIndexes = (/first_window_pattern,second_window_pattern, third_window_pattern/)

    lgres@lgMonoItemType = False
    lgres@lgItemTypes = (/"Lines", "Lines", "Lines"/)

    ;lgres@lgMonoMarkerIndex = False
    ;lgres@lgMarkerIndexes   = (/6,6,6/)
    ;lgres@lgMonoMarkerThickness = True
    ;lgres@lgMarkerThicknessF = 2*n_res
    ;lgres@lgMarkerSizeF = 0.0
    ;lgres@lgMarkerColors  = (/"Black","royalblue", "salmon"/)

    ;create individual marker for legend
    ;pgres = True
    ;pgx = (/0.67,0.69,0.69,0.67,0.67/)
    ;pgy = (/0.45,0.45,0.46,0.48,0.45/)
    ;pgres@gsFillOpacityF = 0.2
    ;pgres@gsFillColor    = "Black"
    ;gsn_polygon_ndc(wks, pgx, pgy, pgres)

    lgres@lgMonoLineColor = False
    ;lgres@lgLineColors    = (/"Black","dodgerblue","firebrick3"/)
    lgres@lgLineColors    = (/first_window_color, second_window_color, third_window_color/)

    lgres@lgBoxBackground = "White"
    lgres@lgMonoLineThickness = True
    lgres@lgLineThicknessF = 2*n_res

    ;lgres@lgLabelStrings = lgLabels
    lgres@lgPerimOn     = False
    lgres@lgPerimFill   = "SolidFill"
    lgres@lgPerimColor  = "Black"
    lgres@lgPerimThicknessF = 2*n_res

    lgres@lgLabelFontHeightF = 0.05
    lgres@lgLabelFontAspectF = 1.2
    lgres@lgItemCount = 3
    lgres@lgItemOrder = (/2,1,0/)
    lgres@lgBoxMinorExtentF = 0.3
    gsn_legend_ndc(wks,3,lgLabels,0.11,0.9,lgres)
    ;drawNDCGrid(wks)
    frame(wks)

end
