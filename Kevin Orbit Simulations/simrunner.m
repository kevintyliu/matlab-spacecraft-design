function result = simrunner(minlat, maxlat, filenum)
%Given minimum latitude for coverage minlat (deg), maximum latitude for
%coverage maxlat (deg), and number of excel spreadsheet export filenum,
%runs simulations for parameters (numPlanes, satsPerPlane, a, i, nadir, f)
%which are determined below. Returns structre result with fields name,
%maxMax, avgMax, avgAvg, belowPercent. Also exports data to an excel
%spreadsheet based on given filenum. Prints out elapsed time.
tic;                                             %Begins time calculation
app = actxserver('STK10.Application');           %Creates STK application
root = app.Personality2;
scenario = root.Children.New('eScenario', 'First'); %Creates STK scenario
n = 1;                                  %Count for which row to write data

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

numPlanesCount = 1;                     %number of plane cases
satsPerPlaneCount = 1;                  %number of sats per plane cases
semimajorAxisCount = 1;                 %number of semimajor axes to test
iCount = 1;                             %number of inclinations to test (usually 1, same as latitude coverage definition
nadirCount = 1;                         %number of nadir angles to test
numSimulationsMax = satsPerPlaneCount*semimajorAxisCount*iCount*nadirCount*1    %number of simulations that will be calculated, you must adjust equation
details = zeros(numSimulationsMax, 6);  %matrix of satellite parameter information

for numPlanes = 1:1                     %What parameters to use, input it yourself so that it corresponds to above numbers
    for satsPerPlane = 1:1
        for a = 6971:100:6971+100*(semimajorAxisCount-1)
            for i =  97.7592:97.7592  %usually maxlat:maxlat
                for nadir = 55:10:55+10*(nadirCount-1)
                    for f = 0:numPlanes-1
                        result.name{n} = strcat( 'numPlanes', num2str(numPlanes), 'satsPerPlane', num2str(satsPerPlane), 'f', num2str(f), 'a', num2str(a), 'i', num2str(i), 'nadir', num2str(nadir));   %name given parameters of constellation
                        [result.maxMax(n), result.avgMax(n), result.avgAvg(n), result.belowPercent{n, 1}, result.maxEclipse(n)] = stksim2(app, root, scenario, MyGrid, numPlanes, satsPerPlane, f, a, i, nadir);              %runs simulation and stores data in result
                        details(n, 1) = numPlanes;       %Info parameters
                        details(n, 2) = satsPerPlane;
                        details(n, 3) = a;
                        details(n, 4) = i;
                        details(n, 5) = nadir;
                        details(n,6) = f;
                        n = n+1;            %moves row down
                    end
                end
            end
        end
    end
end
names = result.name(:);             %Converts to matrix
titlerow = {'Names', 'Number of Planes', 'Sats Per Plane', 'Semimajor Axis (km)', ...
    'Inclination (deg)', 'Nadir Angle (deg)', 'f', 'MaxMax Revisit Time (hours)', 'AverageMax Revisit Time (hours)', ...
    'AvgAvg Revisit Time (hours)', 'MaxEclipse Time (hours)', 'Value Below 5%', ...
    'Value Below 10%', 'Value Below 15%', 'Value Below 20%', 'Value Below 25%', 'Value Below 30%', ...
    'Value Below 35%', 'Value Below 40%', 'Value Below 45%', 'Value Below 50%', 'Value Below 55%', ...
    'Value Below 60%', 'Value Below 65%', 'Value Below 70%', 'Value Below 75%', 'Value Below 80%', ...
    'Value Below 85%', 'Value Below 90%', 'Value Below 95%'};       %title for first row of excel
maxMaxColumn = result.maxMax(:);    %Converts to matrix
avgMaxColumn = result.avgMax(:);    %Converts to matrix
avgAvgColumn = result.avgAvg(:);    %Converts to matrix
maxEclipseColumn = result.maxEclipse(:);    %Converts to matrix
excelloc = strcat('SimulationData', num2str(filenum), '.xlsx'); %title of excel file location
percentTable = cell2mat(result.belowPercent);   %Converts to matrix
xlswrite(excelloc, names, 1, 'A2');     %Writes onto excel
xlswrite(excelloc, titlerow);
xlswrite(excelloc, details, 1, 'B2');
xlswrite(excelloc, maxMaxColumn, 1, 'H2');
xlswrite(excelloc, avgMaxColumn, 1, 'I2');
xlswrite(excelloc, avgAvgColumn, 1, 'J2');
xlswrite(excelloc, maxEclipseColumn, 1, 'K2');
xlswrite(excelloc, percentTable, 1, 'L2');
totaltime = {strcat(num2str(toc/3600), ' Hours')};               %displays timeelapsed
xlswrite(excelloc, totaltime, 1, 'AF8');
