clc
clear all
close all

%% UI Setup (defaults and shit)
run('99-utils.m');


%% Global values
gravity               = 9.81; % m/s^2
participantMass       = 80;   % kg

% Ball values
ballMass   = 8;    % Kg
ballSpeed  = -1;     % m/s

% Trapdoor values
trapDoorLength       = 3;      % meters
trapDoorTimeSecurity = 0.02;   % seconds. Marge de s¨¦curit¨¦ donn¨¦e

%% Trampoline values
springCoefficient  = 6000; % N/m
trampFallHeight   = 5;    % m hauteur du participant avant de tomber sur la trampoline.
trampSafetyMargin = 0.5;  % 50 cm need to be added to the total of the trampoline height.

%% Bassin values
poolFallHeight   = 10;   % meters. Hauteur initial entre le participant et la hauteur de l'eau.
hydroCoefficient  = 47;   % kg/m; b.
buoyancyConstant = 0.95; % flotability constant. k_f (slightly negative)
safeSpeedFactor  = 1.10; % Pourcentage de la vitesse d'equilibre qui est permit de frappe le fond de la piscine

%% Trajectory Data

% Only the first 4 since we need to figure out the last
first_points = [
% x: m  y: m
	0,    30; % A
	8,    19; % B
	15,   20; % C
	20,   16; % D
];

% Last point of the trajectory (with multiple possibly y values)
E_x     = 25;                % m
E_range = linspace(10,15,12); % m


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

