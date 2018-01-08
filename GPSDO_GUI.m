%-------------------------------------------------------------------------
%                           GUI Specific functions
%-------------------------------------------------------------------------

function varargout = GPSDO_GUI(varargin)
% GPSDO_GUI M-file for GPSDO_GUI.fig
%      GPSDO_GUI, by itself, creates a new GPSDO_GUI or raises the existing
%      singleton*.
%
%      H = GPSDO_GUI returns the handle to a new GPSDO_GUI or the handle to
%      the existing singleton*.
%
%      GPSDO_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GPSDO_GUI.M with the given input arguments.
%
%      GPSDO_GUI('Property','Value',...) creates a new GPSDO_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GPSDO_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GPSDO_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GPSDO_GUI

% Last Modified by GUIDE v2.5 09-Nov-2017 14:54:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GPSDO_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GPSDO_GUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before GPSDO_GUI is made visible.
function GPSDO_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GPSDO_GUI (see VARARGIN)

% Choose default command line output for GPSDO_GUI
%clc;
handles.output = hObject;
pause on;

%setup a timer1 object
handles.guifig = gcf;

%timer updating after every 1 secs
handles.tmr1Draw = timer('TimerFcn',{@TmrFcn1Draw,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

%timer updating after every 1 secs
handles.tmr1UpdateTime = timer('TimerFcn',{@TmrFcn1UpdateTime,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

%timer updating after every 1 secs
handles.tmr1Gpsdo1 = timer('TimerFcn',{@TmrFcn1Gpsdo1,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

%timer updating after every 1 secs
handles.tmr1Gpsdo2 = timer('TimerFcn',{@TmrFcn1Gpsdo2,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

%timer updating after every 1 secs
handles.tmr1Gpsdo3 = timer('TimerFcn',{@TmrFcn1Gpsdo3,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

handles.tmr1ArmTime = timer('TimerFcn',{@TmrFcn1ArmTime,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',1,'Name','Timer1sec');

handles.tmrgpsconfigupdate = timer('TimerFcn',{@TmrFcnUpdateGpsCfg,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',10,'Name','PositionMsgTimer');

handles.tmrgpsinfo = timer('TimerFcn',{@TmrFcn1UpdateGpsInfo,handles.guifig},'BusyMode','Queue',...
    'ExecutionMode','FixedRate','Period',10,'Name','GpsInfoTimer');

    
    
%setup a timer5 object
%timer updating after every 5 secs
% handles.tmr5 = timer('TimerFcn',{@TmrFcn5,handles.guifig},'BusyMode','Queue',...
%     'ExecutionMode','FixedRate','Period',5,'Name','Timer5sec');
% guidata(handles.guifig,handles);

%setup a timer60 object
%timer updating after every 60 secs
% handles.tmr60 = timer('TimerFcn',{@TmrFcn60,handles.guifig},'BusyMode','Queue',...
%     'ExecutionMode','FixedRate','Period',60,'Name','Timer60sec');
% guidata(handles.guifig,handles);

%setup a timer3600 object
%timer updating after every 3600 secs
% handles.tmr3600 = timer('TimerFcn',{@TmrFcn3600,handles.guifig},'BusyMode','Queue',...
%     'ExecutionMode','FixedRate','Period',3600,'Name','Timer3600sec');
% guidata(handles.guifig,handles);

%get comport settings
[handles, commie] = read_comport_config(handles);

%set initial values
handles.data60(1:60) = nan;
x60 = -60:-1;
handles.data3600(1:3600) = nan;
x3600 = -60:1/61:-1;
handles.data86400(1:86400) = nan;
x86400 = -24:1/3756.5:-1;
handles.dataPlot1 = plot(handles.axes1, x60, handles.data60);
handles.dataPlot2 = plot(handles.axes2, x3600, handles.data3600);
handles.dataPlot3 = plot(handles.axes3, x86400, handles.data86400);
set(handles.axes1,'XGrid','on','YGrid','on');
set(handles.axes2,'XGrid','on','YGrid','on');
set(handles.axes3,'XGrid','on','YGrid','on');
set(handles.dataPlot1,'YDataSource','handles.data60');
set(handles.dataPlot2,'YDataSource','handles.data3600');
set(handles.dataPlot3,'YDataSource','handles.data86400');

handles.armTime = 0;
handles.atConfig = 0;
handles.logDataEnabled = 0;

%clear existing com-ports from matlab workspace
s = instrfind;
if ~isempty(s), fclose(s); delete(s); clear s; end

%initialise command monitor object
handles.cmMon = commandMonitor(handles.text_commandMon,'All GPSDOs disconnected.',10);
%initialise gpsdo objects
handles.gpsdo1 = gpsdo(1);
handles.gpsdo2 = gpsdo(2);
handles.gpsdo3 = gpsdo(3);
handles.gps1 = gps(1,commie,handles.cmMon);


% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = GPSDO_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%clear existing com-ports from matlab workspace
s = instrfind;
if ~isempty(s), fclose(s); delete(s); clear s; end

%close all open files
fclose('all');
clc;
guidata(hObject, handles);


%------------------------------------------------------------------------
%                           timer functions
%------------------------------------------------------------------------
%Timer Function1
function TmrFcn1UpdateTime(~,~,handles) %Timer function
%handles = guidata(handles);
handles = guidata(handles);
date = datestr(now,24);
time = datestr(now,13);
set(handles.dateNow,'String',date);
set(handles.timeNow,'String',time);
guidata(handles.guifig, handles);

function TmrFcnUpdateGpsCfg(~,~,handles)
handles = guidata(handles);
if handles.gps1.connected
    
    handles.gps1.position_message(handles.cmMon);
    if handles.gps1.ser.BytesAvailable > 400
        try
            handles.gps1.position_message(handles.cmMon);    
        catch
   
        end
        
        fid = fopen('gps_info.cfg', 'w'); 
        fwrite(fid, ['Time=' handles.gps1.time double(sprintf('\n')) ...
            'Date=' handles.gps1.date double(sprintf('\n')) ...
            '# Lat/Long in unsigned notation - Change to signed and multiply by 90/324e6' double(sprintf('\n')) ...
            'Current_Lat=' num2str(handles.gps1.lat) double(sprintf('\n')) ...
            '# ' num2str(handles.gps1.latread) double(sprintf('\n')) ...
            'Current_Long=' num2str(handles.gps1.long) double(sprintf('\n')) ...
            '# ' num2str(handles.gps1.longread) double(sprintf('\n')) ...
            'Current_Alt=' num2str(handles.gps1.height) double(sprintf('\n'))...
            'Pos_Hold_Lat=' num2str(handles.gps1.pos_hold_lat) double(sprintf('\n')) ...
            'Pos_Hold_Long=' num2str(handles.gps1.pos_hold_long) double(sprintf('\n')) ...
            'Pos_Hold_Alt=' num2str(handles.gps1.pos_hold_alt)]);
        fclose(fid);
    end
    guidata(handles.guifig, handles);
end 

function TmrFcn1UpdateGpsInfo(~,~,handles) %Timer function
handles = guidata(handles);
if handles.gps1.connected
    
    set(handles.gps_date,'String',['Date:  ' handles.gps1.date double(sprintf('\n')) ...
        'Time:  ' handles.gps1.time(1:10) double(sprintf('\n')) 'Latitude:  ' num2str(handles.gps1.latread) double(sprintf('\n')) ...
        'Longitude:  ' num2str(handles.gps1.longread) double(sprintf('\n')) 'Height:  ' num2str(handles.gps1.height/100) ' m' double(sprintf('\n')) ...
        'Mode:  ' handles.gps1.mode double(sprintf('\n')) 'Sats Visible:  ' num2str(handles.gps1.satVisible) double(sprintf('\n')) ...
        'Sats Tracked:  ' num2str(handles.gps1.satTracked)]);         
    guidata(handles.guifig, handles);
end


%Timer Function1
function TmrFcn1Draw(~,~,handles) %Timer function
handles = guidata(handles);
%plot data if anything is connected
refreshdata(handles.dataPlot1,'caller');
refreshdata(handles.dataPlot2,'caller');
refreshdata(handles.dataPlot3,'caller');
drawnow;
guidata(handles.guifig, handles);


%Timer Function1
function TmrFcn1Gpsdo1(~,~,handles) %Timer function
handles = guidata(handles);
if handles.gpsdo1.connected, 
    %fprintf('%s\n',datestr(now+eps,13))
    [handles.gpsdo1, handles, handles.cmMon] = handles.gpsdo1.readDataToPlot(handles,handles.cmMon); 
    guidata(handles.guifig, handles);
end


%Timer Function1
function TmrFcn1Gpsdo2(~,~,handles) %Timer function
handles = guidata(handles);
if handles.gpsdo2.connected,
    [handles.gpsdo2, handles, handles.cmMon] = handles.gpsdo2.readDataToPlot(handles,handles.cmMon); 
    guidata(handles.guifig, handles);
end

%Timer Function1
function TmrFcn1Gpsdo3(~, ~ , handles) %Timer function
handles = guidata(handles);
if handles.gpsdo3.connected, 
    [handles.gpsdo3, handles, handles.cmMon] = handles.gpsdo3.readDataToPlot(handles,handles.cmMon); 
    guidata(handles.guifig, handles);
end 



%Timer Function1
function TmrFcn1ArmTime(~,~,handles) %Timer function

handles = guidata(handles);
date = datestr(now,24);
time = datestr(now,13);
fid = fopen('armtime.cfg');

%Search for armtime date and time in the artime.cfg file
while 1
    tline = fgetl(fid);
    if strfind(tline, 'Date=')>0;     %Find string Date
        temp_datestr = tline(6:end);
    end
    if strfind(tline, 'Arm_Time=')>0;
        temp_timestr = tline(10:end); %Find string Arm_Time
    end    
    if ~ischar(tline)
       break
    end
end

fclose(fid); %Close .cfg file

temp_time = datenum(temp_timestr); %Integer representation of Time string 

if strcmp(temp_datestr,date)       %If correct date
    if (temp_time > datenum(time)) %And time is in future (> current time)
    
        % if ~handles.gpsdo1.atCon;   %Not using auto_arm button
            if (handles.gpsdo1.armTime ~= temp_time) %If the new armtime is different than stored value
                    
                handles.gpsdo1.armed = 1;
                handles.armTime = temp_time;      %Global armtime set to .cfg armtime
                armTimeStr = datestr(handles.armTime,13);   %String format of armtime

%                 if ~handles.gpsdo1.armed          %If the gpsdo is not armed

                    handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr); %Arm the Gpsdo
                    for n=1:50  %Ensure the armed bit is high
                        
                        [~, ~, ~, ~, rtc_reg,~]  = handles.gpsdo1.serialObj.readRegister( '36', '0');
                        rtc_reg = hex2bin(rtc_reg);            
                        armed_now = str2double(rtc_reg(end-2));
                        
                        handles.cmMon.update(rtc_reg(end-2));
                        
                        if ~armed_now                   
                            handles.cmMon.update('Ish-u'); 
                            handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr);
                        else
                            handles.cmMon.update('It was armed .. apparently');
                            break;
                        end
                        pause(1);
                    end
                    set(handles.edit_armTime,'String',armTimeStr);     %Edit box displays new armtime
                
            end

        %handles.cmMon.update(['GPSDO Armed for: ' datestr(handles.gpsdo1.armTime,13)]);
       % end
    end
end

if handles.gpsdo1.armed
    if handles.gpsdo1.armTime > datenum(time)
        for n=1:50  %Ensure the armed bit is high
                        
                        [~, ~, ~, ~, rtc_reg,~]  = handles.gpsdo1.serialObj.readRegister( '36', '0');
                        rtc_reg = hex2bin(rtc_reg);            
                        armed_now = str2double(rtc_reg(end-2));
                        
                       
                        
                        if ~armed_now                   
                            handles.cmMon.update('Ish-u'); 
                            handles.gpsdo1.armGPSDO(handles.cmMon,datestr(handles.armTime,13));
                        else
                            
                            break;
                        end
                        pause(1);
        end
    end
end

if (handles.gpsdo1.connected)
    if handles.gpsdo1.armed
       
        handles.gpsdo1.isGPSDOarmed(handles.cmMon); 
    
    
    end;
    %if handles.gpsdo1.armed, armTime = handles.gpsdo1.armTime; end;
end

if (handles.gpsdo2.connected)
    if handles.gpsdo2.armed, handles.gpsdo2.isGPSDOarmed(handles.cmMon); end;
   % if handles.gpsdo2.armed, armTime = handles.gpsdo2.armTime; end;
end

if (handles.gpsdo3.connected)
    if handles.gpsdo3.armed, handles.gpsdo3.isGPSDOarmed(handles.cmMon); end;
    %if handles.gpsdo3.armed, armTime = handles.gpsdo3.armTime; end;
end

%handles.cmMon.update(handles.gpsdo1.gps_pof);

if handles.armTime ~= 0   
    %if handles.gpsdo1.armed     
        if handles.armTime > datenum(time)
            countDown_datenum = handles.armTime - datenum(time);
            countDown = datestr(countDown_datenum,13);
            set(handles.downCount,'String',countDown);
            if countDown_datenum/(24*60*60) < 10
               set(handles.downCount,'ForeGroundColor','red');
            end
        
        elseif handles.armTime == (datenum(time)-1)
            handles.cmMon.update('GPSDO Firing!');
        else
            handles.armTime = 0;
        end
    %end
end

if handles.armTime == 0
    set(handles.downCount,'String','hh:mm:ss','ForeGroundColor','black');
   
end   
guidata(handles.guifig, handles);

%Timer Function3600
% function TmrFcn3600(src,event,handles) %Timer function
% handles = guidata(handles);
% % if handles.gpsdo1.paramPanelSelected, handles.gpsdo1.syncTime(handles.cmMon); end
% % if handles.gpsdo2.paramPanelSelected, handles.gpsdo2.syncTime(handles.cmMon); end
% % if handles.gpsdo3.paramPanelSelected, handles.gpsdo3.syncTime(handles.cmMon); end
% % stop(handles.tmr1);
% % tmp = now+1/(24*3600);
% % startat(handles.tmr1,datestr(tmp));
% guidata(handles.guifig, handles);


%------------------------------------------------------------------------
%                           pushbuttons
%------------------------------------------------------------------------
% --- Executes on button press in togglebutton4.


% --- Executes on button press in pushbutton_autoArm.
function pushbutton_autoArm_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_autoArm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.armTime = now+10/(24*60*60);
armTimeStr = datestr(handles.armTime,13);
%armTimeStr = armTimeStr(end-7:end);

%handles.armTime = datenum(armTimeStr);
set(handles.edit_armTime,'String',armTimeStr);

if ~handles.gpsdo1.armed    
    
    handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr);
    set(handles.edit_armTime,'String',armTimeStr);    
    for n=1:50
    	
        [~, ~, ~, ~, rtc_reg,~]  = handles.gpsdo1.serialObj.readRegister( '36', '0');
        rtc_reg = hex2bin(rtc_reg);            
        armed_now = str2double(rtc_reg(end-2));
        pause(1);
        if ~armed_now

            handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr);
            handles.cmMon.update('Ish-u');


        else
            handles.cmMon.update('Bit went high A');
            break;
        end
    end
    
    
else    
    
    handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr);
    for n=1:50
    	
        [~, ~, ~, ~, rtc_reg,~]  = handles.gpsdo1.serialObj.readRegister( '36', '0');
        rtc_reg = hex2bin(rtc_reg);            
        armed_now = str2double(rtc_reg(end-2));
        pause(1);
        if ~armed_now

            handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr);
            handles.cmMon.update('Ish-u');


        else
            handles.cmMon.update('Bit went high B');
            break;
        end
    end
    set(handles.edit_armTime,'String',armTimeStr);
    
    
end
%if handles.gpsdo1.connected, handles.gpsdo1.armGPSDO(handles.cmMon,armTimeStr); end;
%if handles.gpsdo2.connected, handles.gpsdo2.armGPSDO(handles.cmMon,armTimeStr); end;
%if handles.gpsdo3.connected, handles.gpsdo3.armGPSDO(handles.cmMon,armTimeStr); end;

guidata(hObject, handles);


% --- Executes on button press in pushbutton_loadConfig.
function pushbutton_loadConfig_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.gpsdo1.selectedForUpload || handles.gpsdo2.selectedForUpload || handles.gpsdo3.selectedForUpload
    %get file name
    [FileName,PathName] = uigetfile('.\Filter Config Files\*.txt','Select the config file: ');
    fid = fopen(fullfile(PathName,FileName));
    %read file into cell strings
    x = 1;
    instruction{x} = fgetl(fid);
    while ischar(instruction{:,x})
        x = x+1;
        instruction{x} = fgetl(fid);
    end
    %close file
    fclose(fid);
    instruction = instruction';
    
    if handles.gpsdo1.selectedForUpload, handles.gpsdo1.uploadData(handles.cmMon,instruction); end
    if handles.gpsdo2.selectedForUpload, handles.gpsdo2.uploadData(handles.cmMon,instruction); end
    if handles.gpsdo3.selectedForUpload, handles.gpsdo3.uploadData(handles.cmMon,instruction); end
else
    handles.cmMon.update('Error: No GPSDO selected for upload!');
end
guidata(hObject, handles);

% --- Executes on button press in gpsdo1_connect.
function gpsdo1_connect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo1_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.gpsdo1.connected == 0 %going from disconnected --> connected
    %dbstop if all error;
    handles.gpsdo1.connect(handles,handles.cmMon);
    if handles.gpsdo1.connected
        set(handles.gpsdo1_connect,'Value',1);
        set(hObject,'String','Connected','ForegroundColor','Blue');
    else
        set(handles.gpsdo1_connect,'Value',0);
    end
elseif handles.gpsdo1.connected == 1 %going from connected --> disconnected
    handles.gpsdo1.disconnect(handles,handles.cmMon);
    set(hObject,'String','Disconnected','ForegroundColor','Red');
    set(handles.gpsdo1_connect,'Value',0);
    
end

if handles.gpsdo1.connected && ~(handles.gpsdo2.connected || handles.gpsdo3.connected)
    handles = enable_all_items(handles);
    two = 2/(60^2*24); % two seconds in serial time
    fTime = now + eps + two;
    startat(handles.tmr1Gpsdo1,fTime);
    startat(handles.tmr1Gpsdo2,fTime);
    startat(handles.tmr1Gpsdo3,fTime);
    startat(handles.tmr1ArmTime,fTime);
    
    startat(handles.tmr1UpdateTime,fTime);
    startat(handles.tmr1Draw,fTime);
elseif ~(handles.gpsdo1.connected || handles.gpsdo2.connected || handles.gpsdo3.connected)
    handles = disable_all_items(handles);
    stop(handles.tmr1Draw);
    stop(handles.tmr1ArmTime);
    stop(handles.tmr1UpdateTime);
    stop(handles.tmr1Gpsdo1);
    stop(handles.tmr1Gpsdo2);
    stop(handles.tmr1Gpsdo3);
end
guidata(hObject, handles);

% --- Executes on button press in gpsdo2_connect.
function gpsdo2_connect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo2_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gpsdo2_connect
if handles.gpsdo2.connected == 0 %going from disconnected --> connected
    handles.gpsdo2.connect(handles,handles.cmMon);
    if handles.gpsdo2.connected
        set(handles.gpsdo2_connect,'Value',1);
        set(hObject,'String','Connected','ForegroundColor','Blue');
    else
        set(handles.gpsdo2_connect,'Value',0);
    end
elseif handles.gpsdo2.connected == 1 %going from connected --> disconnected
    handles.gpsdo2.disconnect(handles,handles.cmMon);
    set(hObject,'String','Disconnected','ForegroundColor','Red');
    set(handles.gpsdo2_connect,'Value',0);
end

if handles.gpsdo2.connected && ~(handles.gpsdo1.connected || handles.gpsdo3.connected)
    handles = enable_all_items(handles);
    two = 2/(60^2*24); % two seconds in serial time
    fTime = now + eps + two;
    startat(handles.tmr1Gpsdo1,fTime);
    startat(handles.tmr1Gpsdo2,fTime);
    startat(handles.tmr1Gpsdo3,fTime);
    startat(handles.tmr1ArmTime,fTime);
    startat(handles.tmr1UpdateTime,fTime);
    startat(handles.tmr1Draw,fTime);
elseif ~(handles.gpsdo1.connected || handles.gpsdo2.connected || handles.gpsdo3.connected)
    handles = disable_all_items(handles);
    stop(handles.tmr1Draw);
    stop(handles.tmr1ArmTime);
    stop(handles.tmr1UpdateTime);
    stop(handles.tmr1Gpsdo1);
    stop(handles.tmr1Gpsdo2);
    stop(handles.tmr1Gpsdo3);
end
guidata(hObject, handles);

% --- Executes on button press in gpsdo3_connect.
function gpsdo3_connect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo3_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gpsdo3_connect
if handles.gpsdo3.connected == 0 %going from disconnected --> connected
    handles.gpsdo3.connect(handles,handles.cmMon);
    if handles.gpsdo3.connected
        set(handles.gpsdo3_connect,'Value',1);
        set(hObject,'String','Connected','ForegroundColor','Blue');
    else
        set(handles.gpsdo3_connect,'Value',0);
    end
elseif handles.gpsdo3.connected == 1 %going from connected --> disconnected
    handles.gpsdo3.disconnect(handles,handles.cmMon);
    set(hObject,'String','Disconnected','ForegroundColor','Red');
    set(handles.gpsdo3_connect,'Value',0);
   
end

if handles.gpsdo3.connected && ~(handles.gpsdo1.connected || handles.gpsdo2.connected)
    handles = enable_all_items(handles);
    two = 2/(60^2*24); % two seconds in serial time
    fTime = now + eps + two;
    startat(handles.tmr1Gpsdo1,fTime);
    startat(handles.tmr1Gpsdo2,fTime);
    startat(handles.tmr1Gpsdo3,fTime);
    startat(handles.tmr1ArmTime,fTime);
    startat(handles.tmr1UpdateTime,fTime);
    startat(handles.tmr1Draw,fTime);
elseif ~(handles.gpsdo1.connected || handles.gpsdo2.connected || handles.gpsdo3.connected)
    handles = disable_all_items(handles);
    stop(handles.tmr1Draw);
    stop(handles.tmr1ArmTime);
    stop(handles.tmr1UpdateTime);
    stop(handles.tmr1Gpsdo1);
    stop(handles.tmr1Gpsdo2);
    stop(handles.tmr1Gpsdo3);
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton_syncRTC.
function pushbutton_syncRTC_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_syncRTC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% if handles.gpsdo1.paramPanelSelected, handles.gpsdo1.syncTime(handles.cmMon); end
% if handles.gpsdo2.paramPanelSelected, handles.gpsdo2.syncTime(handles.cmMon); end
% if handles.gpsdo3.paramPanelSelected, handles.gpsdo3.syncTime(handles.cmMon); end
% stop(handles.tmr1);
% tmp = now+1/(24*3600);
% startat(handles.tmr1,datestr(tmp));
% guidata(hObject, handles);



function pushbutton_logData_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_logData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_logData

if handles.logDataEnabled == 0 %going from off to on
    %change button text
    handles.logDataEnabled = 1;
    set(hObject,'String','Data Logging Started','ForeGroundColor','blue');
    handles.gpsdo1.logData = 1;
    handles.gpsdo2.logData = 1;
    handles.gpsdo3.logData = 1;
elseif handles.logDataEnabled == 1; %going from on to off
    handles.logDataEnabled = 0;
    handles.gpsdo1.logData = 0;
    handles.gpsdo2.logData = 0;
    handles.gpsdo3.logData = 0;
    %change button text
    set(hObject,'String','Data Logging Stopped','ForeGroundColor','red');
end
guidata(hObject, handles);



%------------------------------------------------------------------------
%                           radiobuttons
%------------------------------------------------------------------------
% --- Executes when selected object is changed in panel_select_gpsdo.
function panel_select_gpsdo_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in panel_select_gpsdo
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.gpsdo1_paramSelect,'Value')
    handles.gpsdo1.selectParameterPanel(handles, handles.cmMon);
    handles.gpsdo2.deselectParameterPanel();
    handles.gpsdo3.deselectParameterPanel();
elseif get(handles.gpsdo2_paramSelect,'Value')
    handles.gpsdo2.selectParameterPanel(handles, handles.cmMon);
    handles.gpsdo1.deselectParameterPanel();
    handles.gpsdo3.deselectParameterPanel();
elseif get(handles.gpsdo3_paramSelect,'Value')
    handles.gpsdo3.selectParameterPanel(handles, handles.cmMon);
    handles.gpsdo1.deselectParameterPanel();
    handles.gpsdo2.deselectParameterPanel();
end
guidata(hObject, handles);



% --- Executes when selected object is changed in plot_selection_change.
function plot_selection_change_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in plot_selection_change
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
%define axes plots
if get(handles.radiobutton_plotGPSDO1,'Value')
    handles.gpsdo1.plotDataSelected = 1;
else
    handles.gpsdo1.plotDataSelected = 0;
end

if get(handles.radiobutton_plotGPSDO2,'Value')
    handles.gpsdo2.plotDataSelected = 1;
    
else
    handles.gpsdo2.plotDataSelected = 0;
end

if get(handles.radiobutton_plotGPSDO3,'Value')
    handles.gpsdo3.plotDataSelected = 1;
    
else
    handles.gpsdo3.plotDataSelected = 0;
end
guidata(hObject, handles);









%------------------------------------------------------------------------
%                            edit_boxes
%------------------------------------------------------------------------

function gpsdo1_comSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo1_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gpsdo1_comSelect as text
%        str2double(get(hObject,'String')) returns contents of gpsdo1_comSelect as a double
gpsdo_nr = 1;

tmp = str2double(get(hObject,'String'));

if isnan(tmp) || tmp >=100
    set(hObject,'String','?');
    handles.cmMon.update('Error: Value must be an integer 1..99.');
elseif gpsdo_nr == 1 && (strcmp(tmp,handles.gpsdo2.comPort) || strcmp(tmp,handles.gpsdo3.comPort))
    set(hObject,'String','?');
    handles.cmMon.update('Error: Port already assigned.');
else
    set(hObject,'String',['COM' get(hObject,'String')]);
    eval(sprintf('handles.gpsdo%i.comPort = tmp;',gpsdo_nr));
    eval(sprintf('handles.cmMon.update(''COM%i assigned to GPSDO%i.'');',tmp,gpsdo_nr));
end
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function gpsdo1_comSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gpsdo1_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsdo2_comSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gosdo2_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gosdo2_comSelect as text
%        str2double(get(hObject,'String')) returns contents of gosdo2_comSelect as a double
gpsdo_nr = 2;

tmp = str2double(get(hObject,'String'));
if isnan(tmp) || tmp >=100
    set(hObject,'String','?');
    handles.cmMon.update('Error: Value must be an integer 1..99.');
elseif gpsdo_nr == 2 && (strcmp(tmp,handles.gpsdo1.comPort) || strcmp(tmp,handles.gpsdo3.comPort))
    set(hObject,'String','?');
    handles.cmMon.update('Error: Port already assigned.');
else
    set(hObject,'String',['COM' get(hObject,'String')]);
    eval(sprintf('handles.gpsdo%i.comPort = tmp;',gpsdo_nr));
    eval(sprintf('handles.cmMon.update(''COM%i assigned to GPSDO%i.'');',tmp,gpsdo_nr));
end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function gpsdo2_comSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gosdo2_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function gpsdo3_comSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo3_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gpsdo3_comSelect as text
%        str2double(get(hObject,'String')) returns contents of gpsdo3_comSelect as a double
gpsdo_nr = 3;

tmp = str2double(get(hObject,'String'));
if isnan(tmp) || tmp >=100
    set(hObject,'String','?');
    handles.cmMon.update('Error: Value must be an integer 1..99.');
elseif gpsdo_nr == 3 && (strcmp(tmp,handles.gpsdo1.comPort) || strcmp(tmp,handles.gpsdo2.comPort))
    set(hObject,'String','?');
    handles.cmMon.update('Error: Port already assigned.');
else
    set(hObject,'String',['COM' get(hObject,'String')]);
    eval(sprintf('handles.gpsdo%i.comPort = tmp;',gpsdo_nr));
    eval(sprintf('handles.cmMon.update(''COM%i assigned to GPSDO%i.'');',tmp,gpsdo_nr));
end


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function gpsdo3_comSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gpsdo3_comSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_armTime_Callback(hObject, eventdata, handles)
% hObject    handle to edit_armTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_armTime as text
%        str2double(get(hObject,'String')) returns contents of edit_armTime as a double

%check if string is valid
rtc_alarm = get(handles.edit_armTime,'String');
hours = str2double(rtc_alarm(end-7:end-6));
sep1 = rtc_alarm(3);
mins = str2double(rtc_alarm(end-4:end-3));
sep2 = rtc_alarm(6);
secs = str2double(rtc_alarm(end-1:end));

handles.armTime = datenum(rtc_alarm);

if (((sep1 == ':') && (sep2 == ':')) && ((hours < 24) && (hours >= 0)) && ((mins < 60) && (mins >= 0)) && ((secs < 60) && (secs >= 0)))
    if handles.gpsdo1.connected, handles.gpsdo1.armGPSDO(handles.cmMon,rtc_alarm);end;
    if handles.gpsdo2.connected, handles.gpsdo2.armGPSDO(handles.cmMon,rtc_alarm);end;
    if handles.gpsdo3.connected, handles.gpsdo3.armGPSDO(handles.cmMon,rtc_alarm);end;
else
    handles.cmMon.update(sprintf('Error: Must be of format - HH:MM:SS'));
end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function edit_armTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_armTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_pll_tau_Callback(hObject, eventdata, handles)
% hObject    handle to edit_pll_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_pll_tau as text
%        str2double(get(hObject,'String')) returns contents of edit_pll_tau as a double

% --- Executes during object creation, after setting all properties.
function edit_pll_tau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pll_tau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mean_samples_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mean_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mean_samples as text
%        str2double(get(hObject,'String')) returns contents of edit_mean_samples as a double


% --- Executes during object creation, after setting all properties.
function edit_mean_samples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mean_samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_drift_comp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_drift_comp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_drift_comp as text
%        str2double(get(hObject,'String')) returns contents of edit_drift_comp as a double

% --- Executes during object creation, after setting all properties.
function edit_drift_comp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_drift_comp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_phase_offset_Callback(hObject, eventdata, handles)
% hObject    handle to edit_phase_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_phase_offset as text
%        str2double(get(hObject,'String')) returns contents of edit_phase_offset as a double


% --- Executes during object creation, after setting all properties.
function edit_phase_offset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_phase_offset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%-------------------------------------------------------------------------
%                              checkboxes
%-------------------------------------------------------------------------

% --- Executes on button press in gpsdo1_uploadSelect.
function gpsdo1_uploadSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo1_uploadSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gpsdo1_uploadSelect
handles.gpsdo1.selectedForUpload = get(handles.gpsdo1_uploadSelect,'Value');
guidata(hObject, handles);

% --- Executes on button press in gpsdo2_uploadSelect.
function gpsdo2_uploadSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo2_uploadSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gpsdo2_uploadSelect
handles.gpsdo2.selectedForUpload = get(handles.gpsdo2_uploadSelect,'Value');
guidata(hObject, handles);



% --- Executes on button press in gpsdo3_uploadSelect.
function gpsdo3_uploadSelect_Callback(hObject, eventdata, handles)
% hObject    handle to gpsdo3_uploadSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gpsdo3_uploadSelect
handles.gpsdo3.selectedForUpload = get(handles.gpsdo3_uploadSelect,'Value');
guidata(hObject, handles);





% --- Executes on button press in checkbox_survey_mode.
%function checkbox_survey_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_survey_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_survey_mode


% --- Executes on button press in checkbox_pos_hold_mode.
%function checkbox_pos_hold_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pos_hold_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pos_hold_mode


% --- Executes on button press in checkbox_gps_pof.
%function checkbox_gps_pof_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_gps_pof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_gps_pof

% --- Executes on button press in checkbox_mean_en.
function checkbox_mean_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mean_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mean_en


% --- Executes on button press in checkbox_limiter_en.
function checkbox_limiter_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_limiter_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_limiter_en


% --- Executes on button press in checkbox_lfilter_en.
function checkbox_lfilter_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lfilter_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lfilter_en


% --- Executes on button press in checkbox_mean_mode.
function checkbox_mean_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mean_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mean_mode


% --- Executes on button press in checkbox_outlier_en.
function checkbox_outlier_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_outlier_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_outlier_en


% --- Executes on button press in checkbox_filter_update_en.
function checkbox_filter_update_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_filter_update_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_filter_update_en
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_filter_update_en(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_filter_update_en(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_filter_update_en(handles,handles.cmMon); end
guidata(hObject, handles);



% --- Executes on button press in checkbox_sawtooth_en.
function checkbox_sawtooth_en_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sawtooth_en (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sawtooth_en
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_sawtooth_en(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_sawtooth_en(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_sawtooth_en(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_open_loop.
function checkbox_open_loop_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_open_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_open_loop
if handles.gpsdo1.paramPanelSelected, handles.gpsdo1.toggle_open_loop(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected, handles.gpsdo2.toggle_open_loop(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected, handles.gpsdo3.toggle_open_loop(handles,handles.cmMon); end
guidata(hObject, handles);


% --- Executes on button press in checkbox_rtc_alarm_set.
function checkbox_rtc_alarm_set_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rtc_alarm_set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rtc_alarm_set


% --- Executes on button press in checkbox_tic_timeout.
function checkbox_tic_timeout_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_tic_timeout (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_tic_timeout


% --- Executes on button press in checkbox_en_gps_update.
function checkbox_en_gps_update_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_en_gps_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_en_gps_update
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_gps_update_en(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_gps_update_en(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_gps_update_en(handles,handles.cmMon); end
guidata(hObject, handles);


% --- Executes on button press in checkbox_pps.
function checkbox_pps_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pps
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_en_output_pps(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_en_output_pps(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_en_output_pps(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_ref_sel.
function checkbox_ref_sel_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_ref_sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_ref_sel(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_ref_sel(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_ref_sel(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_stdby_mode.
function checkbox_stdby_mode_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_stdby_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_stdby_mode

% --- Executes on button press in checkbox_plotPDerror.
function checkbox_plotPDerror_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotPDerror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotPDerror
if get(handles.checkbox_plotPDerror,'Value');
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotPDcenter.
function checkbox_plotPDcenter_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotPDcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotPDcenter
if get(handles.checkbox_plotPDcenter,'Value');
    set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotSawtoothErr.
function checkbox_plotSawtoothErr_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotSawtoothErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotSawtoothErr
if get(handles.checkbox_plotSawtoothErr,'Value');
    set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotSawtoothCorr.
function checkbox_plotSawtoothCorr_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotSawtoothCorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotSawtoothCorr
if get(handles.checkbox_plotSawtoothCorr,'Value');
    set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotOutlierRemoved.
function checkbox_plotOutlierRemoved_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotOutlierRemoved (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of
% checkbox_plotOutlierRemoved
if get(handles.checkbox_plotOutlierRemoved,'Value');
   set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotAveragerOut.
function checkbox_plotAveragerOut_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotAveragerOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotAveragerOut
if get(handles.checkbox_plotAveragerOut,'Value');
   set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotDACvoltage,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_plotDACvoltage.
function checkbox_plotDACvoltage_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_plotDACvoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_plotDACvoltage
if get(handles.checkbox_plotDACvoltage,'Value');
   set(handles.checkbox_plotPDerror,'Value',0);
    set(handles.checkbox_plotPDcenter,'Value',0)
    set(handles.checkbox_plotSawtoothErr,'Value',0);
    set(handles.checkbox_plotSawtoothCorr,'Value',0);
    set(handles.checkbox_plotOutlierRemoved,'Value',0);
    set(handles.checkbox_plotAveragerOut,'Value',0);
       
    handles.gpsdo1.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo2.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo3.plotPDerror = get(handles.checkbox_plotPDerror,'Value');
    handles.gpsdo1.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo2.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo3.plotPDcenter = get(handles.checkbox_plotPDcenter,'Value');
    handles.gpsdo1.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo2.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo3.plotSawtoothErr = get(handles.checkbox_plotSawtoothErr,'Value');
    handles.gpsdo1.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo2.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo3.plotSawtoothCorr = get(handles.checkbox_plotSawtoothCorr,'Value');
    handles.gpsdo1.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo2.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo3.plotOutlierRemoved = get(handles.checkbox_plotOutlierRemoved,'Value');
    handles.gpsdo1.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo2.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo3.plotAveragerOut = get(handles.checkbox_plotAveragerOut,'Value');
    handles.gpsdo1.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo2.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
    handles.gpsdo3.plotDACVoltage = get(handles.checkbox_plotDACvoltage,'Value');
end
guidata(hObject, handles);

% --- Executes on button press in checkbox_sawtoothCorrect.
function checkbox_sawtoothCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sawtoothCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_SDFsawtoothCorrect(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_SDFsawtoothCorrect(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_SDFsawtoothCorrect(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_outlierRemoval.
function checkbox_outlierRemoval_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_outlierRemoval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_SDFoutlierRemoval(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_SDFoutlierRemoval(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_SDFoutlierRemoval(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_movingAverager.
function checkbox_movingAverager_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_movingAverager (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_SDFaveraging(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_SDFaveraging(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_SDFaveraging(handles,handles.cmMon); end
guidata(hObject, handles);

% --- Executes on button press in checkbox_loopFilter.
function checkbox_loopFilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_loopFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_SDFloopFilter(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_SDFloopFilter(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_SDFloopFilter(handles,handles.cmMon); end
guidata(hObject, handles);


% --- Executes on button press in checkbox_enableSDF.
function checkbox_enableSDF_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_enableSDF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ref_sel
if handles.gpsdo1.paramPanelSelected,handles.gpsdo1.toggle_enableSDF(handles,handles.cmMon); end
if handles.gpsdo2.paramPanelSelected,handles.gpsdo2.toggle_enableSDF(handles,handles.cmMon); end
if handles.gpsdo3.paramPanelSelected,handles.gpsdo3.toggle_enableSDF(handles,handles.cmMon); end
guidata(hObject, handles);
%-end--------------------------------------------------------------------
%                            menu items
% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox_fromFile('About','.\Config Files\about.txt');

% --------------------------------------------------------------------
function menu_readme_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox_fromFile('readme.txt','.\Config Files\readme.txt');


%---------------------------------------------------------------------
%                            plot create functions
% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2


% --- Executes during object creation, after setting all properties.
function axes3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes3



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_plotPDerror_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_plotPDerror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_plotPDcenter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_plotPDcenter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_plotSawtoothErr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_plotSawtoothErr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% --- Executes during object creation, after setting all properties.
function checkbox_plotAveragerOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_plotAveragerOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_plotDACvoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_plotDACvoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in gps1_connect.
function gps1_connect_Callback(hObject, eventdata, handles)
% hObject    handle to gps1_connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gps1_connect
if handles.gps1.connected == 0 %going from disconnected --> connected
    %dbstop if all error;
    set(hObject,'String','Connecting ...','ForegroundColor','Red');
    handles.gps1.connect(handles,handles.cmMon);
    
    if handles.gps1.connected
        set(handles.gps1_connect,'Value',1);
        set(hObject,'String','Connected','ForegroundColor','Blue');
        handles.gps1.query_pos_mode(handles.cmMon);
       % fTime = now;
        two = 2/(60^2*24);
        startat(handles.tmrgpsconfigupdate,now+two);
        startat(handles.tmrgpsinfo,now+two);
    else
        set(handles.gps1_connect,'Value',0);
    end
elseif handles.gps1.connected == 1 %going from connected --> disconnected
    handles.gps1.disconnect(handles,handles.cmMon);
    stop(handles.tmrgpsinfo);
    stop(handles.tmrgpsconfigupdate);
    set(hObject,'String','GPS Comms d/c','ForegroundColor','Red');
    set(handles.gps1_connect,'Value',0);
end
guidata(hObject, handles);


% --- Executes on button press in survey_button.


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)

% hObject    handle to survey_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.gps1.connected == 1 && handles.gps1.inSurvey == 0 && ~handles.gps1.waiting
    handles.gps1.inSurvey = 1;    
    if handles.gps1.inSurvey == 1
        set(handles.pushbutton14,'Value',1);       
        set(hObject,'String','Surveying!','ForegroundColor','Blue');
        handles.gps1.survey_mode(handles.cmMon);
%         if error
%             set(handles.pushbutton14,'Value',0);
%             set(hObject,'String','Auto Survey','ForegroundColor','Black');     
%         end
    
    else
        set(handles.pushbutton14,'Value',0);
    end  

elseif handles.gps1.inSurvey == 1 && ~handles.gps1.waiting %going from connected --> disconnected
    set(hObject,'String','Auto Survey','ForegroundColor','Black');
    handles.gps1.posHold(handles.cmMon);
    set(handles.pushbutton14,'Value',0);

else
    handles.cmMon.update('GPS is busy, try again ...');

end
% Hint: get(hObject,'Value') returns toggle state of survey_button
guidata(hObject, handles);


% --- Executes on button press in save_position.
function save_position_Callback(hObject, eventdata, handles)
% hObject    handle to save_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.gps1.connected == 1
    handles.gps1.savePos(handles.cmMon);
end
guidata(hObject, handles);
% --- Executes on button press in apply_position.
function apply_position_Callback(hObject, eventdata, handles)
% hObject    handle to apply_position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.gps1.connected == 1
    handles.gps1.applyPos(handles.cmMon);
end
guidata(hObject, handles);


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cmMon.update('');
guidata(hObject, handles);



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
instruction = get(handles.edit9,'String');
ins = instruction(1:4);
data = instruction(5:end);
handles.gps1.write_command(handles.cmMon,ins,data);
pause(4);
[data,errors]=handles.gps1.read_command(handles.cmMon,ins);
if ~errors    
    handles.cmMon.update([sprintf('GPS Response: %s',data)]);
else
    handles.cmMon.update('Manual Instruction Error!')
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in init_gps.
function init_gps_Callback(hObject, eventdata, handles)
% hObject    handle to init_gps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function init_gps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to init_gps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
