function [InitialObservation, LoggedSignal] = resetVictim()
% Function to reset simulation environment of the victim at initial startup
% and after each training episode.

load("savedVars.mat");

% Choose intial channel state
channel_state = [1 2];

% Randomly choose initial channel selection with 0 being no-transmission
victim_cs = randi([0, nChannels]);

LoggedSignal.cs = victim_cs;
LoggedSignal.channel_state = channel_state;

InitialObservation = zeros(mem_length, 3);
InitialObservation(1, :) = [victim_cs 0 0];

LoggedSignal.victim_obs = InitialObservation;

end