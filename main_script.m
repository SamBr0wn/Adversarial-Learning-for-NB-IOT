
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function

load("PPO_victim_agent.mat");
load("PPO_jammer_agent.mat");


Parameters = load("Parameters.mat");


numTrials = 10;
x = 1:numTrials;

BLER_results = zeros(1,numTrials);
Throughput_results = zeros(1,numTrials);

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
    [Throughput_result,BLER_result] = simulate(SNRdB,Obs_j);
    BLER_results(i) = BLER_result;
    Throughput_results(i) = Throughput_result;

    victim_action = getAction(PPO_victim_agent, Obs_v);
    jammer_action = getAction(PPO_jammer_agent, Obs_j);


    channel_state = evolveChannel(channel_state, Parameters.channel_evolve_prob);
    jammer_cs = mod(jammer_cs + jammer_action{1} - 1, Parameters.nChannels) + 1;
    victim_cs = mod(victim_cs + victim_action{1} - 1, Parameters.nChannels) + 1;

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

% plot(x,BLER_results,x,)
