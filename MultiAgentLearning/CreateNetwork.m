function agent = CreateNetwork(env, displayNetwork) 
% Copyright 2024 The MathWorks, Inc.

%% Define network architectures
criticNet = [
    imageInputLayer([1 19 1],"Name","state","Normalization","none")
    fullyConnectedLayer(64,"Name","Fully_64_1")
    tanhLayer("Name","tanh_activation1")
    fullyConnectedLayer(64,"Name","Fully_64_2")
    tanhLayer("Name","tanh_activation2")
    fullyConnectedLayer(32,"Name","Fully_32")
    reluLayer("Name","relu_activation1")
    fullyConnectedLayer(1,"Name","output")];

actorNet = [
    imageInputLayer([1 19 1],"Name","state","Normalization","none")
    fullyConnectedLayer(64,"Name","Fully_64_1")
    tanhLayer("Name","tanh_activation1")
    fullyConnectedLayer(64,"Name","Fully_64_2")
    tanhLayer("Name","tanh_activation2")
    fullyConnectedLayer(32,"Name","Fully_32")
    reluLayer("Name","relu_activation1")
    fullyConnectedLayer(27,"Name","action")];

%% Create Agents
lgraph1 = layerGraph(criticNet);
lgraph2 = layerGraph(actorNet);

if displayNetwork
    figure;
    plot(lgraph1);
    title('Critic network')
    figure;
    plot(lgraph2);
    title('Actor network')
end

obsInfo = getObservationInfo(env);
obsInfo = obsInfo{1};
actInfo = getActionInfo(env);
actInfo = actInfo{1};

criticOpts = rlRepresentationOptions('LearnRate',1e-3,'GradientThreshold',1,'UseDevice','cpu');
critic = rlValueRepresentation(criticNet,obsInfo,'Observation',{'state'},criticOpts);

actor = rlDiscreteCategoricalActor(actorNet,obsInfo,actInfo);

agent = rlPPOAgent(actor,critic);
end