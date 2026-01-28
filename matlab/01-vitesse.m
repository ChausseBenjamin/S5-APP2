% run('00-global.m')
run('02-valve.m')
run('01-trajectoire.m')

% Select the E value where the final slope is closest to 0 (horizontal ending)
final_slopes = slopes(end, :);  % Get the final slope for each E value
[~, best_idx] = min(abs(final_slopes));  % Find index with slope closest to 0

% Extract vectors for the chosen trajectory
trajectory = trajectories(:, best_idx);  % Position data for selected E
slope = slopes(:, best_idx);             % Derivative data for selected E
angle = angles(:, best_idx);             % Angle data for selected E
friction = cos(angle);                   % Friction

% Plot the friction for this trajectory
% (without coefficient which is a constant to be decided later)
figure(4); clf; hold on; axis tight;
plot(x_plot, friction,
  'Color', 'red',
  'LineWidth', 2);
grid on;
xlabel('x (m)');
ylabel('cos(θ)');
% title(sprintf('Friction Force Along Selected Trajectory (E = %.2f)', E_range(best_idx)));
save_plot(gcf, '01-friction');

mu_candidates = [ ...
  linspace(0.61,0.66,6), ...
];


% Memory pre-allocation - ensure proper dimensions
speeds = zeros(length(x_plot), numel(mu_candidates));

% Pre-compute the integral part (independent of mu)
work_integral_base = zeros(size(x_plot));

% Pre-compute integration part of the friction work
for i = 1:length(x_plot)
  % Integration from 0 to x_plot(i)
  % Find indices where x_plot <= x_plot(i)
  idx = x_plot <= x_plot(i);
  x_subset = x_plot(idx);
  angle_subset = angle(idx);

  if length(x_subset) > 1
    work_integral_base(i) = x_subset(end) - x_subset(1); % Distance traveled
  else
    work_integral_base(i) = 0;
  end
end

figure(5); clf; hold on; axis tight;

% Now calculate friction work and speed for each mu candidate
friction_works = zeros(length(x_plot), numel(mu_candidates)); % Store all friction works

for k = 1:numel(mu_candidates);
  mu = mu_candidates(k);

  % Calculate friction work and speed inline
  % Initialize arrays for this mu
  speed = zeros(length(x_plot), 1);
  friction_work = zeros(length(x_plot), 1);

  % Calculate for each point along the trajectory
  for i = 1:length(x_plot)
    % Friction work: W_friction = μ * m * g * distance
    friction_work(i) = mu * participantMass * gravity * work_integral_base(i);

    potential_energy_i = participantMass * gravity * trajectory(i);

    initial_potential_energy = participantMass * gravity * initialHeight;

    kinetic_energy = initial_potential_energy - potential_energy_i - friction_work(i);

    speed(i) = sqrt(2 * kinetic_energy / participantMass);
  end

  speeds(:, k) = speed; % Store for this mu
  friction_works(:, k) = friction_work; % Store for this mu

  % Plot this speed curve
  color_idx = mod(k-1, length(palette)) + 1; % Cycle through colors
  plot(x_plot, speed,
    'LineWidth', 2,
    'Color', palette{color_idx}, ...
    'DisplayName', sprintf('μ = %.2f', mu));
end

% Add horizontal reference lines
x_limits = [min(x_plot), max(x_plot)];
x_final_limits = [20, max(x_plot)]; % Final speed lines only from x=20 to end

% Overall min/max
plot(x_limits, [minSpeed, minSpeed], '--',
  'Color', [1.0, 0.5, 0.5],
  'LineWidth', 1.5, ...
  'HandleVisibility', 'off');
plot(x_limits, [maxSpeed, maxSpeed], '--',
  'Color', [1.0, 0.5, 0.5],
  'LineWidth', 1.5, ...
  'HandleVisibility', 'off');

% Final speeds min/max
plot(x_final_limits, [minFinalSpeed, minFinalSpeed], '--',
  'Color', [1.0, 0.6, 0.0],
  'LineWidth', 1.5, ...
  'HandleVisibility', 'off');
plot(x_final_limits, [maxFinalSpeed, maxFinalSpeed], '--',
  'Color', [1.0, 0.6, 0.0],
  'LineWidth', 1.5, ...
  'HandleVisibility', 'off');

% Invisible lines for Legend groups
h1 = plot(NaN, NaN, '--',
  'LineWidth', 1.5,
	'Color', [1.0, 0.5, 0.5],
	'DisplayName', 'Limites globales (10-45 km/h)');
h2 = plot(NaN, NaN, '--',
  'LineWidth', 1.5,
	'Color', [1.0, 0.6, 0.0],
	'DisplayName', 'Limites finales (20-25 km/h)');

grid on;
xlabel('x (m)');
ylabel('Speed (m/s)');
% title('Speed vs Position for Different Friction Coefficients');
legend('show', 'Location', 'northeast');
save_plot(gcf, '01-speeds');

% Hard-coded because we look at multiple criterias:
% - global min/max speeds
% - final speed
chosen_mu = 0.62;

valve_opening = find_valve_opening(valve_coeffs, chosen_mu);

% mu range and RMS error information
[mu_min, mu_max, mu_predicted] = find_mu_range(valve_coeffs, valve_opening, y_valve, x_valve);

% Function to calculate speed for a given mu value
function speed = calculate_speed_for_mu(mu, x_plot, trajectory, work_integral_base, participantMass, gravity, initialHeight)
    speed = zeros(length(x_plot), 1);

    for i = 1:length(x_plot)
        friction_work_i = mu * participantMass * gravity * work_integral_base(i);

        potential_energy_i = participantMass * gravity * trajectory(i);

        initial_potential_energy = participantMass * gravity * initialHeight;

        kinetic_energy = initial_potential_energy - potential_energy_i - friction_work_i;

        if kinetic_energy >= 0
            speed(i) = sqrt(2 * kinetic_energy / participantMass);
        else
            speed(i) = 0;
        end
    end
end

% Calculate speeds for the three mu values
speed_min = calculate_speed_for_mu(mu_min, x_plot, trajectory, work_integral_base, participantMass, gravity, initialHeight);
speed_target = calculate_speed_for_mu(mu_predicted, x_plot, trajectory, work_integral_base, participantMass, gravity, initialHeight);
speed_max = calculate_speed_for_mu(mu_max, x_plot, trajectory, work_integral_base, participantMass, gravity, initialHeight);

% Create the comparison plot
figure;
hold on;
grid on;

% title('Comparaison des vitesses selon l''incertitude du coefficient de frottement', 'FontSize', 17);
xlabel('Distance horizontale (m)', 'FontSize', 15);
ylabel('Vitesse (m/s)', 'FontSize', 15);

plot(x_plot, speed_min, '--', 'LineWidth', 2, 'Color', palette{1},
'DisplayName', sprintf('μ_{min} = %.3f', mu_min));
plot(x_plot, speed_target, '-', 'LineWidth', 2, 'Color', palette{2},
'DisplayName', sprintf('μ_{cible} = %.3f', mu_predicted));
plot(x_plot, speed_max, '--', 'LineWidth', 2, 'Color', palette{3},
'DisplayName', sprintf('μ_{max} = %.3f', mu_max));

x_limits = [min(x_plot), max(x_plot)];
x_final_limits = [20, max(x_plot)]; % Final speed lines only from x=20 to end

% Overall min/max speed limits
plot(x_limits, [minSpeed, minSpeed], ':', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5], 'HandleVisibility', 'off');
plot(x_limits, [maxSpeed, maxSpeed], ':', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5], 'HandleVisibility', 'off');

% Final speed limits (only from x=20 to end)
plot(x_final_limits, [minFinalSpeed, minFinalSpeed], ':', 'LineWidth', 1, 'Color', [0.7, 0.3, 0.3], 'HandleVisibility', 'off');
plot(x_final_limits, [maxFinalSpeed, maxFinalSpeed], ':', 'LineWidth', 1, 'Color', [0.7, 0.3, 0.3], 'HandleVisibility', 'off');

% Invisible lines for legend groups
h1 = plot(NaN, NaN, ':', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5], 'DisplayName', 'Limites globales (10-45 km/h)');
h2 = plot(NaN, NaN, ':', 'LineWidth', 1, 'Color', [0.7, 0.3, 0.3], 'DisplayName', 'Limites finales (20-25 km/h)');

axis tight;
legend('show', 'Location', 'northeast');
save_plot(gcf, '01-speed-comparison');

% Extract final velocities at point E (last point in trajectory)
final_speed_min = speed_min(end);
final_speed_target = speed_target(end);
final_speed_max = speed_max(end);
