clc
clear all
close all

run('01-trajectoire.m')

% Extract data for the best candidate E = 12.5
% Find the index corresponding to E = 12.5 in E_range
[~, best_idx] = min(abs(E_range - 12.5));
fprintf('Selected E = %.2f (index %d)\n', E_range(best_idx), best_idx);

% Extract vectors for the chosen trajectory
trajectory = trajectories(:, best_idx);  % Position data for E = 12.5
slope = slopes(:, best_idx);             % Derivative data for E = 12.5
angle = angles(:, best_idx);             % Angle data for E = 12.5
friction = cos(angle);                   % Friction

% Plot the friction for this trajectory (without coefficient which is a constant)
figure(4); clf; hold on; axis tight;
plot(x_plot, friction, 'LineWidth', 2, 'Color', 'red');
grid on;
xlabel('x (m)');
ylabel('cos(θ)');
title('Friction Force Along Selected Trajectory (E = 12.5)');
save_plot(gcf, '01-friction');

mu_candidates = [0.47:0.05:0.87];

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

	% Ensure vectors are column vectors for consistent operations
	if size(x_subset, 1) == 1
		x_subset = x_subset';
	end
	if size(angle_subset, 1) == 1
		angle_subset = angle_subset';
	end

	% Integrand: angle(x) * x
	integrand = angle_subset .* x_subset;

	% Numerical integration using trapezoidal rule
	if length(x_subset) > 1
		integral_result = trapz(x_subset, integrand);
		work_integral_base(i) = integral_result(1); % Ensure scalar assignment
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

	% Calculate friction work: simply multiply pre-computed integral by mu
	friction_work = mu * work_integral_base;
	friction_works(:, k) = friction_work; % Store for this mu

	% Calculate speed using the given formula:
	% Speed(x) = sqrt(2*gravity * (initialHeight - trajectory(x) + friction_work(x)))
	speed_squared = 2 * gravity * (initialHeight - trajectory - friction_work);

	% Ensure no negative values under square root (physics constraint)
	speed_squared = max(speed_squared, 0);
	speed = sqrt(speed_squared);

	speeds(:, k) = speed; % Store for this mu

	% Plot this speed curve
	color_idx = mod(k-1, length(palette)) + 1; % Cycle through colors
	plot(x_plot, speed, 'LineWidth', 2, 'Color', palette{color_idx}, ...
		'DisplayName', sprintf('μ = %.2f', mu));
end

grid on;
xlabel('x (m)');
ylabel('Speed (m/s)');
title('Speed vs Position for Different Friction Coefficients');
legend('show', 'Location', 'best');
save_plot(gcf, '01-speeds');
