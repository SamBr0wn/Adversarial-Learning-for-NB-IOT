function [NextObs,Reward,IsDone,LoggedSignals] = stepVictimDefense(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

Parameters = load("Parameters.mat");

new_channel_state = evolveChannel(LoggedSignals.channel_state, Parameters.channel_evolve_prob);
LoggedSignals.channel_state = new_channel_state;

if ~isfield(LoggedSignals, "PPO_jammer_agent")
    load("PPO_jammer_agent.mat");
    LoggedSignals.PPO_jammer_agent = PPO_jammer_agent;
end

jammer_action = getAction(LoggedSignals.PPO_jammer_agent, LoggedSignals.jammer_obs);


%why can't victom select 0 / no transmit
LoggedSignals.cs_v = mod(LoggedSignals.cs_v + Action - 1, Parameters.nChannels) + 1;
LoggedSignals.cs_j = mod(LoggedSignals.cs_j + jammer_action{1} - 1, Parameters.nChannels) + 1;


% if any(new_channel_state == LoggedSignals.cs)
%     cs_SNR = Parameters.goodSNRdB;
% else
%     cs_SNR = Parameters.badSNRdB;
% end
% 
% % [simThroughput, bler] = simulate(cs_SNR, 0);
% simThroughput = cs_SNR + 10;


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

j_selected_gc = 0;
if any(new_channel_state == LoggedSignals.cs_j)
    j_selected_gc = 1;
end

LoggedSignals.jammer_obs(1) = j_selected_v;
LoggedSignals.victim_obs(1) = j_selected_v;

LoggedSignals.jammer_obs(2) = j_selected_gc;
LoggedSignals.victim_obs(2) = v_selected_gc;


cs_Reward = -1;
if (v_selected_gc)
    cs_Reward = 1;
end
jammer_Reward = 1;
if (j_selected_v)
    jammer_Reward = -1;
end

Reward = 0.6 * cs_Reward + 0.4 * jammer_Reward;
% elseif (abs(LoggedSignals.cs_j - LoggedSignals.cs_v) < 2 )
%     Reward = -0.5;
% end
    
NextObs = LoggedSignals.victim_obs;

IsDone = false;

fprintf("Step: %d; Channel: %s; JCS: %d; VCS: %d; Victim Action: %d; VObs: %s; JObs: %s; Reward: %f\n", ...
   LoggedSignals.stepNum, arrToStr(new_channel_state), LoggedSignals.cs_j, LoggedSignals.cs_v, Action, ...
   arrToStr(NextObs), arrToStr(LoggedSignals.jammer_obs), Reward);

LoggedSignals.stepNum = LoggedSignals.stepNum + 1;

end