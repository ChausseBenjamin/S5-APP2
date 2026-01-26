%% - Coussin trampoline

clc;
clear all;
close all;

run('00-global.m');

initialSpeed  = trampInitialVertSpeed;
initialHeight = trampolineInitialHeight;
totalMass     = participantMass + ballMass;

% - Énergie du participant
% - - Toute l'énergie potentiel à 5 mètre devient cinétique en touchant le coussin.
% - - Si on à une énergie cinétique initial, alors elle est simplement additionnée.

% - - Énergie cinétique initial
initialKineticEnergy = 0.5 * totalMass * (initialSpeed^2);
% - - Énergie potentielle à 5 mètres
potentialEnergyAtDistance = totalMass * gravity * initialHeight;
% - - Énergie mécanique à l'impact avec le coussin. Em = Ep + Ec
participantEnergyAtImpact = initialKineticEnergy + potentialEnergyAtDistance;

% - Distance de déformation / équilibre
% - - Énergie du participant = énergie du ressort
distance = sqrt(participantEnergyAtImpact / (0.5 * springCoefficient));

% - Displays
disp(['masse du participant:  ', num2str(participantMass), 'kg'])
disp(['masse du ballon:       ', num2str(ballMass), 'kg'])
disp(['masse des deux:        ', num2str(totalMass), 'kg'])
disp('')
disp(['hauteur de la chute:   ', num2str(initialHeight), 'm'])
disp(['vitesse initial:       ', num2str(initialSpeed), 'm/s'])
disp(['coefficient de raideur: ', num2str(springCoefficient), ' N/m'])
disp('')
disp(['energie cinetique initial:            ', num2str(initialKineticEnergy), 'J'])
disp(['energie potentielle a hauteur h0:     ', num2str(potentialEnergyAtDistance), 'J'])
disp(['energie que le ressort doit absorbee: ', num2str(participantEnergyAtImpact), 'J'])
disp('')
disp(['distance de deformation du ressort:   ', num2str(distance), 'm'])
