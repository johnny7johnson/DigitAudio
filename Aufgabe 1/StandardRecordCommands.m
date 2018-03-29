r = audiorecorder(48000, 16, 1);
record(r);     % speak into microphone...
pause(r);
p = play(r);   % listen
resume(r);     % speak again
stop(r);
p = play(r);   % listen to complete recording
mySpeech = getaudiodata(r, 'int16'); % get data as int16 array