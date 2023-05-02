
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function

obsInfo_v = rlNumericSpec([3 t]);
obsInfo_v.Name = "Victom Channel Select";
obsInfo_v.Description = 'TX Channel Selected, BLER, Throughput';

actInfo_v = rlNumericSpec([1 1]);
actInfo_v.Name = "TX Channel Action";

% create environment
env = rlFunctionEnv(obsInfo_v,actInfo_v,stepVictim,resetVictim);

% create agent
qTable_v = rlTable(obsInfo_v, actInfo_v);
qFunction_v = rlQValueFunction(qTable_v, obsInfo_v, actInfo_v);
qOptions_v = rlOptimizerOptions(LearnRate=1);

agentOpts_v = rlQAgentOptions;
agentOpts_v.DiscountFactor = 1;
agentOpts_v.EpsilonGreedyExploration.Epsilon = 0.9;
agentOpts_v.EpsilonGreedyExploration.EpsilonDecay = 0.01;
agentOpts_v.CriticOptimizerOptions = qOptions_v;
qAgent_v = rlQAgent(qFunction_v,agentOpts_v); 

trainOpts_v = rlTrainingOptions;
trainOpts_v.MaxStepsPerEpisode = 50;
trainOpts_v.MaxEpisodes = 500;
trainOpts_v.StopTrainingCriteria = "AverageReward";
trainOpts_v.StopTrainingValue = 2; %
trainOpts_v.ScoreAveragingWindowLength = 30;

doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(qAgent_v,env,trainOpts_v); %#ok<UNRCH> 
else
    % Load pretrained agent for the example.
    load("genericMDPQAgent.mat","qAgent"); 
end

