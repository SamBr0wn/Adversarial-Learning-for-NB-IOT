function [NextObs,Reward,IsDone,LoggedSignals] = stepJammer(Action, LoggedSignals)
% Function to step the simulation environment of the victim based on the
% action chosen by the policy. The next observation (channel chosen and
% throughput achieved), the reward (based on throughput), and the "IsDone"
% flag are returned.

Parameters = load("Parameters.mat");

new_channel_state = evolveChannel(LoggedSignals.channel_state, Parameters.channel_evolve_prob);
LoggedSignals.channel_state = new_channel_state;

if ~isfield(LoggedSignals, "PPO_victim_agent")
    load("PPO_victim_agent.mat");
    LoggedSignals.PPO_victim_agent = PPO_victim_agent;
end


victim_action = getAction(LoggedSignals.PPO_victim_agent, LoggedSignals.victim_obs);


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
LoggedSignals.jammer_obs(1) = j_selected_v;

selected_good_channel = 0;
if any(new_channel_state == LoggedSignals.cs_j)
    selected_good_channel = 1;
end
LoggedSignals.jammer_obs(2) = selected_good_channel;

LoggedSignals.victim_obs = v_selected_gc;

Reward = -1;
if (j_selected_v)
    Reward = 1;
end
% elseif (abs(LoggedSignals.cs_j - LoggedSignals.cs_v) < 2 )
%     Reward = -0.5;
% end
    
NextObs = LoggedSignals.jammer_obs;

IsDone = false;

fprintf("Step: %d; Channel: %s; JCS: %d; VCS: %d Last Action: %d; Cur Obs: %s; Reward: %f\n", ...
   LoggedSignals.stepNum, arrToStr(new_channel_state), LoggedSignals.cs_j, LoggedSignals.cs_v, Action, ...
   arrToStr(NextObs), Reward);

LoggedSignals.stepNum = LoggedSignals.stepNum + 1;

end