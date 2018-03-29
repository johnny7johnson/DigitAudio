load('1deg_LSR4328P_ch01_48NLRNA_2400.mat');

%load 0° Head rotation HRIR
ZeroDegreePosition = (61*2)-1;                      %because always left and right channel
ch1 = HRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
%Plot HRIR
figure
t= (1: size(ch1)) * (1/Fs) * 10^3;
plot(t, ch1);
ylabel('Amplitude');
xlabel('Time (ms)');
title('Ch 1 - 0° head rotation');


%Override ch1 variables with ch2
load('1deg_LSR4328P_ch02_48NLRNA_2400.mat');
ch2 = HRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
%Plot HRIR
figure
t= (1: size(ch2)) * (1/Fs) * 10^3;
plot(t, ch2);
ylabel('Amplitude');
xlabel('Time (ms)');
title('Ch 2 - 0° head rotation');

