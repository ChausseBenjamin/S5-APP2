run('00-global.m')

valve_pcnt     = valve_dataset(:,1);
valve_friction = valve_dataset(:,2);

x_valve = valve_pcnt(:);       % 11x1 column
y_valve = valve_friction(:);   % 11x1 column

M = [ones(length(x_valve),1), x_valve, x_valve.^2];  % 11x3 matrix

valve_coeffs = (inv(M.'*M) * M.') * y_valve;  % 3x1 coefficients

% Dense x values for smooth curve
x_fit = linspace(min(x_valve), max(x_valve), 1000);   % points between min and max of x
y_fit = valve_coeffs(1) + valve_coeffs(2)*x_fit + valve_coeffs(3)*x_fit.^2;    % evaluate quadratic

% Predicted values from fitted quadratic
y_fit_points = valve_coeffs(1) + valve_coeffs(2)*x_valve + valve_coeffs(3)*x_valve.^2;

% Residual sum of squares
SS_res = sum((y_valve - y_fit_points).^2);

% Total sum of squares
SS_tot = sum((y_valve - mean(y_valve)).^2);

% R^2
R2 = 1 - SS_res / SS_tot;

% RMS (Root Mean Square) error
residuals = y_valve - y_fit_points;
RMS = sqrt(mean(residuals.^2));

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

text(0.95, 0.82, sprintf('RMS = %.4f', RMS), ...
    'HorizontalAlignment', 'right');

axis tight;

% Save using the new save_plot function
save_plot(gcf, '02-valve');



function valve_opening = find_valve_opening(valve_coeffs, target_mu)
    % Find valve opening percentage for a given friction coefficient
    % Solves the quadratic equation: target_mu = a + b*x + c*x^2
    % Rearranged to: c*x^2 + b*x + (a - target_mu) = 0

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

    % Calculate residuals (difference between observed and predicted)
    residuals = y_valve - y_predicted;

    % Calculate RMS (Root Mean Square) error
    rms_error = sqrt(mean(residuals.^2));

    % For uncertainty interval using 1× RMS error
    % This gives a more typical engineering uncertainty estimate
    confidence_multiplier = 1.0;  % 1× RMS error

    uncertainty = confidence_multiplier * rms_error;

    % Calculate range
    mu_min = mu_predicted - uncertainty;
    mu_max = mu_predicted + uncertainty;

end
