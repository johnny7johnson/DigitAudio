
%Aufgabe1
load('1deg_LSR4328P_ch01_48NLRNA_2400.mat');
ch1 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch1,Fs);
title('Ch 1 - 0° head rotation');


%Override ch1 variables with ch2
load('1deg_LSR4328P_ch02_48NLRNA_2400.mat');
ch2 = extractZeroDegreeHRIR(HRIR, MAP);
plotHRIR(ch2, Fs);
title('Ch 2 - 0° head rotation');

%Aufgabe 2
%Convolution:
%
% Mergler Johanna, Häußermann Lea, Kahn Simon, Hauck Simon
%
%Die Blocklänge soll 4096 (zero padding), 512 oder 64 Samples betragen (3 Versionen)
CastanetesHRIR = audioread('27 Single Instrument Castanets 48.0 kHz.wav');

convTotalSingal(64, CastanetesHRIR(:,1), CastanetesHRIR(:,2), ch1, ch2, Fs);       %Blocksize 64
convTotalSingal(512, CastanetesHRIR(:,1), CastanetesHRIR(:,2), ch1, ch2, Fs);       %Blocksize 512
convTotalSingal(4096, CastanetesHRIR(:,1), CastanetesHRIR(:,2), ch1, ch2, Fs);       %Blocksize 4096


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
%load 0° Head rotation HRIR
IndexOfZeroInMap = findZeroDegreesFirstIndex(ChannelMAP);
ZeroDegreePosition = (IndexOfZeroInMap*2)-1;                      %because gleft and right channel
ch = MultiChannelHRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
end


% *************************************************************************
% Convolute and plot the left channel of the wavefile with the ch01,ch02 left
% and the right channel of the wavefile with the ch01,ch02 right channels
% *************************************************************************
function convTotalSingal(blockSize, castanetsLeft, castanetsRight, ch1, ch2, Fs)
    
    ch01_leftEar = ch1(:,1);
    ch01_rightEar = ch1(:,2);
    ch02_leftEar = ch2(:,1);
    ch02_rightEar = ch2(:,2);
    
    
    %Folded singal for ch01
    ch01_left = convBlock(castanetsLeft, ch01_leftEar, blockSize);
    ch01_right = convBlock(castanetsLeft, ch01_rightEar, blockSize);
    
    %Folded signal for ch02
    ch02_left = convBlock(castanetsRight, ch02_leftEar, blockSize);
    ch02_right = convBlock(castanetsRight, ch02_rightEar, blockSize);
    
    %Add the corresponding channels
    totalLeft = ch01_left + ch02_left;
    totalRight = ch01_right + ch02_right;
    
    %toSec = (1/Fs) * 10^3;
    %tL = (1: size(totalLeft)) * toSec;
    %tR = (1: size(totalRight)) * toSec;

    figure
    subplot(2,1,1);
    plot( totalLeft);
    xlabel('Time ');
    ylabel('Amplitude');
    title(strcat('WaveFile left ear, Blocksize ', num2str(blockSize)));
    
    
    subplot(2,1,2);
    plot( totalRight);
    xlabel('Time ');
    ylabel('Amplitude');
    title(strcat('WaveFile right ear, Blocksize ', num2str(blockSize)));
    
end


% *************************************************************************
% Fold a block with a filter file for the given block size
% *************************************************************************
function folded = convBlock(waveFile, filter, blockSize)

    if length(filter) > blockSize
        padding = length(filter);
    else 
        padding = blockSize;
    end 

    padding = length(filter);    %Create result array with the size of the wavefile and the filter size
    folded = zeros(1, length(waveFile)+padding);


    
    %Iterate through wavefile and jump to the start if each block
    for k=1:blockSize:length(waveFile)-blockSize+1                    %-blockSize cheating?
        
        %Create the block of the wavefile
        block = waveFile(k:k+blockSize-1);
        
        %Fold block
        foldedBlock = conv(block, filter);
        
        %Write the folded block in the result array by adding the 
        %current value to the stored value
        for i=1:length(foldedBlock)
            folded(k+i-1) = foldedBlock(i) + folded(k+i-1);
        end
    end
end

