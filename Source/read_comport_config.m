function [handles, commie] = read_comport_config(handles)

%open config file
fid = fopen('comport.cfg');

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

set(handles.gpsdo1_comSelect,'String',instruction{1});
handles.gpsdo1.comPort = str2double(instruction{1}(4));
set(handles.gpsdo2_comSelect,'String',instruction{2});
handles.gpsdo2.comPort = str2double(instruction{2}(4));
set(handles.gpsdo3_comSelect,'String',instruction{3});
handles.gpsdo3.comPort = str2double(instruction{3}(4));

commie = instruction{4};
  

