function handles = disable_all_items(handles)

set(handles.dateNow,'Enable','off');
set(handles.timeNow,'Enable','off');
set(handles.downCount,'Enable','off');
set(handles.edit_armTime,'Enable','off');

set(handles.pushbutton_loadConfig,'Enable','off');
set(handles.pushbutton_autoArm,'Enable','off');
set(handles.pushbutton_syncRTC,'Enable','off');
set(handles.pushbutton_logData,'Enable','off');

set(handles.edit_phase_offset,'Enable','off');
set(handles.edit_drift_comp,'Enable','off');
set(handles.edit_mean_samples,'Enable','off');

set(handles.checkbox_stdby_mode,'Enable','off');

set(handles.checkbox_ref_sel,'Enable','off');
set(handles.checkbox_rtc_alarm_set,'Enable','off');
set(handles.checkbox_en_gps_update,'Enable','off');
set(handles.checkbox_pps,'Enable','off');
set(handles.checkbox_tic_timeout,'Enable','off');

set(handles.checkbox_open_loop,'Enable','off');
set(handles.checkbox_sawtooth_en,'Enable','off');
set(handles.checkbox_outlier_en,'Enable','off');
set(handles.checkbox_mean_mode,'Enable','off');
set(handles.checkbox_mean_en,'Enable','off');
set(handles.checkbox_limiter_en,'Enable','off');
set(handles.checkbox_lfilter_en,'Enable','off');
set(handles.checkbox_filter_update_en,'Enable','off');

set(handles.checkbox_gps_pof,'Enable','off');
set(handles.checkbox_survey_mode,'Enable','off');
set(handles.checkbox_pos_hold_mode,'Enable','off');

set(handles.checkbox_plotPDerror,'Enable','off');
set(handles.checkbox_plotPDcenter,'Enable','off');
set(handles.checkbox_plotSawtoothErr,'Enable','off');
set(handles.checkbox_plotSawtoothCorr,'Enable','off');
set(handles.checkbox_plotOutlierRemoved,'Enable','off');
set(handles.checkbox_plotAveragerOut,'Enable','off');
set(handles.checkbox_plotDACvoltage,'Enable','off');

set(handles.checkbox_enableSDF,'Enable','off');
set(handles.checkbox_outlierRemoval,'Enable','off');
set(handles.checkbox_sawtoothCorrect,'Enable','off');
set(handles.checkbox_movingAverager,'Enable','off');
set(handles.checkbox_loopFilter,'Enable','off');

end