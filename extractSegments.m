function [segment, lengthB] = extractSegments(annot, begin, ending)
%EXTRACTSEGMENTS gives the start end end time of the annotated segment
%
% input:    time    time with start and endtime of segment
%           id      id of the different beginnings and endings of segment
%           begin   id of start
%           ending  id of end 
% output:   t_Beg   time of beginning of chosen segment
%           t_End   time of ending of chosen segment
%           lengthB number of annotated segments

index_B = find(annot.id == begin);   %vS_beg
index_E = find(annot.id == ending);   %vS_end
lengthB = length(index_B);
lengthE = length(index_E);

if lengthB ~= lengthE
    disp 'missing starting or end time'
else
    segment.begin = annot.time(index_B);
    segment.end = annot.time(index_E);
end

idxHR_s80 = find(annot.id == 41);
idxSpO2_s90 = find(annot.id == 42);
idxHR = find(annot.id == 43);
idxRR = find(annot.id == 44);
idxPulse = find(annot.id == 45);
idxSpO2 = find(annot.id == 46);
idxPerf = find(annot.id == 47);

for kk = 1 : lengthB
    idx_HRs80 = annot.time(idxHR_s80) > segment.begin(kk) & annot.time(idxHR_s80) < segment.end(kk);
    idx_SpO2s90 = annot.time(idxSpO2_s90) > segment.begin(kk) & annot.time(idxSpO2_s90) < segment.end(kk);
    idx_HR = annot.time(idxHR) > segment.begin(kk) & annot.time(idxHR) < segment.end(kk);
    idx_RR = annot.time(idxRR) > segment.begin(kk) & annot.time(idxRR) < segment.end(kk);
    idx_Pulse = annot.time(idxPulse) > segment.begin(kk) & annot.time(idxPulse) < segment.end(kk);
    idx_SpO2 = annot.time(idxSpO2) > segment.begin(kk) & annot.time(idxSpO2) < segment.end(kk);
    idx_Perf = annot.time(idxPerf) > segment.begin(kk) & annot.time(idxPerf) < segment.end(kk);

    segment.HR_s80{1,kk} = annot.time(idxHR_s80(idx_HRs80));
    segment.SpO2_s90{1,kk} = annot.time(idxSpO2_s90(idx_SpO2s90));
    segment.HR{1,kk} = annot.time(idxHR(idx_HR));
    segment.RR{1,kk} = annot.time(idxRR(idx_RR));
    segment.SpO2{1,kk} = annot.time(idxSpO2(idx_SpO2));
    segment.Pulse{1,kk} = annot.time(idxPulse(idx_Pulse));
    segment.Perf{1,kk} = annot.time(idxPerf(idx_Perf));
    segment.HR_s80{2,kk} = annot.values(idxHR_s80(idx_HRs80));
    segment.SpO2_s90{2,kk} = annot.values(idxSpO2_s90(idx_SpO2s90));
    segment.HR{2,kk} = annot.values(idxHR(idx_HR));
    segment.RR{2,kk} = annot.values(idxRR(idx_RR));
    segment.SpO2{2,kk} = annot.values(idxSpO2(idx_SpO2));
    segment.Pulse{2,kk} = annot.values(idxPulse(idx_Pulse));
    segment.Perf{2,kk} = annot.values(idxPerf(idx_Perf));
end

end