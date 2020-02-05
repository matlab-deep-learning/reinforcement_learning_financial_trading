function [InitialObservation,StockSaved] = myResetFunction(trainData)
% Copyright 2020 The MathWorks, Inc.

%% init
[total_step,n_step] = size(trainData);
init_invest = 20000;

%% reset the environment
cur_step = 1;
stock_price = trainData(cur_step, :);

%randomize stock holdings at the beginning
Ir = rand(1);

%% Init cash in and cash invested
cash_in_hand = round(init_invest*Ir);
invest_cash = init_invest-cash_in_hand;

stock_init = rand(1,3);
stock_init = stock_init/sum(stock_init);
stock_init_buy = invest_cash.*stock_init;

%% Save it in shared structure
StockSaved.stock_owned  = round(stock_init_buy./stock_price{:,:});
StockSaved.cash_in_hand = cash_in_hand;

%% Init Indicators
Ind1 = zeros(1,3);
Ind2 = Ind1;
Ind3 = Ind1;
Ind4 = Ind1;

%% Init price differentiation ratio 
diffPricesBought = zeros(1,3);
%% Init first state and buffer
StockSaved.State = [StockSaved.stock_owned,diffPricesBought,StockSaved.cash_in_hand,Ind1,Ind2,Ind3,Ind4];
StockSaved.last7 = zeros(7,3);
StockSaved.last7(1,:) = stock_price{:,:};
StockSaved.prevBoughtPrices = Ind1;
StockSaved.profits = [];
%% Adding parameters to the structure saved
StockSaved.total_step = total_step;
StockSaved.n_step = n_step;
StockSaved.cur_step = cur_step;
StockSaved.cur_val = [];

%% Updating initial Observation
InitialObservation = StockSaved.State;