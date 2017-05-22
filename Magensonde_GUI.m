function [] = Magensonde_GUI()
%MAGENSONDE_GUI opens GUI:
%   choose patient
%   choose measurement
%   choose segment -> valid, invalid, invalid ECG
%   opens new GUI for displaying gTec and iXtrend of each segment
%
%   2. Mai 2017 Barbara Jesacher

%% FIGURE
S.figure = figure('units', 'pixels',...
                  'position', [500 500 200 180],...
                  'menubar', 'none',...
                  'name', 'Magensonde_GUI',...
                  'numbertitle', 'off',...
                  'resize', 'on');
%% STRING
S.STR1 = {'PN01';'PN02';'PN03';'PN04';'PN05';'PN09';'PN10';'PN11';'PN12';'PN13'};
S.STR2 = {'MN01';'MN02';'MN03';'MN04';'MN05'};
S.STR3 = {'valid'; 'invalid'; 'invalid ECG'};
%% TEXT
S.text = uicontrol('style', 'text',...
                   'unit', 'pix',...
                   'position', [20 130 150 30],...
                   'string', 'Choose measurement:',...
                   'enable', 'inactive',...
                   'fontsize', 14,...
                   'callback', {@text_call, S});
%% POP UP
S.popup(1) = uicontrol('style', 'pop',...
                       'unit', 'pix',...
                       'position', [20 90 90 30],...
                       'string', S.STR1);           
S.popup(2) = uicontrol('style', 'pop',...
                       'unit', 'pix',...
                       'position', [20 70 90 30],...
                       'string', S.STR2);          
S.popup(3) = uicontrol('style', 'pop',...
                       'unit', 'pix',...
                       'position', [20 50 90 30],...
                       'string', S.STR3);          
%% PUSH BUTTON
S.pushB = uicontrol('style', 'pushbutton',...
                   'unit', 'pix',...
                   'position', [115 70 55 30],...
                   'backgroundcolor', 'w',...
                   'HorizontalAlign', 'left',...
                   'string', 'LOAD',...
                   'fontsize', 14,...
                   'callback', {@pushB_call, S});
S.choice = [0 0 0];
set(S.popup(:), 'call', {@popup_call, S});             


%% function for push button -> load data
function [] = pushB_call(varargin)
S = varargin{3};
choice = get(S.popup(:), {'string', 'value'});
T.patient = choice{1,1}{choice{1,2}};
T.measure = choice{2,1}{choice{2,2}};
path1 = '/Volumes/data-ti/HuCE/HuCE-microLab/PretermEECG/';
path = strcat(path1, '10_ClinicalStudy/01_PilotTrial/SynchronisedData/');
addpath(genpath(strcat(path1, '12_Algorithm/SharedCode/ShowOutput')));
pathFolder = strcat(path, T.patient, '/', T.measure, '/');

for ii = 1:3
    fprintf(' %s\n', deblank(choice{ii,1}{choice{ii,2}}))
end
% load Annotations.csv
fid = fopen(strcat(pathFolder, T.patient, T.measure, '_Annotations.csv'));
data_annot = textscan(fid, '%s%s%s%s%s%s', 'delimiter', ',');
fclose(fid);
disp '... annotations loaded'

myfolder = pathFolder;
file = dir(myfolder);

filename = struct2cell(file);
count = 0;

for aa = 1 : size(filename, 2)
    [~, wholeName, ext] = fileparts(filename{1, aa});
    if strcmp(ext, '.bin')
        count = count + 1;
        indPoint(count) = find(wholeName == '.');
        ind{count} = find(wholeName == '_');
        newFileName{count} = wholeName;
    end
end
try
    filename_ix = newFileName{1,3};
    strIxtrend = filename_ix(ind{1,3}(1):indPoint(3)+3);
    dateString_I = filename_ix(ind{1,3}(2)+1:indPoint(3)+3);
catch
    disp 'there are no iXtrend signals'
end

filename_gtec = newFileName{1,1};
strGTec = filename_gtec(ind{1,1}(1):indPoint(1)+3);
dateString_G = filename_gtec(ind{1,1}(3)+1:indPoint(1)+3);

% segment 
annotations.time = str2double(data_annot{1,2});
annotations.id = str2double(data_annot{1,1});
annotations.values = data_annot{1,6};
T.segment = choice{3,1}{choice{3,2}};
A = data_annot{1,6};
annotations.values = cellfun(@(x) x(2:end-4), A(cellfun('length', A) > 1), 'un',0);

switch T.segment
    case 'valid'
        [T.segments, T.nbSeg] = extractSegments(annotations, 0, 1);
    case 'invalid'
        [T.segments, T.nbSeg] = extractSegments(annotations, 2, 3);
    case 'invalid ECG'
        [T.segments, T.nbSeg] = extractSegments(annotations, 4, 5);    
end

% segment time
strFormFile = 'mm_dd_yyyy_HH_MM_SS.FFF';

% load signal from gTec
path_gtec = strcat(pathFolder, T.patient, T.measure, strGTec, '.bin');  
dateNum_gtec = datenum(dateString_G, strFormFile, 2010);
disp '... gTec loaded'

% load signal from iXtrend
try
    path_ix = strcat(pathFolder, T.patient, T.measure, strIxtrend, '.bin');
    dateNum_ix = datenum(dateString_I, strFormFile, 2010);
    disp '... ixtrend loaded'
catch
    disp '... no ixtrend'
end

nbChan_gTec = 10;
nbChan_ix = 4;
T.fs_gTec = 1200;
T.fs_ix = 499.7761;
binSize = 4;

if T.nbSeg ~= 0
    
    for ii = 1 : T.nbSeg
        segTime = T.segments.begin(ii);
        segLength = T.segments.end(ii) - T.segments.begin(ii);
        segTimeStr_gTec = datestr(segTime/86400 + dateNum_gtec, strFormFile);

        segTimeNum_gT = datenum(segTimeStr_gTec, strFormFile, 2010);

        [sig_gTec{ii}, t_gTec{ii}] = getSegmentInfo(path_gtec, dateNum_gtec, segTimeNum_gT, ...
                                        segLength, T.fs_gTec, nbChan_gTec, binSize);

        try
            [sig_ix{ii}, t_ix{ii}] = getSegmentInfo(path_ix, dateNum_ix, segTimeNum_gT, segLength, ...
                                            T.fs_ix, nbChan_ix, binSize);
        catch
            sig_ix{ii} = [];
            t_ix{ii} = [];
        end
    end
  
% Opens GUI
plotSegments(sig_gTec, t_gTec, sig_ix, t_ix, T); 
 
else
    disp 'no valid segments -> choose another one!!!'
end

end

%% function for popup -> choose patient and measurement
function [] = popup_call(varargin)
end

%% function for popup -> choose patient and measurement
function [] = text_call(varargin)
end

end