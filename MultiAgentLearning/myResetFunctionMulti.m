function [InitialObservation,StockSaved] = myResetFunctionMulti(trainData, numAgents)
% Copyright 2024 The MathWorks, Inc.

%% init
[total_step,n_step] = size(trainData);
init_invest = 20000; % all agents have 20000 dollars
StockSaved = cell(1, numAgents);

% InitialObservation is a cell array of observations
InitialObservation = cell(1, numAgents);
%% reset the environment
cur_step = 1;
stock_price = trainData(cur_step, :);

%% Define initial state for each agent
for agent=1:numAgents 
    %randomize stock holdings for each agent
    Ir = rand(1);
    
    %% Init cash in and cash invested
    cash_in_hand = round(init_invest*Ir);
    invest_cash = init_invest-cash_in_hand;
    
    stock_init = rand(1,3);
    stock_init = stock_init/sum(stock_init);
    stock_init_buy = invest_cash.*stock_init;
    
    %% Save it in shared structure
    StockSavedAgent.stock_owned  = round(stock_init_buy./stock_price{:,:});
    StockSavedAgent.cash_in_hand = cash_in_hand;
    
    %% Init Indicators
    Ind1 = zeros(1,3);
    Ind2 = Ind1;
    Ind3 = Ind1;
    Ind4 = Ind1;
    
    %% Init price differentiation ratio 
    diffPricesBought = zeros(1,3);
    %% Init first state and buffer
    StockSavedAgent.State = [StockSavedAgent.stock_owned,diffPricesBought,StockSavedAgent.cash_in_hand,Ind1,Ind2,Ind3,Ind4];
    StockSavedAgent.last7 = zeros(7,3);
    StockSavedAgent.last7(1,:) = stock_price{:,:};
    StockSavedAgent.prevBoughtPrices = Ind1;
    StockSavedAgent.profits = [];
    %% Adding parameters to the structure saved
    StockSavedAgent.total_step = total_step;
    StockSavedAgent.n_step = n_step;
    StockSavedAgent.cur_step = cur_step;
    StockSavedAgent.cur_val = [];
    
    StockSavedAgent.data = trainData;
    %% Updating initial Observation
    StockSaved{agent} = StockSavedAgent;
    InitialObservation{agent} = { StockSavedAgent.State };
end