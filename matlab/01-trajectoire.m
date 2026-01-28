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
friction     = zeros(length(x_plot), numel(E_range)); % (without mass as it's irrelevant)

% Storage for finding E with derivative closest to 0
end_derivatives = zeros(numel(E_range), 1);
polynomial_coeffs = cell(numel(E_range), 1);

% Generate a unique position and slope curve for each
% possible E height
for k = 1:numel(E_range)
    x = [x_base; E_x];
    y = [y_base; E_range(k)];

    p = polyfit(x, y, numel(x)-1);

    polynomial_coeffs{k} = p;

    height     = polyval(p, x_plot);
    dp         = polyder(p);
    derivative = polyval(dp, x_plot);
    angle      = atan(derivative);

    end_derivatives(k) = polyval(dp, E_x);

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

% Find E with end derivative closest to 0
[~, closest_idx] = min(abs(end_derivatives));
optimal_E = E_range(closest_idx);
optimal_coeffs = polynomial_coeffs{closest_idx};

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
% title('Polynomial trajectories');
plot(x_base, y_base, 'o',
  'LineWidth', 2,
  'Color', palette{7},
  'MarkerSize', 3);
legend_labels = cell(numel(E_range), 1);
for i = 1:numel(E_range)
    legend_labels{i} = sprintf('E = %.1f m ', E_range(i));
end
legend(legend_labels, 'location', 'northeast');

% Add two separate text objects - one above the other
text1 = sprintf('Polynomiale avec E=%.2f:', optimal_E);
text2 = sprintf('F(x)=%.6f+%.6fx+%.6fx^2+%.6fx^3+%.6fx^4', ...
          optimal_coeffs(5),
          optimal_coeffs(4),
          optimal_coeffs(3),
          optimal_coeffs(2),
          optimal_coeffs(1));

text(0.02, 0.04, text1,
  'Units', 'normalized',
  'VerticalAlignment', 'bottom',
  'BackgroundColor', 'white',
  'EdgeColor', 'black',
  'FontSize', 12);
text(0.02, 0.02, text2,
  'Units', 'normalized',
  'VerticalAlignment', 'bottom',
  'BackgroundColor', 'white',
  'EdgeColor', 'black',
  'FontSize', 12);
save_plot(gcf, '01-trajectories');

figure(2);
grid on;
xlabel('x (m)');
ylabel('𝑑𝑦/𝑑𝑥');
% title('Derivatives of trajectories');
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
% title('Slope Angle');
legend_labels = cell(numel(E_range), 1);
for i = 1:numel(E_range)
    legend_labels{i} = sprintf('E = %.1f m ', E_range(i));
end
legend(legend_labels, 'location', 'northwest');
save_plot(gcf, '01-angles');
