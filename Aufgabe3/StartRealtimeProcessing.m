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
settings.inputDeviceID = soundadaptor;
settings.inputChans = inputchans;
settings.outputChans = outputchans;
settings.numberInputChans = inputchans(end) - inputchans(1) +1;
settings.numberOutputChans =  outputchans(end) - outputchans(1) + 1;
settings.allChanList = settings.numberInputChans + settings.numberOutputChans;
settings.fadeInRamp(:, 1) = linspace(0,1,settings.blocksize*settings.FADE_BLOCKS)';
settings.fadeOutRamp(:, 1) = linspace(1,0,settings.blocksize*settings.FADE_BLOCKS)';
settings.fadeStartRamp(:, 1) = linspace(0,1,settings.blocksize*settings.FADE_INOUT)';
settings.fadeEndRamp(:, 1) = linspace(1,0,settings.blocksize*settings.FADE_INOUT)';
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

% Audio realtime loop                                           %here here
% here here here here
drawnow
while (settings.audioprocessing == 1)
    
    settings.frameCount = settings.frameCount + 1;
    if (rem(settings.frameCount,100) == 0)                                  %rem = modulo
        fprintf('Frame %d is processed.\n', settings.frameCount)            %just print out state
    end
    pageNumList = [pageNumList playrec('playrec', nextOutSamples, settings.outputChans, -1, settings.inputChans)];
    
    if(settings.repeatCount==1)
        %This is the first time through so reset the skipped sample count
        playrec('resetSkippedSampleCount');
    end
    
    % pr.runMaxSpeed==true means a very tight while loop is entered until the
    % page has completed whereas when pr.runMaxSpeed==false the 'block' !!!
    % command in playrec is used.  This repeatedly suspends the thread
    % until the page has completed, meaning the time between page
    % completing and the 'block' command returning can be much longer than
    % that with the tight while loop
    if(length(pageNumList) > settings.pageBufCount)         %= if there is something left to compile
        if(settings.runMaxSpeed)
            while(playrec('isFinished', pageNumList(1)) == 0)
            end
        else
            playrec('block', pageNumList(1));               %hold on
        end
        
        %1) Write ready block into output variable
        x = double(playrec('getRec', pageNumList(1)));             % get input
        % tic           -> sample block der raus geschreiben wird
        y = x;                                                      % process audioblock
                                                                    % --> here audio blockprocessing has to be implemented!
        %2) Calculate next block
        % toc         
        
        x=getNextRecordBlock(settings.repeatCount);
        %spetial case: crossfading
        if(rem(settings.repeatCount,200)==0)
        %x
        end
        % write output
        nextOutSamples(:,1:settings.numberOutputChans) = y;         
        %test 
        if (rem(settings.frameCount,500) == 0)                                  %rem = modulo
            %disp(y)              %just print out state
        end
         %end test
        %% playrec
        playrec('delPage', pageNumList(1));           %move fifo buffer forward
        pageNumList = pageNumList(2:end);
        settings.repeatCount = settings.repeatCount + 1;    %loopcounter++

    end
    drawnow
end

playrec('delPage');
fprintf('Loop back complete with %d samples skipped\n', playrec('getSkippedSampleCount'));
return
end

function nextBlock = getNextRecordBlock(currentBlockNumber)
    global settings h;
    currentSliderPos = get(h.SliderDirection, 'Value');

    global settings signals;
    cn = 13;        %myFixChannelNumber
    bs = settings.blocksize;

        
    %stop loop if record is over
    if((currentBlockNumber+1)*bs>=length(signals.spatialSignals(:,cn)))
        nextBlock = [];
        settings.audioprocessing = 0;
        disp('stopped loop because record is over')
        return
    end
    
    nextBlock = signals.spatialSignals(currentBlockNumber*bs:(currentBlockNumber+1)*bs,cn:cn+1);

    %just coose the current slider possition
    %TODO

        
end

