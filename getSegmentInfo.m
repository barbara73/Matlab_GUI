function [sig, t] = getSegmentInfo(path, dateNum, timeNum, length, fs, channels, binSize)
%GETSEGMENTINFO


%Get nbr of samples
info = dir(path);
nbSamples = info.bytes / channels / binSize;

desSampl = round((timeNum - dateNum)*60*60*24*fs); 
index = desSampl > cumsum(nbSamples);
desSampl = desSampl - sum(index.*nbSamples);
desBytes = desSampl*binSize*channels;
fid = fopen(path, 'r');%%%%%%%%%%

fseek(fid, desBytes, -1);
if binSize == 4
    sig = fread(fid, [channels, length*fs], 'single')';
elseif binSize == 8
    sig = fread(fid, [channels, length*fs], 'double')';
end

t = (1:1:size(sig, 1))/fs;
end