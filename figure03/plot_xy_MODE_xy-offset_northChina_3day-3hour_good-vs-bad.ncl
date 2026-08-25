load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    ;read data
    csv_path = "../outputs/data/"
    csv_CLDAS_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_CLDAS_th-10mm.csv", -1, "string")
    delim = ","
    ;date 
    date_str    = str_get_field(csv_CLDAS_fi, 1, delim)
    nlines = dimsizes(date_str)
    date_str := date_str(1:nlines-1)
    date_series = rm_single_dims(str_split_csv(date_str, delim, 0))
    print(date_series)
    ;centroid lat
    centroid_lat_CLDAS_str = str_get_field(csv_CLDAS_fi, 5, delim)
    centroid_lat_CLDAS_str := centroid_lat_CLDAS_str(1:nlines-1)
    centroid_lat_CLDAS_series = tofloat(rm_single_dims(str_split_csv(centroid_lat_CLDAS_str, delim, 0)))

    ;centroid lon
    centroid_lon_CLDAS_str = str_get_field(csv_CLDAS_fi, 6, delim)
    centroid_lon_CLDAS_str := centroid_lon_CLDAS_str(1:nlines-1)
    centroid_lon_CLDAS_series = tofloat(rm_single_dims(str_split_csv(centroid_lon_CLDAS_str, delim, 0)))

    csv_good_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_good_th-10mm.csv", -1, "string")
    ;centroid lat
    centroid_lat_good_str = str_get_field(csv_good_fi, 5, delim)
    centroid_lat_good_str := centroid_lat_good_str(1:nlines-1)
    centroid_lat_good_series = tofloat(rm_single_dims(str_split_csv(centroid_lat_good_str, delim, 0)))

    ;centroid lon
    centroid_lon_good_str = str_get_field(csv_good_fi, 6, delim)
    centroid_lon_good_str := centroid_lon_good_str(1:nlines-1)
    centroid_lon_good_series = tofloat(rm_single_dims(str_split_csv(centroid_lon_good_str, delim, 0)))

    csv_bad_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_bad_th-10mm.csv", -1, "string")
    ;centroid lat
    centroid_lat_bad_str = str_get_field(csv_bad_fi, 5, delim)
    centroid_lat_bad_str := centroid_lat_bad_str(1:nlines-1)
    centroid_lat_bad_series = tofloat(rm_single_dims(str_split_csv(centroid_lat_bad_str, delim, 0)))

    ;centroid lon
    centroid_lon_bad_str = str_get_field(csv_bad_fi, 6, delim)
    centroid_lon_bad_str := centroid_lon_bad_str(1:nlines-1)
    centroid_lon_bad_series = tofloat(rm_single_dims(str_split_csv(centroid_lon_bad_str, delim, 0)))

    ;calculate x_offset distance (km)
    relative_x_offset_good_series = gc_latlon(centroid_lat_CLDAS_series, centroid_lon_CLDAS_series, centroid_lat_CLDAS_series, centroid_lon_good_series, 2, 4)
    ;assign sign
    relative_x_offset_good_series = relative_x_offset_good_series * sign_matlab(centroid_lon_good_series - centroid_lon_CLDAS_series)
    ;print("relative_x_offset_good_series: " + relative_x_offset_good_series)
    ;calculate y_offset distance (km)
    relative_y_offset_good_series = gc_latlon(centroid_lat_CLDAS_series, centroid_lon_CLDAS_series, centroid_lat_good_series, centroid_lon_CLDAS_series, 2, 4)
    ;assign sign
    relative_y_offset_good_series = relative_y_offset_good_series * sign_matlab(centroid_lat_good_series - centroid_lat_CLDAS_series)

    ;for bad
    relative_x_offset_bad_series = gc_latlon(centroid_lat_CLDAS_series, centroid_lon_CLDAS_series, centroid_lat_CLDAS_series, centroid_lon_bad_series, 2, 4)
    ;assign sign
    relative_x_offset_bad_series = relative_x_offset_bad_series * sign_matlab(centroid_lon_bad_series - centroid_lon_CLDAS_series)
    ;print("relative_x_offset_bad_series: " + relative_x_offset_bad_series)
    ;calculate y_offset distance (km)
    relative_y_offset_bad_series = gc_latlon(centroid_lat_CLDAS_series, centroid_lon_CLDAS_series, centroid_lat_bad_series, centroid_lon_CLDAS_series, 2, 4)
    ;assign sign
    relative_y_offset_bad_series = relative_y_offset_bad_series * sign_matlab(centroid_lat_bad_series - centroid_lat_CLDAS_series)

    printMinMax(relative_x_offset_good_series, 1)
    printMinMax(relative_y_offset_good_series, 1)
    printMinMax(relative_x_offset_bad_series, 1)
    printMinMax(relative_y_offset_bad_series, 1)


    ;plot
    n_res = 0.4
    wks_type = "pdf"
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;system("mkdir -p " + "../outputs/figs/soundings/z_700-300hPa/")
    wks_name = "../outputs/figs/MODE_xy-offset_northChina_3day-3hour_good-vs-bad"
    wks = gsn_open_wks(wks_type, wks_name)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    ;res@gsnAddCyclic = False

    ;viewport
    res@vpWidthF  = 0.42
    res@vpHeightF = 0.2
    res@vpXF       = 0.1
    res@vpYF       = 0.5

    res@gsnStringFont = 21
    res@gsnLeftString   = ""
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF    = 0.018
    res@gsnCenterStringFontHeightF  = 0.018
    res@gsnRightStringFontHeightF   = 0.018
    res@gsnLeftStringOrthogonalPosF   = 0.01
    res@gsnCenterStringOrthogonalPosF = 0.01
    res@gsnRightStringOrthogonalPosF  = 0.02

    res@tiMainFontHeightF = 0.018
    res@tiMainString = ""
    res@gsnLeftString = ""
    res@gsnRightString = ""

    ;tickmark
    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF  = 4.5*n_res
    res@tmYLMajorThicknessF = 3.5*n_res
    res@tmYLMinorThicknessF = 3.5*n_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMajorOutwardLengthF = 0.01
    res@tmYLMinorLengthF    = 0.006
    res@tmYLMinorOutwardLengthF = 0.006
    res@tmXBMajorThicknessF = 4.5*n_res
    res@tmXBMinorThicknessF = 3.5*n_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMinorLengthF    = 0.006
    res@tmXBMinorOutwardLengthF = 0.006
    res@tmXBLabelFont = 21
    res@tmYLLabelFont = 21
    res@tmXBLabelFontHeightF = 0.012
    res@tmYLLabelFontHeightF = 0.012
    res@tmXBLabelFontAspectF = 1.2
    res@tmYLLabelFontAspectF = 1.2

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(0,23,4)
    res@tmXBLabels = (/"00", "12", "00", "12",  "00", "12"/)
    res@tmXBMinorValues = ispan(0,23,1)

    res@tmYLMode = "Explicit"
    res@tmYLValues = ispan(-200,100,50)
    res@tmYLLabels = res@tmYLValues
    res@tmYLMinorValues = fspan(-210,110,33)
    res@trYMinF = -210
    res@trYMaxF = 110
    res@trXMinF = -1
    res@trXMaxF = 24


    xyres = res
    xyres@tiYAxisString = "~F21~Centroid distance offset (km)"
    xyres@tiYAxisSide ="Left"
    xyres@tiYAxisFontHeightF = 0.016

    xyres@tiXAxisString = "~F21~Forecast date"
    xyres@tiXAxisSide ="Bottom"
    xyres@tiXAxisFontHeightF = 0.016

    xyres@xyDashPatterns = (/0,0,1,1/)
    xyres@xyMarkLineMode = "Lines"
    ;xyres@xyMarkers = (/1,1,1,1/)
    ;xyres@xyMarkerColors = (/"blue","red","blue","red"/)
    xyres@xyLineColors = (/"royalblue","salmon", "royalblue", "salmon"/)
    xyres@xyLineThicknesses = (/6,6,6,6/)*n_res

    plot_xy = gsn_csm_xy(wks, ispan(0,23,1), (/relative_x_offset_bad_series, relative_x_offset_good_series, relative_y_offset_bad_series, relative_y_offset_good_series/), xyres)

    lnres = True
    lnres@gsLineDashPattern = 15
    lnres@gsLineThicknessF = 3*n_res
    lnres@tfPolyDrawOrder = "PostDraw"
    lnres@gsLineColor = "black"
    anno_11 = gsn_add_polyline(wks, plot_xy, (/-2,25/), (/0,0/), lnres)

    txres = True
    txres@txFontHeightF = 0.014
    txres@txFontThicknessF = 2.0*n_res
    txres@txFont = 21
    txres@txFontColor = "Black"
    txres@txAngleF = 0.0
    txres@txJust = "CenterCenter"
    plot_xy@tmXBlabel1 = gsn_add_text(wks, plot_xy, "29th July", 4, -200, txres)
    plot_xy@tmXBlabel2 = gsn_add_text(wks, plot_xy, "30th July", 12, -200, txres)
    plot_xy@tmXBlabel3 = gsn_add_text(wks, plot_xy, "31st July", 20, -200, txres)
    draw(plot_xy)

    lgLabels = "~F25~" + (/"Early-side east-west","Late-side east-west", "Early-side north-south", "Late-side north-south"/)
    lgres = True
    lgres@tfPolyDrawOrder = "PostDraw"

    lgres@vpWidthF = 0.2
    lgres@vpHeightF = 0.1
    lgres@lgAutoManage = False

    lgres@lgMonoDashIndex = False
    lgres@lgDashIndexes = (/0,0,1,1/)

    lgres@lgMonoItemType = False
    lgres@lgItemTypes = (/"Lines", "Lines", "Lines", "Lines"/)

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
    lgres@lgLineColors = (/"royalblue","salmon", "royalblue", "salmon"/)

    lgres@lgBoxBackground = "White"
    lgres@lgBoxMajorExtentF = 0.25
    lgres@lgBoxMinorExtentF = 0.4
    lgres@lgMonoLineThickness = True
    lgres@lgLineThicknessF = 4.5*n_res

    ;lgres@lgLabelStrings = lgLabels
    lgres@lgPerimOn     = False
    lgres@lgPerimFill   = "SolidFill"
    lgres@lgPerimColor  = "Black"
    lgres@lgPerimThicknessF = 4*n_res

    lgres@lgLabelFontHeightF = 0.07
    lgres@lgItemCount = 4
    lgres@lgItemOrder = (/3,2,1,0/)
    gsn_legend_ndc(wks,4,lgLabels,0.16,0.7,lgres)
    ;drawNDCGrid(wks)
    frame(wks)

end
