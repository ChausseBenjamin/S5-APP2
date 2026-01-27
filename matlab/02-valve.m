run('00-global.m')

valve_pcnt     = valve_dataset(:,1);
valve_friction = valve_dataset(:,2);

x = valve_pcnt(:);       % 11x1 column
y = valve_friction(:);   % 11x1 column

M = [ones(length(x),1), x, x.^2];  % 11x3 matrix

valve_coeffs = (inv(M.'*M) * M.') * y;  % 3x1 coefficients

% Dense x values for smooth curve
x_fit = linspace(min(x), max(x), 100);   % 100 points between min and max of x
y_fit = valve_coeffs(1) + valve_coeffs(2)*x_fit + valve_coeffs(3)*x_fit.^2;    % evaluate quadratic

% Predicted values from fitted quadratic
y_fit_points = valve_coeffs(1) + valve_coeffs(2)*x + valve_coeffs(3)*x.^2;

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
  'Color', palette{7},
  'MarkerSize', 3);

% Fitted Curve with specified color
plot(x_fit, y_fit, '-',
  'Color', palette{2},
	'LineWidth', 2);

% Add legend (defaults to northeast automatically)
legend('Données expérimentales', 'Approximation quadratique');

% Add function equation with Unicode symbols (units now default to normalized)
text(0.95, 0.85, sprintf('F(x) = %.4f + %.4fx + %.4fx²', valve_coeffs(1), valve_coeffs(2), valve_coeffs(3)), ...
    'HorizontalAlignment', 'right');

text(0.95, 0.75, sprintf('R² = %.4f', R2), ...
    'HorizontalAlignment', 'right');

axis tight;

% Save using the new save_plot function
save_plot(gcf, '02-valve');



function [mu_min, mu_max, mu_predicted] = find_mu_range(valve_coeffs, x_opening, y, R2)
    mu_predicted = valve_coeffs(1) + valve_coeffs(2)*x_opening + valve_coeffs(3)*x_opening^2;
    n = length(y);  % number of data points
    p = 3;          % number of parameters (intercept + linear + quadratic)

    % Degrees of freedom
    df = n - p;

    % Estimate standard error from R²
    % R² = 1 - SS_res/SS_tot, so SS_res = SS_tot*(1-R²)
    SS_tot = sum((y - mean(y)).^2);
    SS_res = SS_tot * (1 - R2);

    % Standard error of estimate
    std_error = sqrt(SS_res / df);

    % For 95% confidence interval (approximately ±2 standard errors)
    % You can adjust this multiplier for different confidence levels
    confidence_multiplier = 2.0;  % ~95% confidence

    uncertainty = confidence_multiplier * std_error;

    % Calculate range
    mu_min = mu_predicted - uncertainty;
    mu_max = mu_predicted + uncertainty;

    % Display results
    fprintf('Valve opening %.2f%%:\n', x_opening);
    fprintf('  Predicted μ = %.4f\n', mu_predicted);
    fprintf('  Range: %.4f ≤ μ ≤ %.4f\n', mu_min, mu_max);
    fprintf('  Uncertainty: ±%.4f (based on R² = %.4f)\n', uncertainty, R2);
end
