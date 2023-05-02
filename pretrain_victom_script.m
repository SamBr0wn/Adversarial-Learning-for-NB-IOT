
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function

obsInfo_v = rlNumericSpec([3 1]);
obsInfo_v.Name = "Victom Channel Select";
obsInfo_v.Description = 'TX Channel Selected, BLER, Throughput';

actInfo_v = rlNumericSpec([1 1]);
actInfo_v.Name = "TX Channel Action";

% create environment
env = rlFunctionEnv(obsInfo_v,actInfo_v,stepVictim,resetVictim);

% create agent
qTable = rlTable(obsInfo_v, actInfo_v);
qFunction = rlQValueFunction(qTable, obsInfo_v, actInfo_v);
qOptions = rlOptimizerOptions(LearnRate=1);

agentOpts = rlQAgentOptions;
agentOpts.DiscountFactor = 1;
agentOpts.EpsilonGreedyExploration.Epsilon = 0.9;
agentOpts.EpsilonGreedyExploration.EpsilonDecay = 0.01;
agentOpts.CriticOptimizerOptions = qOptions;
qAgent = rlQAgent(qFunction,agentOpts); 

trainOpts = rlTrainingOptions;
trainOpts.MaxStepsPerEpisode = 50;
trainOpts.MaxEpisodes = 500;
trainOpts.StopTrainingCriteria = "AverageReward";
trainOpts.StopTrainingValue = 2; %
trainOpts.ScoreAveragingWindowLength = 30;

doTraining = false;

if doTraining
    % Train the agent.
    trainingStats = train(qAgent,env,trainOpts); %#ok<UNRCH> 
else
    % Load pretrained agent for the example.
    load("genericMDPQAgent.mat","qAgent"); 
end

