clear;

run('variables.m'); % this line should get moved to the main function
Parameters = load("Parameters.mat");

load("PPO_victim_agent.mat");

numAdjTrials = 10;

channel1 = randi([1 (Parameters.nChannels - 1)]);
channel_state = [channel1 mod(channel1 + 1, Parameters.nChannels + 1)];
victim_cs = randi([0, Parameters.nChannels]);


Obs_v = 0;
if any(channel_state == victim_cs)
    Obs_v = 1;
end


for i= 1:numAdjTrials
   
    victim_action = getAction(PPO_victim_agent, Obs_v);


    channel_state = evolveChannel(channel_state);
    victim_cs = mod(victim_cs + victim_action{1} - 1, Parameters.nChannels) + 1;

    Obs_v = 0;
    if any(channel_state == victim_cs)
        Obs_v = 1;
    end   
end

nTimeslots = 100;
nReps = 1000;
accuracy = zeros(1,nTimeslots);
for i = 1:nTimeslots
    channel_state = evolveChannel(channel_state);
    victim_cs_pre = victim_cs;
    count = 0;

    for j = 1:nReps
        victim_action = getAction(PPO_victim_agent, Obs_v);
        
        victim_cs = mod(victim_cs_pre + victim_action{1} - 1, Parameters.nChannels) + 1;
        if any(channel_state == victim_cs)
            count = count + 1;
        end
    end
    accuracy(i) = count / nReps;

    Obs_v = 0;
    if any(channel_state == victim_cs)
        Obs_v = 1;
    end 

end

plot(accuracy);