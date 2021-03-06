classdef gps<handle
    
    properties
        number    
        cmMonObj
        
        %Serial
        comPort
        con_error
        ser
        connected
        %Long status message
        time
        date
        
        lat
        long
        coords
        height
        pos_hold_lat
        pos_hold_long
        pos_hold_alt
        pos_latread
        pos_longread
        mode
        
        latread
        longread
        
        satTracked
        satVisible
        
        %Misc
        maskAngle
        inSurvey
        inPosition
        cable_delay
        
        waiting
    end
    
    methods
        % Create GPS Object
        function [Obj, cmMonObj] = gps(number, comPort, cmMonObj)
            Obj.number = number;
            Obj.comPort = comPort;
            Obj.connected = 0; 
            Obj.waiting = 0;
            Obj.pos_hold_config();
            
        end
        
        function [raw,char_array,errors] = read_GPS_serial_port(Obj,cmMonObj)
        %function [raw, cmd, data, errors] = read_GPS_serial_port(Obj,cmMonObj)
            % this function reads the serial port buffer and parses the read data
            % if no bytes are available an error is return -1
            % if the data is not a valid cmd string an error is return -1
            % data is returned as hexadecimal strings
            
                        
            if Obj.ser.BytesAvailable > 0
                errors = 0;
                x = fread(Obj.ser,Obj.ser.BytesAvailable);
                i = 1:length(x);
                dat = dec2hex(x(i));
                str = '';
                [m, ~] = size(dat);
                if m > 1
                    for k = 1:length(dat)
                        str = [str dat(k,1:end)];
                    end
                end
                raw = str;
                
                column = 0;
                row = 0;
                for n=4:(length(str)-3)
    
                   if (strncmp(str(n:n+3), '4040',4))
                        row = row + 1;
                        column = 0;
                   end

                   if row > 0
                        column = column + 1; 
                        char_array(row,column) = str(n);  
                   end
                end;
    
                %Discard last string incase of incomplete string
            
                char_array = char_array((1:row-1),(1:end));
                
                
            else
                errors = 1;
                cmMonObj.update('No Bytes Available');
            end
            
        end
        
       
         
        
        function write_GPS_serial_port(Obj,raw)
            i = 1:2:length(raw);
            q = 2:2:length(raw);
            raw1 = [raw(i)' raw(q)'];
            if Obj.ser.BytesAvailable > 1
                fread(Obj.ser,Obj.ser.BytesAvailable);
            end
            fwrite(Obj.ser,hex2dec(raw1(:,:)));
        end
        
        function [cmd, data, errors] = write_command(Obj, cmMonObj, cmd, data)
            % this function writes a write command to the GPSDO
            % it then reads the confirmation from the GPSDO to ensure cmd is sent
            % error is 0 if sent success or 1 if sent fail
            
            %send write instruction to serial port
            raw = Obj.get_serial_parity(['4040' cmd data '0D0A']);
            cmMonObj.update([sprintf('HEX Written to GPS: %s', raw)]);
            errors = 1;
            
            % retry 8x times
            %for i = 1:2
            flushinput(Obj.ser);
            Obj.write_GPS_serial_port(raw);
    
        end
        %======================================================================
        %--------------GPS COMMANDS-------------------------------------
        function patience(Obj)
              for n=1:1000
                  if Obj.waiting == 1
                      pause(0.005);
                  else
                      break;
                  end
              end
        end
        
        function [data,errors] = read_command(Obj,cmMonObj,cmd)
            
%             if Obj.waiting 
%                 Obj.patience();
%             end
%             
            Obj.waiting = 1;
%                            
            errors = 0;
            
            for i = 1:100
                if Obj.ser.BytesAvailable < 100
                    pause(0.005);
                else
                    break;
                end
            end
            
            [~,char_array,errors] = read_GPS_serial_port(Obj,cmMonObj);
            if ~errors 
                %cmMonObj.update(char_array(1,:));
                %cmd;
                [m,~] = size(char_array);
                for i = 1:m
                    if strcmp(char_array(i,5:8), cmd)
                        str = strcat(char_array(i,:));
                        errors = 0;
                        break;
                    else
                        errors = 1;
                    end
                end

                if ~errors
                        %[cmd, data, errors] = parse_raw_gps_comms_string(str);
                    if length(str) <= 15
                        cmd = nan;
                        data = nan;
                        errors = 1;
                        return;
                    else
                        errors = 0;
                        header = str(1:4);
                        cmd = str(5:8);
                        data = str(9:end-6);
                        chksum = str(end-5:end-4);
                        footer = str(end-3:end);
                        tmp = NaN;
                        chksum_str = [cmd data];
                    end

                        if (strncmp(header, '4040', 3)) && (strncmp(footer,'0D0A',3)) %does command header/footer exist
                            if length(chksum_str) >= 4 % data must contain at least one char plus a parity cahr
                                tmp = bitxor(hex2dec(chksum_str(1:2)),hex2dec(chksum_str(3:4))); % check data parity
                                for i = 6:2:length(chksum_str)
                                    tmp = bitxor(hex2dec(chksum_str(i-1:i)),tmp);
                                end
                                tmp2 = hex2dec(chksum);

                                if tmp ~= tmp2
                                    cmMonObj.update('Checksum Mismatch')
                                    cmd = nan;
                                    data = nan;
                                    errors = 1;
                                end
                            end
                        else

                            cmd = nan;
                            data = nan;
                            errors = 1;
                        end
                      



                else
                    errors = 1;
                    cmMonObj.update('Failed to read command!')
                    cmd = NaN;
                    data = NaN;

                end

  
            else
                errors = 1;
                %cmMonObj.update('Serial port read error!')

            end
                 
            Obj.waiting = 0;
            
        end
        function query_pos_mode(Obj,cmMonObj)
            Obj.write_command(cmMonObj,'4764','FF');
            pause(4);
            [data,~] = Obj.read_command(cmMonObj,'4764');
     
            if strcmp(data,'01')
                %cmMonObj.update('In Position Hold Mode');
                Obj.inPosition = 1;
                Obj.inSurvey = 0;
                Obj.mode = 'Position Hold';
            
            elseif strcmp(data,'03')
                %cmMonObj.update('Busy Surveying');
                Obj.inSurvey = 1;
                Obj.inPosition = 0;
                Obj.mode = 'Survey Mode';
            else
                cmMonObj.update('Buffer Read Issue. Toggle GPS Connect Button.');
            end          
        end
        
        function position_message(Obj,cmMonObj)
    
            
            [data,errors] = Obj.read_command(cmMonObj,'4861');
            %Time 
            full_time = data(1:22);
            month = hex2dec(full_time(1:2));
            day = hex2dec(full_time(3:4));
            year = hex2dec(full_time(5:8));
            hour = hex2dec(full_time(9:10));
            minute = hex2dec(full_time(11:12));
            second = hex2dec(full_time(13:14));
            fractional = hex2dec(full_time(15:end));
            Obj.date = strcat(num2str(day),'/',num2str(month),'/',num2str(year));
            Obj.time = strcat(num2str(hour),':',num2str(minute),':',num2str(second),':',num2str(fractional));
            
            %Coordinates
            full_coord = data(23:54);            
            Obj.lat = hex2dec(full_coord(1:8));
            Obj.long = hex2dec(full_coord(9:16));
            x = Obj.lat - (Obj.lat >= 2.^(32-1)).*2.^32;    
            y = Obj.long - (Obj.long >= 2.^(32-1)).*2.^32;
            Obj.latread = x*(90/324e6);
            Obj.longread = y*(90/324e6);
            Obj.height = hex2dec(full_coord(17:24));
            Obj.coords = [Obj.lat Obj.long];
            
            %Satellites
            Obj.satVisible = hex2dec(data(103:104));
            Obj.satTracked = hex2dec(data(105:106));

        end 
        
        function initialise_gps(Obj,cmMonObj)
            Obj.write_command(cmMonObj,'4167','FF');
        end
        
        function query_mask(Obj,cmMonObj)
            Obj.write_command(cmMonObj,'4167','FF');
            pause(4);
            [data,errors] = Obj.read_command(cmMonObj,'4167');
            if ~errors
                angle = hex2dec(data);
                cmMonObj.update([sprintf('Mask Angle: %i degrees', angle)]);
                Obj.maskAngle = angle;
            else
                cmMonObj.update('Unable to read mask angle');
            end
        end
        
        
    function [cmd, data, errors] = parse_raw_gps_comms_string(raw)
            %this function does a parity check and parse the gpsdo data string into cmd
            %addr and data
            
        if length(raw) <= 15
            cmd = nan;
            data = nan;
            errors = 1;
            return;
        else
            errors = 0;
            header = raw(1:4);
            cmd = raw(5:8);
            data = raw(9:end-6);
            chksum = raw(end-5:end-4);
            footer = raw(end-3:end);
            tmp = NaN;
            chksum_str = [cmd data];
        end
            
        if (strncmp(header, '4040', 3)) && (strncmp(footer,'0D0A',3)) %does command header/footer exist
                if length(chksum_str) >= 4 % data must contain at least one char plus a parity cahr
                    tmp = bitxor(hex2dec(chksum_str(1:2)),hex2dec(chksum_str(3:4))); % check data parity
                    for i = 6:2:length(chksum_str)
                        tmp = bitxor(hex2dec(chksum_str(i-1:i)),tmp);
                    end
                    tmp2 = hex2dec(chksum);
                    
                    if tmp ~= tmp2
                        cmd = nan;
                        data = nan;
                        errors = 1;
                    end
                end
            else
                cmd = nan;
                data = nan;
                errors = 1;
        end
            
    end
    function char_array = hex2ascii(hex_string)
        char_array = '';
        for i = 2:2:length(hex_string);
           char_array = [char_array char(hex2dec(hex_string(i-1:i)))];
       end
        
    end

    function [cmd, data, errors] = scan_for_cmd(char_array,cmd)
            errors = 0;
            [m,~] = size(char_array);
            for i = 1:m
                if char_array(i,5:8) == cmd
                    str = strcat(char_array(i,:));
                    [cmd, data, errors] = parse_raw_gps_comms_string(str);
                else
                    cmd = NaN;
                    data = NaN;
                    errors = 1;
                end
            end
    end
        
        function connect(Obj, guiObj, cmMonObj)
            Obj.connectGps(cmMonObj);
            
            if ~Obj.con_error
                Obj.connected = 1;
   
            else
                Obj.connected = 0;
            end
            
        end
        function disconnect(Obj,cmMonObj)
            Obj.deletePort(cmMonObj);
            Obj.connected = 0;
        end
        
        function survey_mode(Obj,cmMonObj)

            Obj.write_command(cmMonObj,'4764','03');
            Obj.query_pos_mode(cmMonObj);
           
            
        end
        
        function [data,errors] = savePos(Obj, cmMonObj)
           
            fid = fopen('gps_info.cfg', 'w');
            
            fwrite(fid, ['# GPS INFORMATION AND CONFIG' double(sprintf('\n')) ... 
                '#=================================' double(sprintf('\n')) ...
                '# Heights are in centimetres (cm) above geoid' double(sprintf('\n')) ...
                '# Lat/Long stored as unsigned 32bit integers ' double(sprintf('\n')) ...
                '# Change to signed and multiply by 90/324e6 for Decimal degrees' double(sprintf('\n'))... 
                '#=================================' double(sprintf('\n')) ...
                '# GPS Status' (sprintf('\n')) ...
                '#=================================' double(sprintf('\n')) ...
                'DATE = ' Obj.date double(sprintf('\n')) ...
                'TIME = ' Obj.time double(sprintf('\n')) ...  
                '# Latitude: ' num2str(Obj.latread) double(sprintf('\n')) ...
                'LATITUDE = ' num2str(Obj.lat) double(sprintf('\n')) ...
                '# Longitude: ' num2str(Obj.longread) double(sprintf('\n')) ...
                'LONGITUDE = ' num2str(Obj.long) double(sprintf('\n')) ...
                'ALTITUDE = ' num2str(Obj.height) double(sprintf('\n')) ...
                '#=================================' double(sprintf('\n')) ...
                '# Position Hold Values' double(sprintf('\n')) ...
                '#=================================' double(sprintf('\n')) ...
                '# PH Latitude: ' num2str(Obj.pos_latread) double(sprintf('\n')) ...
                'POS_HOLD_LAT = ' num2str(Obj.pos_hold_lat) double(sprintf('\n')) ...
                '# PH Longitude ' num2str(Obj.pos_longread) double(sprintf('\n')) ...
                'POS_HOLD_LONG = ' num2str(Obj.pos_hold_long) double(sprintf('\n')) ...           
                'POS_HOLD_HEIGHT = ' num2str(Obj.pos_hold_alt) double(sprintf('\n')) ...
                '#=================================' double(sprintf('\n')) ...
                '# GPS Config' double(sprintf('\n')) ...
                '#=================================' double(sprintf('\n')) ...
                'CABLE_DELAY = ' num2str(Obj.cable_delay)]); 
            
            fclose(fid);
            cmMonObj.update('Position Saved');
        end
               
        function pos_hold_config(Obj)
             fid = fopen('gps_info.cfg', 'r'); 
             while 1
                tline = fgetl(fid);
                if strfind(tline, 'POS_HOLD_LAT = ')>0;
                    pos_hold_lati = tline(16:end);
                    Obj.pos_hold_lat = str2num(pos_hold_lati)
                end
                if strfind(tline, 'POS_HOLD_LONG = ')>0;
                    pos_hold_longi = tline(17:end);
                    Obj.pos_hold_long = str2num(pos_hold_longi);
                end    
                if strfind(tline, 'POS_HOLD_HEIGHT = ')>0;
                    pos_hold_alti = tline(19:end);
                    Obj.pos_hold_alt = str2num(pos_hold_alti);
                end
               
                if strfind(tline, 'CABLE_DELAY = ')>0;
                    delay = tline(15:end);
                    Obj.cable_delay = str2num(delay);
                end
                
                if ~ischar(tline)
                   break
                end
             end
            x = Obj.pos_hold_lat - (Obj.pos_hold_lat >= 2.^(32-1)).*2.^32;    
            y = Obj.pos_hold_long - (Obj.pos_hold_long >= 2.^(32-1)).*2.^32;
            Obj.pos_latread = x*(90/324e6);
            Obj.pos_longread = y*(90/324e6);
        end
        
        function applyPos(Obj, cmMonObj)
            
            fid = fopen('gps_info.cfg'); 
             while 1
                tline = fgetl(fid);
                if strfind(tline, 'LATITUDE = ')>0;
                    pos_hold_lati = tline(12:end);
                    Obj.pos_hold_lat = str2num(pos_hold_lati);

                end
                              
                if strfind(tline, 'LONGITUDE = ')>0;
                    pos_hold_longi = tline(13:end);
                    Obj.pos_hold_long = str2num(pos_hold_longi);
                end    
                 if strfind(tline, 'ALTITUDE = ')>0;
                    pos_hold_alt_temp = tline(12:end);           
                    Obj.pos_hold_alt = str2num(pos_hold_alt_temp);
                end             
                               
                if ~ischar(tline)
                   break;
                end
             end
            
            
         
            fclose(fid);
            
            Obj.savePos(cmMonObj);
            
            cmMonObj.update('Position Hold Parameters Updated');
            
            
            
            new_pos= [dec2hex(Obj.pos_hold_lat,8) dec2hex(Obj.pos_hold_long,8) dec2hex(Obj.pos_hold_alt,8) '00'];         
            Obj.write_command(cmMonObj,'4173',new_pos);
            pause(1);
            
                
            x = Obj.pos_hold_lat - (Obj.pos_hold_lat >= 2.^(32-1)).*2.^32;    
            y = Obj.pos_hold_long - (Obj.pos_hold_long >= 2.^(32-1)).*2.^32;
            cmMonObj.update([sprintf('LATITUDE : %s',num2str(x*(90/324e6)))]);
            cmMonObj.update([sprintf('LONGITUDE : %s',num2str(y*(90/324e6)))]);
            cmMonObj.update([sprintf('HEIGHT : %s m',num2str(Obj.pos_hold_alt/100))]);
            
        end
        
        function [data,errors] = savedPos(Obj, cmMonObj)
            fid = fopen('gps_info.cfg');
            while 1
                tline = fgetl(fid);
                if strfind(tline, 'POS_HOLD_LAT =')>0;
                    lat = tline(16:end);                      
                end
                if strfind(tline, 'POS_HOLD_LONG =')>0;
                    long = tline(17:end);
                end
                if strfind(tline, 'POS_HOLD_HEIGHT =')>0;
                    alt = tline(19:end);
                end
                
                if ~ischar(tline)
                   break
                end
            end
            fclose(fid);    
            cmMonObj.update(lat);
            cmMonObj.update(long);
            cmMonObj.update(alt);
        end
        
        function [data,errors] = posHold(Obj, cmMonObj)
            
           
            Obj.write_command(cmMonObj,'4764','01');
            errors = 0;
            if ~errors
                
                cmMonObj.update([sprintf('Latitude: %s',num2str(Obj.lat))]);
                cmMonObj.update([sprintf('Longitude: %s',num2str(Obj.long))]);
                Obj.query_pos_mode(cmMonObj);
            else
               cmMonObj.update('Position Hold Error!');
            end
        end
        
        function initGPS(Obj, cmMonObj)
           
            % Enter normal 3D positioning mode
            Obj.write_command(cmMonObj, '4764', '00');
            pause(1);
            % Enter position coordinates with As command (4173)
            % Coordinates from stored values in gps_info.cfg
            coordinates = [dec2hex(Obj.pos_hold_lat,8) dec2hex(Obj.pos_hold_long,8) dec2hex(Obj.pos_hold_alt,8) '00'];
            cmMonObj.update('Setting Position ...');
            Obj.write_command(cmMonObj,'4173', coordinates);
            
            pause(1);
            
            % Enter Position Hold mode
            Obj.write_command(cmMonObj, '4764', '01');
            pause(1);
            
            % Setup timing parameters with Gf, Ge, Hn (4766, 4765, 486E)
                %Gf - TRAIM alarm limit 
                %Ge - TRAIM on or off
                %Hn - TRAIM Status message
            
            cmMonObj.update('Enabling TRAIM ...'); 
            Obj.write_command(cmMonObj, '4766', '0005');
            pause(1);
            Obj.write_command(cmMonObj, '4765', '01');
            pause(1);
            Obj.write_command(cmMonObj, '486E', '01');
            pause(1);
            % Apply antenna cable delay compensation Az
            Obj.write_command(cmMonObj, '417A', dec2hex(Obj.cable_delay,8));
            pause(1);
            
            Obj.savePos(cmMonObj);
        end
        
    end
        %=====================================================================
        %---------------SERIAL COMMS------------------------------
        % Create Serial Object for Comms
        
    methods (Access = private) 
        
            
        function [Obj, cmMonObj] = connectGps(Obj, cmMonObj)
            
            Obj.con_error = 0;
            Obj.ser = serial(Obj.comPort);
            Obj.ser.Terminator = 'CR/LF';
            Obj.ser.BaudRate = 9600;
            Obj.ser.DataBits = 8;
            Obj.ser.StopBits = 1;
            Obj.ser.OutputBufferSize = 10000;
            Obj.ser.InputBufferSize = 10000;
            
            Obj.ser.ReadAsyncMode = 'continuous';
            Obj.ser.BytesAvailableFcnMode = 'terminator';
            
                        
            try
                fopen(Obj.ser);
            catch
                Obj.con_error = 1;
            end
            if Obj.con_error
                cmMonObj.update(sprintf('Error: Can''t open %s',Obj.comPort));
                Obj.deletePort(cmMonObj);
            elseif ~Obj.con_error
                Obj.connected = 1;
                cmMonObj.update(sprintf('%s serial object created.',Obj.comPort));
                flushinput(Obj.ser);
                cmMonObj.update([sprintf('GPS %i is Connected',Obj.number)]);
                pause(2);
                Obj.position_message(cmMonObj);
                              
            end
        end
        function deletePort(Obj,cmMonObj)
            fclose(Obj.ser);
            delete(Obj.ser);
            clear Obj.ser;
            cmMonObj.update(['GPS disconnected from ' Obj.comPort ': OK']);
            cmMonObj.update([Obj.comPort ' released.']);
        end
        
              
        
     
end
    %====================static functions====================
    
    methods (Static)
  

    function [raw_with_parity] = get_serial_parity(raw_without_parity)
            header = raw_without_parity(1:4);
            parity_str = raw_without_parity(5:end-4);
            footer = raw_without_parity(end-3:end);
            
            tmp = bitxor(hex2dec(parity_str(1:2)),hex2dec(parity_str(3:4))); % check data parity
            for i = 6:2:length(parity_str)
                tmp = bitxor(hex2dec(parity_str(i-1:i)),tmp);
            end
            
            parity_bit = dec2hex(tmp,2);
            raw_with_parity = [header parity_str parity_bit footer];
        end
    end
end
