% Evaluation of local installed soundcards: Type 'RealtimeProcessing'
% without parameters
%
% Example: 'RealtimeProcessing' to evaluate available sound adaptors
%
% Functionality:
% Input is a 2.0 channel audio signal
% Output are two times a 2.0 channel audio signal, 3 routings are possible:
% (1) Pass 2.0 Input, (2) Process Algorithm A, (3) Process Algorithm B
% A crossfading should be applied when switching between (1), (2) or (3) is done
%
%  InL |   InR |
%      |       |
%|------------------------------------------------|
%|  Pass     |    Algorithm A |    Algorithm B    |
%|------------------------------------------------|
%     OutL1 |   OutR1|        OutL2|   OutR2|        


function RealtimeGUI

global settings h;

settings.blocksize = 512;
settings.samplerate = 44100;
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

h.fig = figure('position', [100,100,320,320],'WindowKeyPressFcn',@KeyboardData,'Color',[1 1 1],'Resize','on','MenuBar','none', ...
    'Units','pixels','NextPlot','replace', 'NumberTitle','off', 'ToolBar','none','Tag','IIS Realtime GUI','Name','Realtime Audioprocessing');
% Alternatively: Screen-size dependent
% scrsz = get(0,'ScreenSize');
% h.fig = figure('position', [0.4*scrsz(3),0.4*scrsz(4),0.2*scrsz(3),0.2*scrsz(4)],'KeyPressFcn',@KeyboardData);

h.StartStopPushButton = uicontrol('style', 'pushbutton','position',[70 240 160 40], ...
    'string' , 'Start Audio Processing','enable', 'inactive', 'buttondownfcn', {@StartStopPushButton});

h.PassRadioButton = uicontrol('style', 'radiobutton','position',[10 200 90 40], 'BackgroundColor',[1 1 1],...
    'string' , '2.0 Pass', 'value', 1,'enable', 'inactive', 'buttondownfcn', {@PassRadioButton});

h.ProcARadioButton = uicontrol('style', 'radiobutton','position',[100 200 90 40], 'BackgroundColor',[1 1 1],...
    'string' , '2.0 Process A', 'value', 0,'enable', 'inactive', 'buttondownfcn', {@ProcARadioButton});

h.ProcBRadioButton = uicontrol('style', 'radiobutton','position',[190 200 100 40], 'BackgroundColor',[1 1 1],...
    'string' , '2.0 Process B', 'value', 0,'enable', 'inactive', 'buttondownfcn', {@ProcBRadioButton});

h.FilterizationOnOff = uicontrol('style', 'text','position',[100 132 80 20], 'BackgroundColor',[1 1 1],...
    'string' , 'Filtering:','enable', 'inactive','horizontalAlignment','left');
h.FilterizationCheckbox = uicontrol('style', 'checkbox','position',[180 135 13 13], ...
    'enable', 'inactive', 'value', settings.Filtering,'buttondownfcn', {@BinauralizationCheckbox});
h.FilterizationMinusPushButton = uicontrol('style', 'pushbutton','position',[180 110 30 20], ...
    'string' , '-','FontWeight','bold','enable', 'inactive', 'buttondownfcn', {@BinauralMinusPushButton});
h.FilterizationPlusPushButton = uicontrol('style', 'pushbutton','position',[210 110 30 20], ...
    'string' , '+','FontWeight','bold','enable', 'inactive', 'buttondownfcn', {@BinauralPlusPushButton});
h.AzimuthNumber = uicontrol('style', 'text','position',[245 107 20 20], 'BackgroundColor',[1 1 1],...
    'string' , num2str(settings.BinAzi),'enable', 'inactive', 'horizontalAlignment','center','buttondownfcn', {@AzimuthNumber});
h.AzimuthText = uicontrol('style', 'text','position',[265 107 30 20], 'BackgroundColor',[1 1 1],...
    'string' , '°Azi','enable', 'inactive','horizontalAlignment','left');

h.ReverbText = uicontrol('style', 'text','position',[100 82 80 20], 'BackgroundColor',[1 1 1],...
    'string' , 'Reverb:','enable', 'inactive','horizontalAlignment','left');
h.ReverbCheckbox = uicontrol('style', 'checkbox','position',[180 88 13 13], ...
    'enable', 'inactive', 'value', settings.Reverb, 'buttondownfcn', {@ReverbCheckbox});
h.ReverbMinusPushButton = uicontrol('style', 'pushbutton','position',[180 63 30 20], ...
    'string' , '-','FontWeight','bold','enable', 'inactive', 'buttondownfcn', {@ReverbMinusPushButton});
h.ReverbPlusPushButton = uicontrol('style', 'pushbutton','position',[210 63 30 20], ...
    'string' , '+','FontWeight','bold','enable', 'inactive', 'buttondownfcn', {@ReverbPlusPushButton});
h.ReverbNumber = uicontrol('style', 'text','position',[245 60 20 20], 'BackgroundColor',[1 1 1],...
    'string' , num2str(settings.DryWet),'enable', 'inactive', 'horizontalAlignment','center','buttondownfcn', {@ReverbNumber});
h.ReverbTextOfTen = uicontrol('style', 'text','position',[265 60 30 20], 'BackgroundColor',[1 1 1],...
    'string' , 'of 10','enable', 'off','horizontalAlignment','left');

h.VolumeLeftText = uicontrol('style', 'text','position',[10 30 140 20],'BackgroundColor',[1 1 1], ...
    'string' , 'Volume A', 'enable', 'inactive');
h.VolumeLeft = uicontrol('style', 'text','position',[10 10 70 20],'BackgroundColor',[1 1 1], ...
    'string' ,  num2str(round(100*settings.volumeL)/10), 'enable', 'inactive');
h.MuteLeft = uicontrol('style','checkbox','position',[80 13 70 20],'BackgroundColor',[1 1 1], ...
    'string' , 'Mute', 'enable', 'inactive','value',settings.muteL,'buttondownfcn', {@MuteLeftCheckbox});

h.VolumeRightText = uicontrol('style', 'text','position',[150 30 140 20], 'BackgroundColor',[1 1 1],...
    'string' , 'Volume B', 'enable', 'on','Tag','Volume Right Soundfield');
h.VolumeRight = uicontrol('style', 'text','position',[150 10 70 20], 'BackgroundColor',[1 1 1],...
    'string' , num2str(round(100*settings.volumeR)/10), 'enable', 'on','Tag','Volume Right Soundfield');
h.MuteRight = uicontrol('style', 'checkbox','position',[230 13 70 20],'BackgroundColor',[1 1 1], ...
    'string' , 'Mute', 'enable', 'inactive','value',settings.muteR,'buttondownfcn', {@MuteRightCheckbox});
end


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
    RealtimeProcessing(settings.blocksize,settings.samplerate); %Start audio-processing
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

function PassRadioButton(hObject, eventdata)
global settings h;
set(h.PassRadioButton, 'value', 1);
set(h.ProcARadioButton, 'value', 0);
set(h.ProcBRadioButton, 'value', 0);
if settings.ProcA == 1
    settings.fadeA2B = 0;
    settings.fadeB2A = 0;
    settings.fadeA2Pass = 1;
    settings.fadeB2Pass = 0;
    settings.fadePass2A = 0;
    settings.fadePass2B = 0;
elseif settings.ProcB == 1
    settings.fadeA2B = 0;
    settings.fadeB2A = 0;
    settings.fadeA2Pass = 0;
    settings.fadeB2Pass = 1;
    settings.fadePass2A = 0;
    settings.fadePass2B = 0;
end
end

function ProcARadioButton(hObject, eventdata)
global settings h;
set(h.PassRadioButton, 'value', 0);
set(h.ProcARadioButton, 'value', 1);
set(h.ProcBRadioButton, 'value', 0);
if settings.Pass == 1
    settings.fadeA2B = 0;
    settings.fadeB2A = 0;
    settings.fadeA2Pass = 0;
    settings.fadeB2Pass = 0;
    settings.fadePass2A = 1;
    settings.fadePass2B = 0;
elseif settings.ProcB == 1
    settings.fadeA2B = 0;
    settings.fadeB2A = 1;
    settings.fadeA2Pass = 0;
    settings.fadeB2Pass = 0;
    settings.fadePass2A = 0;
    settings.fadePass2B = 0;
end
end

function ProcBRadioButton(hObject, eventdata)
global settings h;
set(h.PassRadioButton, 'value', 0);
set(h.ProcARadioButton, 'value', 0);
set(h.ProcBRadioButton, 'value', 1);
if settings.Pass == 1
    settings.fadeA2B = 0;
    settings.fadeB2A = 0;
    settings.fadeA2Pass = 0;
    settings.fadeB2Pass = 0;
    settings.fadePass2A = 0;
    settings.fadePass2B = 1;
elseif settings.ProcA == 1
    settings.fadeA2B = 1;
    settings.fadeB2A = 0;
    settings.fadeA2Pass = 0;
    settings.fadeB2Pass = 0;
    settings.fadePass2A = 0;
    settings.fadePass2B = 0;
end
end

function BinauralizationCheckbox(hObject, eventdata)
global settings h;
if settings.Filtering > 0
    settings.Filtering = 0;
else
    settings.Filtering = 1;
end
set(h.FilterizationCheckbox,'value', settings.Filtering);
set(0, 'currentfigure', h.fig)
end

function BinauralPlusPushButton(hObject, eventdata)
global settings h;
if settings.BinAzi < 180
    settings.BinAzi = settings.BinAzi+10;   %90, orig 60
    set(h.AzimuthNumber,'String',num2str(settings.BinAzi))
end
end

function BinauralMinusPushButton(hObject, eventdata)
global settings h;
if settings.BinAzi > 0
    settings.BinAzi = settings.BinAzi-10;   %90, orig 60
    set(h.AzimuthNumber,'String',num2str(settings.BinAzi))
end
end

function ReverbCheckbox(hObject, eventdata)
global settings h;
if settings.Reverb > 0
    settings.Reverb = 0;
else
    settings.Reverb = 1;
    settings.Filtering = 1;
end
set(h.ReverbCheckbox,'value', settings.Reverb);
set(h.FilterizationCheckbox,'value', settings.Filtering);
set(0, 'currentfigure', h.fig)
end

function ReverbPlusPushButton(hObject, eventdata)
global settings h;
if settings.DryWet < 10
    settings.DryWet = settings.DryWet+1;
    set(h.ReverbNumber,'String',num2str(settings.DryWet))
end
end

function ReverbMinusPushButton(hObject, eventdata)
global settings h;
if settings.DryWet > 0
    settings.DryWet = settings.DryWet-1;
    set(h.ReverbNumber,'String',num2str(settings.DryWet))
end
end


function MuteLeftCheckbox(hObject, eventdata)
global settings h;
if (settings.muteL == 1)
    settings.muteL = 0;
    settings.fadeIn = 1;
    settings.fadeOut = 0;
    
else
    settings.muteL = 1;
    settings.fadeIn = 0;
    settings.fadeOut = 1;
end
settings.muteLPressed = 1;
set(h.MuteLeft,'value',settings.muteL)
set(0, 'currentfigure', h.fig)
end

function MuteRightCheckbox(hObject, eventdata)
global settings h;
if (settings.muteR == 1)
    settings.muteR = 0;
    settings.fadeIn = 1;
    settings.fadeOut = 0;
else
    settings.muteR = 1;
    settings.fadeIn = 0;
    settings.fadeOut = 1;
end
settings.muteRPressed = 1;
set(h.MuteRight,'value',settings.muteR)
set(0, 'currentfigure', h.fig)
end

function KeyboardData(hObject, eventdata)
global settings h;

if (settings.rightArea == 1)
    switch eventdata.Key
        case 'uparrow'
            if (settings.volumeR < 1.0)
                settings.volumeR = settings.volumeR + settings.volumeStep;
                set(h.VolumeRight,'string', num2str(round(100*settings.volumeR)/10));
            end
        case 'downarrow'
            if (settings.volumeR >= settings.volumeStep)
                settings.volumeR = settings.volumeR - settings.volumeStep;
                set(h.VolumeRight,'string', num2str(round(100*settings.volumeR)/10));
            end
        case 'leftarrow'
            set(h.VolumeLeftText,'enable','on');
            set(h.VolumeLeft,'enable','on');
            set(h.MuteLeft,'enable','inactive');
            set(h.VolumeRightText,'enable','off');
            set(h.VolumeRight,'enable','off');
            set(h.MuteRight,'enable','off');
            settings.leftArea = 1;
            settings.rightArea = 0;
        case 'space'
            if (settings.muteR == 1) %Fade In
                settings.muteR = 0;
                settings.fadeIn = 1;
                settings.fadeOut = 0;
            else
                settings.muteR = 1; %Fade Out
                settings.fadeIn = 0;
                settings.fadeOut = 1;
            end
            settings.muteRPressed  = 1;
            set(h.MuteRight,'value',settings.muteR)
            %             muteR = settings.muteR;
            %             muteR
            %             stop = settings.Stop;
            %             stop
    end
else
    switch eventdata.Key
        case 'uparrow'
            if (settings.volumeL < 1.0)
                settings.volumeL = settings.volumeL + settings.volumeStep;
                set(h.VolumeLeft,'string', num2str(round(100*settings.volumeL)/10));
            end
        case 'downarrow'
            if (settings.volumeL >= settings.volumeStep)
                settings.volumeL = settings.volumeL - settings.volumeStep;
                set(h.VolumeLeft,'string', num2str(round(100*settings.volumeL)/10));
            end
        case 'rightarrow'
            set(h.VolumeLeftText,'enable','off');
            set(h.VolumeLeft,'enable','off');
            set(h.MuteLeft,'enable','off');
            set(h.VolumeRightText,'enable','on');
            set(h.VolumeRight,'enable','on');
            set(h.MuteRight,'enable','inactive');
            settings.leftArea = 0;
            settings.rightArea = 1;
        case 'space'
            if (settings.muteL == 1) %Fade In
                settings.muteL = 0;
                settings.fadeIn = 1;
                settings.fadeOut = 0;
            else
                settings.muteL = 1; %Fade Out
                settings.fadeIn = 0;
                settings.fadeOut = 1;
            end
            settings.muteLPressed = 1;
            set(h.MuteLeft,'value',settings.muteL)
    end
end
switch eventdata.Key
    case {'s','S'}
        StartStopPushButton(hObject, eventdata);
    case {'p','P'}
        PassRadioButton(hObject, eventdata);
    case {'a','A'}
        ProcARadioButton(hObject, eventdata);
    case {'b','B'}
        ProcBRadioButton(hObject, eventdata);
    case {'q','Q','c','C'}
        settings.StartButton == 0;
        StartStopPushButton(hObject, eventdata);
        close(h.fig);
    case {'+',''+''}
        PlusPushButton(hObject, eventdata);
    case {'-','''-'''}
        MinusPushButton(hObject, eventdata);
end
keycode = double(get(h.fig,'CurrentCharacter'));
if (~isempty(keycode))
    switch keycode
        case 43
            PlusPushButton(hObject, eventdata);
        case 45
            MinusPushButton(hObject, eventdata);
        otherwise
    end
end
end
