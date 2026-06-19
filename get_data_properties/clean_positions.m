function [xys,postim,trig] = clean_positions(posfile)
m = memmapfile(posfile, 'Format', {'single',  [1 1] 'time'; 'single' [6 1]  'xy'; 'single' [1 1]  'trigger'});
a=m.Data;
xys=[a.xy]';
%
% disp(size(xys));
%
postim=[a.time]';
trig = [a.trigger]';
postim(1)=0;
for i = 2:size(xys,1)
    if xys(i,1) == 0
        xys(i,:)=xys(i-1,:); %
    end
    if xys(i,4) == 0
        xys(i,4:6)=xys(i,1:3); %
    end
    %need to swap around big and small lights - labview didn't arrange them by
    %size...
    if xys(i,6)>xys(i,3) % PK comment: i.e. if the size of the second tracked area (LED) is bigger than the first one,then put it first
        %then put the second tracked area at the first LED position in the
        %array
        temp = xys(i,1:3);
        xys(i,1:3) = xys(i,4:6);
        xys(i,4:6) = temp;
    end
    
end
xys(xys(:,3)>200,3)=0;
xys(xys(:,6)>200,6)=0;

x=postim;
v = xys(:,1);
xq = 0:0.02:max(postim);
xys50=[];
xys50=[xys50 interp1(x,xys(:,1),xq)'];
xys50=[xys50 interp1(x,xys(:,2),xq)'];
xys50=[xys50 interp1(x,xys(:,3),xq)'];
xys50=[xys50 interp1(x,xys(:,4),xq)'];
xys50=[xys50 interp1(x,xys(:,5),xq)'];
xys50=[xys50 interp1(x,xys(:,6),xq)'];
xys = xys50; %xys now interpolated at 50hz



end