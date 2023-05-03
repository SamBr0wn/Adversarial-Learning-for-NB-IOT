function [NextObs,Reward,IsDone,LoggedSignals] = stepJammer(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

Parameters = load("Parameters.mat");

new_channel_state = evolveChannel(LoggedSignals.channel_state);
LoggedSignals.channel_state = new_channel_state;
load("PPO_victim_agent.mat");






victim_action = getAction(PPO_victim_agent, LoggedSignals.victim_obs);


%why can't victom select 0 / no transmit
LoggedSignals.cs_j = mod(LoggedSignals.cs_j + Action - 1, Parameters.nChannels) + 1;
LoggedSignals.cs_v = mod(LoggedSignals.cs_v + victim_action{1} - 1, Parameters.nChannels) + 1;


% if any(new_channel_state == LoggedSignals.cs)
%     cs_SNR = Parameters.goodSNRdB;
% else
%     cs_SNR = Parameters.badSNRdB;
% end
% 
% % [simThroughput, bler] = simulate(cs_SNR, 0);
% simThroughput = cs_SNR + 10;

if ~exist("LoggedSignals.jammer_obs", "var")
    LoggedSignals.jammer_obs = zeros(Parameters.mem_length, 1);
end



% % NextObs = [cs_SNR; LoggedSignals.victim_obs(1:(Parameters.mem_length-1))];
% if cs_SNR > Parameters.badSNRdB
%     NextObs = 1;
% else
%     NextObs = 0;
% end

j_selected_v = 0;
if LoggedSignals.cs_j == LoggedSignals.cs_v
    j_selected_v = 1;
end

v_selected_gc = 0;
if any(new_channel_state == LoggedSignals.cs_v)
    v_selected_gc = 1;
end
LoggedSignals.jammer_obs = j_selected_v;

LoggedSignals.victim_obs = v_selected_gc;

Reward = 2*j_selected_v - 1;
NextObs = j_selected_v;

IsDone = false;

fprintf("Step: %d; Channel: %s; CS: %d; Action: %d; Next Obs: %s; Reward: %f\n", ...
   LoggedSignals.stepNum, arrToStr(new_channel_state), LoggedSignals.cs_j, Action, ...
   arrToStr(j_selected_v), Reward);

LoggedSignals.stepNum = LoggedSignals.stepNum + 1;

end