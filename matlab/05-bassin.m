%% - Piscine a vague de valcartier - La meilleur m¨¦thode que l'APP.
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

% - Vitesse d'equilibre
speedEquilibrium = sqrt(((-totalMass*gravity*(buoyancyConstant - 1)))/(hydroCoefficient));
safeEquilibriumSpeed = speedEquilibrium * safeSpeedFactor;
equilibriumXLine = -speedEquilibrium * ones(1, (simulationDuration/timeIncrements) +1);
safeEquilibriumXLine = -safeEquilibriumSpeed * ones(1, (simulationDuration/timeIncrements) +1);

simulatedSafeDepth = 0;

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

    if abs(speed(i+1) - (-safeEquilibriumSpeed)) <= 0.0001
      % - Vitesse securitaire. Enregistre la position.
      simulatedSafeDepth = position(i+1);
    endif
end







 % - M¨¦thode de l'APP
speedEquilibrium = -speedEquilibrium;
speedWhenWaterHit = -sqrt(2*gravity*poolFallHeight);
taylored = (speedEquilibrium^2) + 2*speedEquilibrium*(speedWhenWaterHit - speedEquilibrium);
linearA = gravity*(buoyancyConstant-1) + (hydroCoefficient / participantMass) * taylored;
depth = (((safeEquilibriumSpeed^2) - (speedWhenWaterHit^2))/2)/(linearA);

% - Pour graphiques
appSpeed = linspace(speedEquilibrium, speedWhenWaterHit, sizeOfTime);
graphTaylored = (speedEquilibrium.^2) + 2 .* speedEquilibrium.*(appSpeed - speedEquilibrium);
graphLinearA = gravity.*(buoyancyConstant-1) + (hydroCoefficient / participantMass) .* (graphTaylored);

% - Magouille de signe pour le faire afficher a la bonne place
graphDepth = -((((speedEquilibrium^2) - (appSpeed.^2))/2)./(graphLinearA));
graphDepth = graphDepth - graphDepth(end);






%% Graphique de la vitesse en fonction du temps, lin¨¦aris¨¦.
figure;
hold on;
plot(appSpeed, graphDepth, "LineWidth", 2);
ylim([-10 1]);
line([speedWhenWaterHit speedWhenWaterHit], ylim, 'color', 'r', 'linewidth', 2, 'linestyle', '--');
line([speedEquilibrium speedEquilibrium], ylim, 'color', 'b', 'linewidth', 2, 'linestyle', '--');
line([-safeEquilibriumSpeed -safeEquilibriumSpeed], ylim, 'color', 'g', 'linewidth', 2, 'linestyle', '--');
ylabel("Profondeur (m)");
xlabel("Vitesse (m/s)");
title("Vitesse en fonction de la profondeur APP");
grid on;

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

%% Graphique vitesse en fonction de la position
##figure;
##plot(time, position, "LineWidth", 2);
##xlabel("Temps (s)");
##ylabel("Position (m)");
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
disp(["profondeur s¨¦curitaire du bassin d'eau: (APP)  ", num2str(depth), ' metres'])
disp(["profondeur s¨¦curitaire simule:                 ", num2str(simulatedSafeDepth), ' metres'])
