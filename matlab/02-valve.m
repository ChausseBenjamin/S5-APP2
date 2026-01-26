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
y_fit_points = v(1) + v(2)*x + v(3)*x.^2;

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

title('Friction selon l''ouverture de la valve', 'FontSize', 17);
xlabel('Ouverture de la valve (%)', 'FontSize', 15);
ylabel('Coefficient de frottement μf', 'FontSize', 15);

% Data points with specified color
plot(valve_pcnt, valve_friction, 'o',
  'LineWidth', 2,
  'Color', palette{8},
  'MarkerSize', 3);

% Fitted Curve with specified color
plot(x_fit, y_fit, '-',
  'Color', palette{2},
	'LineWidth', 2);

% Add legend (defaults to northeast automatically)
legend('Données expérimentales', 'Approximation quadratique');

% Add function equation with Unicode symbols (units now default to normalized)
text(0.95, 0.85, sprintf('F(x) = %.4f + %.4fx + %.4fx²', v(1), v(2), v(3)), ...
    'HorizontalAlignment', 'right');

text(0.95, 0.75, sprintf('R² = %.4f', R2), ...
    'HorizontalAlignment', 'right');

axis tight;

% Save using the new save_plot function
save_plot(gcf, '02-valve');
