function [maxMaxRevisitTime, avgMaxRevisitTime, avgRevisitTimePoint, revisitTimeBelowPercent, maxEclipseTime] = stksim2(app, root, scenario, MyGrid, numPlanes, satsPerPlane, f, a, i, nadir)
%Given application app, root root, scenario path scenario, Grid Coverage
%definition MyGrid, number of Planes numPlanes, satellites per plane
%satsPerPlane, integer multiple f for determining phase difference in
%Walker Constellation, semimajor axis a (km), and inclination i, returns
%the greatest max revisit time for coverage points maxMaxRevisitTime
%(hours), max revisit time averaged over the points (hours), and average
%revisit time averaged over all coverage points (hours)


% app = actxserver('STK10.Application');
% % root = app.Personality2;
% % scenario = root.Children.New('eScenario', 'First'); %Creates Scenario
assert (f >= 0 && f< numPlanes);                %Checks that f is in bounds
scenario.SetTimePeriod('1 Jan 2004 23:30:00.000', '15 Jan 2004 23:30:00.000'); %Sets time
root.ExecuteCommand('Animate * Reset'); %Animates

% MyGrid = scenario.Children.New('eCoverageDefinition', 'MyGrid');    %Creates coverage
% cmd = ['Cov */CoverageDefinition/MyGrid Grid AreaOfInterest LatBounds ' num2str(minlat) ' ' num2str(maxlat)] %Defines the bounds of the coverage, granularity of 6
% root.ExecuteCommand(cmd);

[cons, maxEclipseTime] = createConstellation(numPlanes, satsPerPlane, f, a, i, scenario, root, nadir);   %Creates constellation
% access = sensor1.GetAccessToObject(MyGrid);
% access.ComputeAccess;

% FOMMax = MyGrid.Children.New('eFigureOfMerit', 'FOMMax'); %Create Max revisit time Figure of Merit
% cmd = ['Cov */CoverageDefinition/MyGrid/FigureOfMerit/FOMMax FOMDefine Definition RevisitTime Compute Maximum'];
% root.ExecuteCommand(cmd);

% FOMAvg = MyGrid.Children.New('eFigureOfMerit', 'FOMAvg'); %Create Avg revisit time Figure of Merit
% cmd = ['Cov */CoverageDefinition/MyGrid/FigureOfMerit/FOMAvg FOMDefine Definition RevisitTime Compute Average'];
% root.ExecuteCommand(cmd);

cmd = ['Cov */CoverageDefinition/MyGrid Asset */Constellation/Constel Assign']; %Assign Constellation to Grid
root.ExecuteCommand(cmd);

cmd = ['Cov */CoverageDefinition/MyGrid Access Compute'];   %Compute Access
root.ExecuteCommand(cmd);

% cmd = ['Cov */CoverageDefinition/MyGrid Access Export "C:\Users\SEAK1\Kevin\TestCoverage.txt"'];    %Exports Grid data to text file, probably unnecessary
% root.ExecuteCommand(cmd);

cmd = 'GetReport */CoverageDefinition/MyGrid/FigureOfMerit/FOMMax "Grid Stats"';   %Gets report for Max Revisit Time
res = root.ExecuteCommand(cmd);

[maxMaxRevisitTime, avgMaxRevisitTime] = maxTimeCalculator(res);    %Processes data and returns value

cmd = 'GetReport */CoverageDefinition/MyGrid/FigureOfMerit/FOMAvg "Grid Stats"';   %Gets report for Average Revisit Time
res = root.ExecuteCommand(cmd);
avgRevisitTimePoint = avgTimeCalculator(res);   %Processes data and returns value

revisitTimeBelowPercent = zeros(1,19);
for k = 5:5:95
    cmd = ['GetReport */CoverageDefinition/MyGrid/FigureOfMerit/' strcat('FOMPercentBelow', num2str(k)) ' "Grid Stats"'];   %Gets report for Percent Below
    res = root.ExecuteCommand(cmd);
    revisitTimeBelowPercent(k/5) = percentBelowCalculator(res);
end

% cmd = ['GetReport */Satellite/SatPlane1Num1 "Eclipse Times"'];
% res = root.ExecuteCommand(cmd);
% someinfo = maxEclipseCalculator(res)
% maxElipseTime=2;

cmd = ['UnloadMulti / */Constellation/Constel']; %Unloads Constellation for next simulation
root.ExecuteCommand(cmd);

cmd = ['UnloadMulti / */Satellite/*']; %Unloads Satellites for next simulation
root.ExecuteCommand(cmd);
end

