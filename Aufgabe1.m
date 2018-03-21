%Aufgabe 1 - Teil 1
%Fs = Sample rate = 48000

load('Tonhalle.mat');

%Rechnen
length = 400 * 10^-3;        %400 ms 

sampleNumber = int16(400*1000000*(1/48000));
sampleNumber = length * Fs;

y=HRIR(1:sampleNumber, 1:2);
t= (1:sampleNumber) * (1/Fs);

%mySmallArray = HRIR(1:sampleNumber,1:2);

%y = mySmallArray(1:end,1)*length*Fs; 
%t = (1/400)*Fs;
%t=(1:length(y))'/Fs;

%Zeichnen
plot(t,y);

%Beschriften:
xlabel('Time (ms)'); 
ylabel('Amplitude (dB)');