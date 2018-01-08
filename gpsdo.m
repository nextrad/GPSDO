classdef gpsdo<handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        serialObj
        sdfObj
        
        gpsdoNr
        comPort
        gpsdoID
        
        connected
        selectedForUpload
        wasArmed
        armed
        paramPanelSelected
        logData
        isLogging
        fname
        
        now_date
        
        plotDataSelected
        plotPDerror
        plotPDcenter
        plotOutlierRemoved
        plotSawtoothErr
        plotSawtoothCorr
        plotAveragerOut
        plotDACVoltage
        
        armTime
        rtc_time
        gps_date
        
        plot60dataPDerror
        plot60dataPDcenter
        plot60dataOutlierRemoved
        plot60dataSawtoothErr
        plot60dataSawtoothCorr
        plot60dataAveragerOut
        plot60dataDACvoltage
        
        plot3600dataPDerror
        plot3600dataPDcenter
        plot3600dataOutlierRemoved
        plot3600dataSawtoothErr
        plot3600dataSawtoothCorr
        plot3600dataAveragerOut
        plot3600dataDACvoltage
        
        plot86400dataPDerror
        plot86400dataPDcenter
        plot86400dataOutlierRemoved
        plot86400dataSawtoothErr
        plot86400dataSawtoothCorr
        plot86400dataAveragerOut
        plot86400dataDACvoltage
        
        stdby_mode
        ref_sel
        rtc_alarm_set
        en_gps_update
        output_pps
        tic_timeout
        pll_lock
        open_loop
        sawtooth_en
        outlier_en
        mean_mode
        mean_en
        limiter_en
        lfilter_en
        filter_update_en
        driftComp
        samplesAvg
        timeOffset
        pllTau
        survey_mode
        gps_pof
        pos_hold_mode
        
        en_stdby_mode
        en_ref_sel
        en_rtc_alarm_set
        en_en_gps_update
        en_output_pps
        en_tic_timeout
        en_pll_lock
        en_open_loop
        en_sawtooth_en
        en_outlier_en
        en_mean_mode
        en_mean_en
        en_limiter_en
        en_lfilter_en
        en_filter_update_en
        en_driftComp
        en_samplesAvg
        en_timeOffset
        en_pllTau
        en_survey_mode
        en_gps_pof
        en_pos_hold_mode
        en_checkbox_enableSDF
        en_checkbox_outlierRemoval
        en_checkbox_sawtoothCorrect
        en_checkbox_movingAverager
        en_checkbox_loopFilter
        
        logFid
        
        atCon %Allows auto_arm_button if a future config time is being used
        
    end
    
    methods
        function obj = gpsdo(gpsdoNr)
            % constructor method
            obj.gpsdoNr = gpsdoNr;
            
            obj.comPort = 0;
            obj.gpsdoID = 0;
            
            obj.connected = 0;
            obj.selectedForUpload = 0;
            obj.wasArmed = 0;
            obj.armed = 0;
            obj.paramPanelSelected = 0;
            obj.logData = 0;
            obj.isLogging = 0;
            obj.fname = '';
            
            obj.now_date = nan;
            
            obj.plotDataSelected = 0;
            obj.plotPDerror = 0;
            obj.plotPDcenter = 0;
            obj.plotOutlierRemoved = 0;
            obj.plotSawtoothErr = 0;
            obj.plotSawtoothCorr = 0;
            obj.plotAveragerOut = 0;
            obj.plotDACVoltage = 0;

            obj.armTime = '00:00:00';
            obj.rtc_time = '00:00:00';
            obj.gps_date = 'YY/MM/DD';
            
            obj.stdby_mode = 0;
            obj.ref_sel = 0;
            obj.rtc_alarm_set = 0;
            obj.en_gps_update = 0;
            obj.output_pps = 0;
            obj.pll_lock = 0;
            obj.tic_timeout = 0;
            obj.open_loop = 0;
            obj.sawtooth_en = 0;
            obj.outlier_en = 0;
            obj.mean_mode = 0;
            obj.mean_en = 0;
            obj.limiter_en = 0;
            obj.lfilter_en = 0;
            obj.filter_update_en = 0;
            obj.driftComp = 0;
            obj.samplesAvg = 0;
            obj.timeOffset = 0;
            obj.pllTau = 0;
            obj.survey_mode = 0;
            obj.gps_pof = 0;
            obj.pos_hold_mode = 0;
            
            obj.en_stdby_mode = 'off';
            obj.en_ref_sel = 'on';
            obj.en_rtc_alarm_set = 'off';
            obj.en_en_gps_update = 'on';
            obj.en_output_pps = 'on';
            obj.en_tic_timeout = 'off';
            obj.pll_lock = 'off';
            obj.en_open_loop = 'on';
            obj.en_sawtooth_en = 'on';
            obj.en_outlier_en = 'off';
            obj.en_mean_mode = 'off';
            obj.en_mean_en = 'off';
            obj.en_limiter_en = 'off';
            obj.en_lfilter_en = 'off';
            obj.en_filter_update_en = 'on';
            obj.en_driftComp = 'off';
            obj.en_samplesAvg = 'off';
            obj.en_timeOffset = 'off';
            obj.en_pllTau = 'off';
            obj.en_survey_mode = 'off';
            obj.en_gps_pof = 'off';
            obj.en_pos_hold_mode = 'off';
            obj.en_checkbox_enableSDF = 'on';
            obj.en_checkbox_outlierRemoval = 'off';
            obj.en_checkbox_sawtoothCorrect = 'off';
            obj.en_checkbox_movingAverager = 'off';
            obj.en_checkbox_loopFilter = 'off';
            
            obj.atCon = 0;
        end
        function obj = delete(obj)
            disableGuiItems(obj)
        end
        function [obj, guiObj, cmMonObj] = connect(obj, guiObj, cmMonObj)
            eval(sprintf('obj.comPort = get(guiObj.gpsdo%i_comSelect,''String'');',obj.gpsdoNr));
            obj.serialObj = gpsdoSerialInterface(cmMonObj,obj.comPort,obj.gpsdoNr);
            obj.sdfObj = softwareDefinedFilter(cmMonObj,obj.comPort,obj.gpsdoNr);
            [cmMonObj, errors] = obj.serialObj.testConnectivity(cmMonObj);
            if ~errors
                obj.plot60dataPDerror(1:60) = nan;
                obj.plot60dataPDcenter(1:60) = nan;
                obj.plot60dataOutlierRemoved(1:60) = nan;
                obj.plot60dataSawtoothErr(1:60) = nan;
                obj.plot60dataSawtoothCorr(1:60) = nan;
                obj.plot60dataAveragerOut(1:60) = nan;
                obj.plot60dataDACvoltage(1:60) = nan;
                
                obj.plot3600dataPDerror(1:3600) = nan;
                obj.plot3600dataPDcenter(1:3600) = nan;
                obj.plot3600dataOutlierRemoved(1:3600) = nan;
                obj.plot3600dataSawtoothErr(1:3600) = nan;
                obj.plot3600dataSawtoothCorr(1:3600) = nan;
                obj.plot3600dataAveragerOut(1:3600) = nan;
                obj.plot3600dataDACvoltage(1:3600) = nan;
                
                obj.plot86400dataPDerror(1:86400) = nan;
                obj.plot86400dataPDcenter(1:86400) = nan;
                obj.plot86400dataOutlierRemoved(1:86400) = nan;
                obj.plot86400dataSawtoothErr(1:86400) = nan;
                obj.plot86400dataSawtoothCorr(1:86400) = nan;
                obj.plot86400dataAveragerOut(1:86400) = nan;
                obj.plot86400dataDACvoltage(1:86400) = nan;
                
                obj.connected = 1;
                obj.enableGuiItems(guiObj);
                eval(sprintf('obj.paramPanelSelected = get(guiObj.gpsdo%i_paramSelect,''Value'');',obj.gpsdoNr));
                eval(sprintf('obj.plotDataSelected = get(guiObj.radiobutton_plotGPSDO%i,''Value'');',obj.gpsdoNr));
                if obj.paramPanelSelected
                    obj.selectParameterPanel(guiObj, cmMonObj);
                end
                obj.plotPDerror = get(guiObj.checkbox_plotPDerror,'Value');
                obj.plotPDcenter = get(guiObj.checkbox_plotPDcenter,'Value');
                obj.plotSawtoothErr = get(guiObj.checkbox_plotSawtoothErr,'Value');
                obj.plotSawtoothCorr = get(guiObj.checkbox_plotSawtoothCorr,'Value');
                obj.plotOutlierRemoved = get(guiObj.checkbox_plotOutlierRemoved,'Value');
                obj.plotAveragerOut = get(guiObj.checkbox_plotAveragerOut,'Value');
                obj.plotDACVoltage = get(guiObj.checkbox_plotDACvoltage,'Value');
            else
                obj.connected = 0;
            end
        end
        function [obj guiObj cmMonObj] = disconnect(obj,guiObj,cmMonObj)
            obj.serialObj.deletePort(cmMonObj);
            obj.sdfObj.delete;
            [obj guiObj] = obj.disableGuiItems(guiObj);
            obj.connected = 0;
        end
        function [obj guiObj cmMonObj] = selectParameterPanel(obj,guiObj, cmMonObj)
            if obj.connected
                [obj guiObj cmMonObj errors] = getRegisters(obj,guiObj, cmMonObj);
                if ~errors
                    [obj, guiObj] = enableParamPanelItems(obj,guiObj);
                    [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    obj.paramPanelSelected = 1;
                else
                    obj.paramPanelSelected = 0;
                end
            end
        end
        function obj = deselectParameterPanel(obj)
            if obj.connected, obj.paramPanelSelected = 0; end
        end
        
        function [obj guiObj cmMonObj] = readDataToPlot(obj,guiObj,cmMonObj)
            if obj.connected
                date = now;
%                 for i = 1:3
%                     [~, ~, ~, ~, PDcenter,error0]     = obj.serialObj.readRegister( '19', '1'); %PDcenter
%                     if ~error0, break; end
%                 end
                error0 = 1;
                
                for i = 1:3
                    [~, ~, ~, ~, PDerror,error1]      = obj.serialObj.readRegister( '1D', '1'); %PDerror
                    if ~error1, break; end
                end
                
%                 for i = 1:3
%                     [~, ~, ~, ~, sawtoothErr,error2]  = obj.serialObj.readRegister( '3B', '0'); %sawtoothErr
%                     if ~error2, break; end
%                 end
                error2 = 1;
                
                for i = 1:3
                    [~, ~, ~, ~, sawtoothCorr,error3] = obj.serialObj.readRegister( '50', '3'); %sawtoothCorr
                    if ~error3, break; end
                end
                if error0
                    PDcenter = nan;
                end
                if error1
                    PDerror = nan;
                end
                if error2
                    sawtoothErr = nan;
                end
                if error3
                    sawtoothCorr = nan;
                end

                % pd_error
                q = quantizer([16 0]);
                PDerror = hex2num(q,PDerror)*65e-12/1e-9;
                if length(PDerror) ~= 1, PDerror = nan; end

                % PDcenter
%                 q = quantizer([16 0]);
%                 PDcenter = hex2num(q,PDcenter)*65e-12/1e-9;
%                 if length(PDcenter) ~= 1, PDcenter = nan; end

                % sawtooth
%                 q = quantizer([8 0]);
%                 sawtoothErr = hex2num(q,sawtoothErr);
%                 if length(sawtoothErr) ~= 1, sawtoothErr = nan; end

                % sawtoothCorr
                q = quantizer([32 0]);
                sawtoothCorr = hex2num(q,sawtoothCorr)*65e-12*2^-16/1e-9;%+65;
                if length(sawtoothCorr) ~= 1, sawtoothCorr = nan; end
                
                if obj.sdfObj.sdf_en
                    obj.sdfObj.update(cmMonObj,sawtoothCorr,0);
                    %obj.sdfObj.update(cmMonObj,PDerror-65,sawtoothErr);
                    
                    if (obj.sdfObj.locked)
                        eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''ForegroundColor'',''green'');',obj.gpsdoNr));
                    else
                        eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''ForegroundColor'',''red'');',obj.gpsdoNr));
                    end
                    
                    set(guiObj.edit_pll_tau,'String',int2str(obj.sdfObj.tau));
                                        
                    outlierRemoved = obj.sdfObj.outlier_output;
                    averagerOut = obj.sdfObj.averager_output;
                    DACvoltage = (obj.sdfObj.filter_output.*10/2^20);%./1e-3; %mV
                    %update DAC value
                    
                    dac_instruction = ['40' obj.sdfObj.dac_value];
                    for i = 1:3
                        [~, ~, ~, ~, ~, error2] = obj.serialObj.writeRegister('0F','3',dac_instruction);
                        if ~error2, break; end
                    end
                    for i = 1:3
                        [~, ~, ~, ~, ~, error2] = obj.serialObj.writeRegister('07','0','80');
                        if ~error2, break; end
                    end
                    
                else % not obj.sdfObj.sdf_en
                    % DACvoltage
                    for i = 1:3
                        [~, ~, ~, ~, DACvoltage,error4]      = obj.serialObj.readRegister( '70', '3'); %DACvoltage
                        if ~error4, break; end
                    end
                    if error4
                        DACvoltage = nan;
                    end
                    q = quantizer([32 0]);
                    DACvoltage = hex2num(q,DACvoltage)*(10/2^32);%/1e-3;
                    if length(DACvoltage) ~= 1, DACvoltage = nan; end
                    
                    outlierRemoved = nan;
                    averagerOut = nan;
                    
                end
                
                if obj.logData && ~obj.isLogging
                    obj.isLogging = 1;
                    %update command_monitor
                    str_now = datestr(now,31);
                    eval(sprintf('cmMonObj.update(''Data logging for GPSDO%i started: %s'');',obj.gpsdoNr,str_now));
                    %open log file
                    tmp = datestr(now,'yyyy-mm-dd_HH-MM-SS');
                    obj.fname = ['./Log_Files/gpsdoData' num2str(obj.gpsdoNr) '_' tmp '.bin'];
                    obj.logFid = fopen(obj.fname,'a');
                    eval(sprintf('cmMonObj.update(''Writing data to file: %s'');',obj.fname));
                elseif ~obj.logData && obj.isLogging
                    obj.isLogging = 0;
                    fclose(obj.logFid);
                    str_now = datestr(now,31);
                    eval(sprintf('cmMonObj.update(''Data logging for GPSDO%i stopped: %s'');',obj.gpsdoNr,str_now));
                    eval(sprintf('cmMonObj.update(''Closing binary file: %s'');',obj.fname));
                elseif obj.isLogging && obj.isLogging
                    %date = now;
                    fwrite(obj.logFid,[date PDcenter PDerror sawtoothErr sawtoothCorr outlierRemoved averagerOut DACvoltage],'double');
                end
                
                % update plot arrays
                obj.plot60dataPDerror = [obj.plot60dataPDerror(2:60) PDerror];
                obj.plot3600dataPDerror = [obj.plot3600dataPDerror(2:3600) PDerror];
                obj.plot86400dataPDerror  = [obj.plot86400dataPDerror(2:86400) PDerror];
                
                obj.plot60dataPDcenter  = [obj.plot60dataPDcenter(2:60) PDcenter];
                obj.plot3600dataPDcenter = [obj.plot3600dataPDcenter(2:3600) PDcenter];
                obj.plot86400dataPDcenter  = [obj.plot86400dataPDcenter(2:86400) PDcenter];
                
                obj.plot60dataSawtoothErr  = [obj.plot60dataSawtoothErr(2:60) sawtoothErr];
                obj.plot3600dataSawtoothErr = [obj.plot3600dataSawtoothErr(2:3600) sawtoothErr];
                obj.plot86400dataSawtoothErr  = [obj.plot86400dataSawtoothErr(2:86400) sawtoothErr];
                
                obj.plot60dataSawtoothCorr  = [obj.plot60dataSawtoothCorr(2:60) sawtoothCorr];
                obj.plot3600dataSawtoothCorr = [obj.plot3600dataSawtoothCorr(2:3600) sawtoothCorr];
                obj.plot86400dataSawtoothCorr  = [obj.plot86400dataSawtoothCorr(2:86400) sawtoothCorr];
                
                obj.plot60dataOutlierRemoved  = [obj.plot60dataOutlierRemoved(2:60) outlierRemoved];
                obj.plot3600dataOutlierRemoved = [obj.plot3600dataOutlierRemoved(2:3600) outlierRemoved];
                obj.plot86400dataOutlierRemoved  = [obj.plot86400dataOutlierRemoved(2:86400) outlierRemoved];
                
                obj.plot60dataAveragerOut  = [obj.plot60dataAveragerOut(2:60) averagerOut];
                obj.plot3600dataAveragerOut = [obj.plot3600dataAveragerOut(2:3600) averagerOut];
                obj.plot86400dataAveragerOut  = [obj.plot86400dataAveragerOut(2:86400) averagerOut];
                
                obj.plot60dataDACvoltage  = [obj.plot60dataDACvoltage(2:60) DACvoltage];
                obj.plot3600dataDACvoltage = [obj.plot3600dataDACvoltage(2:3600) DACvoltage];
                obj.plot86400dataDACvoltage  = [obj.plot86400dataDACvoltage(2:86400) DACvoltage];
                
                if obj.plotDataSelected
                    if obj.plotPDerror
                        guiObj.data60(1:60) = obj.plot60dataPDerror(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataPDerror(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataPDerror(1:86400);
                    elseif obj.plotPDcenter
                        guiObj.data60(1:60) = obj.plot60dataPDcenter(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataPDcenter(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataPDcenter(1:86400);
                    elseif obj.plotSawtoothErr
                        guiObj.data60(1:60) = obj.plot60dataSawtoothErr(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataSawtoothErr(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataSawtoothErr(1:86400);
                    elseif obj.plotSawtoothCorr
                        guiObj.data60(1:60) = obj.plot60dataSawtoothCorr(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataSawtoothCorr(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataSawtoothCorr(1:86400);
                    elseif obj.plotOutlierRemoved
                        guiObj.data60(1:60) = obj.plot60dataOutlierRemoved(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataOutlierRemoved(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataOutlierRemoved(1:86400);    
                    elseif obj.plotAveragerOut
                        guiObj.data60(1:60) = obj.plot60dataAveragerOut(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataAveragerOut(1:3600);
                        guiObj.data86400(1:86400) = obj.plot86400dataAveragerOut(1:86400);    
                    elseif obj.plotDACVoltage
                        guiObj.data60(1:60) = obj.plot60dataDACvoltage(1:60);
                        guiObj.data3600(1:3600) = obj.plot3600dataDACvoltage(1:3600);
                        guiObj.data86400(1:86400)= obj.plot86400dataDACvoltage(1:86400);
                    end
                end
            end
        end
        
        function [obj, cmMonObj] = armGPSDO(obj,cmMonObj,time)
            if obj.connected
                %read & update rtc_alarm register
                [errors] = setBit(obj.serialObj,'36','04');
                
                    %write rtc_alarm
                    rtc_alarm_vec = datevec(time);
                    rtc_alarm_sec = dec2hex(rtc_alarm_vec(6),2);
                    rtc_alarm_min = dec2hex(rtc_alarm_vec(5),2);
                    rtc_alarm_hr  = dec2hex(rtc_alarm_vec(4),2);
                    %write rtc_register
                    data = [rtc_alarm_hr rtc_alarm_min rtc_alarm_sec];
                    [~, ~, ~, ~, ~, errors] = obj.serialObj.writeRegister('33','2', data);
                    [errors1] = setBit(obj.serialObj,'36','04');
                    errors = errors || errors1;
                    if ~errors
                        %set rtc_register update bit
                        [~, ~, ~, ~, ~, errors1] = obj.serialObj.writeRegister('06','1','0502');
                        [~, ~, ~, ~, data, errors2] = obj.serialObj.readRegister('36','0');
                        tmp = obj.hex2bin(data);
                        if (~(errors1 || errors2) && tmp(end-2))
                            obj.wasArmed = 1;
                            obj.armed = 1;
                            obj.armTime = datenum(time);
                            cmMonObj.update(['GPSDO' int2str(obj.gpsdoNr) ' armed for ' time]);
                        else
                            cmMonObj.update(['Error: Failed to arm GPSDO' int2str(obj.gpsdoNr) '!']);
                        end
                    end
                elseif errors
                    cmMonObj.update(['Error: Failed to arm GPSDO' int2str(obj.gpsdoNr) '!']);
                end
            end
        
        function [obj cmMonObj] = uploadData(obj,cmMonObj,instructions)
            if obj.connected 
                obj.serialObj.loadInstructionSet(cmMonObj,instructions); 
            end
        end
        
        function [obj guiObj cmMonObj] = isGPSDOarmed(obj, cmMonObj)
            [~, ~, ~, ~, rtc_reg,~]  = obj.serialObj.readRegister( '36', '0');
            rtc_reg = hex2bin(rtc_reg);
            
            armed_now = str2double(rtc_reg(end-2));
            
            if obj.armed && ~armed_now
                obj.armed = 0; 
                obj.atCon = 0;
                %cmMonObj.update(['GPSDO' int2str(obj.gpsdoNr) ' fired at ' datestr(obj.armTime,13)]);
            end
        end
        
        function [obj cmMonObj] = syncTime(obj, cmMonObj)
            [~,~,~,~,data30_36,errors1] = obj.serialObj.readRegister('30','2');
            [~,~,~,~,data81_84,errors2] = obj.serialObj.readRegister('81','3');
            if ~(errors1 || errors2)
                hr = int2str(hex2dec(data30_36(1:2))); %hr
                min = int2str(hex2dec(data30_36(3:4))); %min
                sec = int2str(hex2dec(data30_36(5:6))); %sec
                if length(hr) == 1, hr = ['0' hr]; end
                if length(min) == 1, min = ['0' min]; end
                if length(sec) == 1, sec = ['0' sec]; end
                obj.rtc_time = [hr ':' min ':' sec];
                
                m = int2str(hex2dec(data81_84(1)));
                d = int2str(hex2dec(data81_84(2)));
                y = int2str(hex2dec(data81_84(4)));
                if length(m) == 1, m = ['0' m]; end
                if length(d) == 1, d = ['0' d]; end
                if length(y) == 1, y = ['0' y]; end
                obj.gps_date = [y '/' m '/' d];
                
                eval(sprintf('system(''time %s'');',obj.rtc_time));
                %eval(sprintf('system(''date %s'');',obj.gps_date));
                
                cmMonObj.update(['System time synced with GPSDO' int2str(obj.gpsdoNr)]);
            else
                cmMonObj.update(['Error: System time could not be synced to GPSDO' int2str(obj.gpsdoNr)]);
            end
        end
        function [obj guiObj cmMonObj] = toggle_en_output_pps(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.output_pps
                    [errors1] = clearBit(obj.serialObj,'36','EF');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.output_pps = 0;
                        cmMonObj.update(['Cleared output_pps in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.output_pps = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'36','10');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.output_pps = 1;
                        cmMonObj.update(['Set output_pps in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.output_pps = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_en_gps_update(obj, guiObj,cmMonObj)
            if obj.connected
                if obj.en_gps_update
                    [errors1] = clearBit(obj.serialObj,'36','F7');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.en_gps_update = 0;
                        cmMonObj.update(['Cleared en_gps_update in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.en_gps_update = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'36','08');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.en_gps_update = 1;
                        cmMonObj.update(['Set en_gps_update in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.en_gps_update = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_ref_sel(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.ref_sel
                    [errors1] = clearBit(obj.serialObj,'36','FD');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.ref_sel = 0;
                        cmMonObj.update(['Cleared ref_sel in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.ref_sel = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'36','02');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('06','1', '0102');
                    if ~(errors1 || errors2)
                        obj.ref_sel = 1;
                        cmMonObj.update(['Set ref_sel in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.ref_sel = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_open_loop(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.open_loop
                    [errors1] = clearBit(obj.serialObj,'75','FE');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.open_loop = 0;
                        cmMonObj.update(['Cleared open_loop in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.open_loop = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'75','01');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.open_loop = 1;
                        cmMonObj.update(['Set open_loop in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.open_loop = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_sawtooth_en(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sawtooth_en
                    [errors1] = clearBit(obj.serialObj,'75','FD');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.sawtooth_en = 0;
                        cmMonObj.update(['Cleared sawtooth_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.sawtooth_en = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'75','02');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.sawtooth_en = 1;
                        cmMonObj.update(['Set sawtooth_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.sawtooth_en = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_lfilter_en(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.lfilter_en
                    [errors1] = clearBit(obj.serialObj,'75','BF');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.lfilter_en = 0;
                        cmMonObj.update(['Cleared lfilter_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.lfilter_en = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'75','40');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.lfilter_en = 1;
                        cmMonObj.update(['Set lfilter_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.lfilter_en = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        function [obj guiObj cmMonObj] = toggle_filter_update_en(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.filter_update_en
                    [errors1] = clearBit(obj.serialObj,'75','7F');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.filter_update_en = 0;
                        cmMonObj.update(['Cleared filter_update_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.filter_update_en = 1;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                else
                    [errors1] = setBit(obj.serialObj,'75','80');
                    [~, ~, ~, ~, ~, errors2] = obj.serialObj.writeRegister('04','3', '01000010');
                    if ~(errors1 || errors2)
                        obj.filter_update_en = 1;
                        cmMonObj.update(['Set filter_update_en in GPSDO' int2str(obj.gpsdoNr)]);
                    else
                        obj.filter_update_en = 0;
                        [obj, guiObj] = setParamPanelItems(obj,guiObj);
                    end
                end
            end
        end
        
        function [obj guiObj cmMonObj] = toggle_enableSDF(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sdfObj.sdf_en %turn SDF off
                    obj.sdfObj.sdf_en = 0;
                    obj.en_checkbox_outlierRemoval = 'off';
                    obj.en_checkbox_sawtoothCorrect = 'off';
                    obj.en_checkbox_movingAverager = 'off';
                    obj.en_checkbox_loopFilter = 'off';
                    set(guiObj.checkbox_outlierRemoval,'Enable',obj.en_checkbox_outlierRemoval);
                    set(guiObj.checkbox_sawtoothCorrect,'Enable',obj.en_checkbox_sawtoothCorrect);
                    set(guiObj.checkbox_movingAverager,'Enable',obj.en_checkbox_movingAverager);
                    set(guiObj.checkbox_loopFilter,'Enable',obj.en_checkbox_loopFilter);
                                        
                    %turn off internal filter
                    cmMonObj.update(['Software defined PLL filter de-activated (GPSDO' int2str(obj.gpsdoNr) ').']);
                    %obj.toggle_open_loop(guiObj,cmMonObj);
                    %obj.toggle_filter_update_en(guiObj,cmMonObj);
                    eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''ForegroundColor'',''black'');',obj.gpsdoNr));
                else 
                    obj.sdfObj.sdf_en = 1; %turn SDF on
                    obj.en_checkbox_outlierRemoval = 'on';
                    obj.en_checkbox_sawtoothCorrect = 'on';
                    obj.en_checkbox_movingAverager = 'on';
                    obj.en_checkbox_loopFilter = 'on';
                    set(guiObj.checkbox_outlierRemoval,'Enable',obj.en_checkbox_outlierRemoval);
                    set(guiObj.checkbox_sawtoothCorrect,'Enable',obj.en_checkbox_sawtoothCorrect);
                    set(guiObj.checkbox_movingAverager,'Enable',obj.en_checkbox_movingAverager);
                    set(guiObj.checkbox_loopFilter,'Enable',obj.en_checkbox_loopFilter);
                                        
                    %turn on internal filter
                    cmMonObj.update(['Software defined PLL filter activated (GPSDO' int2str(obj.gpsdoNr) ').']);
                    %obj.toggle_open_loop(guiObj,cmMonObj);
                    %obj.toggle_filter_update_en(guiObj,cmMonObj);
                    eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''ForegroundColor'',''red'');',obj.gpsdoNr));
                end
            end
        end
        
        function [obj guiObj cmMonObj] = toggle_SDFoutlierRemoval(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sdfObj.outlier_en
                    obj.sdfObj.outlier_en = 0;
                    cmMonObj.update(['SDF Outlier Removal: Off (GPSDO' int2str(obj.gpsdoNr) ').']);
                else
                    obj.sdfObj.outlier_en = 1;
                    cmMonObj.update(['SDF Outlier Removal: On (GPSDO' int2str(obj.gpsdoNr) ').']);
                end
                set(guiObj.checkbox_outlierRemoval,'Value',obj.sdfObj.outlier_en);
            end
        end
        function [obj guiObj cmMonObj] = toggle_SDFsawtoothCorrect(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sdfObj.sawtooth_en
                    obj.sdfObj.sawtooth_en = 0;
                    cmMonObj.update(['SDF Sawtooth Correction: Off (GPSDO' int2str(obj.gpsdoNr) ').']);
                else
                    obj.sdfObj.sawtooth_en = 1;
                    cmMonObj.update(['SDF Sawtooth Correction: On (GPSDO' int2str(obj.gpsdoNr) ').']); 
                end
                set(guiObj.checkbox_sawtoothCorrect,'Value',obj.sdfObj.sawtooth_en);
            end
        end
        function [obj guiObj cmMonObj] = toggle_SDFaveraging(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sdfObj.averager_en
                    obj.sdfObj.averager_en = 0;
                    cmMonObj.update(['SDF Moving Averager: Off (GPSDO' int2str(obj.gpsdoNr) ').']);
                else
                    obj.sdfObj.averager_en = 1;
                    cmMonObj.update(['SDF Moving Averager: On (GPSDO' int2str(obj.gpsdoNr) ').']);
                end
                set(guiObj.checkbox_movingAverager,'Value',obj.sdfObj.averager_en);
            end
        end
        function [obj guiObj cmMonObj] = toggle_SDFloopFilter(obj,guiObj,cmMonObj)
            if obj.connected
                if obj.sdfObj.filter_en
                    obj.sdfObj.filter_en = 0;
                    cmMonObj.update(['SDF 2nd Order IIR Filter: Off (GPSDO' int2str(obj.gpsdoNr) ').']);
                else
                    obj.sdfObj.filter_en = 1;
                    cmMonObj.update(['SDF 2nd Order IIR Filter: On (GPSDO' int2str(obj.gpsdoNr) ').']); 
                end
                set(guiObj.checkbox_loopFilter,'Value',obj.sdfObj.filter_en);
            end
        end
    end
    
    methods (Access = private)
        function [obj guiObj] = enableGuiItems(obj, guiObj)
            eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''Enable'',''on'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.gpsdo%i_uploadSelect,''Enable'',''on'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.gpsdo%i_comSelect,''Enable'',''off'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.radiobutton_plotGPSDO%i,''Enable'',''on'');',obj.gpsdoNr));
        end
        function [obj guiObj] = disableGuiItems(obj, guiObj)
            eval(sprintf('set(guiObj.gpsdo%i_paramSelect,''Enable'',''off'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.gpsdo%i_uploadSelect,''Enable'',''off'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.gpsdo%i_comSelect,''Enable'',''on'');',obj.gpsdoNr));
            eval(sprintf('set(guiObj.radiobutton_plotGPSDO%i,''Enable'',''off'');',obj.gpsdoNr));
        end
        function [obj guiObj cmMonObj errors1] = getRegisters(obj,guiObj, cmMonObj)
            %id & status reg
            [~,~,~,~,data08_0A,errors] = obj.serialObj.readRegister('08','2');
            
            if ~errors
                obj.gpsdoID = hex2dec(data08_0A(1:2));
                data09 = hex2bin(data08_0A(3:4));
                data0A = hex2bin(data08_0A(5:6));
                
                obj.open_loop = str2double(data09(end));
                obj.sawtooth_en = str2double(data09(end-1));
                obj.outlier_en = str2double(data09(end-2));
                obj.mean_mode = str2double(data09(end-3));
                obj.mean_en = str2double(data09(end-4));
                obj.limiter_en = str2double(data09(end-5));
                obj.lfilter_en = str2double(data09(end-6));
                obj.filter_update_en = str2double(data09(end-7));
                
                obj.tic_timeout = str2double(data0A(end));
                obj.ref_sel = str2double(data0A(end-1));
                obj.rtc_alarm_set = str2double(data0A(end-2));
                obj.armed = str2double(data0A(end-2));
                obj.en_gps_update = str2double(data0A(end-3));
                obj.output_pps = str2double(data0A(end-4));
                obj.pll_lock = str2double(data0A(end-5));
            end
            errors1 = errors;
            %psu_reg
            [~,~,~,~,data0E,errors] = obj.serialObj.readRegister('0E','0');
            if ~errors
                data0E = hex2bin(data0E);
                obj.stdby_mode = str2double(data0E(end));
            end
            errors1 = or(errors1,errors);
            %rtc
            [~,~,~,~,data30_36,errors] = obj.serialObj.readRegister('30','5');
            if ~errors
                hr = int2str(hex2dec(data30_36(1:2))); %hr
                min = int2str(hex2dec(data30_36(3:4))); %min
                sec = int2str(hex2dec(data30_36(5:6))); %sec
                if length(hr) == 1, hr = ['0' hr]; end;
                if length(min) == 1, min = ['0' min]; end;
                if length(sec) == 1, sec = ['0' sec]; end;
                obj.rtc_time = [hr ':' min ':' sec];
                
                %rtc_alarm (get the current value in the rtc_alarm reg)
                hr = int2str(hex2dec(data30_36(7:8))); %hr
                min = int2str(hex2dec(data30_36(9:10))); %min
                sec = int2str(hex2dec(data30_36(11:12))); %sec
                if length(hr) == 1, hr = ['0' hr]; end;
                if length(min) == 1, min = ['0' min]; end;
                if length(sec) == 1, sec = ['0' sec]; end;
                obj.armTime = [hr ':' min ':' sec];
            end
            errors1 = or(errors1,errors);
            %phase offset & drift comp
            [~,~,~,~,data3C_43,errors] = obj.serialObj.readRegister('3C','7');
            if ~errors
                obj.timeOffset = int2str(hex2dec(data3C_43(7:12)));
                obj.driftComp = int2str(hex2dec(data3C_43(7:12)));
            end
            errors1 = or(errors1,errors);
            %mean_samples
            [~,~,~,~,data4E_4F,errors] = obj.serialObj.readRegister('4E','1');
            if ~errors
                obj.samplesAvg = int2str(hex2dec(data4E_4F));
            end
            errors1 = or(errors1,errors);
            %filter_reg1 (tau - informative only)
            [~,~,~,~,data74,errors] = obj.serialObj.readRegister('74','0');
            if ~errors
                obj.pllTau = int2str(hex2dec(data74));
            end
            errors1 = or(errors1,errors);
            %gps date
            [~,~,~,~,data81_84,errors] = obj.serialObj.readRegister('81','3');
            if ~errors
                m = int2str(hex2dec(data81_84(1)));
                d = int2str(hex2dec(data81_84(2)));
                y = int2str(hex2dec(data81_84(4)));
                if length(m) == 1, m = ['0' m]; end;
                if length(d) == 1, d = ['0' d]; end;
                if length(y) == 1, y = ['0' y]; end;
                obj.gps_date = [y '-' m '-' d];
            end
            errors1 = or(errors1,errors);
            %gps_status
            %[~,~,~,~,data96_97,errors] = obj.serialObj.readRegister('96','1');
            %errors1 = or(errors1,errors);
            %gps register
            [~,~,~,~,dataAE,errors] = obj.serialObj.readRegister('AE','0');
            if ~errors
                dataAE = hex2bin(dataAE);
                obj.survey_mode = str2double(data0A(end-6));
                obj.gps_pof = str2double(data0A(end-7));
                obj.pos_hold_mode = str2double(dataAE(end-1));
            end
            errors1 = or(errors1,errors);
            if errors1, cmMonObj.update(sprintf('Failed to read some GPSDO%i registers.',obj.gpsdoNr)); end
        end
        function [obj, guiObj] = enableParamPanelItems(obj,guiObj)
            set(guiObj.checkbox_open_loop,'Enable',obj.en_open_loop);
            set(guiObj.checkbox_sawtooth_en,'Enable',obj.en_sawtooth_en);
            set(guiObj.checkbox_outlier_en,'Enable',obj.en_outlier_en);
            set(guiObj.checkbox_mean_mode,'Enable',obj.en_mean_mode);
            set(guiObj.checkbox_mean_en,'Enable',obj.en_mean_en);
            set(guiObj.checkbox_limiter_en,'Enable',obj.en_limiter_en);
            set(guiObj.checkbox_lfilter_en,'Enable',obj.en_lfilter_en);
            set(guiObj.checkbox_filter_update_en,'Enable',obj.en_filter_update_en);
            set(guiObj.checkbox_tic_timeout,'Enable',obj.en_tic_timeout);
            set(guiObj.checkbox_ref_sel,'Enable',obj.en_ref_sel);
            set(guiObj.checkbox_rtc_alarm_set,'Enable',obj.en_rtc_alarm_set);
            set(guiObj.checkbox_en_gps_update,'Enable',obj.en_en_gps_update);
            set(guiObj.checkbox_pps,'Enable',obj.en_output_pps);
            set(guiObj.edit_armTime,'Enable','on');
            set(guiObj.edit_phase_offset,'Enable',obj.en_timeOffset);
            set(guiObj.edit_drift_comp,'Enable',obj.en_driftComp);
            set(guiObj.edit_mean_samples,'Enable',obj.en_samplesAvg);
            set(guiObj.edit_pll_tau,'Enable',obj.en_pllTau);
            set(guiObj.checkbox_stdby_mode,'Enable',obj.en_stdby_mode);
            set(guiObj.checkbox_survey_mode,'Enable',obj.en_survey_mode);
            set(guiObj.checkbox_gps_pof,'Enable',obj.en_gps_pof);
            set(guiObj.checkbox_pos_hold_mode,'Enable',obj.en_pos_hold_mode);
            set(guiObj.checkbox_enableSDF,'Enable',obj.en_checkbox_enableSDF);
            set(guiObj.checkbox_outlierRemoval,'Enable',obj.en_checkbox_outlierRemoval);
            set(guiObj.checkbox_sawtoothCorrect,'Enable',obj.en_checkbox_sawtoothCorrect);
            set(guiObj.checkbox_movingAverager,'Enable',obj.en_checkbox_movingAverager);
            set(guiObj.checkbox_loopFilter,'Enable',obj.en_checkbox_loopFilter);
        end
        function [obj, guiObj] = setParamPanelItems(obj,guiObj)
            eval(sprintf('set(guiObj.text_gpsdo%iID,''String'',int2str(obj.gpsdoID));',obj.gpsdoNr));
            set(guiObj.checkbox_open_loop,'Value',obj.open_loop);
            set(guiObj.checkbox_sawtooth_en,'Value',obj.sawtooth_en);
            set(guiObj.checkbox_outlier_en,'Value',obj.outlier_en);
            set(guiObj.checkbox_mean_mode,'Value',obj.mean_mode);
            set(guiObj.checkbox_mean_en,'Value',obj.mean_en);
            set(guiObj.checkbox_limiter_en,'Value',obj.limiter_en);
            set(guiObj.checkbox_lfilter_en,'Value',obj.lfilter_en);
            set(guiObj.checkbox_filter_update_en,'Value',obj.filter_update_en);
            set(guiObj.checkbox_tic_timeout,'Value',obj.tic_timeout);
            set(guiObj.checkbox_ref_sel,'Value',obj.tic_timeout);
            set(guiObj.checkbox_rtc_alarm_set,'Value',obj.rtc_alarm_set);
            set(guiObj.checkbox_en_gps_update,'Value',obj.en_gps_update);
            set(guiObj.checkbox_pps,'Value',obj.output_pps);
            set(guiObj.edit_armTime,'String',obj.armTime);
            set(guiObj.edit_phase_offset,'String',obj.timeOffset);
            set(guiObj.edit_drift_comp,'String',obj.driftComp);
            set(guiObj.edit_mean_samples,'String',obj.samplesAvg);
            set(guiObj.edit_pll_tau,'String',obj.pllTau);
            set(guiObj.checkbox_stdby_mode,'Value',obj.stdby_mode);
            set(guiObj.checkbox_survey_mode,'Value',obj.survey_mode);
            set(guiObj.checkbox_gps_pof,'Value',obj.gps_pof);
            set(guiObj.checkbox_pos_hold_mode,'Value',obj.pos_hold_mode);
            eval(sprintf('system(''time %s'');',obj.rtc_time));
            %eval(sprintf('system(''date %s'');',obj.gps_date));
            
            set(guiObj.checkbox_enableSDF,'Value',obj.sdfObj.sdf_en);
            set(guiObj.checkbox_outlierRemoval,'Value',obj.sdfObj.outlier_en);
            set(guiObj.checkbox_sawtoothCorrect,'Value',obj.sdfObj.sawtooth_en);
            set(guiObj.checkbox_movingAverager,'Value',obj.sdfObj.averager_en);
            set(guiObj.checkbox_loopFilter,'Value',obj.sdfObj.filter_en);
            
        end
    end
    
    methods (Static)
        function bin = hex2bin(hex)
            dec = hex2dec(hex);
            bin = dec2bin(dec,8);
        end
        
    end
end

