%% teil1
function preprocess
%%kreieren des (linearen) vektors durch ifft?
load('1deg_LSR4328P_ch03_48NLRNA_2400.mat');
castanetes = audioread('27 Single Instrument Castanets 48.0 kHz.wav');
degrees = [-60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60];
 
counter = 1;
convoluted = zeros(length(castanetes)+length(HRIR)-1, length(degrees)*2);            %init array
%% teil2
%convolution of all channels
'Preprocessing'
for d = degrees
    d  %print
    currentChannel = extractXDegreeHRIR(d, HRIR, MAP);
    cast1_l=conv(currentChannel(:,1), castanetes(:,1));
    cast2_r=conv(currentChannel(:,2), castanetes(:,2));             
    
    convoluted(:, counter) = cast1_l;                %left ear for degree    %rotate also
    counter = counter + 1;
    convoluted(:, counter) = cast2_r;                %right ear for degree
    counter = counter + 1;
end
clear counter;  clear cast1_r; clear cast2_l; clear cast2_r; clear d;
%generate linear function arrays for crossfading blocks.

%givenBlockSize = 1024;                                %as default
global settings signals;
signals.castanetes = castanetes;
signals.spatialSignals = convoluted;
end
%% gui
%RealtimeGUI
%% gui

function plotEm
%just test
figure;
plot(castanetes);
faded = fadeEmUp(castanetes(1:10240,:), 10, 1024);
MyWholeSig = [faded; castanetes(10240:end, :)];
figure;
plot(MyWholeSig);

firstSig = rot90(convoluted(11:12,1+10000:10240+10000));          %rotate -60 degrees
secondSig = rot90(convoluted(13:14,1+10000:10240+10000));         %rotate -50 degrees
crossfaded = crossfade(firstSig,secondSig, 10, 1024);
end

%% functions 
%*********************************************************Functions*******************************************
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

function sig = fadeEmUp(bichannelBlocks, blocks, blocksize)           %given the blocks in which the singla shoud be merged
    line = linspace(0,1, blocks*blocksize);
    sig(:,1) = conv(bichannelBlocks(:,1),line);   
    sig(:,2) = conv(bichannelBlocks(:,2),line);
end

%TODO -> do not convolute - > elementwise multiplication
function sig = fadeEmDown(bichannelBlocks, blocks, blocksize)         %given the blocks in which the singla shoud be merged
    line = linspace(1,0, blocks*blocksize);
    sig(:,1) = conv(bichannelBlocks(:,1),line);
    sig(:,2) = conv(bichannelBlocks(:,2),line);
end

function sig = crossfade(currentSignalBlocks, nextSignalBlocks, blocks, blocksize)
upfaded = fadeEmUp(nextSignalBlocks, blocks, blocksize);
downfaded = fadeEmDown(currentSignalBlocks, blocks, blocksize);
%l mit l und r mit r?
sig(:,1) = conv(upfaded(:,1),downfaded(:,1));
sig(:,2) = conv(upfaded(:,2),downfaded(:,2));
end

% Plan:
% 1) Raumklänge
% 2) GUI -> slider funktioniert zum verstellen im aktuellen band
% 3) Crossfading
% 4) life in die gui bringen 
