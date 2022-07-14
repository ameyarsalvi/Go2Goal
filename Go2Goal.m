
clc
clear all
env=QCarENV();
validateEnvironment(env);


observationInfo = getObservationInfo(env);
numObservations = observationInfo.Dimension(1);
actionInfo = getActionInfo(env);
numActions = actionInfo.Dimension(1);



%%

L = 50; % number of neurons
statePath = [
    featureInputLayer(numObservations,'Normalization','none','Name','observation')
    fullyConnectedLayer(L,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(30,'Name','fc2')
    additionLayer(2,'Name','add')
    reluLayer('Name','relu2')
    fullyConnectedLayer(20,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(10,'Name','fc4')
    reluLayer('Name','relu4')
    fullyConnectedLayer(1,'Name','fc9')];

actionPath = [
    featureInputLayer(numActions,'Normalization','none','Name','action')
    fullyConnectedLayer(30,'Name','fc10')];

criticNetwork = layerGraph(statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
    
criticNetwork = connectLayers(criticNetwork,'fc10','add/in2');

%%

%figure
%plot(criticNetwork)

%%

criticOptions = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'L2RegularizationFactor',1e-4);

critic = rlQValueRepresentation(criticNetwork,observationInfo,actionInfo,...
    'Observation',{'observation'},'Action',{'action'},criticOptions);

%%

actorNetwork = [
    featureInputLayer(numObservations,'Normalization','none','Name','observation')
    fullyConnectedLayer(L,'Name','fc1')
    reluLayer('Name','relu1')
    fullyConnectedLayer(50,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(25,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(10,'Name','fc4')
    reluLayer('Name','relu4')
    fullyConnectedLayer(numActions,'Name','fc8')
    tanhLayer('Name','tanh1')
    scalingLayer('Name','ActorScaling1','Scale',[0.45;0.5],'Bias',[0.55;0])];
%%
%figure
%plot(actorNetwork)
%%

actorOptions = rlRepresentationOptions('LearnRate',1e-4,'GradientThreshold',1,'L2RegularizationFactor',1e-4);
actor = rlDeterministicActorRepresentation(actorNetwork,observationInfo,actionInfo,...
    'Observation',{'observation'},'Action',{'ActorScaling1'},actorOptions);

%%

agentOptions = rlDDPGAgentOptions(...
    'SampleTime',0.01,...
    'TargetSmoothFactor',1e-3,...
    'ExperienceBufferLength',10000,...
    'DiscountFactor',0.99,...
    'MiniBatchSize',64);

agentOptions.NoiseOptions.Variance = [0.8;100]; % sqrt(Var)*sqrt(Ts) = (10%) *(Range) 
agentOptions.NoiseOptions.VarianceDecayRate = 1e-4;
agentOptions.ResetExperienceBufferBeforeTraining = true;
%%
%agentOptions.ResetExperienceBufferBeforeTraining = false;

agent = rlDDPGAgent(actor,critic,agentOptions);
%%
maxepisodes = 1000 ;
maxsteps = 1000;
trainingOpts = rlTrainingOptions('MaxEpisodes',maxepisodes,'MaxStepsPerEpisode',maxsteps,'Verbose',true,'StopTrainingCriteria','EpisodeCount','StopTrainingValue',750,'Plots',"none");

%%
trainingStats = train(agent,env,trainingOpts);

%%

simOpts = rlSimulationOptions('MaxSteps',1000);
experience = sim(env,agent,simOpts);

save('workspace.mat')

%%


Obs = experience.Observation.ObservationsForAgent.Data;
Obs = squeeze(Obs);

Act = experience.Action.InputVelocities.Data;
Act = squeeze(Act);



%%
x = Obs(1,:);
y = Obs(2,:);

X = [4;7];
Y = [0;2];
centers = [X Y];
radii = [1;1];

figure
viscircles(centers,radii,'Color','k')
hold on
plot(0,0,'*')
hold on
plot(10,0,'*')
hold on
plot(x,y)
title('Go to Goal')

figure
plot(Act(1,:))
title('Velocity')

figure
plot(Act(2,:))
title('Steering')
%}