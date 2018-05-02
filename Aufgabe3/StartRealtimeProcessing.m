% Evaluation of local installed soundcards: Type 'RealtimeProcessing'
% without parameters
%
% Example: 'RealtimeProcessing' to evaluate available sound adaptors
% Example: 'RealtimeProcessing (22, [9:10], [7:8], 256, 48000)'


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
    disp(length(bichannelBlocks(:,1)));
    line = rot90(linspace(0,1, blocks*blocksize),3);
    disp(length(line));
    sig(:,1) = bichannelBlocks(:,1).*line;   
    sig(:,2) = bichannelBlocks(:,2).*line;
end

function sig = fadeEmDown(bichannelBlocks, blocks, blocksize)         %given the blocks in which the singal shoud be merged
    disp(length(bichannelBlocks(:,1)));
    
line = rot90(linspace(1,0, blocks*blocksize),3);
        disp(length(line));

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

