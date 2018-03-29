load('1deg_LSR4328P_ch01_48NLRNA_2400.mat');

%load 0° Head rotation HRIR
ZeroDegreePosition = (61*2)-1;                      %because always left and right channel
ch1 = HRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);

%Override ch1 variables with ch2
load('1deg_LSR4328P_ch02_48NLRNA_2400.mat');
ch2 = HRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
