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
  "#009CCC", ...
  "#A52C9F", ...
  "#672273", ...
  "#F7A51C", ...
  "#416E37", ...
  "#385A64", ...
  "#6A6D36", ...
	"#b74163", ...
	"#254e70", ...
	"#7c66b7", ...
	"#cc7e00", ...
};

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
end

function result = kph2mps(s)
	result = s/3.6;
end

function result = mps2kph(s)
	result = s*3.6;
end
