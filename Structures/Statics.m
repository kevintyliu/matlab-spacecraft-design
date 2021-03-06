function Statics(components,structures)
% Check each structure, make sure the panels and cylinders can survive
% buckling or not.

        
n1 = length(structures);
% Get the structures assignment
structuresAssignment = cat(1,components.structuresAssignment);

for i = 1:n1
    index = ismember(structuresAssignment(:,1),i,'rows');
    if strcmp(structures(i).Shape,'Rectangle')
        if ~strcmp(structures(i).Plane,'XY')
            % If the panel is a column
            [thickness] = PanelBuckling(P,width,thickness,E,height);
            
        else
            % If the panel is not a column
            
        end
    elseif strcmp(structures(i).Shape,'Cylinder Hollow')
    elseif strcmp(structures(i).Shape,'Sphere')
    elseif strcmp(structures(i).Shape,'Cylinder')
    elseif strcmp(structures(i).Shape,'Cone')
        
        
    end
    
end



fnat_lat = 10; % Lateral natural frequency
fnat_ax = 25; % Axial natural frequency


% We want to cycle through each of the materials and see which one gives
% the least cost for the thickness. 
material =  MaterialTable();

function [thickness] = PanelBuckling(P,width,thickness,E,height)
% Using a safety factor of 1.5, calculate the critical force.
SF = 1.5;
Pcr = P*SF;

% Assuming that the panel is cantilevered,
Le = 2*height;

% Pcr = pi^2*E*crossI/Le^2;
% Check for buckling in both X and Y axes
% crossI = width*thickness^3/12;
thickness= ((Pcr*Le^2/(pi^2*E))*(Le^2/width))^3;

function CylinderBuckling()

function BeamBending()


function ModalAnalysis()
% m would be the sum of everything except for payload
% m_p would be payload mass
% L would be the current initHeight
% What do I use as the E
% What do I use as the I, should I just grab the Ixx and Iyy from the
% matrix?
% What do I use as the A
I = (fnat_lat/0.276)^2*(m*L^3 + 0.236*m_p*L^3)/E;
A = (fnat_ax/0.160)^2*(m*L + 0.333*m_p*L)/E;


