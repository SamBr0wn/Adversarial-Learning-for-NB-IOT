function [InitialObservation, LoggedSignals] = resetVictimDefense()
% Function to reset simulation environment of the victim at initial startup
% and after each training episode.

Parameters = load("Parameters.mat");


% Choose intial channel state
channel1 = randi([1 (Parameters.nChannels - 1)]);
channel_state = [channel1 mod(channel1 + 1, Parameters.nChannels + 1)];

% Randomly choose initial channel selection with 0 being no-transmission
jammer_cs = randi([1, Parameters.nChannels]);
victim_cs = randi([0, Parameters.nChannels]);

LoggedSignals.cs_j = jammer_cs;
LoggedSignals.cs_v = victim_cs;
LoggedSignals.channel_state = channel_state;

% InitialObservation = zeros(Parameters.mem_length, 1);
InitialObservation_v = [0 0];
InitialObservation_j = [0 0];
if jammer_cs == victim_cs
    InitialObservation_v(1) = 1;
    InitialObservation_j(1) = 1;
end
if any(channel_state == jammer_cs)
    InitialObservation_j(2) = 1;
end
if any(channel_state == victim_cs)
    InitialObservation_v(2) = 1;
end

LoggedSignals.jammer_obs = InitialObservation_j;
InitialObservation = InitialObservation_v;

LoggedSignals.victim_obs = InitialObservation_v;

LoggedSignals.stepNum = 0;

end