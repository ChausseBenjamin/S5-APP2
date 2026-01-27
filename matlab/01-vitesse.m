run('00-global.m')
run('02-valve.m')
run('01-trajectoire.m')

% Select the E value where the final slope is closest to 0 (horizontal ending)
final_slopes = slopes(end, :);  % Get the final slope for each E value
[~, best_idx] = min(abs(final_slopes));  % Find index with slope closest to 0
fprintf('Final slopes for each E: ');
fprintf('%.4f ', final_slopes);
fprintf('\n');
fprintf('Selected E = %.2f (index %d) with final slope = %.4f\n', ...
        E_range(best_idx), best_idx, final_slopes(best_idx));

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
title(sprintf('Friction Force Along Selected Trajectory (E = %.2f)', E_range(best_idx)));
save_plot(gcf, '01-friction');

% mu_candidates = [0.62];
% mu_candidates = [0.66];
% mu_candidates = [0.47:0.05:0.87];
mu_candidates = linspace(0.62,0.66,6);

% Check dimensions for debugging
fprintf('x_plot size: [%d, %d]\n', size(x_plot, 1), size(x_plot, 2));
fprintf('Number of mu candidates: %d\n', numel(mu_candidates));

% Memory pre-allocation - ensure proper dimensions
if size(x_plot, 1) == 1
	x_plot = x_plot';  % Make it a column vector
end
speeds = zeros(length(x_plot), numel(mu_candidates));

% Pre-compute the integral part (independent of mu)
fprintf('Pre-computing integral values...\n');
work_integral_base = zeros(size(x_plot));

% Pre-compute integration part of the friction work
for i = 1:length(x_plot)
	% Integration from 0 to x_plot(i)
	% Find indices where x_plot <= x_plot(i)
	idx = x_plot <= x_plot(i);
	x_subset = x_plot(idx);
	angle_subset = angle(idx);
	slope_subset = slope(idx);  % dy/dx values

	% Ensure vectors are column vectors for consistent operations
	if size(x_subset, 1) == 1
		x_subset = x_subset';
	end
	if size(angle_subset, 1) == 1
		angle_subset = angle_subset';
	end
	if size(slope_subset, 1) == 1
		slope_subset = slope_subset';
	end

	% Friction work integrand: F_friction = μ·mg·cos(θ)
	% Since ds = dx/cos(θ), we have:
	% dW = μ·mg·cos(θ)·ds = μ·mg·cos(θ)·(dx/cos(θ)) = μ·mg·dx
	% So the work integral becomes: W = μ·mg·∫dx = μ·mg·x
	% Store the distance x for integration
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
	fprintf('Processing mu = %.2f\n', mu);

	% Calculate friction work and speed inline
	% Initialize arrays for this mu
	speed = zeros(length(x_plot), 1);
	friction_work = zeros(length(x_plot), 1);

	% Calculate for each point along the trajectory
	for i = 1:length(x_plot)
		% Friction work: W_friction = μ * m * g * distance
		friction_work(i) = mu * participantMass * gravity * work_integral_base(i);

		% Total energy at point i: potential energy at that height
		potential_energy_i = participantMass * gravity * trajectory(i);

		% Initial potential energy (at starting height)
		initial_potential_energy = participantMass * gravity * initialHeight;

		% Kinetic energy: KE = Initial_PE - Current_PE - Friction_Work
		kinetic_energy = initial_potential_energy - potential_energy_i - friction_work(i);

		% Speed: v = sqrt(2*KE/m) (ensure non-negative kinetic energy)
		if kinetic_energy >= 0
			speed(i) = sqrt(2 * kinetic_energy / participantMass);
		else
			speed(i) = 0;  % Particle has stopped
		end
	end

	speeds(:, k) = speed; % Store for this mu
	friction_works(:, k) = friction_work; % Store for this mu

	% Plot this speed curve
	color_idx = mod(k-1, length(palette)) + 1; % Cycle through colors
	plot(x_plot, speed,
	  'LineWidth', 2,
		% 'Color', palette{color_idx}, ...
		'DisplayName', sprintf('μ = %.2f', mu));
end

% Add horizontal reference lines
x_limits = [min(x_plot), max(x_plot)];
x_final_limits = [20, max(x_plot)]; % Final speed lines only from x=20 to end

% Overall min/max speed
plot(x_limits, [minSpeed, minSpeed], '--',
  'Color', [1.0, 0.5, 0.5],
	'LineWidth', 1.5, ...
	'DisplayName', sprintf('Min Speed (%.1f m/s)', minSpeed));

plot(x_limits, [maxSpeed, maxSpeed], '--',
  'Color', [1.0, 0.5, 0.5],
	'LineWidth', 1.5, ...
	'DisplayName', sprintf('Max Speed (%.1f m/s)', maxSpeed));

% Final speeds min/max
plot(x_final_limits, [minFinalSpeed, minFinalSpeed], '--',
  'Color', [1.0, 0.6, 0.0],
	'LineWidth', 1.5, ...
	'DisplayName',
  sprintf('Min Final Speed (%.1f m/s)', minFinalSpeed));

plot(x_final_limits, [maxFinalSpeed, maxFinalSpeed], '--',
  'Color', [1.0, 0.6, 0.0],
	'LineWidth', 1.5, ...
	'DisplayName', sprintf('Max Final Speed (%.1f m/s)', maxFinalSpeed));

grid on;
xlabel('x (m)');
ylabel('Speed (m/s)');
title('Speed vs Position for Different Friction Coefficients');
legend('show', 'Location', 'best');
save_plot(gcf, '01-speeds');

chosen_mu = 0.62;

valve_opening = find_valve_opening(x_fit, y_fit, chosen_mu);
[mu_min, mu_max, mu_predicted] = find_mu_range(valve_coeffs, valve_opening, valve_friction, R2);

% Function to calculate speed for a given mu value
function speed = calculate_speed_for_mu(mu, x_plot, trajectory, work_integral_base, participantMass, gravity, initialHeight)
    speed = zeros(length(x_plot), 1);
    
    for i = 1:length(x_plot)
        % Friction work: W_friction = μ * m * g * distance
        friction_work_i = mu * participantMass * gravity * work_integral_base(i);
        
        % Total energy at point i: potential energy at that height
        potential_energy_i = participantMass * gravity * trajectory(i);
        
        % Initial potential energy (at starting height)
        initial_potential_energy = participantMass * gravity * initialHeight;
        
        % Kinetic energy: KE = Initial_PE - Current_PE - Friction_Work
        kinetic_energy = initial_potential_energy - potential_energy_i - friction_work_i;
        
        % Speed: v = sqrt(2*KE/m) (ensure non-negative kinetic energy)
        if kinetic_energy >= 0
            speed(i) = sqrt(2 * kinetic_energy / participantMass);
        else
            speed(i) = 0;  % Particle has stopped
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

title('Comparaison des vitesses selon l''incertitude du coefficient de frottement', 'FontSize', 17);
xlabel('Distance horizontale (m)', 'FontSize', 15);
ylabel('Vitesse (m/s)', 'FontSize', 15);

% Plot the three speed curves
plot(x_plot, speed_min, '--', 'LineWidth', 2, 'Color', palette{1}, 'DisplayName', sprintf('μ_{min} = %.4f', mu_min));
plot(x_plot, speed_target, '-', 'LineWidth', 2, 'Color', palette{2}, 'DisplayName', sprintf('μ_{cible} = %.4f', mu_predicted));
plot(x_plot, speed_max, '--', 'LineWidth', 2, 'Color', palette{3}, 'DisplayName', sprintf('μ_{max} = %.4f', mu_max));

% Add horizontal reference lines
x_limits = [min(x_plot), max(x_plot)];
x_final_limits = [20, max(x_plot)]; % Final speed lines only from x=20 to end

% Overall min/max speed limits
plot(x_limits, [minSpeed, minSpeed], ':', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5], 'DisplayName', 'Vitesse min (10 km/h)');
plot(x_limits, [maxSpeed, maxSpeed], ':', 'LineWidth', 1, 'Color', [0.5, 0.5, 0.5], 'DisplayName', 'Vitesse max (45 km/h)');

% Final speed limits (only from x=20 to end)
plot(x_final_limits, [minFinalSpeed, minFinalSpeed], ':', 'LineWidth', 1, 'Color', [0.7, 0.3, 0.3], 'DisplayName', 'Vitesse finale min (20 km/h)');
plot(x_final_limits, [maxFinalSpeed, maxFinalSpeed], ':', 'LineWidth', 1, 'Color', [0.7, 0.3, 0.3], 'DisplayName', 'Vitesse finale max (25 km/h)');

axis tight;
legend('show', 'Location', 'best');
save_plot(gcf, '01-speed-comparison');

