function sigPD = generatePD(sig)
%GENERATEPD generates signals proximal to distal
%
%   input:  sig     filtered gTec signal (short - long)   
%
%   output: sigPD   leads 3-2, ..., 10-9

%Leads with smallest interelectrode distance from proximal to distal          
sigPD = [sig(:,3), sig(:,4)-sig(:,3), sig(:,5)-sig(:,4),...
              sig(:,6)-sig(:,5), sig(:,7)-sig(:,6), sig(:,8)-sig(:,7),...
              sig(:,9)-sig(:,8), sig(:,10)-sig(:,9)];

end