%Aufgabe 1 - Teil 1             *******************************************
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
subplot(2,1,1),
%plot(t,y);
plot(t,yLeft);

%Label left channel:
title('Tonhalle - Left Channel');
xlabel('Time (ms)'); 
ylabel('Amplitude (dB)');

%figure %right channel
subplot(2,1,2),

plot(t,yRight);

%Label right channel:
title('Tonhalle - Right Channel');
xlabel('Time (ms)'); 
ylabel('Amplitude (dB)');




%Aufgabe 1 - Teil 2         ***********************************************

castanetesHRIR = audioread('27 Single Instrument Castanets 44.1 kHz.wav');
castanetesFs = 44100;

tCastanetes= (1: size(castanetesHRIR)) * (1/castanetesFs);

cast_left = castanetesHRIR(1:end, 1);
cast_right = castanetesHRIR(1:end, 2);

%plot raw data
figure 
subplot(2,1,1),
plot(tCastanetes, cast_left);
xlabel('Time (s)'); 
ylabel('Amplitude (dB)');
title('Castanetes 44.1kHz - Left Channel');

subplot(2,1,2),
plot(tCastanetes, cast_right);
xlabel('Time (s)'); 
ylabel('Amplitude (dB)');
title('Castanetes 44.1kHz - Right Channel');

%Resample:
[P,Q] = rat(48000/castanetesFs);
castanetes_48kHz = resample(castanetesHRIR,P,Q);

left48Raw = castanetes_48kHz(1:end, 1);
right48Raw = castanetes_48kHz(1:end, 2);

%Fold Tohalle with left castanetes
folded_left = conv(left48Raw, HRIR(1:end, 1));
folded_right = conv(left48Raw, HRIR(1:end, 2));

foldedCastanetes = [folded_left, folded_right];

%Resample back to 44.1 kHz
folded_44100 = resample(foldedCastanetes, Q, P);

%Calculate time vector
t_folded = (1: size(folded_44100(:,1))) * (1/44100);

%Plot Folded Signal
figure
subplot(2,1,1),
plot(t_folded, folded_44100(:,1));
xlabel('Time (s)'); 
ylabel('Amplitude (dB)');
title('Left Tonalle Channel folded with left Castanets Channel - 44.1 kHz');

subplot(2,1,2),
plot(t_folded, folded_44100(:,2));
xlabel('Time (s)'); 
ylabel('Amplitude (dB)');
title('Right Tonalle Channel folded with left Castanets Channel - 44.1 kHz');

%Export Audio
audiowrite('Tonhalle folded with Left Castanetes Channel - 44100 Sampling Rate.wav', folded_44100(:,1), 44100);
 
%The End
