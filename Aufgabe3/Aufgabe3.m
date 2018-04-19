%% teil1

%%kreieren des (linearen) vektors durch ifft?
load('1deg_LSR4328P_ch03_48NLRNA_2400.mat');
castanetes = audioread('27 Single Instrument Castanets 48.0 kHz.wav');
degrees = [-60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60];
 
ch = extractXDegreeHRIR(-60, HRIR, MAP);
counter = 1;
convoluted = zeros(length(degrees)*2, length(castanetes)+length(HRIR)-1);            %init array
%% teil2
%convolution of all channels
for d = degrees
    d
    currentChannel = extractXDegreeHRIR(d, HRIR, MAP);
    cast1_l=conv(currentChannel(:,1), castanetes(:,1));
    cast1_r=conv(currentChannel(:,2), castanetes(:,1)); 
    cast2_l=conv(currentChannel(:,1), castanetes(:,2));
    cast2_r=conv(currentChannel(:,2), castanetes(:,2)); 
    
    convoluted(counter,:) = cast1_l + cast2_l;                %left ear for degree 
    counter = counter + 1;
    convoluted(counter,:) = cast1_r + cast2_r;                %right ear for degree
    counter = counter + 1;
end

%% gui
RealtimeGUI
%% gui

%*********************************************************Functions********
function ch = extractXDegreeHRIR(degree, MultiChannelHRIR, ChannelMAP)
%load 0� Head rotation HRIR
IndexOfZeroInMap = findXDegreesFirstIndex(degree, ChannelMAP);
ZeroDegreePosition = (IndexOfZeroInMap*2)-1;                      %because gleft and right channel
ch = MultiChannelHRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
end

function ind =  findXDegreesFirstIndex(degree, myMAP)
searchTerm = degree - 1;
ind = find(myMAP(2,:)>searchTerm, 1);
end
