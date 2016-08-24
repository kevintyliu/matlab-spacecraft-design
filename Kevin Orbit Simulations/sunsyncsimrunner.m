function result = sunsyncsimrunner(semimajoraxis, filenum, linewritecount)
%Given Semimajor Axis semimajoraxis (km), number of excel file to write to
%filenum, and what row in the excel sheet to write on, runs STK simulations
%for sunsynchronous orbits for a variety of nadir angles and exports data
%onto an excel spreadsheet named SimulationData[filenum]
tic;                %Begins time calculation
app = actxserver('STK10.Application');      %Creates STK application
root = app.Personality2;
scenario = root.Children.New('eScenario', 'First'); %Creates STK scenario
n = 1;                      %Count for which row to write data in result
incl = acosd(.9856/(-2.06474*10^14)*semimajoraxis^(3.5));   %Inclination for sunsynchronous orbit
minlat = incl-180;          %Minimum coverage latitude definition
maxlat = 180-incl;          %Maximum coverage latitude definition

MyGrid = scenario.Children.New('eCoverageDefinition', 'MyGrid');    %Creates coverage
cmd = ['Cov */CoverageDefinition/MyGrid Grid AreaOfInterest LatBounds ' num2str(minlat) ' ' num2str(maxlat)]; %Defines the bounds of the coverage, granularity of 6
root.ExecuteCommand(cmd);

FOMMax = MyGrid.Children.New('eFigureOfMerit', 'FOMMax'); %Create Max revisit time Figure of Merit
cmd = ['Cov */CoverageDefinition/MyGrid/FigureOfMerit/FOMMax FOMDefine Definition RevisitTime Compute Maximum'];
root.ExecuteCommand(cmd);

FOMAvg = MyGrid.Children.New('eFigureOfMerit', 'FOMAvg'); %Create Avg revisit time Figure of Merit
cmd = ['Cov */CoverageDefinition/MyGrid/FigureOfMerit/FOMAvg FOMDefine Definition RevisitTime Compute Average'];
root.ExecuteCommand(cmd);

for k = 5:5:95
    FOMPercentBelow = MyGrid.Children.New('eFigureOfMerit', strcat('FOMPercentBelow', num2str(k))); %Create Percent Below (what revisit time is are the points below this revisit time) revisit time Figure of Merit
    cmd = ['Cov */CoverageDefinition/MyGrid/FigureOfMerit/' strcat('FOMPercentBelow', num2str(k)) ' FOMDefine Definition RevisitTime Compute PercentBelow ' num2str(k)];
    root.ExecuteCommand(cmd);
end

numPlanesCount = 1;             %number of plane cases
satsPerPlaneCount = 5;          %number of sats per plane case
iCount = 1;                     %number of inclinations to test (usually 1, same as latitude coverage definition)
nadirCount = 11;                %number of nadir angles to test
numSimulationsMax = satsPerPlaneCount*iCount*nadirCount*1    %number of simulations that will be calculated, you must adjust yourself to reflect above parameters, multiply by f cases
details = zeros(numSimulationsMax, 6);  %matrix of satellite parameter information

for numPlanes = 1:1         %What parameters to use, input it yourself so that it corresponds to above numbers
    for satsPerPlane = 1:5
        for a = semimajoraxis:semimajoraxis     %Don't change this, must be inputted semimajor axis
            for i = incl:incl                   %Don't change this, must be calculated  inclination
                for nadir = 5:5:5+5*(nadirCount-1)
                    for f = 0:numPlanes-1
                        result.name{n} = strcat( 'numPlanes', num2str(numPlanes), 'satsPerPlane', num2str(satsPerPlane), 'f', num2str(f), 'a', num2str(a), 'i', num2str(i), 'nadir', num2str(nadir));   %name giving parameters of constellation
                        [result.maxMax(n), result.avgMax(n), result.avgAvg(n), result.belowPercent{n, 1}] = stksim2(app, root, scenario, MyGrid, numPlanes, satsPerPlane, f, a, i, nadir);              %runs simulation and stores data in result
                        details(n, 1) = numPlanes;          %Info parameters
                        details(n, 2) = satsPerPlane;
                        details(n, 3) = a;
                        details(n, 4) = i;
                        details(n, 5) = nadir;
                        details(n,6) = f;
                        n = n+1;                            %Moves row down
                    end
                end
            end
        end
    end
end

names = result.name(:);                 %Converts to matrix

% titlerow = {'Names', 'Number of Planes', 'Sats Per Plane', 'Semimajor Axis', ...
%     'Inclination', 'Nadir Angle', 'f', 'MaxMax Revisit Time', 'AverageMax Revisit Time', ...
%     'AvgAvg Revisit Time', 'Value Below 5%', ...
%     'Value Below 10%', 'Value Below 15%', 'Value Below 20%', 'Value Below 25%', 'Value Below 30%', ...
%     'Value Below 35%', 'Value Below 40%', 'Value Below 45%', 'Value Below 50%', 'Value Below 55%', ...
%     'Value Below 60%', 'Value Below 65%', 'Value Below 70%', 'Value Below 75%', 'Value Below 80%', ...
%     'Value Below 85%', 'Value Below 90%', 'Value Below 95%'};

maxMaxColumn = result.maxMax(:);        %Converts to matrix
avgMaxColumn = result.avgMax(:);        %Converts to matrix
avgAvgColumn = result.avgAvg(:);        %Converts to matrix
excelloc = strcat('SimulationData', num2str(filenum), '.xlsx'); %Excel file name
percentTable = cell2mat(result.belowPercent);           %Converts to matrix
xlswrite(excelloc, names, 1, strcat('A', num2str(linewritecount))); %Writes to excel
% xlswrite(excelloc, titlerow);
xlswrite(excelloc, details, 1, strcat('B', num2str(linewritecount)));
xlswrite(excelloc, maxMaxColumn, 1, strcat('H', num2str(linewritecount)));
xlswrite(excelloc, avgMaxColumn, 1, strcat('I', num2str(linewritecount)));
xlswrite(excelloc, avgAvgColumn, 1, strcat('J', num2str(linewritecount)));
xlswrite(excelloc, percentTable, 1, strcat('K', num2str(linewritecount)));
result = linewritecount+numSimulationsMax;  %changes result to next excel row number
% toc                             %Displays time elapsed
