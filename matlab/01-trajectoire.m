clc
clear all
close all

run("00-global.m");

x_base = first_points(:,1);
y_base = first_points(:,2);

% Evaluation grid for smooth plotting
x_plot = linspace(min(x_base), E_x, 500);

figure(1); clf; hold on; axis tight;
figure(2); clf; hold on; axis tight;

% Generate a unique position and slope curve for each
% possible E height
for k = 1:numel(E_range)
    % Construct full point set
    x = [x_base; E_x];
    y = [y_base; E_range(k)];

    % Polynomial through all points (degree = N-1)
    p = polyfit(x, y, numel(x)-1);

    % Evaluate polynomial
    y_plot = polyval(p, x_plot);

    % Shape
    figure(1);
    color_idx = mod(k-1, length(palette)) + 1;  % Cycle through colors
    plot(x_plot, y_plot, 'LineWidth', 1.2, 'Color', palette{color_idx});
		% Slope
    plot([E_x], [E_range(k)], 'o',
		  'LineWidth', 2,
			'Color', palette{color_idx},
			'MarkerSize', 3);

    % Derivative polynomial
    dp = polyder(p);
    dy_plot = polyval(dp, x_plot);

    % Slope (derivative)
    figure(2);
    plot(x_plot, dy_plot,
		  'LineWidth', 1.2,
			'Color', palette{color_idx});
		% Use this for the slope in degrees:
    % plot(x_plot, 180*atan(dy_plot)/pi,
end

figure(1);
grid on;
xlabel('x (m)');
ylabel('y (m)');
title('Polynomial trajectories');
plot(x_base, y_base, 'o',
  'LineWidth', 2,
  'Color', palette{7},
  'MarkerSize', 3)
save_plot(gcf, '01-trajectories');

figure(2);
grid on;
xlabel('x (m)');
% ylabel('slope (°)');
ylabel('𝑑𝑦/𝑑𝑥');
title('Derivatives of trajectories');

save_plot(gcf, '01-derivatives');
