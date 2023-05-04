
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function

load("PPO_victim_agent.mat");
load("PPO_jammer_agent.mat");


Parameters = load("Parameters.mat");

doSim = false;

numTrials = 60;
x = 1:numTrials;

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

Obs_j = [0 0];
if jammer_cs == victim_cs
    Obs_j(1) = 1;
end
if any(channel_state == jammer_cs)
    Obs_j(2) = 1;
end
Obs_v = 0;
SNRdB = badSNRdB;
if any(channel_state == victim_cs)
    Obs_v = 1;
    SNRdB = goodSNRdB;
end


for i= 1:numTrials
    disp("Running trial " + i + "...");

    if doSim
        [Throughput_result,BLER_result] = simulate(SNRdB,Obs_j);
        BLER_results(i) = BLER_result;
        Throughput_results(i) = Throughput_result;
    end

    victim_action = getAction(PPO_victim_agent, Obs_v);
    jammer_action = getAction(PPO_jammer_agent, Obs_j);


    channel_state = evolveChannel(channel_state, Parameters.channel_evolve_prob);

    cs_matrix(channel_state, i) = 1;

    jammer_cs = mod(jammer_cs + jammer_action{1} - 1, Parameters.nChannels) + 1;
    victim_cs = mod(victim_cs + victim_action{1} - 1, Parameters.nChannels) + 1;

    victim_cs_matrix(victim_cs, i) = 1;
    jammer_cs_matrix(jammer_cs, i) = 1;

    Obs_j = [0 0];
    if jammer_cs == victim_cs
        Obs_j(1) = 1;
    end
    if any(channel_state == jammer_cs)
        Obs_j(2) = 1;
    end
    Obs_v = 0;
    SNRdB = badSNRdB;
    if any(channel_state == victim_cs)
        Obs_v = 1;
        SNRdB = goodSNRdB;
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
xlabel("Time Step");
ylabel("Channel #");
title("RL Simulation Results");
legend(["Channel Quality", "Victim CS", "Jammer CS"]);

% plot(x,BLER_results,x,)
