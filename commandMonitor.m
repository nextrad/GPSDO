classdef commandMonitor<handle
    % this class writes messages to a textbox object in a FIFO fashion
    properties
        new_string
        old_string
        rows
        fid
        txtObj
    end
    methods
        function cMobj = commandMonitor(textBoxObj,init_string,rows)
            % constructor method
            cMobj.txtObj = textBoxObj;
            cMobj.rows = rows;
            cMobj.new_string{rows} = '';
            cMobj.new_string = cMobj.new_string';
            cMobj.new_string{rows} = init_string;
            cMobj.old_string = cMobj.new_string;
            cMobj.fid = fopen(['.\Log Files\gpsdoCommandMon_' datestr(now,'yyyy-mm-dd_HH-MM-SS') '.log'],'a');
            fprintf(cMobj.fid,'%s\tCommandMon Logfile Created.\n',datestr(now,31));
            fprintf(cMobj.fid,'%s\t%s\n',datestr(now,31),init_string);
            set(textBoxObj,'String',cMobj.new_string);
        end
        function cMobj = update(cMobj,string_to_add)
            x = cMobj.rows;
            for i = 1:x-1
                cMobj.new_string{i} = cMobj.old_string{i+1};
            end
            cMobj.new_string{x} = [datestr(now,'yyyy/mm/dd HH:MM:SS') '  ' string_to_add];
            cMobj.old_string = cMobj.new_string;
            set(cMobj.txtObj,'String',cMobj.new_string);
            fprintf(cMobj.fid,'%s\t%s\n',datestr(now,31),string_to_add);
        end       
        function delete(cMobj)
            %fclose(cMobj.fid);
        end
    end
end