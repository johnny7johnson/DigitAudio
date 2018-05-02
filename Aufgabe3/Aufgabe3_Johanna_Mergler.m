function Aufgabe3
preprocess();
CreateGui();
end

%%RealtimeProcessing
function StartRealtimeProcessing (blocksize ,samplerate)

global settings

% init playrec
if playrec('isInitialised')
    playrec('reset')
else
    disp('Playrec initialization');
end

% Audio-settings, host computer dependent
% tmp_fn = 'getMacAdress.tmp';
dos(['getMac /NH > ' 'getMacAdress.tmp']);
mac_adr = char(textread('getMacAdress.tmp', '%s %*s'));
MACaddress = mac_adr(1,:);
switch MACaddress
    case '90-2B-34-57-4C-F4'
        settings.playDevice = devices(max(size(devices))).deviceID;
    case '00-22-4D-50-A5-FC'
        soundadaptor = 14;
        inputchans = [1:2]; 
        outputchans = [1:2];
    otherwise                   %--- default
        soundadaptor = 4;       %--> adapt to your own settings (ASIO4all)
        inputchans = [1:2];
        outputchans = [1:2];
end

if nargin < 2
    devices = playrec('getDevices');
    fprintf('Sound adaptor devices available at this computer:\n\n')
    for i = 1:max(size(devices))
        fprintf('%s ---> using %s driver at adaptor ID %d driving %d input-channels and %d output-channels\n', devices(i).name, devices(i).hostAPI, devices(i).deviceID, devices(i).inputChans, devices(i).outputChans);
    end
    return
else
    fprintf('\n---> Starting audio realtime-processing loop\n\n')
    devices = playrec('getDevices');
    i = soundadaptor+1;
    fprintf('%s using %s driver at adaptor ID %d driving %d input-channels and %d output-channels was chosen\n\n', devices(i).name, devices(i).hostAPI, devices(i).deviceID, devices(i).inputChans, devices(i).outputChans);
    fprintf('Input --> Adaptor channel %d\n', inputchans);
    fprintf('Output -> Adaptor channel %d\n', outputchans);
    fprintf('\n');
end

settings.outputDeviceID = soundadaptor;
%settings.inputDeviceID = soundadaptor;
settings.inputDeviceID = -1;
settings.inputChans = inputchans;
settings.outputChans = outputchans;
settings.numberInputChans = inputchans(end) - inputchans(1) +1;
settings.numberOutputChans =  outputchans(end) - outputchans(1) + 1;
settings.allChanList = settings.numberInputChans + settings.numberOutputChans;
settings.fadeInRamp = linspace(0,1,settings.blocksize*settings.FADE_BLOCKS)';
settings.fadeOutRamp = linspace(1,0,settings.blocksize*settings.FADE_BLOCKS)';
settings.fadeStartRamp = linspace(0,1,settings.blocksize*settings.FADE_INOUT)';
settings.fadeEndRamp = linspace(1,0,settings.blocksize*settings.FADE_INOUT)';
settings.loop=1;
settings.counter=0;
settings.blocksize = blocksize;

% Init buffers for playrec, a sampleblock is called page in playrec
pageNumList = [];
nextOutSamples = zeros(settings.blocksize, settings.numberOutputChans);
nextInSamples = zeros(settings.blocksize, settings.numberInputChans);

% Playrec settings
settings.frameCount = 0;
settings.startSample = 1;
settings.pageBufCount = 1;
settings.repeatCount = 1;
settings.runMaxSpeed = false;
settings.init = 0;
playrec('init', settings.samplerate, settings.outputDeviceID, settings.inputDeviceID)
warning('off');

y=zeros(settings.blocksize,4);                                  %init the output
                                                         %warum *4 matrix?
                                                         %%TODO? whyyyy
settings.crossfading = false;
loopdegree = settings.DEGREES;

% Audio realtime loop                                           %here here
% here here here here
drawnow
while (settings.audioprocessing == 1)
    settings.frameCount = settings.frameCount + 1;
    if (rem(settings.frameCount,100) == 0)                                  %rem = modulo
        fprintf('Frame %d is processed.\n', settings.frameCount)            %just print out state
    end
    
    %get next block(s) to play
   if(loopdegree == settings.DEGREES)   %case 
        nextOut=getNextRecordBlock(settings.repeatCount);
   else     %case Crossfading
       %nextOut = zeros(10*512,2);
       disp('Crossfading NOW'); %TODO do crossfading here
       firstSig = extractXDegreeChannels(settings.repeatCount, settings.FADE_BLOCKS, loopdegree);
       secondSig = extractXDegreeChannels(settings.repeatCount, settings.FADE_BLOCKS, settings.DEGREES);
  
       nextOut = crossfade(firstSig,secondSig, settings.FADE_BLOCKS, settings.blocksize);
       settings.repeatCount = settings.repeatCount + settings.FADE_BLOCKS -1;
   end
   
   %process next block(s)
   pageNumList = [pageNumList playrec('play', nextOut, settings.outputChans)];        %queue into output queue (buffer)

   if(settings.repeatCount==1)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
   end
    
   %play the next block(s)
    if(length(pageNumList) > settings.pageBufCount)
        if(settings.runMaxSpeed)
            while(playrec('isFinished', pageNumList(1)) == 0)
            end
        else        
            playrec('block', pageNumList(1));
        end

        pageNumList = pageNumList(2:end);
    end
    settings.repeatCount = settings.repeatCount + 1; %loopcounter++
    loopdegree = settings.DEGREES;      %mark which direction has been selected
    drawnow
end

playrec('delPage');
fprintf('Loop back complete with %d samples skipped\n', playrec('getSkippedSampleCount'));
return
end

function nextBlock = getNextRecordBlock(currentBlockNumber)
    global settings;
    nextBlock = extractXDegreeChannels(currentBlockNumber, 1, settings.DEGREES);
end

function blocks = extractXDegreeChannels(currentBlockNumber, blockCount, degree)
 global settings signals;
 global settings;
 ind = find(signals.dirMap(:)==degree, 1);
    cn = 2*ind-1;           %channelnumber       
    bs = settings.blocksize;
    
        %stop loop if record is over
    if((currentBlockNumber+1)*bs>=length(signals.spatialSignals(:,cn)))
        blocks = [];
        settings.audioprocessing = 0;
        settings.repeatCount = 1;
        disp('stopped loop because record is over')
        return
    end
    
    blocks = signals.spatialSignals(currentBlockNumber*bs:(currentBlockNumber+blockCount)*bs-1,cn:cn+1);
end

function sig = fadeEmUp(bichannelBlocks, blocks, blocksize)           %given the blocks in which the singal shoud be merged
    line = rot90(linspace(0,1, blocks*blocksize),3);
    sig(:,1) = bichannelBlocks(:,1).*line;   
    sig(:,2) = bichannelBlocks(:,2).*line;
end

function sig = fadeEmDown(bichannelBlocks, blocks, blocksize)         %given the blocks in which the singal shoud be merged
    line = rot90(linspace(1,0, blocks*blocksize),3);
    sig(:,1) = bichannelBlocks(:,1).*line;
    sig(:,2) = bichannelBlocks(:,2).*line;
end

function sig = crossfade(currentSignalBlocks, nextSignalBlocks, blocks, blocksize)
upfaded = fadeEmUp(nextSignalBlocks, blocks, blocksize);
downfaded = fadeEmDown(currentSignalBlocks, blocks, blocksize);
%l mit l und r mit r?
sig(:,1) = upfaded(:,1) + downfaded(:,1);
sig(:,2) = upfaded(:,2) + downfaded(:,2);
end


%% GUI
function CreateGui

global settings h;

settings.blocksize = 512;
settings.samplerate = 48000;
settings.volumeL = 1.0;
settings.volumeR = 1.0;
settings.volumeStep  = 0.01;
settings.muteL = 0;
settings.muteR = 0;
settings.keyboardUp = 0.0;
settings.keyboardDown = 0.0;
settings.keyboardLeft = 0.0;
settings.keyboardRight = 0.0;
settings.leftArea = 0;
settings.rightArea = 1;
settings.StartButton = 1;
settings.StopButton = 0;
settings.Pass = 1;
settings.ProcA = 0;
settings.ProcB = 0;
settings.fadeA2B = 0;
settings.fadeB2A = 0;
settings.fadeA2Pass = 0;
settings.fadeB2Pass = 0;
settings.fadePass2A = 0;
settings.fadePass2B = 0;
settings.FADE_BLOCKS = 8;               % crossfading blocks
settings.FADE_INOUT = 96;               % start/stop blocks
settings.Filtering = 0;
settings.Reverb = 0;
settings.DryWet = 7;
settings.BinAzi = 170;
settings.initFilterA = 1;
settings.DEGREES = 0;

h.fig = figure('position', [800,200,320,420],'WindowKeyPressFcn',@KeyboardData,'Color',[1 1 1],'Resize','on','MenuBar','none', ...
    'Units','pixels','NextPlot','replace', 'NumberTitle','off', 'ToolBar','none','Tag','IIS Realtime GUI','Name','Realtime Audioprocessing');

h.StartStopPushButton = uicontrol('style', 'pushbutton','position',[70 340 160 40], ...
    'string' , 'Start Audio Processing','enable', 'inactive', 'buttondownfcn', {@StartStopPushButton});

h.BlocksizeLabel = uicontrol('Style','text',...
        'Position',[20 300 80 18],...
        'String', 'Blocksize:');

h.RadioButton64 = uicontrol('style', 'radiobutton','position',[10 260 90 40], 'BackgroundColor',[1 1 1],...
    'string' , '64 Samples', 'value', 0,'enable', 'inactive', 'buttondownfcn', {@RadioButton64});

h.RadioButton512 = uicontrol('style', 'radiobutton','position',[100 260 90 40], 'BackgroundColor',[1 1 1],...
    'string' , '512 Samples', 'value', 1,'enable', 'inactive', 'buttondownfcn', {@RadioButton512});

h.RadioButton1024 = uicontrol('style', 'radiobutton','position',[190 260 100 40], 'BackgroundColor',[1 1 1],...
    'string' , '1024 Samples', 'value', 0,'enable', 'inactive', 'buttondownfcn', {@RadioButton1024});

h.BlocksCountLabel = uicontrol('Style','text',...
        'Position',[20 230 120 18],...
        'String', 'Number of Blocks:');
    
h.SliderBlocks = uicontrol('Style', 'Slider', 'position',[30 190 160 30], ...
          'SliderStep', [1/10 1/10], ...
          'Min', 1, 'Max', 10, 'Value', settings.FADE_BLOCKS, ...
          'Callback', {@SliderBlocksCallback});
      
h.SliderBlocksDisplay = uicontrol('Style','text',...
        'Position',[200 195 25 20],...
        'String', num2str(settings.FADE_BLOCKS));
    
h.BlocksCountLabel = uicontrol('Style','text',...
        'Position',[20 130 120 18],...
        'String', 'Input Direction:');
    
h.SliderDirection = uicontrol('Style', 'Slider', 'position',[50 70 220 40], ...
          'SliderStep', [1/10 1/10], ...
          'Min', -60, 'Max', 60, 'Value', settings.DEGREES, ...
          'Callback', {@SliderDirectionCallback});
      
h.SoundDirectionLabel = uicontrol('Style','text',...
        'Position',[70 45 180 18],...
        'String', strcat(num2str(settings.DEGREES), ' °'));      
      
end  %end gui


function StartStopPushButton(hObject, eventdata)
global settings h;
if (settings.StartButton == 1)
    settings.fadeIn = 1;
    settings.fadeOut = 0;
    settings.audioprocessing = 1;
    settings.StartButton = 0;
    settings.StopButton = 1;
    settings.Start = 1;
    settings.Stop = 0;
    set(h.StartStopPushButton, 'String', 'Stop Audio Processing');
    StartRealtimeProcessing(settings.blocksize,settings.samplerate); %Start audio-processing
else
    settings.fadeIn = 0;
    settings.fadeOut = 1;
    settings.audioprocessing = 0;
    settings.StartButton = 1;
    settings.StopButton = 0;
    settings.Start = 0;
    settings.Stop = 1;
    set(h.StartStopPushButton, 'String', 'Start Audio Processing');
end
end

function RadioButton64(hObject, eventdata)
global settings h;
if (settings.StartButton == 1)
set(h.RadioButton64, 'value', 1);
set(h.RadioButton512, 'value', 0);
set(h.RadioButton1024, 'value', 0);
h.blocksize = 64;
end
end

function RadioButton512(hObject, eventdata)
global settings h;
if (settings.StartButton == 1)
set(h.RadioButton64, 'value', 0);
set(h.RadioButton512, 'value', 1);
set(h.RadioButton1024, 'value', 0);
h.blocksize = 512;
end
end

function RadioButton1024(hObject, eventdata)
global settings h;
if (settings.StartButton == 1)
set(h.RadioButton64, 'value', 0);
set(h.RadioButton512, 'value', 0);
set(h.RadioButton1024, 'value', 1);
h.blocksize = 1024;
end
end

function SliderBlocksCallback(hObject, eventdata)
global settings h;
settings.FADE_BLOCKS = round(get(hObject, 'Value'));
set(hObject, 'Value', settings.FADE_BLOCKS);
set(h.SliderBlocksDisplay, 'String', num2str(settings.FADE_BLOCKS));
end

function SliderDirectionCallback(hObject, eventdata)
global settings h;
settings.DEGREES = round(get(hObject, 'Value'), -1);        %round to 10 degrees
set(hObject, 'Value', settings.DEGREES);
set(h.SoundDirectionLabel, 'String', strcat(num2str(settings.DEGREES),' °'));

end


%% preprocessing
function preprocess
%%kreieren des (linearen) vektors durch ifft?
load('1deg_LSR4328P_ch03_48NLRNA_2400.mat');
castanetes = audioread('27 Single Instrument Castanets 48.0 kHz.wav');
degrees = [-60, -50, -40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60];
 
counter = 1;
convoluted = zeros(length(castanetes)+length(HRIR)-1, length(degrees)*2);            %init array

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
signals.dirMap = [60 50 40 30 20 10 0 -10 -20 -30 -40 -50 -60];
end


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
