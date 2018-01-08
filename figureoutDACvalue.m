%%
clc
max = 2^20/2-1
min = -2^20/2

LSB = (1/(2^20))

q = quantizer('mode','fixed','roundmode','round','overflowmode','saturate','format',[20 4])

outp_max = [num2hex(q,max)]
outp_min = [num2hex(q,min)]

outp_LSB = [num2hex(q,LSB)]

hex2num(q,'00001')