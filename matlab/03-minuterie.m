%% - Trappe, minuteries et collisions
% - Effacage des donn¨¦es
clc;
clear all;
close all;

% - Fetch les variables de configurations
run('01-vitesse.m');

% - Variables pour design
participantSpeed = final_speed_target; % m/s
restitutionCoefficient = 0.8;    % Quand il n'attrape pas la balle

% - Calculs des vitesses du participant apr¨¨s impact
finalSpeedBallCatched = ((participantMass*participantSpeed) + (ballMass * ballSpeed)) / (ballMass + participantMass);
finalSpeedBallNotCatched = ((participantMass*participantSpeed) + ballMass*(ballSpeed + restitutionCoefficient*(ballSpeed - participantSpeed))) / (ballMass + participantMass);

% - Temps pour parcourir la trappe
timeWithBallCatched    = trapDoorLength / finalSpeedBallCatched;
timeWithoutBallCatched = trapDoorLength / finalSpeedBallNotCatched;

safeTimeWithBallCatched    = timeWithBallCatched + trapDoorTimeSecurity;
safeTimeWithoutBallCatched = timeWithoutBallCatched - trapDoorTimeSecurity;

% - Displays
disp(['coefficient de restitution du ballon: ', num2str(restitutionCoefficient), ''])
disp('Masses:')
disp(['    - participant: ', num2str(participantMass), 'kg'])
disp(['    - ballon:      ', num2str(ballMass), 'kg'])
disp('Vitesses initiaux')
disp(['    - participant: ', num2str(participantSpeed), ' m/s'])
disp(['    - ballon:      ', num2str(ballSpeed), ' m/s'])
disp('Vitesses finaux')
disp(['    - si ballon attrape:   ', num2str(finalSpeedBallCatched), ' m/s'])
disp(['    - sans ballon attrape: ', num2str(finalSpeedBallNotCatched), ' m/s'])
disp(['    - difference:           ', num2str(finalSpeedBallCatched-finalSpeedBallNotCatched), ' m/s'])
disp('Temps de parcours de la trappe')
disp(['    - si ballon attrape:   ', num2str(timeWithBallCatched), 's'])
disp(['    - sans ballon attrape: ', num2str(timeWithoutBallCatched), 's'])
disp(['    - difference de temps:  ', num2str(timeWithoutBallCatched-timeWithBallCatched), 's'])
disp('Avec marges de securite')
disp(['    - si ballon attrape:   ', num2str(safeTimeWithBallCatched), 's'])
disp(['    - sans ballon attrape: ', num2str(safeTimeWithoutBallCatched), 's'])
disp(['    - difference de temps:  ', num2str(safeTimeWithoutBallCatched-safeTimeWithBallCatched), 's'])
disp('Choix de la minuterie')
disp(['    - ', num2str((safeTimeWithoutBallCatched+safeTimeWithBallCatched)/2), 's'])
