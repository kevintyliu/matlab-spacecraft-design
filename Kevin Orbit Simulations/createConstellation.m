function [constellation maxEclipseTime] = createConstellation(numPlanes, satsPerPlane, f, a, i, scenario, root, nadir)
%Given number of planes numPlanes, satellites per plane satsPerPlane,
%integer multiple f for phase difference in Walker Constellations,
%semimajor axis a (km), and inclination i (deg), and nadir angle nadir
%(deg), returns constellation satellites
% n = 1;
a= a*1000;              %Converts kilometers to meters
basePhaseDifference = 360/(numPlanes*satsPerPlane); %Phase difference between planes
constellation = scenario.Children.New('eConstellation', 'Constel');     %Creates constellation
for n1 = numPlanes:-1:1
    for n2 = satsPerPlane:-1:1
        sat_name = strcat('SatPlane',num2str(n1),'Num',num2str(n2));    %name of satellite
        sat = scenario.Children.New('eSatellite', sat_name);            %Creates satellite object
        raan = (n1-1)*360/numPlanes;                                    %Equally spreads RAAN
        v = mod((n2-1)*360/satsPerPlane - (n1-1)*f*basePhaseDifference, 360);       %Calculates the true anomaly inclduing phase difference
        
        cmd = ['SetState */Satellite/' strcat('SatPlane',num2str(n1),'Num',num2str(n2)) ' Classical TwoBody "', scenario.StartTime, '" "', scenario.StopTime, '" 60 ICRF "', scenario.StartTime, '" ' num2str(a) ' 0 ' num2str(i) ' 0 ' num2str(raan) ' ' num2str(v)];
        root.ExecuteCommand(cmd);       %Creates satellite
        
        if (n1 == 1)
            if (n2 == 1)
                satelliteDP = sat.DataProviders.Item('Eclipse Summary').ExecElements(scenario.StartTime, scenario.StopTime, {'Total Duration'});
                res = satelliteDP.DataSets.GetDataSetByName('Total Duration');
                data = res.GetValues();
                maxEclipseTime = max([data{:}])/3600;
            end
        end
        
        %         cons{n}=sat;
        sensor_name = strcat('SenPlane',num2str(n1),'Num',num2str(n2)); %name of sensor
        %         sensor = sat.Children.New('eSensor', sensor_name );
        sat.Children.New('eSensor', sensor_name );                 %Creates sensor as child to satellite
        
        cmd = ['Define */Satellite/' strcat('SatPlane',num2str(n1),'Num',num2str(n2)) '/Sensor/' strcat('SenPlane',num2str(n1),'Num',num2str(n2)) ' SimpleCone ' num2str(nadir) ' AngularRes 6.0'];
        root.ExecuteCommand(cmd);       %Defines sensor properties
        %         sensors{n} = sensor;
        
        cmd = ['Chains */Constellation/Constel Add Satellite/' sat_name '/Sensor/' sensor_name];
        root.ExecuteCommand(cmd);       %Adds satellite to Constellation
        %         n = n+1;
    end
end