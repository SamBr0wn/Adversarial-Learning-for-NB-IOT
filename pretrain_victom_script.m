clear;

% ----------Begining of the simulation - victom pre training---------
run('variables.m'); % this line should get moved to the main function
Parameters = load("Parameters.mat");

obsInfo_v = rlNumericSpec([mem_length, 1], "DataType", "double");
obsInfo_v.Name = "Victim Channel Select";
obsInfo_v.Description = 'TX Channel Selected, BLER, Throughput';

actInfo_v = rlNumericSpec([1 1], "DataType", "double");
actInfo_v.Name = "TX Channel Action";

type resetVictim.m
type stepVictim.m

% ----------create environment----------
env = rlFunctionEnv(obsInfo_v, actInfo_v, "stepVictim", "resetVictim");

PPO_opt = rlPPOAgentOptions;
PPO_agent = rlPPOAgent(obsInfo_v,actInfo_v,PPO_opt);

opt = rlTrainingOptions(...
    MaxEpisodes=10,...
    MaxStepsPerEpisode=10,...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=480);
trainResults = train(PPO_agent,env,opt);

trainResults = train(PPO_agent, env, trainResults);

