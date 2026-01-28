%% - Piscine a vague de valcartier - La meilleur m��thode que l'APP.
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

% - Vitesse d'equilibre
speedEquilibrium = sqrt((-gravity*(buoyancyConstant-1))/((hydroCoefficient)/(participantMass)));
safeEquilibriumSpeed = speedEquilibrium * safeSpeedFactor;
speedEquilibrium = -speedEquilibrium;
safeEquilibriumSpeed = -safeEquilibriumSpeed;

% - Calculs a travers la linearization
speedWhenWaterHit = -sqrt(2*gravity*poolFallHeight);

% - Pour graphiques
appSpeed = linspace(safeEquilibriumSpeed, speedWhenWaterHit, sizeOfTime);

% - Calcul de la profondeur
lambda = ((-(gravity * (buoyancyConstant - 1))) / (speedEquilibrium^2)) + (hydroCoefficient / participantMass);
delta = safeEquilibriumSpeed - speedEquilibrium;
depth = (1/lambda) * log(delta/(speedWhenWaterHit - speedEquilibrium))

% - Graphique de la profondeur
delta = appSpeed - speedEquilibrium;
zGraph = (1/lambda) * log(delta/(speedWhenWaterHit - speedEquilibrium));

figure;
hold on;
plot(appSpeed, zGraph, "LineWidth", 2, "Color", palette{1});
ylim([-5 0]);
xlim([-15 -0.5]);
line([speedWhenWaterHit speedWhenWaterHit], ylim, 'DisplayName', 'Vitesse frappe eau', 'color', palette{2}, 'linewidth', 2, 'linestyle', '--');
line([speedEquilibrium speedEquilibrium], ylim, 'DisplayName', 've', 'color', palette{3}, 'linewidth', 2, 'linestyle', '--');
line([safeEquilibriumSpeed safeEquilibriumSpeed], ylim, 'DisplayName', 've securitaire', 'color', palette{4}, 'linewidth', 2, 'linestyle', '--');
line(xlim, [depth depth], 'DisplayName', 'profondeur', 'color', palette{5}, 'linewidth', 2, 'linestyle', '--');
ylabel("Profondeur (m)");
xlabel("Vitesse (m/s)");
title("Vitesse en fonction de la profondeur APP");
grid on;
legend('show', 'Location', 'northeast');



% - SIMULATION DE LA POSITION DANS LE TEMPS COMPLET - Pas demander dans la problematique

% - Axes vides qu'on vas remplir point par point.
position = zeros(1, sizeOfTime);
speed = zeros(1, sizeOfTime);
acceleration = zeros(1, sizeOfTime);

% - Conditions initiales
position(1) = poolFallHeight; % La position debute a l'hauteur du pont pierre-laporte. A pos=0 on frappe le fleuve saint-laurent.
speed(1) = 0;                 % la vitesse du participant est mis a 0. Pas specifier dans le guide.

% - Vitesse d'equilibre
equilibriumXLine = -speedEquilibrium * ones(1, (simulationDuration/timeIncrements) +1);
safeEquilibriumXLine = -safeEquilibriumSpeed * ones(1, (simulationDuration/timeIncrements) +1);

simulatedSafeDepth = 0;
timeIndexWaterHit = 0;

% - Simulation.
for i = 1:sizeOfTime-1

    % Choix du milieu
    if position(i) >= 0
        acceleration(i) = -gravity;
        timeIndexWaterHit = i;
    else
        acceleration(i) = -(1 - buoyancyConstant)*gravity + (hydroCoefficient/totalMass)*(speed(i)*speed(i));
    end

    % - Int��gration pour obtenir la vitesse et la position
    speed(i+1) = speed(i) + acceleration(i)*timeIncrements;
    position(i+1) = position(i) + speed(i+1)*timeIncrements;

    % - Vitesse securitaire. Enregistre la position.
    if abs(speed(i+1) - (safeEquilibriumSpeed)) <= 0.00005
      simulatedSafeDepth = position(i+1);
    endif
end

%% Graphique vitesse en fonction du temps
##figure;
##hold on;
##plot(time, speed, "LineWidth", 2);
##plot(time, equilibriumXLine, "LineWidth", 2, "b--");
##plot(time, safeEquilibriumXLine, "LineWidth", 2, "r--");
##xlabel("Temps (s)");
##ylabel("Vitesse (m/s)");
##title("Vitesse en fonction du temps");
##grid on;

%graphDepthShifted = NaN(size(graphDepth));
%shift = timeIndexWaterHit+1;
%graphDepthShifted(shift+1:end) = graphDepth(1:end-shift);

%% Graphique vitesse en fonction de la position
##figure;
##hold on;
##plot(time, position, "LineWidth", 2);
##plot(time, -graphDepthShifted - 9, "LineWidth", 2);
##xlabel("Temps (s)");
##ylabel("Position (m)");
##line(xlim, [depth depth], 'DisplayName', 'profondeur', 'color', palette{5}, 'linewidth', 2, 'linestyle', '--');
##title("Position en fonction du temps");
##grid on;

%% Graphique vitesse en fonction de la position
##figure;
##plot(position, speed, "LineWidth", 2);
##xlabel("position (m)");
##ylabel("Vitesse (m/s)");
##title("Vitesse en fonction de la position");
##grid on;




% - Displays
disp('')
disp(["vitesse limite du participant dans l'eau: v_e: ", num2str(speedEquilibrium), 'm/s'])
disp(["profondeur s��curitaire du bassin d'eau: (APP)  ", num2str(depth), ' metres'])
%disp(["profondeur s��curitaire simule:                 ", num2str(simulatedSafeDepth), ' metres'])
