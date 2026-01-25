run('00-global.m')

valve_pcnt     = valve_data(:,1);
valve_friction = valve_data(:,2);

x = valve_pcnt(:);       % 11x1 column
y = valve_friction(:);   % 11x1 column

M = [ones(length(x),1), x, x.^2];  % 11x3 matrix

v = (inv(M.'*M) * M.') * y;  % 3x1 coefficients

% Dense x values for smooth curve
x_fit = linspace(min(x), max(x), 100);   % 100 points between min and max of x
y_fit = v(1) + v(2)*x_fit + v(3)*x_fit.^2;    % evaluate quadratic

% Predicted values from fitted quadratic
y_fit_points = v(1) + v(2)*x + v(3\*x.^2;

% Residual sum of squares
SS_res = sum((y - y_fit_points).^2);

% Total sum of squares
SS_tot = sum((y - mean(y)).^2);

% R^2
R2 = 1 - SS_res / SS_tot;

% Plot
figure;
hold on;
grid on;

title('Valve Friction vs Opening');
xlabel('Valve Opening (%)');
ylabel('Friction Coefficient');

% Data points:
plot(valve_pcnt, valve_friction, 'o',
  'LineWidth', 1.5,
  'Color', '#66aabb');

% Fitted Curve:
plot(x_fit, y_fit, '-',
  'Color', '#b7416e',
	'LineWidth', 2);

% Add R^2 to top-right
text(0.95, 0.95, sprintf('R^2 = %.4f', R2), ...
    'Units', 'normalized', ...   % use axes-relative coordinates
    'HorizontalAlignment', 'right', ...
    'VerticalAlignment', 'top', ...
    'FontSize', 12, ...
    'FontWeight', 'bold');
