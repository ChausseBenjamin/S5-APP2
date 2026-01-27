% Import guard - ensure global variables are loaded
if ~exist('first_points', 'var') || ~exist('E_range', 'var')
    run('00-global.m');
end

figure(1); clf; hold on; axis tight;
figure(2); clf; hold on; axis tight;
figure(3); clf; hold on; axis tight;

x_base = first_points(:,1);
y_base = first_points(:,2);

% Memory pre-allocations
x_plot       = linspace(min(x_base), E_x, 2501);      % x-axis resolution
trajectories = zeros(length(x_plot), numel(E_range)); % Position data
slopes       = zeros(length(x_plot), numel(E_range)); % Derivative data
angles       = zeros(length(x_plot), numel(E_range)); % Angles in degrees
friction     = zeros(length(x_plot), numel(E_range));

% Generate a unique position and slope curve for each
% possible E height
for k = 1:numel(E_range)
    % Construct full point set
    x = [x_base; E_x];
    y = [y_base; E_range(k)];

    % Polynomial through all points (degree = N-1)
    p = polyfit(x, y, numel(x)-1);

    % Evaluate data
    height     = polyval(p, x_plot);
    dp         = polyder(p);
    derivative = polyval(dp, x_plot);
		angle      = atan(derivative);

    % Store data
    trajectories(:, k) = height;
    slopes(:, k)       = derivative;
    angles(:, k)       = angle;

    % Shape
    figure(1);
    color_idx = mod(k-1, length(palette)) + 1;  % Cycle through colors
    plot(x_plot, height,
		'Color', palette{color_idx},
	  'LineWidth', 1.2);

    % Slope (derivative)
    figure(2);
    plot(x_plot, derivative,
	'Color', palette{color_idx},
  'LineWidth', 1.2);

	% Angle
	figure(3);
    plot(x_plot, angle,
		'Color', palette{color_idx},
	  'LineWidth', 1.2);
end

% Add endpoint circles after the loop (so they don't affect legend)
figure(1);
for k = 1:numel(E_range)
    color_idx = mod(k-1, length(palette)) + 1;
    plot([E_x], [E_range(k)], 'o',
  'LineWidth', 2,
	'Color', palette{color_idx},
	'MarkerSize', 3);
end

figure(1);
grid on;
xlabel('x (m)');
ylabel('y (m)');
title('Polynomial trajectories');
plot(x_base, y_base, 'o',
  'LineWidth', 2,
  'Color', palette{7},
  'MarkerSize', 3);
legend_labels = cell(numel(E_range), 1);
for i = 1:numel(E_range)
    legend_labels{i} = sprintf('E = %.1f m ', E_range(i));
end
legend(legend_labels, 'location', 'northeast');
save_plot(gcf, '01-trajectories');

figure(2);
grid on;
xlabel('x (m)');
ylabel('𝑑𝑦/𝑑𝑥');
title('Derivatives of trajectories');
legend_labels = cell(numel(E_range), 1);
for i = 1:numel(E_range)
    legend_labels{i} = sprintf('E = %.1f m ', E_range(i));
end
legend(legend_labels, 'location', 'southeast');
save_plot(gcf, '01-derivatives');

figure(3);
grid on;
xlabel('x (m)');
ylabel('slope (°)');
title('Slope Angle');
legend_labels = cell(numel(E_range), 1);
for i = 1:numel(E_range)
    legend_labels{i} = sprintf('E = %.1f m ', E_range(i));
end
legend(legend_labels, 'location', 'northwest');
save_plot(gcf, '01-angles');
