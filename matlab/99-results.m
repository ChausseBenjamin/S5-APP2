clc;
clear all;
close all;

run('01-vitesse.m');
run('02-valve.m');
fprintf("\n\n\n");

fprintf("Pente final du E choisi: %.4f\n", final_slopes(best_idx));

fprintf("E_y choisi: %.2f\n", trajectory(end));
fprintf("Coefficients de friction choisi: %.2f\n", chosen_mu);

fprintf("Erreur RMS de l'approximation de mu(%%): %.4f\n", RMS);
fprintf("\tmu-: %.4f,\tmu+ %.4f\n", chosen_mu-RMS, chosen_mu+RMS);
fprintf("Ouverture de la valve pour le mu choisi: %.2f\n", valve_opening);

fprintf("Vitesses finales:\n");
fprintf("\tlower: %.2f\ttarget: %.2f, upper: %.2f\n",
  mps2kph(final_speed_min),
	mps2kph(final_speed_target),
	mps2kph(final_speed_max));

fprintf("\n\n\n");
