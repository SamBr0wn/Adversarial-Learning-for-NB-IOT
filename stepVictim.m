function [NextObs,Reward,IsDone,LoggedSignals] = stepVictim(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

Parameters = load("Parameters.mat");

new_channel_state = evolveChannel(LoggedSignals.channel_state);
LoggedSignals.channel_state = new_channel_state;

% if Action == 1
%     LoggedSignals.cs = mod(LoggedSignals.cs + 1, Parameters.nChannels + 1);
% elseif Action == -1
%     LoggedSignals.cs = mod(LoggedSignals.cs - 1, Parameters.nChannels + 1);
% end

%why can't victom select 0 / no transmit
LoggedSignals.cs = mod(LoggedSignals.cs + Action - 1, Parameters.nChannels) + 1;

% if any(new_channel_state == LoggedSignals.cs)
%     cs_SNR = Parameters.goodSNRdB;
% else
%     cs_SNR = Parameters.badSNRdB;
% end

selected_good_channel = 0;

if any(new_channel_state == LoggedSignals.cs)
    selected_good_channel = 1;
end

% [simThroughput, bler] = simulate(cs_SNR, 0);
% simThroughput = cs_SNR + 10;


% NextObs = [cs_SNR; LoggedSignals.victim_obs(1:(Parameters.mem_length-1))];
% if cs_SNR > Parameters.badSNRdB
%     NextObs = 1;
% else
%     NextObs = 0;
% end
% LoggedSignals.victim_obs = NextObs;
% 
% Reward = simThroughput;

LoggedSignals.victim_obs = selected_good_channel;
NextObs = selected_good_channel;

Reward = 2 * selected_good_channel - 1;

IsDone = false;

fprintf("Step: %d; Channel: %s; CS: %d; Action: %d; Next Obs: %s; Reward: %f\n", ...
   LoggedSignals.stepNum, arrToStr(new_channel_state), LoggedSignals.cs, Action, ...
   arrToStr(selected_good_channel), Reward);

LoggedSignals.stepNum = LoggedSignals.stepNum + 1;

end