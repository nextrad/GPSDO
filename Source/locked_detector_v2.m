function [locked data] = locked_detector_v2(input,data,locked_prev,window_size)

            phaseMinMax = max(abs(data));
            phaseMean = abs(mean(data));

            if ((phaseMinMax >= 15e-9) || (phaseMean > 9e-9) || (length(data) < 50))
                    locked = 0;
                    %fprintf('((phaseMinMax >= 15e-9) || (phaseMean > 9e-9) || (length(data) < 50))\n');
            else
                if length(data) < window_size
                    data = [input data];
                    locked = locked_prev;
                    %fprintf('length(data) < window_size\n');
                elseif length(data) > window_size
                    data = [input data(1:window_size-1)];
                    locked = locked_prev;
                    %fprintf('length(data) > window_size\n');
                elseif length(data) == window_size
                    %fprintf('length(data) == window_size\n');
                    data = [input data(1:end-1)];
                    if ((phaseMinMax <= 4.5e-9) && (~locked_prev) && (phaseMean < 5e-10))
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
end