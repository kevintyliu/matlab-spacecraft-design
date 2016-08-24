function [avgRevisitTimePoint] = avgTimeCalculator(res)
%given report from FOM from stk, returns average revisit time averaged 
%overpoints in grid in hours
% boo = false;
% data = res.Range(1,res.Count-1);
% n = 1;
% while (~boo)
%     row = cell2mat(data(n));
%     temp = strfind(row, '"Latitude (deg)","Longitude (deg)","FOM Value (sec)"');
%     if (~isempty(temp))
%         boo = true;
%     end
%     n = n+1;
% end
% data = res.Range(n,res.Count-1)
% sum = 0;
% for k = 1:res.Count-1-n
%     row = cell2mat(data(k));
%     temp = strfind(row, ',');
%     start = temp(2)+1;
%     pointavg = str2double(row(start:length(row)));
%     sum = sum + pointavg;
% end
% avgRevisitTimePoint = sum/(3600*(res.Count-30));
data = res.Range(res.Count-1,res.Count-1);
row = cell2mat(data(1));
temp = strfind(row, ',');
start = temp(2)+1;
avgRevisitTimePoint = str2double(row(start:length(row)))/3600;