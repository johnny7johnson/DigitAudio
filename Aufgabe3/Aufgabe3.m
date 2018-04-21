%% teil1

%%kreieren des (linearen) vektors durch ifft?
load('1deg_LSR4328P_ch03_48NLRNA_2400.mat');
castanetes = audioread('27 Single Instrument Castanets 48.0 kHz.wav');
degrees = [-60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60];
 
counter = 1;
convoluted = zeros(length(degrees)*2, length(castanetes)+length(HRIR)-1);            %init array
%% teil2
%convolution of all channels
for d = degrees
    d  %print
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
clear counter; clear cast1_l; clear cast1_r; clear cast2_l; clear cast2_r; 
%generate linear function arrays for crossfading blocks.

givenBlockSize = 1024;                                %as default

%% gui
RealtimeGUI
%% gui

%just test
figure;
plot(castanetes);
faded = fadeEmUp(castanetes(1:10240,:), 10, 1024);
MyWholeSig = [faded; castanetes(10240:end, :)];
figure;
plot(MyWholeSig);



%% functions 
%*********************************************************Functions********
function ch = extractXDegreeHRIR(degree, MultiChannelHRIR, ChannelMAP)
%load 0° Head rotation HRIR
IndexOfZeroInMap = findXDegreesFirstIndex(degree, ChannelMAP);
ZeroDegreePosition = (IndexOfZeroInMap*2)-1;                      %because gleft and right channel
ch = MultiChannelHRIR(1:end, ZeroDegreePosition:ZeroDegreePosition+1);
end

function ind =  findXDegreesFirstIndex(degree, myMAP)
searchTerm = degree - 1;
ind = find(myMAP(2,:)>searchTerm, 1);
end

function sig = fadeEmUp(bichannelBlocks, blocks, blocksize)         %given the blocks in which the singla shoud be merged
    line = linspace(0,1, blocks*blocksize);
    sig(:,1) = conv(bichannelBlocks(:,1),line);   
    sig(:,2) = conv(bichannelBlocks(:,2),line);
end

function sig = fadeEmDown(bichannelBlocks, blocks, blocksize)         %given the blocks in which the singla shoud be merged
    line = linspace(1,0, blocks*blocksize);
    sig(:,1) = conv(bichannelBlocks(:,1),line);
    sig(:,2) = conv(bichannelBlocks(:,2),line);
end

% Plan:
% 1) Raumklänge
% 2) GUI -> slider funktioniert zum verstellen im aktuellen band
% 3) Crossfading
% 4) life in die gui bringen 
