clear;

% ----------Begining of the simulation - victom pre training---------
run('variables.m'); % this line should get moved to the main function
Parameters = load("Parameters.mat");

obsInfo_vd = rlNumericSpec([1, 2], "DataType", "double");
% obsInfo_vd = rlFiniteSetSpec([0 1]);
obsInfo_vd.Name = "Victim Channel Select";
obsInfo_vd.Description = 'TX Channel Selected, BLER, Throughput';

% actInfo_v = rlNumericSpec([1 1], "DataType", "double");
actInfo_vd = rlFiniteSetSpec(-1:1);
actInfo_vd.Name = "TX Channel Action";

type resetVictimDefense.m;
type stepVictimDefense.m;

% ----------create environment----------
env = rlFunctionEnv(obsInfo_vd, actInfo_vd, "stepVictimDefense", "resetVictimDefense");

PPO_opt = rlPPOAgentOptions;
PPO_victim_agent = rlPPOAgent(obsInfo_vd,actInfo_vd,PPO_opt);

% How do you know how many steps you will do per episode?
opt = rlTrainingOptions(...
    MaxEpisodes=100,...
    MaxStepsPerEpisode=100,...
    StopTrainingCriteria="AverageReward",...
    StopTrainingValue=50);
trainResults = train(PPO_victim_agent,env,opt);

trainResults = train(PPO_victim_agent, env, trainResults);

save("PPO_fortified_victim_agent", "PPO_victim_agent");

