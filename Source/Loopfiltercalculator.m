% this M-code calculates and plots the 3rd-order PLL response
% 
clc;
close all;
clear all;
LoopTimeConstant = 150;
Ts = 1;                % sampling frequency


N = 10;                 % heterodyne factor

Kf = 1;              % filter gain [V/V]

Kpd = 7693/(pi());       % [V/rad] phase detector gain
Kvco = 16/(2^24);        % [Hz/V] OCXO gain

fl = 1/(LoopTimeConstant/(Ts^2));               % [Hz] loop bandwith - cross-over time at 1/fl
wl = 2*pi()*fl;           % [rad/s] loop bandwidth

r = 2.414;                % choose separation between pole-zero of 2nd order filter
                          % this value influence
                        % damping/overshoot/settling/etc
                          
                          % pole-zero spaced equally around wl
wz = wl/r;                % [rad/s] zero location
wp2 = wl*r;               % [rad/s] pole location

                          % specify 2nd-order filter structure  
num_filter_s = [0 wp2 wp2*wz].*Kf;
den_filter_s = [wz wp2*wz 0];

                          %transform to z-plane IIR filter   
[num_filter_z den_filter_z] = bilinear(num_filter_s, den_filter_s, Ts);

f_pd_s = tf([0 Ts*Kpd], [1 0]);
f_pd_z = tf([Ts*Kpd 0], [1 -1], Ts,'variable','z^-1');
f_vco_z = Kvco/N;

f_avg_z = tf([1 1 1 1], [4], Ts,'variable','z^-1');
f_combined_z = f_avg_z*f_pd_z;

f_filter_s = tf(num_filter_s, den_filter_s);
f_filter_z = tf(num_filter_z, den_filter_z, Ts);

%sisotool(f_pd_z,f_filter_z,Kvco,1);

sisotool(Kvco,f_filter_z,f_pd_z,1);


% [b, a] = tfdata(f_filter_z,'v');
% a = a(2:end);
% f_filter_z = tf(b,a, Ts,'variable','z^-1');
% 
% 
% open_loop_tf_z = f_pd_z * f_filter_z * f_vco_z;
% Kf = 0.0001:0.0001:1.5;
% pm = zeros(1,length(Kf));
% 
% for i = 1:length(Kf)
%     [mag,phase,w] = bode(open_loop_tf_z * Kf(i));
%     [~,pm(i),~,~] = margin(mag,phase,w);
% end
% [pks,locs] = findpeaks(pm)
% plot(Kf,pm)
% Kf = Kf(locs)


zpk(f_filter_z);

format long;

[num, den] = tfdata(f_filter_z,'v');
% b0 = num(1)
% b1 = num(2)
% b2 = num(3)
% a1 = den(2)
% a2 = den(3)

b = num
a = den(2:end)

fprintf('%% Tau = %i\n',LoopTimeConstant);
fprintf('Kf(%i) = %15.15f;\n',LoopTimeConstant,Kf);
fprintf('sObj.a = [%2.15f %2.15f];\n',a(1),a(2));
fprintf('sObj.b = [%2.15f %2.15f %2.15f];\n',b(1),b(2),b(3));
fprintf('a1(%i) = sObj.a(1);\n',LoopTimeConstant);
fprintf('a2(%i) = sObj.a(2);\n',LoopTimeConstant);
fprintf('b1(%i) = sObj.b(1);\n',LoopTimeConstant);
fprintf('b2(%i) = sObj.b(2);\n',LoopTimeConstant);
fprintf('b3(%i) = sObj.b(3);\n',LoopTimeConstant);

% a2(100) = sObj.a(2);
% b1(100) = sObj.b(1);
% b2(100) = sObj.b(2);
% b3(100) = sObj.b(3);

% num_actual = [0.210189819335937   0.0021820068359375 -0.208023071289062];
% den_actual = [1.00000000000000    -1.94111633300781 0.941116333007812];
% 
% f_filter_z = tf(num_actual, den_actual, Ts,'variable','z^-1');
% 
% sisotool(f_pd_z,f_filter_z,Kvco,1);


% a1 = ones(1,1000);
% b1 = ones(1,1000);
% b2 = ones(1,1000);
% b3 = ones(1,1000);
% 
% j = find(a1);
% a1(j) = nan;
% b1(j) = nan;
% b2(j) = nan;
% b3(j) = nan;

%-------------------------------------------------------------------------
% % Kvco = 16/(2^24);

a1(1:4000) = nan;
a2(1:4000) = nan;
b1(1:4000) = nan;
b2(1:4000) = nan;
b3(1:4000) = nan;

tau = [75 100 150 200 300 400 500 600 700 800 900 1000 1500 2000 3000 4000];

% Tau = 75
Kf(75) = 1.216456166419019;
sObj.a = [-1.816336757637674 0.816336757637674];
sObj.b = [3.274753766898197 0.111709141858081 -3.163044625040117];
a1(75) = sObj.a(1);
a2(75) = sObj.a(2);
b1(75) = sObj.b(1);
b2(75) = sObj.b(2);
b3(75) = sObj.b(3);

% Tau = 100
Kf(100) = 0.710963697331973;
sObj.a = [-1.859015867874786 0.859015867874786];
sObj.b = [1.950565476405406 0.050117299920440 -1.900448176484965];
a1(100) = sObj.a(1);
a2(100) = sObj.a(2);
b1(100) = sObj.b(1);
b2(100) = sObj.b(2);
b3(100) = sObj.b(3);

% Tau = 150
Kf(150) = 0.312336014298481;
sObj.a = [-1.903748933060082 0.903748933060082];
sObj.b = [0.873771711386994 0.015031337309995 -0.858740374076999];
a1(150) = sObj.a(1);
a2(150) = sObj.a(2);
b1(150) = sObj.b(1);
b2(150) = sObj.b(2);
b3(150) = sObj.b(3);

% Tau = 200
Kf(200) = 0.172868518846222;
sObj.a = [-1.926932597868349 0.926932597868349];
sObj.b = [0.488442883240285 0.006315526791220 -0.482127356449066];
a1(200) = sObj.a(1);
a2(200) = sObj.a(2);
b1(200) = sObj.b(1);
b2(200) = sObj.b(2);
b3(200) = sObj.b(3);

% Tau = 300
Kf(300) = 0.080779202578656;
sObj.a = [-1.950687880501338 0.950687880501337];
sObj.b = [0.230558846302960 0.001991696845283 -0.228567149457677];
a1(300) = sObj.a(1);
a2(300) = sObj.a(2);
b1(300) = sObj.b(1);
b2(300) = sObj.b(2);
b3(300) = sObj.b(3);

% Tau = 400
Kf(400) = 0.045740379252649;
sObj.a = [-1.962786525966189 0.962786525966189];
sObj.b = [0.131219403365959 0.000851079207808 -0.130368324158151];
a1(400) = sObj.a(1);
a2(400) = sObj.a(2);
b1(400) = sObj.b(1);
b2(400) = sObj.b(2);
b3(400) = sObj.b(3);

% Tau = 500
Kf(500) = 0.028607867667501;
sObj.a = [-1.970118019542568 0.970118019542568];
sObj.b = [0.082323000181602 0.000427429871285 -0.081895570310317];
a1(500) = sObj.a(1);
a2(500) = sObj.a(2);
b1(500) = sObj.b(1);
b2(500) = sObj.b(2);
b3(500) = sObj.b(3);

% Tau = 600
Kf(600) = 0.019036274101817;
sObj.a = [-1.975036185600972 0.975036185600972];
sObj.b = [0.054892437393510 0.000237609006763 -0.054654828386746];
a1(600) = sObj.a(1);
a2(600) = sObj.a(2);
b1(600) = sObj.b(1);
b2(600) = sObj.b(2);
b3(600) = sObj.b(3);

% Tau = 700
Kf(700) = 0.014212549345523;
sObj.a = [-1.978564222030638 0.978564222030638];
sObj.b = [0.041043401544221 0.000152328526074 -0.040891073018146];
a1(700) = sObj.a(1);
a2(700) = sObj.a(2);
b1(700) = sObj.b(1);
b2(700) = sObj.b(2);
b3(700) = sObj.b(3);

% Tau = 800
Kf(800) = 0.011340020754064;
sObj.a = [-1.981218532065773 0.981218532065772];
sObj.b = [0.032784358392341 0.000106491118083 -0.032677867274258];
a1(800) = sObj.a(1);
a2(800) = sObj.a(2);
b1(800) = sObj.b(1);
b2(800) = sObj.b(2);
b3(800) = sObj.b(3);

% Tau = 900
Kf(900) = 0.008374632797650;
sObj.a = [-1.983287924207597 0.983287924207597];
sObj.b = [0.024232243266685 0.000069978749024 -0.024162264517661];
a1(900) = sObj.a(1);
a2(900) = sObj.a(2);
b1(900) = sObj.b(1);
b2(900) = sObj.b(2);
b3(900) = sObj.b(3);

% Tau = 1000
Kf(1000) = 0.007102054912796;
sObj.a = [-1.984946553069536 0.984946553069536];
sObj.b = [0.020564218477855 0.000053455203364 -0.020510763274492];
a1(1000) = sObj.a(1);
a2(1000) = sObj.a(2);
b1(1000) = sObj.b(1);
b2(1000) = sObj.b(2);
b3(1000) = sObj.b(3);

% Tau = 1500
Kf(1500) = 0.003140784394817;
sObj.a = [-1.989939126909834 0.989939126909834];
sObj.b = [0.009113161947990 0.000015799516600 -0.009097362431390];
a1(1500) = sObj.a(1);
a2(1500) = sObj.a(2);
b1(1500) = sObj.b(1);
b2(1500) = sObj.b(2);
b3(1500) = sObj.b(3);

% Tau = 2000
Kf(2000) = 0.001750464780004;
sObj.a = [-1.992444843748848 0.992444843748848];
sObj.b = [0.005084365108394 0.000006612517463 -0.005077752590932];
a1(2000) = sObj.a(1);
a2(2000) = sObj.a(2);
b1(2000) = sObj.b(1);
b2(2000) = sObj.b(2);
b3(2000) = sObj.b(3);

% Tau = 3000
Kf(3000) = 0.000703019672582;
sObj.a = [-1.994956878904588 0.994956878904587];
sObj.b = [0.002044108235418 0.000001772706671 -0.002042335528747];
a1(3000) = sObj.a(1);
a2(3000) = sObj.a(2);
b1(3000) = sObj.b(1);
b2(3000) = sObj.b(2);
b3(3000) = sObj.b(3);

% Tau = 4000
Kf(4000) = 0.000441820494311;
sObj.a = [-1.996215273324073 0.996215273324073];
sObj.b = [0.001285313434169 0.000000836084906 -0.001284477349264];
a1(4000) = sObj.a(1);
a2(4000) = sObj.a(2);
b1(4000) = sObj.b(1);
b2(4000) = sObj.b(2);
b3(4000) = sObj.b(3);

%% Power Curve Fits
fit_a2 = [-11.310213666305350 -0.950583739748284 1.000745932604032];
fit_b1 = [1.395358206059967e+004 -1.931083181164382  -0.001816401155688];
fit_b2 = [2.963215664135938e+004 -2.892501941954441 -1.445512995051100e-005];
fit_b3 = [-1.293244658599672e+004 -1.919335521020394 0.001943831757308];

x2 = 1:4000;
a2_fit = fit_a2(1).*x2.^fit_a2(2)+fit_a2(3);
a1_fit = (-a2_fit)-1;
b1_fit = fit_b1(1).*x2.^fit_b1(2)+fit_b1(3);
b2_fit = fit_b2(1).*x2.^fit_b2(2)+fit_b2(3);
b3_fit = fit_b3(1).*x2.^fit_b3(2)+fit_b3(3);



% ------------------------------------------------------------------------
% % Kvco = 16/(2^20);
% % tau = 5s
% sObj.a = [-0.794672220811326  -0.205327779188674];
% sObj.b = [34.545169027060403  14.268966005583817 -20.276203021476533];


% % tau = 10s
% sObj.a = [-1.137410269288215   0.137410269288215];
% sObj.b = [8.848017061548742   2.037774388933347  -6.810242672615398];


% % tau = 15s
% sObj.a = [-1.328385559651792   0.328385559651792];
% sObj.b = [4.578714624886937   0.731073649549821  -3.847640975337113];


% % tau = 25s
% sObj.a = [-1.534504656926470  0.534504656926470];
% sObj.b = [1.542910109775039   0.152687776867245  -1.390222332907793];

% % tau = 25s 
% sObj.a = [-1.534504656926470  0.534504656926470];
% sObj.b = [1.629877379619988   0.161294136374979  -1.468583243245011];
% a1(25) = sObj.a(1);
% a2(25) = sObj.a(2);
% b1(25) = sObj.b(1);
% b2(25) = sObj.b(2);
% b3(25) = sObj.b(3);
% 
% %tau = 50s 
% sObj.a = [-1.736599389019725  0.736599389019725];
% sObj.b = [0.537333339860087   0.027261963236458  -0.510071376623628];
% a1(50) = sObj.a(1);
% a2(50) = sObj.a(2);
% b1(50) = sObj.b(1);
% b2(50) = sObj.b(2);
% b3(50) = sObj.b(3);
% 
% %tau = 100 seconds 
% sObj.a = [-1.859015867874786  0.859015867874786];
% sObj.b = [0.124607794532389   0.003201638851167  -0.121406155681222];
% a1(100) = sObj.a(1);
% a2(100) = sObj.a(2);
% b1(100) = sObj.b(1);
% b2(100) = sObj.b(2);
% b3(100) = sObj.b(3);
% 
% %tau = 150 seconds 
% sObj.a = [-1.903748933060082  0.903748933060082];
% sObj.b = [0.056584758420071   0.000973417403348  -0.055611341016724];
% a1(150) = sObj.a(1);
% a2(150) = sObj.a(2);
% b1(150) = sObj.b(1);
% b2(150) = sObj.b(2);
% b3(150) = sObj.b(3);
% 
% %tau = 200 seconds
% sObj.a = [-1.926932597868349  0.926932597868349];
% sObj.b = [0.028016165377241   0.000362246741837  -0.027653918635405];
% a1(200) = sObj.a(1);
% a2(200) = sObj.a(2);
% b1(200) = sObj.b(1);
% b2(200) = sObj.b(2);
% b3(200) = sObj.b(3);
% 
% %tau = 300 seconds
% sObj.a = [-1.950687880501338  0.950687880501337];
% sObj.b = [0.013079934549110   0.000112991823110  -0.012966942725999];
% a1(300) = sObj.a(1);
% a2(300) = sObj.a(2);
% b1(300) = sObj.b(1);
% b2(300) = sObj.b(2);
% b3(300) = sObj.b(3);
% 
% %tau = 400 seconds
% sObj.a = [-1.962786525966189  0.962786525966189];
% sObj.b = [0.007684250775203   0.000049839474152  -0.007634411301050];
% a1(400) = sObj.a(1);
% a2(400) = sObj.a(2);
% b1(400) = sObj.b(1);
% b2(400) = sObj.b(2);
% b3(400) = sObj.b(3);
% 
% %tau = 500 seconds
% sObj.a = [-1.970118019542568  0.970118019542568];
% sObj.b = [0.004951760161308   0.000025710071349  -0.004926050089959];
% a1(500) = sObj.a(1);
% a2(500) = sObj.a(2);
% b1(500) = sObj.b(1);
% b2(500) = sObj.b(2);
% b3(500) = sObj.b(3);
% 
% %tau = 600 seconds
% sObj.a = [-1.975036185600972  0.975036185600972];
% sObj.b = [0.003164767563496   0.000013699105252  -0.003151068458244];
% a1(600) = sObj.a(1);
% a2(600) = sObj.a(2);
% b1(600) = sObj.b(1);
% b2(600) = sObj.b(2);
% b3(600) = sObj.b(3);
% 
% %tau = 700 seconds
% sObj.a = [-1.978564222030638  0.978564222030638];
% sObj.b = [0.002229221809380   0.000008273536299  -0.002220948273081];
% a1(700) = sObj.a(1);
% a2(700) = sObj.a(2);
% b1(700) = sObj.b(1);
% b2(700) = sObj.b(2);
% b3(700) = sObj.b(3);
%                 
% %tau = 800 seconds
% % sObj.a = [-1.981218532065773  0.981218532065772];
% % sObj.b = [0.002028822178696   0.000006590079928  -0.002022232098768];
% % a1(800) = sObj.a(1);
% % a2(800) = sObj.a(2);
% % b1(800) = sObj.b(1);
% % b2(800) = sObj.b(2);
% % b3(800) = sObj.b(3);
% 
% %tau = 900 seconds
% Kf = 5.071021254536029e-004;
% sObj.a = [-1.983287924207597  0.983287924207597];
% sObj.b = [0.001467314730324   0.000004237364578  -0.001463077365746];
% a1(900) = sObj.a(1);
% a2(900) = sObj.a(2);
% b1(900) = sObj.b(1);
% b2(900) = sObj.b(2);
% b3(900) = sObj.b(3);
% 
% %tau = 1000s
% sObj.a = [-1.984946553069536  0.984946553069536];
% sObj.b = [0.001253713319670   0.000003258937389  -0.001250454382281];
% a1(1000) = sObj.a(1);
% a2(1000) = sObj.a(2);
% b1(1000) = sObj.b(1);
% b2(1000) = sObj.b(2);
% b3(1000) = sObj.b(3);
% 
% %tau = 1500s
% sObj.a = [-1.989939126909834   0.989939126909834];
% sObj.b = [0.578831231494048e-3   0.001003521467258e-3  -0.577827710026679e-3];
% a1(1500) = sObj.a(1);
% a2(1500) = sObj.a(2);
% b1(1500) = sObj.b(1);
% b2(1500) = sObj.b(2);
% b3(1500) = sObj.b(3);
% 
% %tau = 2000s
% sObj.a = [-1.992444843748848   0.992444843748848];
% sObj.b = [0.327257754183963e-3   0.000425618060129e-3  -0.326832136123945e-3];
% a1(2000) = sObj.a(1);
% a2(2000) = sObj.a(2);
% b1(2000) = sObj.b(1);
% b2(2000) = sObj.b(2);
% b3(2000) = sObj.b(3);
% 
% %tau = 3000s
% sObj.a = [-1.994956878904588   0.994956878904587];
% sObj.b = [0.133240536806967e-3   0.000115549844582e-3  -0.133124986962607e-3];
% a1(3000) = sObj.a(1);
% a2(3000) = sObj.a(2);
% b1(3000) = sObj.b(1);
% b2(3000) = sObj.b(2);
% b3(3000) = sObj.b(3);
% 
% x = [25 50 100 150 200 300 400 500 600 700 900 1000 1500 3000];
% %fit power curve to filter coefficients
% % f(x) = a*x^b+c
% % fit_a2 = [a b c];
% 
% fit_a2 = [-9.352 -0.9098 1.002];
% fit_b1 = [1506 -2.041 6.391e-005];
% fit_b2 = [3870 -3.04 -1.883e-007];
% fit_b3 = [-1366 -2.026 -5.097e-005];
% 
% x2 = 1:3000;
% a2_fit = fit_a2(1).*x2.^fit_a2(2)+fit_a2(3);
% a1_fit = (a2_fit.*-1)-1;
% 
% b1_fit = fit_b1(1).*x2.^fit_b1(2)+fit_b1(3);
% b2_fit = fit_b2(1).*x2.^fit_b2(2)+fit_b2(3);
% b3_fit = fit_b3(1).*x2.^fit_b3(2)+fit_b3(3);
% 
% figure();
% loglog(x2,a2,'ob'),hold,grid,title('a1');
% loglog(x2,a2_fit,'r');
% 
% figure();
% semilogy(x2,b1,'o'),hold,grid,title('b1');
% semilogy(x2,b1_fit,'r');
% 
% figure();
% semilogy(x2,b2,'o'),hold,grid,title('b2');
% semilogy(x2,b2_fit,'r');
% 
% figure();
% semilogy(x2,b3,'o'),hold,grid,title('b3');
% semilogy(x2,b3_fit,'r');
% 
% figure();
% loglog(x2,b1,'o'),hold,grid,title('b1');
% loglog(x2,b1_fit,'r');
% figure();
% loglog(x2,b2,'o'),hold,grid,title('b2');
% loglog(x2,b2_fit,'r');
% figure();
% loglog(x2,b3,'o'),hold,grid,title('b3');
% loglog(x2,b3_fit,'r');

figure();
subplot(2,3,1),semilogx(x2,a1,'o'),hold,grid,title('Coefficient a1'),xlabel('Tau [s]'),ylabel('Magnitude [ ]');
subplot(2,3,1),semilogx(x2,a1_fit,'r');
subplot(2,3,1),xlim([50 4000]);
subplot(2,3,1),ylim([-2 -1.75]);
%figure();
subplot(2,3,2),semilogx(x2,a2,'o'),hold,grid,title('Coefficient a2'),xlabel('Tau [s]'),ylabel('Magnitude [ ]');
subplot(2,3,2),semilogx(x2,a2_fit,'r');
subplot(2,3,2),xlim([50 4000]);
subplot(2,3,2),ylim([0.75 1]);
%figure();
subplot(2,3,4),semilogx(x2,b1,'o'),hold,grid,title('Coefficient b1'),xlabel('Tau [s]'),ylabel('Magnitude [ ]');
subplot(2,3,4),semilogx(x2,b1_fit,'r');
subplot(2,3,4),xlim([50 4000]);
subplot(2,3,4),ylim([-0.1 4]);
%figure();
subplot(2,3,5),semilogx(x2,b2,'o'),hold,grid,title('Coefficient b2'),xlabel('Tau [s]'),ylabel('Magnitude [ ]');
subplot(2,3,5),semilogx(x2,b2_fit,'r');
subplot(2,3,5),xlim([50 4000]);
subplot(2,3,5),ylim([-0.01 0.25]);
%figure();
subplot(2,3,6),semilogx(x2,b3,'o'),hold,grid,title('Coefficient b3'),xlabel('Tau [s]'),ylabel('Magnitude [ ]');
subplot(2,3,6),semilogx(x2,b3_fit,'r');
subplot(2,3,6),xlim([50 4000]);
subplot(2,3,6),ylim([-4 0.1]);

% for i=1:length(tau)
%     a1_tau(i) = a1(tau(i));
%     a2_tau(i) = a2(tau(i));
%     b1_tau(i) = b1(tau(i));
%     b2_tau(i) = b2(tau(i));
%     b3_tau(i) = b3(tau(i));   
% end

