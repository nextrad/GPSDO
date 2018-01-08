function msgbox_fromFile(title,filename)

fid = fopen(filename);

%read file into cell strings
x = 1;
text{x} = fgetl(fid);
while ischar(text{:,x})
    x = x+1;
    text{x} = fgetl(fid);
end
text{x} = '';
%close file
fclose(fid);
text = text';
msgbox(text,title,'replace');