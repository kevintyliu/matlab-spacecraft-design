function [maxMaxTime, avgMaxTime] = maxTimeCalculator(res)
% boo = false;
% data = res.Range(1,res.Count-1)
% n = 1;
% while (~boo)
%     row = cell2mat(data(n));
%     temp = strfind(row, '"Latitude (deg)","Longitude (deg)","FOM Value (sec)"');
%     if (~isempty(temp))
%         boo = true;
%     end
%     n = n+1;
% end
% data = res.Range(n,res.Count-1);
% maxMaxTime = 0;
% sum = 0;
% for k = 1:(res.Count-1-n)
%     row = cell2mat(data(k));
%     temp = strfind(row, ',');
%     start = temp(2)+1;
%     pointmax = str2double(row(start:length(row)));
%     sum = sum + pointmax;
%     if pointmax>maxMaxTime
%         maxMaxTime = pointmax;
%     end
% end
% maxMaxTime = maxMaxTime/3600;
data = res.Range(res.Count-1,res.Count-1);
row = cell2mat(data(1));
temp = strfind(row, ',');
start = temp(1)+1;
stop = temp(2);
maxMaxTime = str2double(row(start:stop))/3600;
avgMaxTime = str2double(row(stop+1:length(row)))/3600;