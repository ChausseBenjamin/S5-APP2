% Import guard - ensure global variables are loaded
if ~exist('first_points', 'var') || ~exist('E_range', 'var')
    run('00-global.m');
end

valve_pcnt     = valve_dataset(:,1);
valve_friction = valve_dataset(:,2);

x_valve = valve_pcnt(:);       % 11x1 column
y_valve = valve_friction(:);   % 11x1 column

M = [ones(length(x_valve),1), x_valve, x_valve.^2];  % 11x3 matrix

valve_coeffs = (inv(M.'*M) * M.') * y_valve;  % 3x1 coefficients

% Linear approximation using the same mathematical process
M_linear = [ones(length(x_valve),1), x_valve];  % 11x2 matrix for linear fit

valve_coeffs_linear = (inv(M_linear.'*M_linear) * M_linear.') * y_valve;  % 2x1 coefficients

% Dense x values for smooth curve
x_fit = linspace(min(x_valve), max(x_valve), 1000);   % points between min and max of x
y_fit = valve_coeffs(1) + valve_coeffs(2)*x_fit + valve_coeffs(3)*x_fit.^2;    % evaluate quadratic
y_fit_linear = valve_coeffs_linear(1) + valve_coeffs_linear(2)*x_fit;          % evaluate linear

% Predicted values from fitted curves
y_fit_points = valve_coeffs(1) + valve_coeffs(2)*x_valve + valve_coeffs(3)*x_valve.^2;
y_fit_points_linear = valve_coeffs_linear(1) + valve_coeffs_linear(2)*x_valve;

% Residual sum of squares
SS_res = sum((y_valve - y_fit_points).^2);

% Total sum of squares
SS_tot = sum((y_valve - mean(y_valve)).^2);

% R^2
R2 = 1 - SS_res / SS_tot;

% RMS (Root Mean Square) error
residuals = y_valve - y_fit_points;
RMS = sqrt(mean(residuals.^2));

% Linear approximation RMS error
residuals_linear = y_valve - y_fit_points_linear;
RMS_linear = sqrt(mean(residuals_linear.^2));

% Plot
figure; axis tight;
hold on;
grid on;

% title('Friction selon l''ouverture de la valve', 'FontSize', 17);
xlabel('Ouverture de la valve (%)', 'FontSize', 15);
ylabel('Coefficient de frottement μf', 'FontSize', 15);

plot(valve_pcnt, valve_friction, 'o',
  'LineWidth', 2,
  'Color', palette{7},
  'MarkerSize', 3);

% Quadratic
plot(x_fit, y_fit, '-',
  'Color', palette{2},
  'LineWidth', 2);

% Linear
plot(x_fit, y_fit_linear, '-',
  'Color', palette{3},
  'LineWidth', 2);

legend('Données expérimentales',
  'Approximation quadratique F(x)',
  'Approximation linéaire L(x)');

text(0.95, 0.85,
  sprintf('F(x) = %.4f + %.4fx + %.4fx²',
	  valve_coeffs(1),
		valve_coeffs(2),
		valve_coeffs(3)), ...
  'HorizontalAlignment', 'right');

text(0.95, 0.82, sprintf('RMS = %.4f', RMS), ...
    'HorizontalAlignment', 'right');

text(0.95, 0.75,
  sprintf('L(x) = %.4f + %.4fx',
	  valve_coeffs_linear(1),
		valve_coeffs_linear(2)), ...
  'HorizontalAlignment', 'right');

text(0.95, 0.72, sprintf('RMS = %.4f', RMS_linear), ...
    'HorizontalAlignment', 'right');

save_plot(gcf, '02-valve');


function valve_opening = find_valve_opening(valve_coeffs, target_mu)

    a = valve_coeffs(1);
    b = valve_coeffs(2);
    c = valve_coeffs(3);

    % Quadratic formula coefficients for c*x^2 + b*x + (a - target_mu) = 0
    A = c;
    B = b;
    C = a - target_mu;

    % Solve quadratic equation
    discriminant = B^2 - 4*A*C;

    if discriminant < 0
        error('No real solution exists for μ = %.4f', target_mu);
    end

    % Two possible solutions
    x1 = (-B + sqrt(discriminant)) / (2*A);
    x2 = (-B - sqrt(discriminant)) / (2*A);

    % Choose the solution within the valid range [0, 100]
    solutions = [x1, x2];
    valid_solutions = solutions(solutions >= 0 & solutions <= 100);

    if isempty(valid_solutions)
        warning('No solution within valid range [0, 100%] for μ = %.4f. Closest solutions: %.2f%%, %.2f%%', target_mu, x1, x2);
        % Return the closest solution to the valid range
        if abs(x1 - 50) < abs(x2 - 50)
            valve_opening = x1;
        else
            valve_opening = x2;
        end
    elseif length(valid_solutions) == 1
        valve_opening = valid_solutions(1);
    else
        % If multiple valid solutions, choose the one closer to the middle of the range
        [~, idx] = min(abs(valid_solutions - 50));
        valve_opening = valid_solutions(idx);
    end

end

function [mu_min, mu_max, mu_predicted] = find_mu_range(valve_coeffs, x_opening, y_valve, x_valve)
    mu_predicted = valve_coeffs(1) + valve_coeffs(2)*x_opening + valve_coeffs(3)*x_opening^2;

    % Calculate predicted values for all experimental points
    y_predicted = valve_coeffs(1) + valve_coeffs(2)*x_valve + valve_coeffs(3)*x_valve.^2;

    rms_error = sqrt(mean(residuals.^2));
    mu_min = mu_predicted - rms_error;
    mu_max = mu_predicted + rms_error;

end
