%% - Piscine a vague de valcartier
clc;
clear all;
close all;

run('00-global.m');

% - Variables pour le design
timeIncrements = 0.001;
simulationDuration = 5;
time = 0:timeIncrements:simulationDuration;
sizeOfTime = length(time);
totalMass = participantMass + ballMass;
timeIndexWaterHit = 0;

% - Axes vides qu'on vas remplir point par point.
position = zeros(1, sizeOfTime);
speed = zeros(1, sizeOfTime);
acceleration = zeros(1, sizeOfTime);

% - Conditions initiales
position(1) = poolFallHeight; % La position debute a l'hauteur du pont pierre-laporte. A pos=0 on frappe le fleuve saint-laurent.
speed(1) = 0;                 % la vitesse du participant est mis a 0. Pas specifier dans le guide.


% - Simulation.
for i = 1:sizeOfTime-1

    % Choix du milieu
    if position(i) >= 0
        acceleration(i) = -gravity;
        %disp(acceleration(i))
        timeIndexWaterHit = i;
    else
        %acceleration(i) = -gravity;
        acceleration(i) = -(1 - buoyancyConstant)*gravity + (hydroCoefficient/totalMass)*(speed(i)*speed(i));
        %disp(acceleration(i))
    end

    % - Int¨¦gration pour obtenir la vitesse et la position
    speed(i+1) = speed(i) + acceleration(i)*timeIncrements;
    position(i+1) = position(i) + speed(i+1)*timeIncrements;
end

%% Graphique vitesse en fonction du temps
figure;
hold on;
plot(time, speed, "LineWidth", 2);
xlabel("Temps (s)");
ylabel("Vitesse (m/s)");
title("Vitesse en fonction du temps");
grid on;

%% Graphique vitesse en fonction de la position
figure;
plot(time, position, "LineWidth", 2);
xlabel("Temps (s)");
ylabel("Position (m)");
title("Position en fonction du temps");
grid on;

%% Graphique vitesse en fonction de la position
figure;
plot(position, speed, "LineWidth", 2);
xlabel("position (m)");
ylabel("Vitesse (m/s)");
title("Vitesse en fonction de la position");
grid on;
