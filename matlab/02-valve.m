run('00-global.m')

% Split columns
valve_pcnt     = valve_data(:,1);
valve_friction = valve_data(:,2);

% Plot
figure;
plot(valve_pcnt, valve_friction, 'o', 'LineWidth', 1.5);
grid on;
xlabel('Valve Opening (%)');
ylabel('Friction Coefficient');
title('Valve Friction vs Opening');
