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


%% Trampoline values

springCoefficient     = 6000; % N/m
trampInitialHeight    = 5;    % m
trampInitialVertSpeed = 0;    % m


%% Bassin values

b   = 47;   % kg/m
k_f = 0.95; % flotability constant (slightly negative)

