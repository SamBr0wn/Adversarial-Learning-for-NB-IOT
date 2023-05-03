function [NextObs,Reward,IsDone,LoggedSignals] = stepVictim(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

load("savedVars.mat");

new_channel_state = evolveChannel(LoggedSignals.channel_state);

if any(new_channel_state == mod(floor(Action), nChannels))
    cs_SNR = goodSNRdB;
else
    cs_SNR = badSNRdB;
end

[simThroughput, bler] = simulate(cs_SNR, 0);

if ~exist("LoggedSignal.victim_obs", "var")
    LoggedSignal.victim_obs = zeros(mem_length, 1);
end

NextObs = [cs_SNR; LoggedSignal.victim_obs(1:(mem_length-1))];

Reward = simThroughput;

IsDone = false;

end