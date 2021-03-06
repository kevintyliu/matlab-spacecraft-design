classdef Orbit
    %class that represents the orbit of a satellite. It has parameters of
    %semimajor axis, eccentricity, inclination, right ascenscion of the
    %ascending node, argument of perigee, true anomaly, and central body.
    %The class includes getter methods for all parameters,
    %getPeriod,getFrequency (or mean motion), getr (distance from central
    %body), getVelocity, getE (eccentric anomaly), getM (mean anomaly),
    %getElapsedTime (time for satellite to traverse from a start true
    %anomaly to a stop true anomaly), and getrho. Also has a static method
    %returning a planet structure getPlanet, which returns any planet in
    %the solar system using the name of the planet (ex. 'Earth') or its
    %place in the solar system (ex. 1 is Mercury, 2 is Venus, ect.).
    properties
        a %semimajor axis (km)
        e %eccentricity
        i %inclination (deg)
        raan %right ascension of the ascending node (deg)
        argofper %argument of perigee (deg)
        v %true anomaly (deg)
        centralbody
    end
    methods
        function obj = Orbit(a, e, i, raan, argofper, v, planet) %What is the argofper for a circular orbit?
            obj.centralbody = Orbit.getPlanet(planet);
            assert (a > obj.centralbody.radius);
            assert (e >= 0 && e<1);
            assert (i >= 0 && i <= 180);
            assert (0 <= raan && raan <=180);
            assert (0 <= argofper && argofper < 360);
            obj.a = a;
            obj.e = e;
            obj.i = i;
            obj.raan = raan;
            obj.argofper = argofper;
            obj.v = v;
        end
        function a = geta(obj)
            a = obj.a;
        end
        function e = gete(obj)
            e = obj.e;
        end
        function i = geti(obj)
            i = obj.i;
        end
        function raan = getraan(obj)
            raan = obj.raan;
        end
        function argofper = getargofper(obj)
            argofper = obj.argofper;
        end
        function v = getv(obj)
            v = obj.v;
        end
        function period = getPeriod(obj)
            %in minutes
            period = 2*pi*sqrt(10^9*(obj.a)^3/obj.centralbody.mu)/60;
        end
        function frequency = getFrequency(obj)
            %same as mean motion
            %in rad/s
            frequency = sqrt(obj.centralbody.mu/(obj.a^3*10^9));
        end
        function r = getr(obj)
            %distance of satellite from central body (km)
            r = obj.a*(1-obj.e^2)/(obj.e*cosd(obj.v)+1);
        end
        function velocity = getVelocity(obj)
            %in m/s
            velocity = sqrt(obj.centralbody.mu*(2/getr(obj)-1/obj.a)/1000);
        end
        function E = getE(obj)
            %returns eccentric anomaly
            E = acos((obj.e+cosd(obj.v))/(1+obj.e*cosd(obj.v)));
        end
        function M = getM(obj)
            %returns mean anomaly (rad)
            M = getE(obj)-obj.e*sin(getE(obj));
        end
        function time = getElapsedTime(obj, start, stop)
            %given start and stop angles (deg),
            %returns time elapsed in seconds for the satellite to go from
            %start angle start to end angle end (degrees)
            assert (stop >= start);
            time = 0;
            overcount = floor(start/360);
            start = start - 360 * overcount;
            stop = stop -360 * overcount;
            if stop-start >= 360
                revolutions = floor((stop-start)/360);
                stop = stop-360*revolutions;
                time = getPeriod(obj)*60*revolutions;
            end
            if start>180
                E1 = 2*pi-acos((obj.e+cosd(start))/(1+obj.e*cosd(start)));
                M1 = E1-obj.e*sin(E1);
            else
                E1 = acos((obj.e+cosd(start))/(1+obj.e*cosd(start)));
                M1 = E1-obj.e*sin(E1);
            end
            if stop>180
                E2 = 2*pi-acos((obj.e+cosd(stop))/(1+obj.e*cosd(stop)));
                M2 = E2-obj.e*sin(E2);
            else
                E2 = acos((obj.e+cosd(stop))/(1+obj.e*cosd(stop)));
                M2 = E2-obj.e*sin(E2);
            end
            time = time+(M2-M1)/getFrequency(obj);
        end
        function rho = getrho(obj)
            %returns rho angle (deg)
            rho = asind(obj.centralbody.radius/(getr(obj)));
        end
        function info(obj)
            ca = {'Period'; 'Frequency/Mean Motion'; ...
                'r (distance from central body)'; 'Velocity';...
                'Time elapsed for satellite from 0-90 true anomaly';...
                'rho'};
            values = {sprintf('%0.3f minutes', getPeriod(obj)); ...
                sprintf('%0.7f rad/s', getFrequency(obj));...
                sprintf('%0.3f km', getr(obj)); ...
                sprintf('%0.3f m/s', getVelocity(obj));...
                sprintf('%0.2f s', getElapsedTime(obj,0,90));...
                sprintf('%0.3f degrees', getrho(obj))};
            ca = [ca values];
            display(cell2table(ca, 'VariableNames', {'Property', 'Value'}));
            %             %display(sprintf( 'Period: \t\t\t\t\t\t\t\t\t\t\t\t %0.3f minutes', getPeriod(obj)));
            %             display(sprintf( 'Frequency/Mean Motion: \t\t\t\t\t\t\t\t\t %0.3f rad/s', getFrequency(obj)));
            %             display(sprintf( 'r (distance from central body): %0.3f km', getr(obj)));
            %             display(sprintf( 'Velocity: %0.3f m/s', getVelocity(obj)));
            %             display(sprintf( 'Time elapsed for satellite from 0-90 true anomaly: %0.2f s', getElapsedTime(obj,0,90)));
            %             display(sprintf( 'rho: %0.3f degrees', getrho(obj)));
        end
    end
    methods(Static)
        %radius (km), mass (kg), mu (m^3s^-2), g (m/s^2), rhonot (atm), H (km)
        function planet = getPlanet( choose )
            [number, text, raw] = xlsread('Planets.xlsx');
            num = -1;
            for k = 2:size(text)
                if strcmp(choose, text(k,1))
                    num = k;
                end
            end
            if num == -1
                error('Planet not Found');
            else
                num = num - 1;
                planet.radius = number(num, 1);
                planet.mass = number(num, 2);
                planet.mu = number(num,3);
                planet.g = number(num, 4);
                planet.rhoNot = number(num, 5);
                planet.H = number(num, 6);
            end
            
            %             [~, text, ~] = xlsread('Planets.xlsx','A2:A9');
            %             num = -1;
            %             for k = 1:size(text)
            %                 if strcmp(choose, text(k,1))
            %                     num = k;
            %                 end
            %             end
            %             if num == -1
            %                 error('Planet not Found');
            %             else
            %                 num = num+1;
            %                 planet.radius = xlsread('Planets.xlsx', strcat('B',...
            %                     num2str(num), ':B', num2str(num)));
            %                 planet.mass = xlsread('Planets.xlsx', strcat('C',...
            %                     num2str(num), ':C', num2str(num)));
            %                 planet.mu = xlsread('Planets.xlsx', strcat('D',...
            %                     num2str(num), ':D', num2str(num)));
            %                 planet.g = xlsread('Planets.xlsx', strcat('E',...
            %                     num2str(num), ':E', num2str(num)));
            %                 planet.rhoNot = xlsread('Planets.xlsx', strcat('F',...
            %                     num2str(num), ':F', num2str(num)));
            %                 planet.H = xlsread('Planets.xlsx', strcat('G',...
            %                     num2str(num), ':G', num2str(num)));
            %             end
            
%             if isa(choose, 'char')
%                 if strcmp(choose, 'Mercury')
%                     choose = 1;
%                 elseif strcmp(choose, 'Venus')
%                     choose = 2;
%                 elseif strcmp(choose, 'Earth')
%                     choose = 3;
%                 elseif strcmp(choose, 'Mars')
%                     choose = 4;
%                 elseif strcmp(choose, 'Jupiter')
%                     choose = 5;
%                 elseif strcmp(choose, 'Saturn')
%                     choose = 6;
%                 elseif strcmp(choose, 'Uranus')
%                     choose = 7;
%                 elseif strcmp(choose, 'Neptune')
%                     choose = 8;
%                 end
%             end
%             assert (rem(choose,1) == 0);
%             planets(1).radius =  2439.7; %Mercury
%             planets(1).mass = 330*10^21;
%             planets(1).mu = 2.20329*10^13;
%             planets(1).g = 3.7;
%             planets(1).rhoNot = 0;
%             planets(1).H = 1000; %trivial
%             planets(2).radius =  6051.8; %Venus
%             planets(2).mass = 4868.5*10^21;
%             planets(2).mu = 3.248599*10^14;
%             planets(2).g = 8.572;
%             planets(2).rhoNot = 91;
%             planets(2).H = 15.9;
%             planets(3).radius =  6371; %Earth
%             planets(3).mass = 5973.6*10^21;
%             planets(3).mu = 3.9860044189*10^14;
%             planets(3).g = 9.80665;
%             planets(3).rhoNot = 1;
%             planets(3).H = 8.5;
%             planets(4).radius =  3389.5; %Mars
%             planets(4).mass = 641.85*10^21;
%             planets(4).mu = 4.2828372*10^13;
%             planets(4).g = 3.7;
%             planets(4).rhoNot = .01;
%             planets(4).H = 11.1;
%             planets(5).radius =  69911; %Jupiter
%             planets(5).mass = 1898600*10^21;
%             planets(5).mu = 1.266865349*10^17;
%             planets(5).g = 24.79;
%             planets(5).rhoNot = -1; %Unknown
%             planets(5).H = 11.1;
%             planets(6).radius =  58232; %Saturn
%             planets(6).mass = 568460*10^21;
%             planets(6).mu = 3.79311879*10^16;
%             planets(6).g = 10.445;
%             planets(6).rhoNot = -1; %Unknown
%             planets(6).H = 59.5;
%             planets(7).radius =  25362; %Uranus
%             planets(7).mass = 86832*10^21;
%             planets(7).mu = 5.7939399*10^15;
%             planets(7).g = 8.87;
%             planets(7).rhoNot = -1; %Unknown
%             planets(7).H = 27.7;
%             planets(8).radius =  24622; %Neptune
%             planets(8).mass = 102430*10^21;
%             planets(8).mu = 6.8365299*10^15;
%             planets(8).g = 11.15;
%             planets(8).rhoNot = -1; %Unknown
%             planets(8).H = 19.7;
%             planet = planets(choose);
        end
    end
end