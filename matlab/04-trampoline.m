%% - Coussin trampoline

clc;
clear all;
close all;

run('00-global.m');

initialSpeed  = trampInitialVertSpeed;
initialHeight = trampInitialHeight;
totalMass     = participantMass + ballMass;

% - energie du participant
% - - Toute l'energie potentiel a 5 metre devient cinetique en touchant le coussin.
% - - Si on a une energie cinetique initial, alors elle est simplement additionnee.

% - - energie cinetique initial
initialKineticEnergy = 0.5 * totalMass * (initialSpeed^2);
% - - energie potentielle a 5 metres
potentialEnergyAtDistance = totalMass * gravity * initialHeight;
% - - energie mecanique a l'impact avec le coussin. Em = Ep + Ec
participantEnergyAtImpact = initialKineticEnergy + potentialEnergyAtDistance;

% - Distance de deformation / equilibre
% - - energie du participant = energie du ressort
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
