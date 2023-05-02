
% Begining of the simulation - victom pre training
run('variables.m'); % this line should get moved to the main function

obsInfo_j = rlNumericSpec([3 1]);
obsInfo_j.Name = "Jammer Channel Select";
obsInfo_j.Description = 'TX Channel Selected, BLER, Throughput';

actInfo_j = rlNumericpec([1 1]);
actInfo_j.Name = "TX Channel Action";

% create environment
env = rlFunctionEnv(obsInfo_j,actInfo_j,stepJammer,resetJammer);

% create agent
qTable_j = rlTable(obsInfo_j, actInfo_j);
qFunction_j = rlQValueFunction(qTable_j, obsInfo_j, actInfo_j);
qOptions_j = rlOptimizerOptions(LearnRate=1);

agentOpts_j = rlQAgentOptions;
agentOpts_j.DiscountFactor = 1;
agentOpts_j.EpsilonGreedyExploration.Epsilon = 0.9;
agentOpts_j.EpsilonGreedyExploration.EpsilonDecay = 0.01;
agentOpts_j.CriticOptimizerOptions = qOptions_j;
qAgent_j = rlQAgent(qFunction_j,agentOpts_j); 

trainOpts_j = rlTrainingOptions;
trainOpts_j.MaxStepsPerEpisode = 50;
trainOpts_j.MaxEpisodes = 500;
trainOpts_j.StopTrainingCriteria = "AverageReward";
trainOpts_j.StopTrainingValue = 2; %
trainOpts_j.ScoreAveragingWindowLength = 30;

doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(qAgent_j,env,trainOpts_j); %#ok<UNRCH> 
else
    % Load pretrained agent for the example.
    load("genericMDPQAgent.mat","qAgent"); 
end