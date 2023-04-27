function [InitialObservation, LoggedSignal] = resetVictim()
% Function to reset simulation environment of the victim at initial startup
% and after each training episode.

% Randomly choose initial channel selection with 0 being no-transmission
victim_cs = randi([0, Nc]);

LoggedSignal.cs = victim_cs;

InitialObservation = zeros(mem_length, Nc + 2);
InitialObservation(1, victim_cs + 1) = 1;

end