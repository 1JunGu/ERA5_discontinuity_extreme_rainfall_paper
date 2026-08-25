;**********************************************************************
; This function attaches a single vertical Y axis in the
; center of the given plot.
;**********************************************************************
function attach_vert_axis(wks,plot)
local vres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin
;---Retrieve information from original plot
    getvalues plot
        "vpXF"     : vpx
        "vpYF"     : vpy
        "vpWidthF" : vpw
        "vpHeightF": vph

        "trXMinF"  : xmin
        "trXMaxF"  : xmax
        "trYMinF"  : ymin
        "trYMaxF"  : ymax

        "tmYLLabels" : labels
        "tmYLValues" : values
        "tmYLLabelFont" : labelfont

        "tmYLMinorValues" : mvalues

        "tmYLLabelFontHeightF"    : font_height
        "tmYLMajorLengthF"        : mj_length
        "tmYLMinorLengthF"        : mn_length
        "tmYLMajorOutwardLengthF" : mjo_length
        "tmYLMinorOutwardLengthF" : mno_length
    end getvalues

;---Turn off the dead center tickmark label
    nlabels = dimsizes(labels)
    if((nlabels % 2).eq.1) then
        labels((nlabels-1)/2) = ""
    end if

    vres              = True

;---Don't draw or advance frame
    vres@gsnDraw      = False
    vres@gsnFrame     = False

;---Make sure blank plot has same axis limits as original plot
    vres@trXMinF      = xmin 
    vres@trXMaxF      = xmax
    vres@trYMinF      = ymin
    vres@trYMaxF      = ymax

;---Make sure blank plot has same size as original plot
    vres@vpXF         = vpx
    vres@vpYF         = vpy
    vres@vpWidthF     = vpw
    vres@vpHeightF    = vph

;---Turn off top, bottom, and right axis.
    vres@tmYROn       = False
    vres@tmXTOn       = False
    vres@tmXBOn       = False
    vres@tmYRBorderOn = False
    vres@tmXTBorderOn = False
    vres@tmXBBorderOn = False

;---Make tickmarks cross the axis.
    vres@tmYLMajorLengthF        = mj_length
    vres@tmYLMinorLengthF        = mn_length
    vres@tmYLMajorOutwardLengthF = mjo_length/2.
    vres@tmYLMinorOutwardLengthF = mno_length/2.

    vres@tmBorderLineColor       = "Gray40"
    vres@tmYLMajorLineColor      = "Gray40"
    vres@tmYLMinorLineColor      = "Gray40"

;---Make axis label font smaller
    vres@tmYLLabelFontHeightF    = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
    vres@tmYLMode                = "Explicit"
    vres@tmYLLabels              = labels
    vres@tmYLValues              = values
    vres@tmYLMinorValues         = mvalues
    vres@tmYLLabelFont           = labelfont

;---Create the blank plot with just a single vertical axis.
    vaxis = gsn_blank_plot(wks,vres)

;---Attach this axis to the original plot.
    amres                = True
    amres@amParallelPosF =  0.5     ; Shift right to center of plot
    vamid = gsn_add_annotation(plot,vaxis,amres)
    return(vamid)
end

;**********************************************************************
; This function attaches a single horizontal X axis in the
; center of the given plot.
;**********************************************************************
function attach_horiz_axis(wks,plot)
local hres, amres, xmin, xmax, ymin, ymax, vpx, vpy, vpw, vph, \
mj_length, mjo_length, mn_length, mno_length, font_height
begin

;---Retrieve information from original plot
    getvalues plot
        "vpXF"     : vpx
        "vpYF"     : vpy
        "vpWidthF" : vpw
        "vpHeightF": vph

        "trYMinF"  : ymin
        "trYMaxF"  : ymax
        "trXMinF"  : xmin
        "trXMaxF"  : xmax

        "tmXBLabelFontHeightF"    : font_height

        "tmXBLabels" : labels
        "tmXBValues" : values
        "tmXBMinorValues" : mvalues
        "tmXBLabelFont" : labelfont

        "tmXBMajorLengthF"        : mj_length
        "tmXBMinorLengthF"        : mn_length
        "tmXBMajorOutwardLengthF" : mjo_length
        "tmXBMinorOutwardLengthF" : mno_length
    end getvalues

;---Turn off the dead center tickmark label
    nlabels = dimsizes(labels)
    if((nlabels % 2) .eq. 1) then
        labels((nlabels-1)/2) = ""
    end if

    hres           = True

;---Don't draw or advance frame
    hres@gsnDraw      = False
    hres@gsnFrame     = False

;---Make sure blank plot has same size as original plot
    hres@vpXF         = vpx
    hres@vpYF         = vpy
    hres@vpWidthF     = vpw
    hres@vpHeightF    = vph

;---Make sure blank plot has same axis limits as original plot
    hres@trXMinF      = xmin 
    hres@trXMaxF      = xmax
    hres@trYMinF      = ymin
    hres@trYMaxF      = ymax


;---Turn off left, right, and top axis.
    hres@tmYLOn       = False
    hres@tmYROn       = False
    hres@tmXTOn       = False
    hres@tmYLBorderOn = False
    hres@tmYRBorderOn = False
    hres@tmXTBorderOn = False

;---Make tickmarks cross the axis.
    hres@tmXBMajorLengthF       = mj_length
    hres@tmXBMinorLengthF       = mn_length
    hres@tmXBMajorOutwardLengthF= mjo_length/2.
    hres@tmXBMinorOutwardLengthF= mno_length/2.

    hres@tmBorderLineColor       = "Gray40"
    hres@tmXBMajorLineColor      = "Gray40"
    hres@tmXBMinorLineColor      = "Gray40"

;---Make axis label font smaller
    hres@tmXBLabelFontHeightF   = 0.60 * font_height

;---Reset the labels w/o the "0" value labeled
    hres@tmXBMode                = "Explicit"
    hres@tmXBLabels              = labels
    hres@tmXBValues              = values
    hres@tmXBMinorValues         = mvalues
    hres@tmXBLabelFont           = labelfont

;---Create the blank plot with just a single horizontal axis.
    haxis = gsn_blank_plot(wks,hres)

;---Attach this axis to the original plot.
    amres                  = True
    amres@amOrthogonalPosF = -0.5     ; Shift up to center of plot
    hamid = gsn_add_annotation(plot,haxis,amres)

    return(hamid)
end

;**********************************************************************
; This function removes the existing axes from an NCL plot and
; reattaches a cartesian-style axis.
;**********************************************************************
function cartesian_axis(wks,plot)
begin
    setvalues plot
        "tiMainString"      : ""

;---Turn off all default axes.
        "tmXBBorderOn"      : False
        "tmXTBorderOn"      : False
        "tmYLBorderOn"      : False
        "tmYRBorderOn"      : False
        "tmXBOn"            : False
        "tmXTOn"            : False
        "tmYLOn"            : False
        "tmYROn"            : False
        "tmXUseBottom"      : False
        "tmYUseLeft"        : False

;---Turn off all labels
        "tmXBLabelsOn"      : False
        "tmXTLabelsOn"      : False
        "tmYLLabelsOn"      : False
        "tmYRLabelsOn"      : False
    end setvalues

;---Attach single X and Y axis in center of plot.
    hid = attach_horiz_axis(wks,plot)
    vid = attach_vert_axis(wks,plot)

;---Be sure to return the ids of the axes we just attached.
    plot@haxis = hid
    plot@vaxis = vid
    return(plot)
end

;**********************************************************************
; Main code.
;**********************************************************************
begin

    ;read data
    csv_path = "../outputs/data/"
    csv_CLDAS_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_CLDAS.csv", -1, "string")
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

    csv_good_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_good.csv", -1, "string")
    ;centroid lat
    centroid_lat_good_str = str_get_field(csv_good_fi, 5, delim)
    centroid_lat_good_str := centroid_lat_good_str(1:nlines-1)
    centroid_lat_good_series = tofloat(rm_single_dims(str_split_csv(centroid_lat_good_str, delim, 0)))

    ;centroid lon
    centroid_lon_good_str = str_get_field(csv_good_fi, 6, delim)
    centroid_lon_good_str := centroid_lon_good_str(1:nlines-1)
    centroid_lon_good_series = tofloat(rm_single_dims(str_split_csv(centroid_lon_good_str, delim, 0)))

    csv_bad_fi = asciiread(csv_path + "MODE_pr_northChina_3day-3hour_bad.csv", -1, "string")
    ;centroid lat
    centroid_lat_bad_str = str_get_field(csv_bad_fi, 5, delim)
    centroid_lat_bad_str := centroid_lat_bad_str(1:nlines-1)
    centroid_lat_bad_series = tofloat(rm_single_dims(str_split_csv(centroid_lat_bad_str, delim, 0)))

    ;centroid lon
    centroid_lon_bad_str = str_get_field(csv_bad_fi, 6, delim)
    centroid_lon_bad_str := centroid_lon_bad_str(1:nlines-1)
    centroid_lon_bad_series = tofloat(rm_single_dims(str_split_csv(centroid_lon_bad_str, delim, 0)))

    relative_lat_good_series = centroid_lat_good_series - centroid_lat_CLDAS_series
    relative_lon_good_series = centroid_lon_good_series - centroid_lon_CLDAS_series

    relative_lat_bad_series = centroid_lat_bad_series - centroid_lat_CLDAS_series
    relative_lon_bad_series = centroid_lon_bad_series - centroid_lon_CLDAS_series

    printMinMax(relative_lat_good_series, 1)
    printMinMax(relative_lat_bad_series, 1)
    print("----")
    printMinMax(relative_lon_good_series, 1)
    printMinMax(relative_lon_bad_series, 1)

    ;plot
    n_res = 2
    wks_type = "pdf"
    wks_type@wkWidth  = 1024*n_res;
    wks_type@wkHeight = 1024*n_res

    wks = gsn_open_wks(wks_type,"../outputs/figs/scatter_MODE-centroid_northChina_3day-3hour_good-vs-bad")
    ;time_color_map = read_colormap_file("WhiteBlueGreenYellowRed")
    time_color_map = read_colormap_file("MPL_rainbow")
    time_color_levels = new((/3,4/),double)
    time_color_levels(:,:) = time_color_map(1:121:60,:)

    
    res = True
    res@gsnMaximize   = False
    res@gsnDraw       = False
    res@gsnFrame      = False

    res@vpHeightF = 0.9
    res@vpWidthF  = 0.9
    res@vpXF = 0.05
    res@vpYF = 0.95
    res@vpClipOn = False
    
    res@tiMainString       = ""
    ;res@xyMonoDashPattern  = True
    res@trXMaxF = 1.8
    res@trXMinF = -1.8
    res@trYMaxF = 1.8
    res@trYMinF = -1.8

    ;tickmark
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
    res@tmXBLabelFontHeightF = 0.04
    res@tmYLLabelFontHeightF = 0.04
    res@tmXBLabelFontAspectF = 1.2
    res@tmYLLabelFontAspectF = 1.2

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5

    res@tmXBMode = "Explicit"
    res@tmXBValues = (/-1.5,-1.,-0.5,0,0.5,1,1.5/)
    res@tmXBLabels = res@tmXBValues + "~S~o~N~"
    res@tmXBMinorValues = fspan(-1.8, 1.8, 37)

    res@tmYLMode = "Explicit"
    res@tmYLValues = res@tmXBValues
    res@tmYLLabels = res@tmYLValues + "~S~o~N~"
    res@tmYLMinorValues = fspan(-1.8, 1.8, 37)
    x_coord = fspan(-1.8, 1.8, 2)
    y_coord = x_coord * 0
    plot = gsn_csm_xy(wks,x_coord,y_coord,res)
;---Change to a cartesian axis.
    c_axis = cartesian_axis(wks,plot)

    gsres = True
    gsres@gsMarkerSizeF = 0.015
    gsres@gsMarkerThicknessF = 1
    gsres@tfPolyDrawOrder = "PostDraw"
    gsres@vpClipOn = False

    mstring = "q";filled diamond
    fontnum = 35
    xoffset = 0.0
    yoffset = 0.0
    ratio   = 0.8
    size    = 1.2
    angle   = 0.0
    marker_diamond = NhlNewMarker(wks, mstring, fontnum, xoffset, yoffset, ratio, size, angle)

    do i = 0, dimsizes(relative_lat_good_series)-1
        color_index = i/8
        gsres@gsMarkerColor = time_color_levels(color_index,:)
        gsres@gsMarkerIndex = 16
        plot@$unique_string("good")$ = gsn_add_polymarker(wks, plot, relative_lon_good_series(i), relative_lat_good_series(i), gsres)
        gsres@gsMarkerIndex = marker_diamond
        plot@$unique_string("bad")$ = gsn_add_polymarker(wks, plot, relative_lon_bad_series(i), relative_lat_bad_series(i), gsres)
    end do
    txres = True
    txres@txFontHeightF = 0.014
    txres@txFont = 26
    txres@txFontColor = "Black"
    txres@txFontThicknessF = 2.0*n_res
    txres@txAngleF = 0.0
    tx_x = 1.2
    tx_y = -0.2
    plot@tiYAxis = gsn_add_text(wks, plot, "Longitudial distance", tx_x, tx_y, txres)
    tx_x = -0.3
    tx_y = 1.2
    txres@txAngleF = 90.0
    plot@tiYAxis = gsn_add_text(wks, plot, "Latitudinal distance", tx_x, tx_y, txres)


    ;create a legend for the centroid using individual polymarkers and text labels
    lgres = True
    lgres@gsMarkerSizeF = 0.015
    lgres@gsMarkerThicknessF = 1
    lgres@gsMarkerIndex = marker_diamond
    lgres@gsMarkerColor = "Black"
    x = 0.6
    y = -1.
    plot@lgpm1 = gsn_add_polymarker(wks, plot, x, y, lgres)
    txres@txFont = 25
    txres@txAngleF = 0.0
    txres@txJust = "CenterLeft"
    x = x + 0.1
    plot@lgtx1 = gsn_add_text(wks, plot, "Early-side members", x, y, txres)

    lgres@gsMarkerIndex = 16
    x = 0.6
    y = y - 0.1
    plot@lgpm2 = gsn_add_polymarker(wks, plot, x, y, lgres)
    x = x + 0.1
    plot@lgtx2 = gsn_add_text(wks, plot, "Late-side members", x, y, txres)

;Create customized label
    lbres = True
    lbres@vpXF = 0.6
    lbres@vpYF = 0.16
    lbres@vpWidthF = 0.3
    lbres@vpHeightF= 0.08

    lbres@lbPerimOn             = False
    lbres@lbBoxLinesOn          = True
    lbres@lbBoxLineThicknessF   = 4.0
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF   = 1.2
    lbres@lbOrientation         = "Horizontal"
    lbres@lbFillColors          = time_color_levels
    lbres@lbMonoFillPattern     = True
    lbres@lbLabelFontHeightF    = 0.012
    lbres@lbLabelAlignment      = "BoxCenters";"InteriorEdges"
    lbres@lbTitleJust           = "TopCenter"
    lbres@lbTitleFontHeightF    = 0.015
    lbres@lbTitleOffsetF        = 0.2
    lbres@lbTitleExtentF        = 0.25
    lbres@lbTitleString         = "~F25~Forecast day";optional
    lbres@lbTitlePosition       = "Bottom"
    lbres@lbLabelStride         = 1
    nboxes = dimsizes(time_color_levels)
    labels = "~F25~"+(/" 29th July "," 30th July "," 31st July "/)
    lbid_mslp = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_mslp)

    draw(plot)
    ;drawNDCGrid(wks)
    frame(wks)
end
