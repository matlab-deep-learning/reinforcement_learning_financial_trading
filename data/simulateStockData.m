function [trainData,testData] = simulateStockData
% Copyright 2020 The MathWorks, Inc.

% nVariables = 3;
expReturn   = [0.0014,0.0009,0.0006];

sigma = [0.0247,0.0207,0.0213];

correlation = [1,0.4383,0.2748;
    0.4383,1,0.2616;
    0.2748,0.2616,1];

% t           = 0;
X = [38.63;100.34;64.9]; %starting prices

F = @(t,X) diag(expReturn)* X;
G = @(t,X) diag(X) * diag(sigma);

SDE = sde(F, G, 'Correlation', ...
    correlation, 'StartState', X);

GBM = gbm(diag(expReturn),diag(sigma), 'Correlation', ...
    correlation, 'StartState', X);
trainPeriod = 2598;
testPeriod = 1113;
nPeriods = trainPeriod+testPeriod;      % # of simulated observations
dt       =   1;      % time increment = 1 day
rng(2,'twister')
[X,T] = simulate(GBM, nPeriods, 'DeltaTime', dt, ...
    'nTrials', 10);

% plot(X(1:2598,:,8))
simIndex = 10; %selecting 1 simulation
trainData = X(1:trainPeriod,:,simIndex);
trainData = array2table(trainData);

testData = X(trainPeriod+1:end,:,simIndex);
testData = array2table(testData);
