classdef softwareDefinedFilter<handle
    % Class help goes here
    properties
        sdf_en
        
        outlier_en
        outlier_en_prev
        outlier_input
        outlier_window
        outlier_memory
        outlier_output
        outlier_consequtive
        
        sawtooth_en
        sawtooth_memory
        sawtooth_input
        sawtooth_output
        
        averager_en
        averager_en_prev
        averager_window
        averager_memory
        averager_input
        averager_output
        
        filter_en
        filter_input
        filter_output
        filter_x
        filter_y
        filter_n
        a
        b
        
        dac_value
        
        locked
        locked_prev
        locked_memory1
        locked_memory2
        locked_input
        locked_window
        
        openloop_en
        
        gpsdoNr
        comPort
    end
    methods
        function [sObj ,cmMonObj] = softwareDefinedFilter(cmMonObj,comPort,gpsdoNr)
            % Assign properties
            sObj.comPort = comPort;
            sObj.gpsdoNr = num2str(gpsdoNr);
            
            sObj.sdf_en = 0;
            
            sObj.outlier_en = 1;
            sObj.outlier_window = 513;
            sObj.outlier_consequtive = 0;
            
            sObj.sawtooth_en = 0;
            
            sObj.averager_en = 0;
            sObj.averager_window = 16;
            
            sObj.filter_en = 1;
            sObj.filter_output = 0;
            
            sObj.filter_x(1:4) = 0;
            sObj.filter_y(1:4) = 0;
            
            
            sObj.filter_n = 2;
            % tau = 25s 
            %sObj.a = [-1.534504656926470   0.534504656926470];
           % sObj.b = [1.629877379619988   0.161294136374979  -1.468583243245011];
%           % tau = 50s 
              sObj.a = [-1.736599389019725   0.736599389019725];
              sObj.b = [0.537333339860087   0.027261963236458  -0.510071376623628];
             
             %tau = 150 seconds 
%             sObj.a = [-1.903748933060082   0.903748933060082];
%             sObj.b = [0.059947232059599   0.001031261431499  -0.058915970628100];
            
            %DAC voltage at center value (+-2e-7)
            sObj.dac_value = '000000';
            
            sObj.locked = 0;
            sObj.locked_prev = 0;
            sObj.locked_window = 128;
            
            sObj.openloop_en = 0;
            
        end
        
        
        
        function [sObj] = update(sObj,cmMonObj,pd_error,sawtooth_error)
            if (~(sObj.locked) && sObj.locked_prev)  %when lock is lost
                eval(sprintf('cmMonObj.update(''GPSDO%s phase-lock: NO'');',sObj.gpsdoNr));
                
                %outlier detection only active while locked
                % disable and reset outlier detector if it was previously
                % set by user
                if sObj.outlier_en == 1
                    sObj.outlier_en_prev = 1;
                    sObj.outlier_en = 0;
                    sObj.outlier_consequtive = 0;
                    sObj.outlier_memory = [];
                    sObj.averager_memory = [];
                    eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned off'');',sObj.gpsdoNr));
                end
            % tau = 25s 
            %sObj.a = [-1.534504656926470   0.534504656926470];
            %sObj.b = [1.629877379619988   0.161294136374979  -1.468583243245011];
% %           % tau = 50s 
              sObj.a = [-1.736599389019725   0.736599389019725];
              sObj.b = [0.537333339860087   0.027261963236458  -0.510071376623628];
             
             %tau = 150 seconds 
 %            sObj.a = [-1.903748933060082   0.903748933060082];
 %            sObj.b = [0.059947232059599   0.001031261431499  -0.058915970628100];
   
            eval(sprintf('cmMonObj.update(''SDF tau = 50s for GPSDO%s'');',sObj.gpsdoNr));
            
            elseif (sObj.locked) && ~(sObj.locked_prev) %when lock is gained
                eval(sprintf('cmMonObj.update(''GPSDO%s phase-lock: OK'');',sObj.gpsdoNr));
                
                %re-enable outlier detection if it was previously set by user
                %outlier detection only active while locked
                if sObj.outlier_en_prev == 1
                    sObj.outlier_en = 1; 
                    sObj.outlier_en_prev = 0;
                    eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned on'');',sObj.gpsdoNr));
                end
                
                %tau = 150 seconds 
               sObj.a = [-1.903748933060082   0.903748933060082];
               sObj.b = [0.059947232059599   0.001031261431499  -0.058915970628100];
                
                %tau = 400 seconds
%                 sObj.a = [-1.962786525966189   0.962786525966189];
%                 sObj.b = [0.007684250775203   0.000049839474152  -0.007634411301050];
                
                %tau = 800 seconds
               % sObj.a = [-1.981218532065773   0.981218532065772];
                %sObj.b = [0.002130793543428   0.000006921306317  -0.002123872237111];
                
				% tau = 50s 
%                 sObj.a = [-1.736599389019725   0.736599389019725];
%                 sObj.b = [0.537333339860087   0.027261963236458  -0.510071376623628];

                eval(sprintf('cmMonObj.update(''SDF tau = 800s for GPSDO%s'');',sObj.gpsdoNr));
                
            end
            
            %discard outliers
            sObj.outlier_input = pd_error;% - 135;
            [sObj sObj.outlier_output sObj.outlier_memory sObj.outlier_consequtive] = sObj.discard_if_outlier(sObj.outlier_input,sObj.outlier_memory,sObj.outlier_consequtive,sObj.outlier_window,sObj.outlier_en);
            
            %correct sawtooth errors
            sObj.sawtooth_input = sObj.outlier_output;
            [sObj.sawtooth_output sObj.sawtooth_memory] = sObj.correct_sawtooth(sObj.sawtooth_input,sawtooth_error,sObj.sawtooth_memory,sObj.sawtooth_en);
            
            %calculate moving average
            sObj.averager_input = sObj.sawtooth_output;
            [sObj.averager_output sObj.averager_memory] = sObj.moving_avg_filter(sObj.averager_input,sObj.averager_memory,sObj.averager_window,sObj.averager_en);
            
            %calculate IIR filter value
            sObj.filter_input = sObj.averager_output;
            [sObj.filter_output sObj.filter_y sObj.filter_x] = sObj.second_order_IIR_filter((sObj.filter_input).*10, sObj.filter_y,sObj.filter_x, sObj.b(1), sObj.b(2), sObj.b(3), sObj.a(1), sObj.a(2), sObj.filter_en);
                  
            %convert filter output to 20-bit DAC value
            [sObj.dac_value] = sObj.calculate_DAC_value(sObj.filter_output);
            %sObj.dac_value = '000000';
            %sObj.dac_value = '7fffff';
            %determine PLL lock status
            sObj.locked_prev = sObj.locked;
            [sObj sObj.locked sObj.locked_memory1] = sObj.locked_detector(sObj.filter_input,sObj.locked_memory1,sObj.locked,sObj.locked_window);
            %locked status is averaged over 24 sample window to remove rapid fluctuations
            [x sObj.locked_memory2] = sObj.moving_avg_filter(sObj.locked,sObj.locked_memory2,24,1);                
            if x >= 1
                sObj.locked = 1;
            elseif x <= 0.8
                sObj.locked = 0;
            end
            
        end
        
        function delete(sObj)
        end
        
        function [sObj outp data consequtive] = discard_if_outlier(sObj,input,data,consequtive,window_size,enable)
            %this algorithm calculates the median deviation to the original median
            %recursively. Each new value is compared against the current median
            %deviation. If the value is outside of +-5sigma it is discarded and the
            %last value is repeated. Output data equals the input data until there are
            %N values in the filter memory.
            
            %see Ulrich Bangert's explanation below for a better understanding.
            if ~enable
                outp = input;
                data = input;
            else
                if length(data) < window_size
                    data = [data  input];
                    outp = input;
                elseif length(data) >= window_size
                    
                    [median_abs_dev] = sObj.median_deviation(data-mean(data));
                    if ((abs(input-mean(data))) > (5*median_abs_dev))                  %if outlier
                        
                        if consequtive < 64
                           outp = data(end);
                           data = [data(2:end) data(end)];
                           consequtive = consequtive + 1;
                        else
                           outp = data(end);
                           data = [data(2:end) input];
                           consequtive = 0;
                        end
                    else                                                %not outlier
                        data = [data(2:end) input];
                        outp = input;
                    end
                end
            end
        end
        
        function [sObj locked data] = locked_detector(sObj,input,data,locked_prev,window_size)
            %lock detector
            %this function calculate moving lock detection
            %the avg slope accross the window size is calculated
            %loss of lock is assumed if the abs(slope) < 0.1
            %when locked outp = 1;
            %else not locked outp = 0;
            
            if length(data) < window_size
                data = [input data];
                locked = 0;
            elseif length(data) >= window_size
                data = [input data(1:end-1)];
                m = sObj.average_slope(data);
                %m = data(end)-data(1)./window_size;
                
                locked = 0;
                if abs(input) >= 18
                    %locked = 0;
                else
                    if abs(m) > 0.8
                        %locked = 0;
                    else
                        if (abs(input) <= 13)
                            %locked = 0;
                            if (abs(m) < 0.04)
                                locked = 1;
                            else
                                locked = locked_prev;
                            end
                        end
                    end
                end
            end
        end
    end
    
    methods (Static)
        function [median_abs_dev] = median_deviation(data)
            %data array length must be uneven
            median_idx = ceil(length(data)/2);
            sorted_array = sort(data);
            median = sorted_array(median_idx);
            
            median_abs_deviation = zeros(1,length(data));
            
            for i = 1:length(data)
                median_abs_deviation(i) = sqrt((data(i)-median).^2);
            end
            
            second_sorted_array = sort(median_abs_deviation);
            median_abs_dev = second_sorted_array(median_idx);
        end
        
        function [outp data] = correct_sawtooth(input,sawtooth,data,enable)
            if ~enable
                outp = input;
                data = sawtooth;
            else
                if length(data) < 2
                    data = [data sawtooth];
                    outp = input;
                elseif length(data) >= 2
                    data = [data(2) sawtooth];
                    outp = input + data(1);
                end
            end
        end
        
        function [outp data] = moving_avg_filter(input,data,window_size,enable)
            if ~enable
                outp = input;
                data = input;
            else
                if length(data) < window_size
                    data = [data input];
                    outp = input;
                elseif length(data) >= window_size
                    data = [data(2:end) input];
                    outp = sum(data)./window_size;
                end
            end
        end
        
        function [y] = average_slope(x)
            m = zeros(1,length(x)-1);
            if length(x) == 1
                m = 0;
            else
                for i = 1:length(x)-2
                    m(i) = ((x(i+2) - x(i)) - (x(i+1) - x(i)))./2;
                end
            end
            y = mean(m);
        end
        
        function [outp y x] = second_order_IIR_filter(input,y,x,b0,b1,b2,a1,a2,enable)
            % direct form I - second order IIR filter
            if ~enable
                outp = input;
            else
                outp = (b0.*input + b1.*x(1) + b2.*x(2)) - (a1.*y(1) + a2.*y(2));
                x = [input x(1)];
                
                %limit output to maximum pd_value to prevent filter woundup
                if outp > 2^20/2-1
                    outp = 2^20/2-1;
                elseif outp < -2^20/2
                    outp = -2^20/2;
                end
                y = [outp y(1)];
            end
        end
        
        function [outp y x] = nth_order_IIR_filter(input, y, x, b, a, N, enable)
            % direct form I
            
            %must declare:
            %   y(1:N) = nan;
            %   x(1:N) = nan;
            
            %declare zeros b(1:N+1)
            %declare poles a(1:N)
            
            if ~enable
                outp = input;
            else
                outp = (b(1).*input + sum(b(2:N+1).*x)) - sum(a.*y);
                x = [input x(1:N-1)];
                
                %limit output to maximum pd_value to prevent filter woundup
                if outp > 2^20/2-1
                    outp = 2^20/2-1;
                elseif outp < -2^20/2
                    outp = -2^20/2;
                end
                y = [outp y(1:N-1)];
            end
        end
        
        function [outp] = calculate_DAC_value(input)
            q = quantizer('fixed', 'round', 'saturate', [20 0]);
            outp = [num2hex(q,input) '0'];
        end
        
    end
end


