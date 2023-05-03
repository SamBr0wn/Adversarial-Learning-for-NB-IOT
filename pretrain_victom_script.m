clear;

% ----------Begining of the simulation - victom pre training---------
run('variables.m'); % this line should get moved to the main function
Parameters = load("Parameters.mat");

% obsInfo_v = rlNumericSpec([mem_length, 1], "DataType", "double");
obsInfo_v = rlFiniteSetSpec([0 1]);
obsInfo_v.Name = "Victim Channel Select";
obsInfo_v.Description = 'TX Channel Selected, BLER, Throughput';

% actInfo_v = rlNumericSpec([1 1], "DataType", "double");
actInfo_v = rlFiniteSetSpec(-1:1);
actInfo_v.Name = "TX Channel Action";

type resetVictim.m;
type stepVictim.m;

% ----------create environment----------
env = rlFunctionEnv(obsInfo_v, actInfo_v, "stepVictim", "resetVictim");

PPO_opt = rlPPOAgentOptions;
PPO_victim_agent = rlPPOAgent(obsInfo_v,actInfo_v,PPO_opt);

opt = rlTrainingOptions(...
    MaxEpisodes=100,...
    MaxStepsPerEpisode=200,...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=500);
trainResults = train(PPO_victim_agent,env,opt);

trainResults = train(PPO_victim_agent, env, trainResults);

save("PPO_victim_agent", "PPO_victim_agent");

