
load('1deg_LSR4328P_ch01_48NLRNA_2400.mat');
ch1 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch1,Fs);
title('Ch 1 - 0� head rotation');


%Override ch1 variables with ch2
load('1deg_LSR4328P_ch02_48NLRNA_2400.mat');
ch2 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch2, Fs);
title('Ch 2 - 0� head rotation');

%Convolution:
%Aufgabe
%Die Blockl�nge soll 4096 (zero padding), 512 oder 64 Samples betragen (3 Versionen)
CastanetesHRIR = audioread('27 Single Instrument Castanets 48.0 kHz.wav');
test = convoluteBlockwise(CastanetesHRIR(:,1), ch1, 512);


%********************************************Functions section************
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
%load 0� Head rotation HRIR
IndexOfZeroInMap = findZeroDegreesFirstIndex(ChannelMAP);
ZeroDegreePosition = (IndexOfZeroInMap*2)-1;                      %because always left and right channel
ch = MultiChannelHRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
end

function convSignal = convoluteBlockwise(audioTrackChannel, surroundSound, blockSize)
%Aufgabe
%Implementieren Sie eine blockweise Faltung mit �berlappung
%Verwenden Sie f�r die Blockverarbeitung eine for-Schleife und Modulo-Indizierung.
left = [];
right = [];
for i = 1:blockSize:size(audioTrackChannel)
    %convolute signal with left an right surround sound cannels 
    left = [left, conv(audioTrackChannel((i-1)*blockSize+1:i*blockSize), surroundSound(1:end, 1))];
    right = [right, conv(audioTrackChannel((i-1)*blockSize+1:i*blockSize), surroundSound(1:end, 2))];

end 
convSignal = [left, right];


%Fourier: transforma and reverse transform
%test = fft(CastanetesHRIR);            %make fourier tranformation
%reversed = ifft(test);                 %reverse it to normal signal
%plot(CastanetesHRIR - test);           %Check differnce between tranformed
                                        %and original signal
                                        %=> do this later with aufgabe1
end

function folded = convBlockwise(audioTrackChannel, surroundSound, blockSize)

    folded = zeros(1, length(audioTrackChannel) + length(blockSize));
    for k = 1:blockSize:length(audioTrackChannel)
        block = audioTrackChannel(k:k+blockSize-1);
        foldedBlock = conv(block, surroundSound);
        for i=1:length(foldedBlock)
           folded(k+i-1) = foldedBlock(i) + folded(k+i-1); 
        end
    end

end