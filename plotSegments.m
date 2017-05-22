function plotSegments(sig_gt, t_gt, sig_ix, t_ix, X)
%PLOTSEGMENTS opens GUI:
%   Choose between segments with slider
%   choose between leads LS and PD
%   choose which annotations should be visible
%   make ECG and respiration signal of iXtrend visible
%   make ECG of gTec visible
%   make legend
%   save GUI
%   print figure
%   choose limits or apply current zoom
%
%   input:  sig_gt:    	gTec signal
%           t_gt:       time vector
%           sig_ix:     iXtrend signal
%           t_ix:       time vector for iXtrend
%           X:          structure containing segment information
%
%   2. Mai 2017 Barbara Jesacher

%% FIGURE
X.figure = figure('units', 'pixels', 'position', [200 200 1000 800],...
                  'Visible', 'off', 'name', 'plotSegments',...
                  'numbertitle', 'off', 'resize', 'on');
%%              
X.axes(1:X.nbSeg) = axes('Units', 'Normalized', 'OuterPosition', [.1, .19, .8, .75],...
                         'Visible', 'off'); 
X.hax(1:X.nbSeg) = axes('Units', 'Normalized', 'OuterPosition', [.1, .18, .8, 1e-5],...
                        'Visible', 'off', 'Color', 'none');
X.rax(1:X.nbSeg) = axes('Units', 'Normalized', 'OuterPosition', [.1, .14, .8, 1e-5],...
                        'Visible', 'off', 'Color', 'none');
X.sax(1:X.nbSeg) = axes('Units', 'Normalized', 'OuterPosition', [.1, .1, .8, 1e-5],...
                        'Visible', 'off', 'Color', 'none');
%% AXES                  
X.slideSegment = uicontrol('style', 'slide', 'unit', 'pix',...
                           'position', [40 650 100 30], 'min', 1,...
                           'max', round(X.nbSeg), 'val', 1,...
                           'SliderStep', [1/(X.nbSeg-1) , 1/(X.nbSeg-1)]);
%% EDIT TEXT                    
X.edit = uicontrol('style', 'edit', 'unit', 'pix',...
                   'position', [40 685 100 20], 'fontsize', 14,...
                   'string', '1');
X.editLimit = uicontrol('style', 'edit', 'unit', 'pix',...
                   'position', [40 180 100 20], 'fontsize', 14,...
                   'string', '0');
set([X.edit, X.slideSegment], 'call', {@edit_call, X});

%% TEXT               
X.textLimit = uicontrol('style', 'text', 'unit', 'pix',...
                       'position', [40 200 140 25],...
                       'HorizontalAlign', 'left',...
                       'fontsize', 14,...
                 	   'string', 'XLim (sec):', 'call', {@text_call, X});                        
X.textLead = uicontrol('style', 'text', 'unit', 'pix',...
                       'position', [40 615 140 25],...
                       'HorizontalAlign', 'left', 'fontsize', 14,...
                       'string', 'Load leads:', 'call', {@text_call, X});
X.textSegment = uicontrol('style', 'text', 'unit', 'pix',...
                          'position', [40 705 140 25],...
                          'HorizontalAlign', 'left',...
                          'fontsize', 14,...
                          'string', 'Segment:', 'call', {@text_call, X});
X.textAnnotation = uicontrol('style', 'text', 'unit', 'pix',...
                             'position', [40 350 140 25],...
                             'HorizontalAlign', 'left',...
                             'fontsize', 14,...
                             'string', 'Annotations:', 'call', {@text_call, X});
X.textIxtrend = uicontrol('style', 'text', 'unit', 'pix',...
                          'position', [40 445 140 25],...
                          'HorizontalAlign', 'left',...
                          'fontsize', 14,...
                          'string', 'iXtrend:', 'call', {@text_call, X});
X.textgTec = uicontrol('style', 'text', 'unit', 'pix',...
                       'position', [40 520 140 25],...
                       'HorizontalAlign', 'left',...
                       'fontsize', 14,...
                 	   'string', 'gTec:', 'call', {@text_call, X});                        
%% TOGGLE BUTTON
% TODO: change annotations.values if pulse and perf needed!!!!!
X.tgAnnot(1) = uicontrol('style', 'toggle', 'unit', 'pix',...
                        'position', [40 330 100 20], 'string', 'HR');
X.tgAnnot(2) = uicontrol('style', 'toggle', 'unit', 'pix',...
                        'position', [40 305 100 20], 'string', 'RR');
X.tgAnnot(3) = uicontrol('style', 'toggle', 'unit', 'pix',...
                        'position', [40 280 100 20], 'string', 'SpO2');
set(X.tgAnnot(:), 'call', {@tgAnnot_call, X});      

X.tgSignals(1) = uicontrol('style', 'toggle', 'unit', 'pix',...
                           'position', [40 425 100 20], 'string', 'ECG');
X.tgSignals(2) = uicontrol('style', 'toggle', 'unit', 'pix',...
                           'position', [40 400 100 20], 'string', 'Resp');
X.tgSignals(3) = uicontrol('style', 'toggle', 'unit', 'pix',...
                           'position', [40 500 100 20], 'string', 'ECG');
set(X.tgSignals(:), 'call', {@tgSignals_call, X});   

X.tgLeads(1) = uicontrol('style', 'toggle', 'unit', 'pix',...
                       'position', [40 595 100 20], 'string', 'SL');
X.tgLeads(2) = uicontrol('style', 'toggle', 'unit', 'pix',...
                       'position', [40 570 100 20], 'string', 'PD');
set(X.tgLeads(:), 'call', {@tgLeads_call, X});      
%% PUSH BUTTON
X.pushSave = uicontrol('style', 'pushbutton', 'unit', 'pix',...
                        'position', [40 55 100 25],...
                        'backgroundcolor', 'w',...
                        'HorizontalAlign', 'left',...
                        'string', 'SAVE', 'fontsize', 14,...
                        'callback', {@pushSave_call, X});
X.pushPrint = uicontrol('style', 'pushbutton', 'unit', 'pix',...
                        'position', [40 25 100 25],...
                        'backgroundcolor', 'w',...
                        'HorizontalAlign', 'left',...
                        'string', 'PRINT', 'fontsize', 14,...
                        'callback', {@pushPrint_call, X});
X.pushLegend = uicontrol('style', 'pushbutton', 'unit', 'pix',...
                         'position', [40 85 100 25],...
                         'backgroundcolor', 'w',...
                         'HorizontalAlign', 'left',...
                         'string', 'LEGEND', 'fontsize', 14,...
                         'callback', {@pushLegend_call, X});
X.pushLimit = uicontrol('style', 'pushbutton', 'unit', 'pix',...
                        'position', [40 150 100 25],...
                        'backgroundcolor', 'w',...
                        'HorizontalAlign', 'left',...
                        'string', 'APPLY', 'fontsize', 14);%,...
                        %'callback', {@pushLimit_call, X});
set([X.editLimit, X.pushLimit], 'call', {@editLimit_call, X});

%%                                         
X.figure.Visible = 'on';
X.figure.Resize = 'on';


%% text call
function [] = text_call(varargin)
end


%% toggle call for selecting the segment of this measurement
function [] = tgLeads_call(varargin)
[hObj, X] = varargin{[1,3]};
ll = round(get(X.slideSegment, 'value'));

colour = [166,206,227;31,120,180;178,223,138;51,160,44;251,154,153;...
          227,26,28;253,191,111;255,127,0;202,178,214;106,61,154]/255;
cla
h = zoom;
h.Enable = 'on';
ax = X.axes(ll);
set(ax, 'Visible', 'on');

hold(ax, 'on')

if get(hObj, 'val') == 0
    hObj.Value = 1;
end

X.sigPD{ll} = generatePD(sig_gt{ll});

switch hObj
    case X.tgLeads(1)
        X.tgLeads(2).Value = 0;             % new way of setting structure
        set(X.tgAnnot(1:3), 'val', 0)       % set structure until 2016
        set(X.tgSignals(1:3), 'val', 0) 

        % plot SL
        for kk = 1:8
            count = kk*2;
            plot(ax, t_gt{ll}, sig_gt{ll}(:, kk+2)-count+10*2, '-', ...
                                        'linewidth', 2, 'Color', colour(kk,:));
        end        
        legendInfo = {'eECG \enspace 3-2','eECG \enspace  4-2','eECG \enspace 5-2',...
                        'eECG \enspace 6-2','eECG \enspace 7-2',...
                        'eECG \enspace 8-2', 'eECG \enspace 9-2',...
                        'eECG 10-2'};  
        lgd = legend(ax, legendInfo,'interpreter','latex',...
                            'FontUnits','points', 'FontWeight','normal',...
                            'FontSize',14, 'FontName','Times',...
                            'Orientation','vertical', 'Location',[0.85, 0.5, 0.1, 0.05]);                
      	lgd.Visible = 'off';
    case X.tgLeads(2)
        set(X.tgLeads(1), 'val', 0)
      	set(X.tgAnnot(1:3), 'val', 0) 
        set(X.tgSignals(1:3), 'val', 0) 

        % plot PD
        for kk = 1:8
            count = kk*2;
            plot(ax, t_gt{ll}, X.sigPD{ll}(:, kk)-count+10*2, '-',...
                                        'linewidth', 2, 'Color', colour(kk,:));
        end
        legendInfo = {'eECG \enspace 3-2','eECG \enspace  4-3','eECG \enspace 5-4',...
                        'eECG \enspace 6-5','eECG \enspace 7-6','eECG \enspace 8-7',...
                        'eECG \enspace 9-8', 'eECG 10-9'};      
        lgd = legend(ax, legendInfo,'interpreter','latex',...
                            'FontUnits','points', 'FontWeight','normal',...
                            'FontSize',14, 'FontName','Times',...
                            'Orientation','vertical', 'Location',[0.85, 0.5, 0.1, 0.05]);          
        lgd.Visible = 'off';
end
xlabel(ax,'$\bf{time\enspace [s]}$', 'interpreter', 'latex',...
                  'FontUnits', 'points', 'FontWeight','bold',...
                  'FontSize', 14, 'FontName','Times');
ylabel(ax,'$\bf{voltage\enspace [mV]}$', 'interpreter', 'latex',...
                  'FontUnits', 'points', 'FontWeight','bold',...
                  'FontSize', 14, 'FontName','Times');
set(ax,'TickLabelInterpreter','latex',...
               'FontUnits','points', 'FontWeight', 'normal',...
               'FontSize', 14, 'FontName', 'Times');   
set(ax, 'XlimMode', 'auto')
xlim(ax, [0 600])
xticks(ax, 'auto')
xticklabels(ax, 'auto')
set(ax, 'XTickLabelMode', 'auto')
ylim(ax, [-5 inf])
yticks(ax, -1:2:1)
grid(ax, 'on')
hold(ax, 'off')
end


%% toggle call for ECG signals
function [] = tgSignals_call(varargin)
[hObj, X] = varargin{[1,3]};
ll = round(get(X.slideSegment, 'value'));
ax = X.axes(ll);
hold(ax, 'on')

if ~isempty(sig_ix{ll})
    resp = sig_ix{ll}(:,3);
end

switch hObj
    case X.tgSignals(1)     
        try
            if get(hObj, 'val') == 1
                hObj.UserData(1) = plot(ax, t_ix{ll}, sig_ix{ll}(:,2), 'c-',...
                                        'linewidth', 2, 'DisplayName', 'ECG'); 
            else
                 delete(hObj.UserData(1));
            end
        catch
            disp 'no signal'
        end
    case X.tgSignals(2)
        try
            if get(hObj, 'val') == 1
                hObj.UserData(2) = plot(ax, t_ix{ll}(~isnan(resp)), resp(~isnan(resp))*2-2,...
                                        'k-', 'linewidth', 2, 'DisplayName', 'Resp');
            else
                delete(hObj.UserData(2))
            end
        catch
            disp 'no resp'
        end
    case X.tgSignals(3)
        if get(hObj, 'val') == 1
            hObj.UserData(3) = plot(ax, t_gt{ll}, sig_gt{ll}(:,1)+2, 'y-',...
                                        'linewidth', 2, 'DisplayName','sECG');   
        else
            delete(hObj.UserData(3));
        end
end
end


%% toggle call for annotations
function [] = tgAnnot_call(varargin)
[hObj, X] = varargin{[1,3]};
idx = round(get(X.slideSegment, 'value'));
hAx = X.hax(idx);

if ~isempty(sig_ix{idx})
    y = 1e-18;

    switch hObj
        case X.tgAnnot(1)
            if hObj.Value == 1
                hAx.Visible = 'on';
                x = hAx.XLim(1) : hAx.XLim(2);
                p = plot(hAx, x, y, 'b');
                xticks(hAx, X.segments.HR{1,idx}-X.segments.begin(idx));
                xticklabels(hAx, X.segments.HR{2,idx});
                annotation = '$\bf{HR\enspace [bpm]}$';
                lgd = legend(p, annotation, 'Location', [0.85, 0.16, 0.1, 0.05]);
                lgd.Interpreter = 'latex';
                lgd.TextColor = 'blue';
                lgd.Box = 'off';
                hObj.UserData(1) = lgd;
%                 set(X.hax(idx), 'XColor', 'b')
                hAx.XColor = 'b';
            else
                set(X.hax(idx), 'Visible', 'off');
                delete(hObj.UserData(1));
            end
        case X.tgAnnot(2)
            if hObj.Value == 1
                set(X.rax(idx), 'Visible', 'on');
                x = X.rax(idx).XLim(1)  : X.rax(idx).XLim(2);
                p = plot(X.rax(idx), x, y, 'g');
                xticks(X.rax(idx), X.segments.RR{1,idx}-X.segments.begin(idx))
                xticklabels(X.rax(idx), X.segments.RR{2,idx})
                annotation = '$\bf{RR\enspace [rpm]}$';
                lgd = legend(p, annotation, 'Location', [0.85, 0.12, 0.1, 0.05]);
                lgd.Interpreter = 'latex';
                lgd.TextColor = 'green';
                lgd.Box = 'off';
                hObj.UserData(2) = lgd;
                set(X.rax(idx), 'XColor', 'g')
            else
                set(X.rax(idx), 'Visible', 'off');
                delete(hObj.UserData(2));
            end
        case X.tgAnnot(3)
            if hObj.Value == 1
                set(X.sax(idx), 'Visible', 'on');
                x = X.sax(idx).XLim(1)  : X.sax(idx).XLim(2);
                p = plot(X.sax(idx), x, y, 'k');
                xticks(X.sax(idx), X.segments.SpO2{1,idx}-X.segments.begin(idx))
                xticklabels(X.sax(idx), X.segments.SpO2{2,idx})
                annotation = '$\bf{SpO_2\enspace [\%]}$';
                lgd = legend(p, annotation, 'Location', [0.85, 0.08, 0.1, 0.05]);
                lgd.Interpreter = 'latex';
                lgd.TextColor = 'black';
                lgd.Box = 'off';
                hObj.UserData(3) = lgd;
                set(X.sax(idx), 'XColor', 'k')
            else
                set(X.sax(idx), 'Visible', 'off');
                delete(hObj.UserData(3));
            end
    end
    set(X.hax(idx),'TickLabelInterpreter','latex',...
                   'FontUnits','points', 'FontWeight', 'normal',...
                   'FontSize', 12, 'FontName', 'Times');   
    set(X.rax(idx),'TickLabelInterpreter','latex',...
                   'FontUnits','points', 'FontWeight', 'normal',...
                   'FontSize', 12, 'FontName', 'Times');   
    set(X.sax(idx),'TickLabelInterpreter','latex',...
                   'FontUnits','points', 'FontWeight', 'normal',...
                   'FontSize', 12, 'FontName', 'Times');   

    linkaxes([X.axes(idx), X.sax(idx), X.rax(idx), X.hax(idx)], 'x')
else
    disp 'no annotations'
end
end


%% push back call for printing the image
function [] = pushPrint_call(varargin)
[~, X] = varargin{[1,3]};
idx = round(get(X.slideSegment, 'value'));
ax = X.axes(idx);
xli = ax.XLim;
time = round(X.segments.begin(idx)/60);

title([X.patient, ' ', X.measure, '; ', X.segment, '; sequence: ', num2str(idx),...
                  ' (', num2str(time), ' min after start)',...
                  '; cutout after ', num2str(xli(1)), ' seconds'],...
                  'interpreter', 'latex',...
                  'FontUnits', 'points', 'FontWeight','bold',...
                  'FontSize', 16, 'FontName','Times')

set(gcf,'PaperType','A4');
set(gcf,'PaperOrientation','landscape');
set(gcf,'PaperUnits','normalized');
set(gcf,'PaperPosition',[0 0 1 1]);
   
folder = '/Users/barbara/Dropbox/BFH/Magensonde+/Figures/';
filename = strcat(X.patient, X.measure, '_', X.segment, '_', num2str(idx),'_',...
                                    num2str(round(xli(1))),'.eps');

print(gcf, [folder filename],  '-painters', '-depsc','-tiff', '-r600','-loose', '-noui');
end


%% push button for showing legend
function [] = pushLegend_call(varargin)
[~, X] = varargin{[1,3]};
idx = round(get(X.slideSegment, 'value'));
ax = X.axes(idx);
set(ax.Legend, 'Visible', 'on')
end


%% edit text function for slider and edit box -> sliding between segments
function [] = edit_call(varargin)
[hObj, X] = varargin{[1,3]};

switch hObj
    case X.edit
        sliderInfo = get(X.slideSegment, {'min', 'max', 'value'});
        editString = round(str2double(get(hObj, 'string')));

        if editString >= sliderInfo{1} && editString <= sliderInfo{2}
            set(X.slideSegment, 'value', round(editString))
        else
            set(hObj, 'string', sliderInfo{3})
        end
    case X.slideSegment
        set(X.edit, 'string', round(get(hObj, 'value')))
    otherwise
        disp 'sth wrong!!!';
end
end


%% edit text function for adding limits
function [] = editLimit_call(varargin)
[hObj, X] = varargin{[1,3]};
ll = round(get(X.slideSegment, 'value'));
ax = X.axes(ll);
xli = ax.XLim;

switch hObj
    case X.editLimit
        pushInfo = get(X.pushLimit, 'value');
        editString = str2double(get(hObj, 'string'));
        set(X.pushLimit, 'value', editString)
        xlim(ax, [pushInfo pushInfo+10])
    case X.pushLimit
        set(X.editLimit, 'string', xli(1))
    otherwise
        disp 'sth wrong!!!';
end
xtickLabel = num2cell(0:600);
xtick = xli(1):1:xli(2);
xticks(ax, xtick)
xticklabels(ax, xtickLabel(1:length(xtick)))

end  

%% save last configuration
function [] = pushSave_call(varargin)
[hObj, X] = varargin{[1,3]};
ll = round(get(X.slideSegment, 'value'));
ax = X.axes(ll);
xli = ax.XLim;
hgsave(strcat(X.patient, X.measure, '_', X.segment, '_', ...
                                    num2str(round(xli(1))), 's_savedGUI'))
end

end