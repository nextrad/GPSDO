classdef gpsdoSerialInterface<handle
    % Class help goes here
    properties
        comPort % Property help goes here
        serialObj
        gpsdoNr
        errors
    end
    methods
        function [sObj ,cmMonObj] = gpsdoSerialInterface(cmMonObj,comPort,gpsdoNr)
            % Assign properties
            sObj.comPort = comPort;
            sObj.gpsdoNr = num2str(gpsdoNr);
            sObj.errors = 0;
            % Try to create a serial port object
            sObj.create_comPort(cmMonObj);
        end
        function [raw_out, cmd, addr, nr_of_bytes, data, errors] = writeRegister(sObj, address, nr_bytes, data)
            % this function writes a write command to the GPSDO
            % it then reads the confirmation from the GPSDO to ensure cmd is sent
            % error is 0 if sent success or 1 if sent fail
            
            %send write instruction to serial port
            raw = sObj.get_serial_parity(['7E7E0' nr_bytes address data '0D0A']);
            errors = 1;
            
            % retry 8x times
            for i = 1:2
                sObj.write_GPSDO_serial_port(raw);
                %pause(0.035);
                n = 0;
                while (sObj.serialObj.BytesAvailable == 0)
                    pause(0.0005);
                    n = n +1;
                    if n >= 80
                        break;
                    end
                end
                
                [raw_out, cmd, addr, nr_of_bytes, data, errors] = sObj.read_GPSDO_serial_port();
                if ~errors && strcmp(raw,raw_out)
                    errors = 0;
                    % data is valid and matches the data that's intended to be read
                    break;
                end
            end
        end
        function [raw, cmd, addr, nr_of_bytes, data, errors] = readRegister(sObj,address,nr_bytes)
            
            raw_in = sObj.get_serial_parity(['7E7E8' nr_bytes address '0D0A']);
            raw = nan;
            cmd = nan;
            addr = nan;
            nr_of_bytes = nan;
            data  = nan;
            errors = 1;
            
            % retry 3x times
            for i = 1:2
                sObj.write_GPSDO_serial_port(raw_in);
                %pause(0.035);
                n = 0;
                while (sObj.serialObj.BytesAvailable == 0)
                    pause(0.0005);
                    n = n +1;
                    if n >= 80
                        break;
                    end
                end
                [raw, cmd, addr, nr_of_bytes, data, errors] = sObj.read_GPSDO_serial_port();
                if errors || sObj.check_serial_parity(raw)
                    % data is invalid and does not match the data that's intended to be read
                    errors = 1;
                elseif ~errors && ~sObj.check_serial_parity(raw)
                    % data is valid
                    errors = 0;
                    break;
                end
            end
           
        end
        function [sObj, cmMonObj] = loadInstructionSet(sObj,cmMonObj,instruction)
            cmMonObj.update(['Reading GPSDO' sObj.gpsdoNr ' Config File...']);
            for i = 1:length(instruction)-1
                if instruction{i}(1) == '%'  %if comment
                    cmMonObj.update(instruction{i}(2:end));
                elseif instruction{i}(1) == 'W'  %if write
                    if length(instruction{i}) < 7 %invalid instruction
                        cmMonObj.update('Error: Invalid write instruction');
                        break;
                    else
                        address = instruction{i}(3:4);
                        data = instruction{i}(6:end);
                        nr_bytes = int2str(length(data)/2-1);
                        [~, ~, ~, ~, ~, errors] = sObj.writeRegister(address, nr_bytes, data);
                        if ~errors
                            cmMonObj.update([instruction{i} ' :OK']);
                        elseif errors
                            cmMonObj.update([instruction{i} ' :FAIL']);
                        end
                        
                    end
                elseif instruction{i}(1) == 'R'  %if write
                    if length(instruction{i}) < 6 %invalid instruction
                        cmMonObj.update('Error: Invalid read instruction');
                        break;
                    else
                        address = instruction{i}(3:4);
                        nr_bytes = instruction{i}(6);
                        
                        [~, ~, ~, ~, data, errors] = sObj.readRegister(address, nr_bytes);
                        if ~errors
                            cmMonObj.update([instruction{i} ' :' data]);
                        elseif errors
                            cmMonObj.update([instruction{i} ' :FAIL']);
                        end
                    end
                end
            end
            cmMonObj.update('...Done.');
        end
        function [errors] = setBit(sObj,address,bitMask)
            %xor bitMask at specific address
            %address and bit are both hexadecimal strings
            %read register
            [~ , ~ , ~ , ~, data, errors] = sObj.readRegister(address,'0');
            %set bit
            if ~errors, data = dec2hex(bitxor(hex2dec(bitMask),hex2dec(data)),2); end
            %write register
            if ~errors, sObj.writeRegister(address,'0', data); end
        end
        function [errors] = clearBit(sObj,address,bitMask)
            %and bitMask at specific address
            %address and bit are both hexadecimal strings
            %read register
            [~, ~, ~, ~, data, errors] = sObj.readRegister(address,'0');
            %set bit
            if ~errors, data = dec2hex(bitand(hex2dec(bitMask),hex2dec(data)),2); end
            %write register
            if ~errors, sObj.writeRegister(address,'0', data); end
        end
        function [cmMonObj, errors] = testConnectivity(sObj,cmMonObj)
            [~, ~, ~, ~, ~, errors] = sObj.readRegister('08','0');
            if errors, cmMonObj.update(['Error: GPSDO' sObj.gpsdoNr ' not responding at ' sObj.comPort]); end
            if ~errors, cmMonObj.update(['GPSDO' sObj.gpsdoNr ' connected to ' sObj.comPort ': OK']); end
        end
        function cmMonObj = deletePort(sObj,cmMonObj)
            fclose(sObj.serialObj);
            delete(sObj.serialObj);
            clear sObj.serialObj;
            cmMonObj.update(['GPSDO' sObj.gpsdoNr ' disconnected from ' sObj.comPort ': OK']);
            cmMonObj.update([sObj.comPort ' released.']);
        end
        function delete(sObj)
        end
    end
    
    methods (Access = private)
        function [sObj, cmMonObj] = create_comPort(sObj,cmMonObj)
            sObj.errors = 0;
            %Open Serial Port serial_obj
            sObj.serialObj = serial(sObj.comPort);
            sObj.serialObj.Terminator = 'CR/LF';
            sObj.serialObj.BaudRate = 9600;
            sObj.serialObj.DataBits = 8;
            sObj.serialObj.StopBits = 1;
            sObj.serialObj.OutputBufferSize = 4096;
            sObj.serialObj.InputBufferSize = 4096;
            sObj.serialObj.ReadAsyncMode = 'continuous';
            sObj.serialObj.BytesAvailableFcnMode = 'terminator';
            try
                fopen(sObj.serialObj);
            catch
                %error occurred - delete serial object
%                 fclose(sObj.serialObj);
%                 delete(sObj.serialObj);
%                 clear sObj.serialObj;
                sObj.errors = 1;
            end
            if sObj.errors
                cmMonObj.update(sprintf('Error: Can''t open %s',sObj.comPort));
                sObj.deletePort(cmMonObj);
            elseif ~sObj.errors
                cmMonObj.update(sprintf('%s serial object created.',sObj.comPort));
            end
        end
        
        function write_GPSDO_serial_port(sObj,raw)
            i = 1:2:length(raw);
            q = 2:2:length(raw);
            raw1 = [raw(i)' raw(q)'];
            if sObj.serialObj.BytesAvailable > 1, fread(sObj.serialObj,sObj.serialObj.BytesAvailable);end
            fwrite(sObj.serialObj,hex2dec(raw1(:,:)));
        end
        
        function [raw, cmd, addr, nr_bytes, data, errors] = read_GPSDO_serial_port(sObj)
            % this function reads the serial port buffer and parses the read data
            % if no bytes are available an error is return -1
            % if the data is not a valid cmd string an error is return -1
            % data is returned as hexadecimal strings
            if sObj.serialObj.BytesAvailable > 0
                errors = 0;
                x = fread(sObj.serialObj,sObj.serialObj.BytesAvailable);
                i = 1:length(x);
                dat = dec2hex(x(i));
                str = '';
                [m, n] = size(dat);
                if m > 1
                    for k = 1:length(dat)
                        str = [str dat(k,1:end)];
                    end
                end
                raw = str;
                [cmd, addr, nr_bytes, data, errors] = sObj.parse_raw_gpsdo_comms_string(str);
            else
                raw = nan;
                cmd = nan;
                addr = nan;
                nr_bytes = nan;
                data = nan;
                errors = 1;
            end
        end
    end
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
        
        function [errors] = check_serial_parity(raw)
            
            header = raw(1:4);
            footer = raw(end-3:end);
            
            if (strncmp(header, '7E7E', 3) == 1) && strncmp(footer,'0D0A',3) %does command header/footer exist
                cmd = raw(5);
                nr_bytes = raw(6);
                addr = raw(7:8);
                data = raw(9:end-6);
                parity_bit = raw(end-5:end-4);
                tmp = NaN;
                errors = 0;
                parity_str = [cmd nr_bytes addr data];
                
                if length(parity_str) >= 4 % data must contain at least one char plus a parity cahr
                    tmp = bitxor(hex2dec(parity_str(1:2)),hex2dec(parity_str(3:4))); % check data parity
                    for i = 6:2:length(parity_str)
                        tmp = bitxor(hex2dec(parity_str(i-1:i)),tmp);
                    end
                    tmp2 = hex2dec(parity_bit);
                    
                    if tmp ~= tmp2
                        errors = 1;
                    end
                else
                    errors = 1;
                end
            else
                errors = 1;
            end
        end
        
        function [cmd, addr, nr_bytes, data, errors] = parse_raw_gpsdo_comms_string(raw)
            %this function does a parity check and parse the gpsdo data string into cmd
            %addr and data
            
            if length(raw) <= 15
                cmd = nan;
                nr_bytes = nan;
                addr = nan;
                data = nan;
                errors = 1;
                return;
            else
                errors = 0;
                header = raw(1:4);
                cmd = raw(5);
                nr_bytes = raw(6);
                addr = raw(7:8);
                data = raw(9:end-6);
                parity_bit = raw(end-5:end-4);
                footer = raw(end-3:end);
                tmp = NaN;
                parity_str = [cmd nr_bytes addr data];
            end
            
            if (strncmp(header, '7E7E', 3) == 1) && strncmp(footer,'0D0A',3) %does command header/footer exist
                if length(parity_str) >= 4 % data must contain at least one char plus a parity cahr
                    tmp = bitxor(hex2dec(parity_str(1:2)),hex2dec(parity_str(3:4))); % check data parity
                    for i = 6:2:length(parity_str)
                        tmp = bitxor(hex2dec(parity_str(i-1:i)),tmp);
                    end
                    tmp2 = hex2dec(parity_bit);
                    
                    if tmp ~= tmp2
                        cmd = nan;
                        nr_bytes = nan;
                        addr = nan;
                        data = nan;
                        errors = 1;
                    end
                end
            else
                cmd = nan;
                nr_bytes = nan;
                addr = nan;
                data = nan;
                errors = 1;
            end
            
        end
    end
end

