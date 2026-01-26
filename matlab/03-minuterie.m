%% - Trappe, minuteries et collisions
% - Effacage des donn¨¦es
clc;
clear all;
close all;

% - Fetch les variables de configurations
run('00-global.m');

% - Variables pour design
participantSpeed = 20/3.6; % m/s
restitutionCoefficient = 0.8;    % Quand il n'attrape pas la balle

% - Calculs des vitesses du participant apr¨¨s impact
finalSpeedBallCatched = ((participantMass*participantSpeed) + (ballMass * ballSpeed)) / (ballMass + participantMass);
finalSpeedBallNotCatched = ((participantMass*participantSpeed) + ballMass*(ballSpeed + restitutionCoefficient*(ballSpeed - participantSpeed))) / (ballMass + participantMass);

% - Temps pour parcourir la trappe
timeWithBallCatched    = trapDoorLength / finalSpeedBallCatched;
timeWithoutBallCatched = trapDoorLength / finalSpeedBallNotCatched;

safeTimeWithBallCatched    = timeWithBallCatched - trapDoorTimeSecurity;
safeTimeWithoutBallCatched = timeWithoutBallCatched + trapDoorTimeSecurity;

% - Displays
disp('Masses:')
disp(['    - participant: ', num2str(participantMass), 'kg'])
disp(['    - ballon:      ', num2str(ballMass), 'kg'])
disp('')
disp(['vitesse initiale du participant: ', num2str(participantSpeed), ' m/s'])
disp(['vitesse initiale du ballon:      ', num2str(ballSpeed), ' m/s'])
disp('')
disp(['vitesse final du participant quand ballon attrap¨¦: ', num2str(finalSpeedBallCatched), ' m/s'])
disp(['vitesse final du participant quand pas de ballon:  ', num2str(finalSpeedBallNotCatched), ' m/s'])
disp(['coefficient de restitution du ballon:              ', num2str(restitutionCoefficient), ''])
disp('')
disp(['temps pour parcourir la trappe si ballon attrap¨¦:   ', num2str(timeWithBallCatched), 's'])
disp(['                          avec marge de s¨¦curit¨¦:   ', num2str(safeTimeWithBallCatched), 's'])
disp(['temps pour parcourir la trappe sans ballon attrap¨¦: ', num2str(timeWithoutBallCatched), 's'])
disp(['                          avec marge de s¨¦curit¨¦:   ', num2str(safeTimeWithoutBallCatched), 's'])


##%% - Trappe, minuteries et collisions
##clc;
##clear all;
##close all;
##
##% - Fetch les variables de configurations
##run('00-global.m');
##
##% - Variables pour design
##participantSpeed = 20/3.6; % m/s
##
##% - Coefficient de restitution (balayage)
##restitutionCoefficient = linspace(0, 0.8, 100);
##
##% - Vitesse finale si ballon attrap¨¦ (constante)
##finalSpeedBallCatched = ((participantMass*participantSpeed) + (ballMass * ballSpeed)) ...
##                        / (ballMass + participantMass);
##
##% - Vitesse finale si ballon NON attrap¨¦ (fonction de e)
##finalSpeedBallNotCatched = ((participantMass*participantSpeed) ...
##                           + ballMass*(ballSpeed + restitutionCoefficient .* (ballSpeed - participantSpeed))) ...
##                           / (ballMass + participantMass);
##
##% - Temps pour parcourir la trappe
##timeWithBallCatched    = trapDoorLength ./ finalSpeedBallCatched;
##timeWithoutBallCatched = trapDoorLength ./ finalSpeedBallNotCatched;
##
##% - Marges de s¨¦curit¨¦
##safeTimeWithBallCatched    = timeWithBallCatched - trapDoorTimeSecurity;
##safeTimeWithoutBallCatched = timeWithoutBallCatched + trapDoorTimeSecurity;
##
##%% - Graphique
##figure;
##hold on;
##grid on;
##
##plot(restitutionCoefficient, timeWithoutBallCatched, 'r', 'LineWidth', 2);
##plot(restitutionCoefficient, safeTimeWithoutBallCatched, 'r', 'LineWidth', 1);
##plot(restitutionCoefficient, timeWithBallCatched * ones(size(restitutionCoefficient)), ...
##     'b--', 'LineWidth', 2);
##plot(restitutionCoefficient, safeTimeWithBallCatched * ones(size(restitutionCoefficient)), ...
##     'b--', 'LineWidth', 1);
##
##xlabel('Coefficient de restitution');
##ylabel('Temps pour parcourir la trappe (s)');
##title('Temps de parcours en fonction du coefficient de restitution');
##
##legend('Sans ballon attrap¨¦', 'Ballon attrap¨¦', 'Location', 'best');

