clc
clear all
close all

% Use gnuplot toolkit globally
graphics_toolkit('gnuplot');

% Set global font defaults for all plots
set(0, 'DefaultAxesFontName', 'CMU Serif');
set(0, 'DefaultTextFontName', 'CMU Serif');
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);

% Set global default properties to minimize repetitive settings
set(0, 'DefaultTextUnits', 'normalized');  % So text positioning uses 0-1 coordinates

% Figures root path
global figures_path;
figures_path = '../rapport/figures/';
if ~exist(figures_path, 'dir')
    mkdir(figures_path);
end

palette = {
	"#66aabb", ...
	"#b74163", ...
	"#254e70", ...
	"#7c66b7", ...
	"#cc7e00", ...
	"#436436", ...
	"#059a94", ...
};

% participant mass
m   = 80; % kg

% hydrodynamic coefficient
b   = 47; % kg/m

% flotability constant (slightly negative)
k_f = 0.95;


% Only the first four since we need to figure out the last
first_points = [
% x: m  y: m
	0,    30; % A
	8,    19; % B
	15,   20; % C
	20,   16; % D
];

% Data for the last point of the trajectory
E_x = 25; % m
E_range = linspace(10,15,6); % can increase precision later

valve_data = [
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

function save_plot(fig_handle, filename, square_size)
    global figures_path;

    if nargin < 1 || isempty(fig_handle)
        fig_handle = gcf;
    end

    if nargin < 3 || isempty(square_size)
        square_size = 6; % 6x6 inches square
    end

    [~, name, ~] = fileparts(filename);
    base_path = fullfile(figures_path, name);

    set(fig_handle, 'PaperUnits', 'inches');
    set(fig_handle, 'PaperSize', [square_size square_size]);
    set(fig_handle, 'PaperPosition', [0 0 square_size square_size]);

    print(fig_handle, [base_path '.pdf'], '-dpdfcairo');

    fprintf('PDF saved: %s.pdf (%.1fx%.1f inches, CMU Serif, colored plots)\n', base_path, square_size, square_size);
end
