clear;

% ----------Begining of the simulation - victom pre training---------
run('variables.m'); % this line should get moved to the main function
Parameters = load("Parameters.mat");

% obsInfo_v = rlNumericSpec([mem_length, 1], "DataType", "double");
obsInfo_j = rlFiniteSetSpec([0 1]);
obsInfo_j.Name = "Jammer Channel Select";
obsInfo_j.Description = 'TX Channel Selected, BLER, Throughput';

% actInfo_v = rlNumericSpec([1 1], "DataType", "double");
actInfo_j = rlFiniteSetSpec(-1:1);
actInfo_j.Name = "Jammer Channel Action";

type resetJammer.m;
type stepJammer.m;

% ----------create environment----------
env = rlFunctionEnv(obsInfo_j, actInfo_j, "stepJammer", "resetJammer");

PPO_opt = rlPPOAgentOptions;
PPO_jammer_agent = rlPPOAgent(obsInfo_j,actInfo_j,PPO_opt);

% How do you know how many steps you will do per episode?
opt = rlTrainingOptions(...
    MaxEpisodes=100,...
    MaxStepsPerEpisode=100,...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=50);
trainResults = train(PPO_jammer_agent,env,opt);

trainResults = train(PPO_jammer_agent, env, trainResults);

save("PPO_jammer_agent", "PPO_jammer_agent");
