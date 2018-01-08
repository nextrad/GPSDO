function handles = enable_all_items(handles)

set(handles.dateNow,'Enable','on');
set(handles.timeNow,'Enable','on');
set(handles.downCount,'Enable','on');
set(handles.edit_armTime,'Enable','on');
set(handles.pushbutton_loadConfig,'Enable','on');
set(handles.pushbutton_autoArm,'Enable','on'); 
set(handles.pushbutton_syncRTC,'Enable','on');
set(handles.pushbutton_logData,'Enable','on');

set(handles.checkbox_plotPDerror,'Enable','on');
set(handles.checkbox_plotPDcenter,'Enable','on');
set(handles.checkbox_plotSawtoothErr,'Enable','on');
set(handles.checkbox_plotSawtoothCorr,'Enable','on');
set(handles.checkbox_plotOutlierRemoved,'Enable','on');
set(handles.checkbox_plotAveragerOut,'Enable','on');
set(handles.checkbox_plotDACvoltage,'Enable','on');

end