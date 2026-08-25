load "/home/export/online1/mdt00/shisuan/swustc/jungu/.config/ncl/nclscripts/plot.ncl"
begin
    print_clock("start")
    ;read csv from calculated MSE dt at a certain pressure level
    MSE_dt_csv = asciiread("../outputs/data/dt_MSE/2023-07_global_MAE_dt-MSE_500hPa.csv", -1, "string")
    delim = ","
    date_str = str_get_field(MSE_dt_csv, 1, delim)
    nlines = dimsizes(date_str)
    date_str:= date_str(1:nlines-1)
    date_series = rm_single_dims(str_split_csv(date_str, delim, 0))
    date_series_split = str_split_by_length(date_series, 2)

    MSE_str = str_get_field(MSE_dt_csv, 2, delim)
    MSE_str:= MSE_str(1:nlines-1)
    MSE_series = todouble(rm_single_dims(str_split_csv(MSE_str, delim, 0)))
    printMinMax(MSE_series,1)
    num_mse = num(.not.ismissing(MSE_series))
    print("num_mse: " + num_mse)

    ;perform wavelet transform
    mother = 0 ;Morlet
    dt     = 1
    param  = 6.0
    s0     = 2*dt
    dj     = 0.25
    jstot  = 1 + toint(((log10(num_mse*dt/s0))/dj)/log10(2))
    ;npad   = 1024 ; power of 2
    npad   = num_mse
    noise  = 1 ;red noise
    isigtest = 0
    siglvl = 0.05


    w = wavelet(MSE_series, mother, dt, param, s0, dj, jstot, npad, noise, isigtest, siglvl, 0)
    jtot = w@period
    ;print("jtot: " + jtot)
    power = onedtond(w@power, (/dimsizes(jtot), num_mse/))
    power!0 = "period"
    power&period = w@period
    power!1 = "time"
    power&time = ispan(0, num_mse-1, 1)
    SIG = power
    SIG = power/conform(power, w@signif, 0)
    print(w@period)
    ;print(jtot)
    printVarSummary(power)
    printMinMax(SIG({0:32}, :),1)

    power_avg_time = dim_avg_n_Wrap(power({3:32}, :), 1)

    output_path = "../outputs/figs/wavelet_dt-MSE/"
    system("mkdir -p " + output_path)
    ;plot 
    n_res = 1
    wks_type = "pdf"
    wks_type@wkPaperSize  = "A4"; 8.3 x 11.7 inches
    wks_type@wkOrientation = "Portrait"
    wks_type@wkDeviceLowerX = 36; points
    wks_type@wkDeviceLowerY = 126; points
    ;wks_type@wkWidth  = 1024*n_res;
    ;wks_type@wkHeight = 1024*n_res
    wks_name = output_path + "wavelet_dt-MSE_500hPa_global_hourly_single-level"
    wks = gsn_open_wks(wks_type, wks_name)

    power_cnlevels = fspan(0.02, 0.16, 8); 9 colors
    power_cmap = read_colormap_file("MPL_rainbow")
    power_colors = new((/9,4/),float)
    power_colors  = power_cmap(6:126:15,:)
    ;power_colors(0,3) = 0 ;set alpha

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnAddCyclic = False
    res@vpHeightF = 0.25
    res@vpWidthF  = 0.7
    res@vpXF = 0.08
    res@vpYF = 0.95

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
    res@tmXBValues = ispan(0, 720, 120)
    res@tmXBLabels = date_series_split(::120,3)
    ;res@tmXBLabels = res@tmXBValues
    res@tmXBMinorValues = ispan(0,720,24)

    res@tmYLMode = "Explicit"
    ;res@trYAxisType = "LinearAxis"
    res@tmYLValues = (/4, 8, 12, 16, 20, 24, 28, 32/)
    res@tmYLLabels = res@tmYLValues
    res@trYReverse = True
    ;cnres@tmYLMinorValues = ispan(26,45,1)
    res@tiYAxisFont = 21
    res@tiYAxisFontHeightF = 0.017
    res@tiYAxisFontAspectF = 1.3125
    res@tiYAxisString = "Period (hours)"

    ;res@tiXAxisFont = 25
    ;res@tiXAxisFontHeightF = 0.017
    ;res@tiXAxisString = "Date"

    cnres = res
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    cnres@cnFillMode = "AreaFill"
    cnres@cnRasterSmoothingOn = True
    cnres@cnSmoothingDistanceF = 1e-4
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = power_cnlevels
    cnres@cnFillColors    = power_colors
    cnres@lbLabelBarOn    = False

    cnres@gsnLeftString = ""
    cnres@gsnCenterString = ""
    plot = gsn_csm_contour(wks,power({3:32},:),cnres)

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
    shres@cnLineLabelFont = 21
    shade = gsn_csm_contour(wks,SIG({3:32},:),shres)
    ;sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
    ;shres@cnLineThicknessF = 5*n_res
    ;shres@cnLineDashPattern = 0

    overlay(plot, shade)

    ;Create common label
    lbres = True
    lbres@vpXF = 0.1
    lbres@vpYF = 0.65
    lbres@vpWidthF = 0.6
    lbres@vpHeightF= 0.06

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 2.0*n_res
    lbres@lbFillColors  = power_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.012
    lbres@lbLabelFontAspectF = 1.2
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation      = "Horizontal"
    lbres@lbTitlePosition    = "Bottom"
    ;lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.017
    lbres@lbTitleFontAspectF = 1.3125
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    ;lbres@lbTitleString = "~F25~Wavelet spectrum for 500-hPa MSE difference series";optional
    lbres@lbTitleString = "~F21~Wavelet spectral power";optional
    lbres@lbLabelStride = 1
    nboxes := dimsizes(power_colors)
    labels := "~F21~"+power_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)

    ;attach xy plot for average over time
    xyres = True
    xyres@gsnDraw = False
    xyres@gsnFrame= False
    xyres@gsnMaximize  = False

    xyres@vpWidthF    = 0.18
    xyres@vpHeightF   = 0.25
    xyres@vpXF        = 0.81
    xyres@vpYF        = 0.95

    xyres@gsnStringFont = 21
    xyres@gsnLeftString   = ""
    xyres@gsnRightString  = ""
    xyres@gsnLeftStringFontHeightF    = 0.018
    xyres@gsnCenterStringFontHeightF  = 0.018
    xyres@gsnRightStringFontHeightF   = 0.018
    xyres@gsnLeftStringOrthogonalPosF   = 0.01
    xyres@gsnCenterStringOrthogonalPosF = 0.01
    xyres@gsnRightStringOrthogonalPosF  = 0.02

    xyres@tiMainFontHeightF = 0.018
    xyres@tiMainString = ""
    xyres@gsnLeftString = ""
    xyres@gsnRightString = ""

    ;tickmark
    xyres@tmXTOn = False
    xyres@tmYROn = False
    xyres@tmBorderThicknessF  = 4.5*n_res
    xyres@tmYLMajorThicknessF = 3.5*n_res
    xyres@tmYLMinorThicknessF = 3.5*n_res
    xyres@tmYLMajorLengthF    = 0.005
    xyres@tmYLMajorOutwardLengthF = 0
    xyres@tmYLMinorLengthF    = 0.006
    xyres@tmYLMinorOutwardLengthF = 0
    xyres@tmXBMajorThicknessF = 3.5*n_res
    xyres@tmXBMinorThicknessF = 3.5*n_res
    xyres@tmXBMajorLengthF    = 0.01
    xyres@tmXBMajorOutwardLengthF = 0.01
    xyres@tmXBMinorLengthF    = 0.006
    xyres@tmXBMinorOutwardLengthF = 0.006
    xyres@tmXBLabelFont = 21
    xyres@tmYLLabelFont = 21
    xyres@tmXBLabelFontHeightF = 0.015
    xyres@tmXBLabelFontAspectF = 1.2
    xyres@tmYLLabelFontHeightF = 0.015
    xyres@tmYLLabelFontAspectF = 1.2

    xyres@tmXBMinorOn = False
    xyres@tmYLMinorOn = False
    xyres@tmXBLabelDeltaF = -0.5
    xyres@tmYLLabelDeltaF = -0.5

    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = fspan(0,0.15,4)
    xyres@tmXBLabels = xyres@tmXBValues
    ;xyres@tmXBMinorValues = ispan(0,23,1)

    xyres@tmYLMode = "Explicit"
    xyres@tmYLValues = res@tmYLValues
    xyres@xyYStyle  = "Irregular"
    xyres@xyYIrregularPoints =  power_avg_time&period
    xyres@trYReverse = True

    xyres@trYMinF = 3
    xyres@trYMaxF = 32
    xyres@trXMinF = 0
    xyres@trXMaxF = 0.16

    ;xyres@tiXAxisString = "~F25~Average power"
    ;xyres@tiXAxisSide ="Bottom"
    ;xyres@tiXAxisFontHeightF = 0.016

    xyres@xyDashPatterns = (/0,0,1,1/)
    xyres@xyMarkLineMode = "Lines"
    ;xyres@xyMarkers = (/1,1,1,1/)
    ;xyres@xyMarkerColors = (/"blue","red","blue","red"/)
    xyres@xyLineColor = power_colors(8,:)
    xyres@xyLineThicknesses = (/4,3,3,3/)*n_res

    plot_xy = gsn_csm_xy(wks, power_avg_time, power_avg_time&period, xyres)
    draw(plot_xy)

    draw(plot)
    draw(lbid_rain)
    ;drawNDCGrid(wks)
    frame(wks)
    print_clock("end")
end
