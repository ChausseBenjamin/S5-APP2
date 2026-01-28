clc
clear all
close all

%% UI Setup (defaults and shit)
run('99-utils.m');

%% Global values
gravity         = 9.81; % m/s^2
participantMass = 80;   % kg

% Ball values
ballMass   = 8;  % kg
ballSpeed  = -1; % m/s

% Trapdoor values
trapDoorLength       = 3;    % m
trapDoorTimeSecurity = 0.02; % s; Marge de sécurité donnée

%% Trampoline values
springCoefficient = 6000; % N/m
trampFallHeight   = 5;    % m hauteur du participant avant de tomber sur la trampoline.
trampSafetyMargin = 0.5;  % 50 cm needs to be added to the total of the trampoline height.

%% Bassin values
poolFallHeight   = 10;   % m; Hauteur initial entre le participant et la hauteur de l'eau.
hydroCoefficient = 47;   % kg/m; b.
buoyancyConstant = 0.95; % flotability constant. k_f (slightly negative)
safeSpeedFactor  = 1.10; % Pourcentage de la vitesse d'equilibre qui est permit de frappe le fond de la piscine

%% Trajectory Data

% Only the first 4 since we need to figure out the last
first_points = [
% x: m  y: m
	0,    30; % A
	7,    20; % B
	15,   20; % C
	20,   16; % D
];

% Last point of the trajectory (with multiple possibly y values)
E_x     = 25;          % m
E_range = [10:0.5:15]; % m

initialHeight = first_points(1,2);

minSpeed      = kph2mps(10); % m/s
maxSpeed      = kph2mps(45); % m/s
minFinalSpeed = kph2mps(20); % m/s
maxFinalSpeed = kph2mps(25); % m/s

%% Valve values

valve_dataset = [
% percent, friction coefficient
  00,      0.87;
  10,      0.78;
  20,      0.71;
  30,      0.61;
  40,      0.62;
  50,      0.51;
  60,      0.51;
  70,      0.49;
  80,      0.46;
  90,      0.48;
  100,     0.46;
];

