%Aufgabe 1 - Teil 1
%Fs = Sample rate = 48000

load('Tonhalle.mat');

%Calculate:
length = 400 * 10^-3;           %400 ms 

sampleNumber = length * Fs;

y=HRIR(1:sampleNumber, 1:2);    %get samples of left an right channel into matrix
yLeft = y(1:end, 1);
yRight = y(1:end, 2);
t= (1:sampleNumber) * (1/Fs);
t = t(1:end)*10^3;              %scale to milliseconds

%Plot:
figure %left channel
%plot(t,y);
plot(t,yLeft);

%Label left channel:
title('Left Channel');
xlabel('Time (ms)'); 
ylabel('Amplitude (dB)');

figure %right channel
plot(t,yRight);

%Label right channel:
title('Right Channel');
xlabel('Time (ms)'); 
ylabel('Amplitude (dB)');


