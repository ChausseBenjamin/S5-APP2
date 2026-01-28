%% - Coussin trampoline

clc;
clear all;
close all;

run('00-global.m');

% - Variables pour le design
totalMass     = participantMass + ballMass;

% - Energie potentielle gravitationnelle a 5 metres
% - - = m * g * h_0
energyAtTrampHeight = totalMass * gravity * trampFallHeight;
% - Energie potentielle lors de la deflection du ressort
% - - = m*g*x. Le x est un coefficient.
potentialEnergyDeflexion = totalMass * gravity;
% - Energie du ressort
% - - = (1/2) * k_c * x^2. x^2 est un coefficient.
springEnergy = -0.5 * springCoefficient;

% - Deflexion total du coussin trampoline.
distance = roots([springEnergy, potentialEnergyDeflexion, energyAtTrampHeight]);
% - On veut les positifs... Ca ferais pas de sense que le ressort deflechisse vers le participant lol.
deflexionX = max(distance);

% - Displays
disp('Masses:')
disp(['    - participant:  ', num2str(participantMass), 'kg'])
disp(['    - ballon:       ', num2str(ballMass), 'kg'])
disp(['    - total:        ', num2str(totalMass), 'kg'])
disp('')
disp(['hauteur de la chute:   ', num2str(trampFallHeight), 'm'])
disp(['vitesse initial:       ', num2str(0), 'm/s'])
disp(['coefficient de raideur: ', num2str(springCoefficient), ' N/m'])
disp(['marge de securite:     ', num2str(trampSafetyMargin), 'm'])
disp('')
disp(['distance de deformation du coussin:   ', num2str(deflexionX), 'm'])
disp(['hauteur coussin avec safety margin:   ', num2str(deflexionX + trampSafetyMargin), 'm'])
