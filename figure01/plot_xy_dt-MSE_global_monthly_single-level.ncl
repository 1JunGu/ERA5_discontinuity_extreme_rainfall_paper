load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    ;read data
    csv_path = "../outputs/data/dt_MSE/"
    csv_fi = asciiread(csv_path + "2023-07-monthly_global_MAE_dt-MSE_500hPa.csv", -1, "string")
    delim = ","
    ;date 
    date_str = str_get_field(csv_fi, 1, delim)
    nlines = dimsizes(date_str)
    date_str := date_str(1:nlines-1)
    date_series = rm_single_dims(str_split_csv(date_str, delim, 0))
    print(date_series)

    ;area
    dt_MSE_str = str_get_field(csv_fi, 2, delim)
    dt_MSE_str := dt_MSE_str(1:nlines-1)
    dt_MSE_series = tofloat(rm_single_dims(str_split_csv(dt_MSE_str, delim, 0)))

    ;plot
    n_res = 1
    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    wks_name = "../outputs/figs/dt_MSE/xy_dt-MSE_global_monthly_500"
    wks = gsn_open_wks(wks_type, wks_name)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    ;res@gsnAddCyclic = False

    ;viewport
    res@vpWidthF  = 0.43
    res@vpHeightF = 0.3
    res@vpXF       = 0.07
    res@vpYF       = 0.6

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
    res@tmXBMajorThicknessF = 3.5*n_res
    res@tmXBMinorThicknessF = 3.5*n_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMinorLengthF    = 0.006
    res@tmXBMinorOutwardLengthF = 0.006
    res@tmXBLabelFont = 21
    res@tmYLLabelFont = 21
    res@tmXBLabelFontHeightF = 0.015
    res@tmYLLabelFontHeightF = 0.015
    res@tmXBLabelFontAspectF = 1.2
    res@tmYLLabelFontAspectF = 1.2

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5

    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(0,22,6)
    res@tmXBLabels = (/"00", "06", "12", "18"/)
    res@tmXBMinorValues = ispan(0,22,1)

    res@tmYLMode = "Explicit"
    res@tmYLValues = fspan(0.2,0.6,5)
    res@tmYLLabels = sprintf("%2.1f",res@tmYLValues)
    ;res@tmYLMinorValues = fspan(0.8,0.8,33)
    res@trYMinF = 0.2
    res@trYMaxF = 0.65
    res@trXMinF = -1
    res@trXMaxF = 23




    xyres = res
    xyres@tiYAxisString = ""
    xyres@tiYAxisSide ="Left"
    xyres@tiYAxisFontHeightF = 0.016

    xyres@tiXAxisString = ""
    xyres@tiXAxisSide ="Bottom"
    xyres@tiXAxisFontHeightF = 0.016

    mstring = "y";filled square marker
    fontnum = 35
    xoffset = 0.0
    yoffset = 0.0
    ratio   = 1
    size    = 1.2
    angle   = 0.0
    marker_square = NhlNewMarker(wks, mstring, fontnum, xoffset, yoffset, ratio, size, angle)

    xyres@xyDashPatterns = (/0,0,1,1/)
    xyres@xyMarkLineMode = "MarkLines"
    xyres@xyMarkers = (/marker_square,1,1,1/)
    xyres@xyMarkerColors = (/"Royalblue","red","blue","red"/)
    xyres@xyLineColors = (/"Royalblue","salmon","royalblue","salmon"/)
    xyres@xyLineThicknesses = (/3,6,6,6/)*n_res

    plot_xy = gsn_csm_xy(wks, ispan(0,22,1), dt_MSE_series, xyres)

    ;calculate Interquartile Range (IQR)
    sorted_dt_MSE = dt_MSE_series
    qsort(sorted_dt_MSE)
    x25 = round(0.25 * 23, 3) - 1
    x75 = round(0.75 * 23, 3) - 1
    IQR_dt_MSE = sorted_dt_MSE(x75) - sorted_dt_MSE(x25)
    IQR_dt_MSE_lower = sorted_dt_MSE(x25) - 3 * IQR_dt_MSE
    IQR_dt_MSE_upper = sorted_dt_MSE(x75) + 3 * IQR_dt_MSE
    print("IQR of dt_MSE: " + IQR_dt_MSE)
    print("Lower bound of dt_MSE: " + IQR_dt_MSE_lower)
    print("Upper bound of dt_MSE: " + IQR_dt_MSE_upper)


    lnres = True
    lnres@gsLineDashPattern = 2
    lnres@gsLineThicknessF = 3*n_res
    lnres@tfPolyDrawOrder = "PostDraw"
    lnres@gsLineColor = "Royalblue"
    anno_11 = gsn_add_polyline(wks, plot_xy, (/-2,25/), (/IQR_dt_MSE_lower,IQR_dt_MSE_lower/), lnres)
    anno_12 = gsn_add_polyline(wks, plot_xy, (/-2,25/), (/IQR_dt_MSE_upper,IQR_dt_MSE_upper/), lnres)

    draw(plot_xy)
    ;drawNDCGrid(wks)
    frame(wks)

end
