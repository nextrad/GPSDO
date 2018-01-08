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
        isOutlier
        outlier_holdover_value
        
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
        a1
        a2
        b1
        b2
        b3
        a
        b
        tau
        finalTau
        n
        
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
            sObj.outlier_en_prev = 0;
            sObj.outlier_window = 241;
            sObj.isOutlier = 0;
            sObj.outlier_holdover_value = 0;
             
            sObj.sawtooth_en = 0;
            
            sObj.averager_en = 0;
            sObj.averager_window = 16;
            
            sObj.filter_en = 1;
            sObj.filter_output = 0;
            
            sObj.filter_x(1:4) = 0;
            sObj.filter_y(1:4) = 0;
            
            sObj.finalTau = 1000;
              
            sObj.filter_n = 2;
      
            fit_a2 = [-11.310213666305350 -0.950583739748284 1.000745932604032];
            fit_b1 = [1.395358206059967e+004 -1.931083181164382  -0.001816401155688];
            fit_b2 = [2.963215664135938e+004 -2.892501941954441 -1.445512995051100e-005];
            fit_b3 = [-1.293244658599672e+004 -1.919335521020394 0.001943831757308];

            x = 1:5000;
            sObj.a2 = fit_a2(1).*x.^fit_a2(2)+fit_a2(3);
            sObj.a1 = (-sObj.a2)-1;

            sObj.b1 = fit_b1(1).*x.^fit_b1(2)+fit_b1(3);
            sObj.b2 = fit_b2(1).*x.^fit_b2(2)+fit_b2(3);
            sObj.b3 = fit_b3(1).*x.^fit_b3(2)+fit_b3(3);
                
            sObj.n = 0;
            sObj.tau = 75;
            
%             sObj.a = [-1.816336757637674   0.816336757637674];
%             sObj.b = [3.502657508760383   0.119483445894925  -3.383174062865457];
            
            [sObj.a sObj.b sObj.tau] = sObj.adjustFilterCoef(sObj.tau,sObj.a1,sObj.a2,sObj.b1,sObj.b2,sObj.b3);
            % over damped test
%             sObj.a = [-1.193726638137195 0.193726638137194];
%             sObj.b = [13.337960878980091 0.045289407000129 -13.292671471979968];
          
            %DAC voltage at center value (+-2e-7)
            %sObj.dac_value = '000000';
            
            sObj.locked = 0;
            sObj.locked_prev = 0;
            sObj.locked_window = sObj.tau;
            
            sObj.openloop_en = 0;
            
            %eval(sprintf('cmMonObj.update(''GPSDO%s: SDF turned on'');',sObj.gpsdoNr));
            
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
                    sObj.isOutlier = 0;
                    sObj.outlier_holdover_value = 0;
                    sObj.outlier_memory = [];
                    sObj.averager_memory = [];
                    eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned off'');',sObj.gpsdoNr));
                end
                
                sObj.n = 0;
                sObj.tau = 75;

                [sObj.a, sObj.b, sObj.tau] = sObj.adjustFilterCoef(sObj.tau,sObj.a1,sObj.a2,sObj.b1,sObj.b2,sObj.b3);
                % over damped test
%                 sObj.a = [-1.193726638137195 0.193726638137194];
%                 sObj.b = [13.337960878980091 0.045289407000129 -13.292671471979968];
                
%                 sObj.a = [-1.816336757637674   0.816336757637674];
%                 sObj.b = [3.502657508760383   0.119483445894925  -3.383174062865457];
                
                eval(sprintf('cmMonObj.update(''SDF tau = %i for GPSDO%s'');',sObj.tau,sObj.gpsdoNr));
                sObj.locked_window = sObj.tau;
                
            elseif (sObj.locked) && ~(sObj.locked_prev) %when lock is gained
                eval(sprintf('cmMonObj.update(''GPSDO%s phase-lock: OK'');',sObj.gpsdoNr));
                sObj.n = 0;
                sObj.tau = 75;
%                 %re-enable outlier detection if it was previously set by user
%                 %outlier detection only active while locked
%                 if sObj.outlier_en_prev == 1
%                     sObj.outlier_en = 1; 
%                     sObj.outlier_en_prev = 0;
%                     eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned on'');',sObj.gpsdoNr));
%                 end
                
            [sObj.a sObj.b sObj.tau] = sObj.adjustFilterCoef(sObj.tau,sObj.a1,sObj.a2,sObj.b1,sObj.b2,sObj.b3);
                        % over damped test
%                 sObj.a = [-1.193726638137195 0.193726638137194];
%                 sObj.b = [13.337960878980091 0.045289407000129 -13.292671471979968];
            
%             sObj.a = [-1.816336757637674   0.816336757637674];
%             sObj.b = [3.502657508760383   0.119483445894925  -3.383174062865457];
            
            eval(sprintf('cmMonObj.update(''SDF tau = %i for GPSDO%s'');',sObj.tau,sObj.gpsdoNr));  
                
            elseif (sObj.locked) && (sObj.locked_prev) %when still locked
                if sObj.n < (round(sObj.finalTau*0.6))
                    sObj.n = sObj.n+1; 
                    sObj.tau = sObj.findTau(sObj.n,sObj.finalTau);
                    sObj.locked_window = sObj.tau;
                    [sObj.a, sObj.b, sObj.tau] = sObj.adjustFilterCoef(sObj.tau,sObj.a1,sObj.a2,sObj.b1,sObj.b2,sObj.b3);
                    %eval(sprintf('cmMonObj.update(''SDF tau = %i for GPSDO%s'');',sObj.tau,sObj.gpsdoNr));     
                elseif sObj.n == (round(sObj.finalTau*0.6))
                    sObj.n = sObj.n+1;
                    eval(sprintf('cmMonObj.update(''SDF tau = %i for GPSDO%s'');',sObj.tau,sObj.gpsdoNr));
                    %re-enable outlier detection if it was previously set by user
                    %outlier detection only active while locked
                    if sObj.outlier_en_prev == 1
                        sObj.outlier_en = 1; 
                        sObj.outlier_en_prev = 0;
                        eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned on'');',sObj.gpsdoNr));
                    end
                end
            elseif (~sObj.locked) && (~sObj.locked_prev) %when never locked
                %outlier detection only active while locked
                % disable and reset outlier detector if it was previously
                % set by user
                if sObj.outlier_en == 1
                    sObj.outlier_en_prev = 1;
                    sObj.outlier_en = 0;
                    sObj.isOutlier = 0;
                    sObj.outlier_holdover_value = 0;
                    sObj.outlier_memory = [];
                    sObj.averager_memory = [];
                    eval(sprintf('cmMonObj.update(''GPSDO%s: Outlier detection turned off'');',sObj.gpsdoNr));
                end
                
                sObj.n = 0;
                sObj.tau = 75;
                [sObj.a, sObj.b, sObj.tau] = sObj.adjustFilterCoef(sObj.tau,sObj.a1,sObj.a2,sObj.b1,sObj.b2,sObj.b3);
                            % over damped test
%                 sObj.a = [-1.193726638137195 0.193726638137194];
%                 sObj.b = [13.337960878980091 0.045289407000129 -13.292671471979968];
                
%                 sObj.a = [-1.816336757637674   0.816336757637674];
%                 sObj.b = [3.502657508760383   0.119483445894925  -3.383174062865457];
                
                %eval(sprintf('cmMonObj.update(''SDF tau = %i for GPSDO%s'');',sObj.tau,sObj.gpsdoNr));
                sObj.locked_window = sObj.tau;
            end
     
           
            
            %correct sawtooth errors
            %sObj.sawtooth_input = pd_error;% - 135;
            %[sObj.sawtooth_output sObj.sawtooth_memory] = sObj.correct_sawtooth(sObj.sawtooth_input,sawtooth_error,sObj.sawtooth_memory,sObj.sawtooth_en);
            
            %discard outliers
            sObj.outlier_input = pd_error; %sObj.sawtooth_output;
            [sObj sObj.outlier_output sObj.outlier_memory sObj.isOutlier sObj.outlier_holdover_value] = sObj.discard_if_outlier(sObj.outlier_input,sObj.outlier_memory,sObj.isOutlier,sObj.outlier_holdover_value,sObj.outlier_window,sObj.outlier_en);

            
            %calculate moving average
            sObj.averager_input = sObj.outlier_output;
            [sObj.averager_output sObj.averager_memory] = sObj.moving_avg_filter(sObj.averager_input,sObj.averager_memory,sObj.averager_window,sObj.averager_en);
            
            %calculate IIR filter value
            sObj.filter_input = sObj.averager_output;
            [sObj.filter_output sObj.filter_y sObj.filter_x] = sObj.second_order_IIR_filter((sObj.filter_input).*10, sObj.filter_y,sObj.filter_x, sObj.b(1), sObj.b(2), sObj.b(3), sObj.a(1), sObj.a(2), sObj.filter_en);
            
                        
            %convert filter output to 20-bit DAC value
            [sObj.dac_value] = sObj.calculate_DAC_value(sObj.filter_output);
            %fprintf('filter_output = %f\n',sObj.filter_output);
            %fprintf('DAC Value = %s\n',sObj.dac_value);

            %sObj.dac_value = '000000';
            %sObj.dac_value = '7fffff';

            %determine PLL lock status
            sObj.locked_prev = sObj.locked;
            [sObj.locked sObj.locked_memory1] = sObj.locked_detector(sObj.outlier_input.*1e-9,sObj.locked_memory1,sObj.locked,sObj.locked_window);

        end
        
        function delete(sObj)
        end
        
        function [sObj outp data outlier outlier_holdover_value] = discard_if_outlier(sObj,input,data,outlier,outlier_holdover_value,window_size,enable)
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
                    
                    [MAD median IQR q1 q3] = sObj.median_deviation(data);
                    %[median_abs_dev] = sObj.median_deviation(data-mean(data));
                    
                    upper_limit = q3 + 1.5*IQR;
                    lower_limit = q1 - 1.5*IQR;
                    if ((input > upper_limit) || (input < lower_limit)) && ~outlier  %if outlier
                        outlier_holdover_value = data(end);
                        data = [data(2:end) input];
                        outp = outlier_holdover_value;
                        outlier = 1;
                    elseif ((input > upper_limit) || (input < lower_limit)) && outlier  %if still outlier
                        data = [data(2:end) input];
                        outp = outlier_holdover_value;
                        outlier = 1;                
                    else                                                %not outlier
                        data = [data(2:end) input];
                        outp = input;
                        outlier = 0;
                    end
                end
            end
        end
    end
    
    methods (Static)
        
        function [locked data] = locked_detector(input,data,locked_prev,window_size)
            
            if length(data) < 2
                phaseMinMax = 0; 
                phaseMean = 0;
            else
                phaseMinMax = abs(mean([input data(1:2)]))/3;
                phaseMean = abs(mean(data));
            end
                
            %fprintf('phaseMinMax = %e\n',phaseMinMax);
            %fprintf('phaseMean = %e\n',phaseMean);
            %fprintf('length(data) = %i\n',length(data));
            %fprintf('((phaseMinMax >= 15e-9) || (phaseMean > 9e-9) || (length(data) < 50))\n')

            if length(data) < window_size
                data = [input data];
                locked = locked_prev;
                if ((phaseMinMax >= 45e-9) || (phaseMean > 9e-9)), locked = 0; end
              %  fprintf('length(data) < window_size\n'); 15e-9  40e-9
            elseif length(data) > window_size
                data = [input data(1:window_size-1)];
                locked = locked_prev;
                if ((phaseMinMax >= 45e-9) || (phaseMean > 9e-9)), locked = 0; end
                %fprintf('length(data) > window_size\n'); 15-9 40e-9
            elseif length(data) == window_size
                %fprintf('length(data) == window_size\n');
                data = [input data(1:end-1)];

                if ((phaseMinMax >= 45e-9) || (phaseMean > 9e-9))
                    locked = 0;
                elseif ((phaseMinMax <= 4.5e-9) && (~locked_prev) && (phaseMean < 5e-10))
                    %fprintf('((phaseMinMax <= 4.5e-9) && (~locked_prev) && (phaseMean < 5e-10))\n\n');
                    locked = 1;
                elseif ((phaseMinMax <= 4.5e-9) && (~locked_prev) && (phaseMean > 5e-10))
                    locked = 0;
                    %fprintf('((phaseMinMax <= 4.5e-9) && (~locked_prev) && (phaseMean > 5e-10))\n\n');
                else                      
                    locked = locked_prev; 
                    %fprintf('locked = locked_prev;\n\n');
                end
            end
           
        end
                
        function [MAD median IQR q1 q3] = median_deviation(data)
            %data array length must be uneven
            %find median
            median_idx = ceil(length(data)*0.5);
            q1_idx = ceil(length(data)*0.25);
            q3_idx = ceil(length(data)*0.75);

            sorted_array = sort(data);

            median = sorted_array(median_idx);
            q1 = sorted_array(q1_idx);
            q3 = sorted_array(q3_idx);

            IQR = q3-q1;
            
            medianDeviation = zeros(1,length(data));

            for i = 1:length(data)
                medianDeviation(i) = sqrt((data(i)-median).^2);
            end

            second_sorted_array = sort(medianDeviation);
            MAD = second_sorted_array(median_idx);
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
        
 
        function [outp y x] = second_order_IIR_filter(input,y,x,b0,b1,b2,a1,a2,enable)
            % direct form I - second order IIR filter
            if ~enable
                outp = input;
            else
                outp = (b0.*input + b1.*x(1) + b2.*x(2)) - (a1.*y(1) + a2.*y(2));
                x = [input x(1)];
                
                %limit output to maximum pd_value to prevent filter woundup
                if outp > 2^24/2-1
                    outp = 2^24/2-1;
                elseif outp < -2^24/2
                    outp = -2^24/2;
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
            q = quantizer('fixed', 'round', 'saturate', [24 0]);
            %q = quantizer('double', 'round', 'saturate', [20 0]);
            outp = num2hex(q,input);
            %fprintf('DAC Value = %s\n',outp);
            %outp = [num2hex(q,input) '0'];
        end
        
        function [a, b, tau] = adjustFilterCoef(tau, a1, a2, b1, b2, b3)
            %A 2nd-order critically damped filter, as is described in [Egan], was used for the UCT GPSDO PLL loop filter. 
            %To make it easier to determine the filter coefficients for any arbitrary tau, sets of filter coefficients were calculated for various tau.
            %Each of these coefficients were plotted vs. tau and it was found that a power function such as, y(x) = a*x^b+c, could be fitted to each plot. 
            %Now each filter coefficient is described by a it is possible to determine tau by
            %reading each coefficient from the curve
            %filter coefficients are determined by sliding 
            a(1) = a1(tau);
            a(2) = a2(tau);
            b(1) = b1(tau);
            b(2) = b2(tau);
            b(3) = b3(tau);
        end
        
        function [tau] = findTau(n,finalTau)
            x = (round(finalTau*0.6)):-1:1;
            y = x.^3;
            y = (y./max(y)*(finalTau-75));
            y = (1-y)+y(1)+74;
            y = ceil(y);
            tau = y(n);
        end
    end
end


