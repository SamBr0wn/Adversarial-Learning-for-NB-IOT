function [NextObs,Reward,IsDone,LoggedSignals] = stepVictim(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

new_channel_state = evolveChannel(LoggedSignals.channel_state);

if new_channel_state(Action)
cs_SNR = 

simulate()





end