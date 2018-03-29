% Stimulusgeneration
r=rand(48000,1);
r = r.*1.99;
r=r-1.0;

% Stimulus loading, alternatively
[y,fs,nbits] = wavread('Sine_440Hz_48.0kHz_-3dB_10sec.wav');

% for help type playrec
% for detailled help type e.g. playrec('help','playrec')

if playrec('isInitialised')
    playrec('reset')
else 
   disp(1) 
end

dev = playrec('getDevices');

MACaddress = getMacAdress;
switch MACaddress
    case '00-22-4D-50-A5-FC' % PC hes     
        %pDevice=dev(13) %pairwise output channels
        %rDevice=dev(3) %pairwise input channels
        pDevice=dev(end);
        rDevice=dev(end);
    case '00-1B-38-8F-03-8E' % laptop in1030 win xp
        pr.playDevice = 'M-Audio';
        pr.recDevice = 'M-Audio';
    otherwise
        pr.playDevice = 'Fireface';
        pr.recDevice = 'Fireface';
end   

pDeviceID = pDevice.deviceID
rDeviceID = rDevice.deviceID
%Fs = 48000;
Fs = fs;
duration = Fs;
playChanNum = pDevice.outputChans
recChanNum = rDevice.inputChans
playChan = 1:2;
recChan = 1:2;



playrec('init',Fs,pDeviceID,rDeviceID,playChanNum,recChanNum)

whos y
%pn = playrec('playrec',r,playChan,duration,recChan);
pn = playrec('playrec',[y(:,1) y(:,2)],playChan,-1,recChan);
playrec('block',pn);
[y,chanNum] = playrec('getRec',pn);

playrec('reset')

