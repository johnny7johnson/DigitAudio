%Convs();               %incomment to convolute signals
CreateGui();
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
