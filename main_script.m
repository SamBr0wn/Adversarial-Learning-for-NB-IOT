
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function


Parameters = load("Parameters.mat");

doSim = true;

numTrials = 5;
x = 1:numTrials;
run_with_jammer = 0; % 1 for running with the jammer
run_with_fortified_victim = false;

load("PPO_jammer_agent.mat");
if run_with_fortified_victim
    victim_agent = load("PPO_fortified_victim_agent.mat");
else
    victim_agent = load("PPO_victim_agent.mat");
end

BLER_results = zeros(1,numTrials);
Throughput_results = zeros(1,numTrials);

num_trials_to_plot = 60;
cs_matrix = zeros(nChannels, num_trials_to_plot);
victim_cs_matrix = zeros(nChannels, num_trials_to_plot);
jammer_cs_matrix = zeros(nChannels, num_trials_to_plot);

% Choose intial channel state
% Randomly choose initial channel selection with 0 being no-transmission
channel1 = randi([1 (Parameters.nChannels - 1)]);
channel_state = [channel1 mod(channel1 + 1, Parameters.nChannels + 1)];
jammer_cs = randi([1, Parameters.nChannels]);
victim_cs = randi([0, Parameters.nChannels]);

jammer_cs_vals = zeros(1, numTrials);
victim_cs_vals = zeros(1, numTrials);

Obs_j = [0 0];
if jammer_cs == victim_cs
    Obs_j(1) = 1;
end
if any(channel_state == jammer_cs)
    Obs_j(2) = 1;
end
if run_with_fortified_victim
    Obs_v = [0 0];
    SNRdB = badSNRdB;
    if victim_cs == jammer_cs
        Obs_v(1) = 1;
    end
    if any(channel_state == victim_cs)
        Obs_v(2) = 1;
        SNRdB = goodSNRdB;
    end
else
    Obs_v = 0;
    SNRdB = badSNRdB;
    if any(channel_state == victim_cs)
        Obs_v = 1;
        SNRdB = goodSNRdB;
    end
end


for i= 1:numTrials
    disp("Running trial " + i + "...");

    if doSim
        [Throughput_result,BLER_result] = simulate(SNRdB,Obs_j);
        BLER_results(i) = BLER_result;
        Throughput_results(i) = Throughput_result;
    end

    if ~run_with_jammer
        Obs_j(1) = 0;
    end

    if run_with_fortified_victim
        victim_action = getAction(victim_agent.PPO_victim_agent, Obs_v);
    else
        victim_action = getAction(victim_agent.PPO_victim_agent, Obs_v);
    end
    if run_with_jammer
        jammer_action = getAction(PPO_jammer_agent, Obs_j);
    else
        jammer_action = {0};
    end
    
    channel_state = evolveChannel(channel_state, Parameters.channel_evolve_prob);

    cs_matrix(channel_state, i) = 1;

    jammer_cs = mod(jammer_cs + jammer_action{1} - 1, Parameters.nChannels) + 1;
    victim_cs = mod(victim_cs + victim_action{1} - 1, Parameters.nChannels) + 1;

    jammer_cs_vals(i) = jammer_cs;
    victim_cs_vals(i) = victim_cs;

    victim_cs_matrix(victim_cs, i) = 1;
    if run_with_jammer
        jammer_cs_matrix(jammer_cs, i) = 1;
    end

    Obs_j = [0 0];
    if jammer_cs == victim_cs
        Obs_j(1) = 1;
    end
    if any(channel_state == jammer_cs)
        Obs_j(2) = 1;
    end
    if run_with_fortified_victim
        Obs_v = [0 0];
        SNRdB = badSNRdB;
        if victim_cs == jammer_cs
            Obs_v(1) = 1;
        end
        if any(channel_state == victim_cs)
            Obs_v(2) = 1;
            SNRdB = goodSNRdB;
        end
    else
        Obs_v = 0;
        SNRdB = badSNRdB;
        if any(channel_state == victim_cs)
            Obs_v = 1;
            SNRdB = goodSNRdB;
        end
    end
       
end


[victim_cs_ind_y, victim_cs_ind_x] = find(victim_cs_matrix == 1);
[jammer_cs_ind_y, jammer_cs_ind_x] = find(jammer_cs_matrix == 1);

victim_cs_ind_y = victim_cs_ind_y + 0.5;
victim_cs_ind_x = victim_cs_ind_x + 0.5;
jammer_cs_ind_y = jammer_cs_ind_y + 0.5;
jammer_cs_ind_x = jammer_cs_ind_x + 0.5;

figure;
pcolor(cs_matrix);
cmap = colormap('gray');
grid();
hold on;
scatter(victim_cs_ind_x, victim_cs_ind_y, 250, 'go', 'filled');
scatter(jammer_cs_ind_x, jammer_cs_ind_y, 250, 'rx', 'LineWidth', 2);
xlabel("Time Step", 'FontSize', 18);
ylabel("Channel #", 'FontSize', 18);
title("RL Simulation Results", 'FontSize', 18);
legend(["Channel Quality", "Victim CS", "Jammer CS"], 'FontSize', 12);
set(gca,'fontsize', 14);

if doSim
    
    figure;
    plot(Throughput_results, 'b-');
    hold on;
    plot(victim_cs_vals == jammer_cs_vals);

end


% if ~run_with_jammer
%     plot(x,Throughput_results);
% end

% plot(x,BLER_results,x,)
