
load('1deg_LSR4328P_ch01_48NLRNA_2400.mat');
ch1 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch1,Fs);
title('Ch 1 - 0° head rotation');


%Override ch1 variables with ch2
load('1deg_LSR4328P_ch02_48NLRNA_2400.mat');
ch2 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch2, Fs);
title('Ch 2 - 0° head rotation');



%********************************************Function section
function plotHRIR(myHRIR, Fs)
figure
t= (1: size(myHRIR)) * (1/Fs) * 10^3;
plot(t, myHRIR);
ylabel('Amplitude');
xlabel('Time (ms)');
end

function ind =  findZeroDegreesFirstIndex(myMAP)
ind = find(myMAP(2,:)>-1, 1);
end

function ch = extractZeroDegreeHRIR(MultiChannelHRIR, ChannelMAP)
%load 0° Head rotation HRIR
IndexOfZeroInMap = findZeroDegreesFirstIndex(ChannelMAP);
ZeroDegreePosition = (IndexOfZeroInMap*2)-1;                      %because always left and right channel
ch = MultiChannelHRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
end