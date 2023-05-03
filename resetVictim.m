function [InitialObservation, LoggedSignals] = resetVictim()
% Function to reset simulation environment of the victim at initial startup
% and after each training episode.

Parameters = load("Parameters.mat");

% Choose intial channel state
channel1 = randi([1 (Parameters.nChannels - 1)]);
channel_state = [channel1 mod(channel1 + 1, Parameters.nChannels + 1)];

% Randomly choose initial channel selection with 0 being no-transmission
victim_cs = randi([0, Parameters.nChannels]);

LoggedSignals.cs = victim_cs;
LoggedSignals.channel_state = channel_state;

% InitialObservation = zeros(Parameters.mem_length, 1);
InitialObservation = 0;

LoggedSignals.victim_obs = InitialObservation;

LoggedSignals.stepNum = 0;

end