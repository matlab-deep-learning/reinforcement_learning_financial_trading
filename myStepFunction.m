function [NextObs,Reward,IsDone,StockSaved] = myStepFunction(Action,StockSaved,trainData,ActionVectors,isTrain)
% Copyright 2020 The MathWorks, Inc.

%% Init of needed variables
cash_in_hand = StockSaved.cash_in_hand;
lastweek = StockSaved.last7;
Reward_action = 0;
bad_actions = 0;
Reward = 0;
diffPricesBought = zeros(1,3);

%% Updating base values of the new step
prev_val = sum(StockSaved.stock_owned.*lastweek(1,:)) + cash_in_hand;
StockSaved.cur_step = StockSaved.cur_step + 1;
stock_price = trainData(StockSaved.cur_step, :);


%% Check action is correct
if ~ismember(Action,1:length(ActionVectors))
    error('Action must be an action combo');
end

%% Updating indicators
% lastweek = StockSaved.last7;
Ind1 = (stock_price{1,:} ./ lastweek(1,:)) - 1; % change from yesterday 
Ind2 = (stock_price{1,:} ./ lastweek(2,:)) - 1; % change from 2 days
Ind3 = (stock_price{1,:} ./ lastweek(end,:)) - 1; % change from 7 days
Ind4 = (stock_price{1,:} ./ mean(lastweek(1,:))) - 1; % change from average of 7 days
if any(isinf(Ind1))
    Ind1(isinf(Ind1))=0;
end
if any(isinf(Ind2))
    Ind2(isinf(Ind2))=0;
end
if any(isinf(Ind3))
    Ind3(isinf(Ind3))=0;
end

if StockSaved.cur_step > 7 % wating for the buffer to be full
    %% Getting actions by stocks
    action_vec = ActionVectors(Action,:);
    sell_index =  action_vec == 0;
    buy_index = action_vec == 2;
 
    %% Handling sell action (sell every things)
    if any(sell_index)
        sell_index =  find(sell_index);
        
        % Retrieving bad actions, you try to sell stocks you don't own
        bad_actions = bad_actions + sum(StockSaved.stock_owned(sell_index) == 0);
        
        % Calculating the reward action regarding indicators
        IndR = [Ind1(sell_index),Ind2(sell_index),Ind3(sell_index),Ind4(sell_index)];
        
        % Selling is rewarded if the indicators are showing negative
        % momentum. I.e. if the price is falling, its a good time to sell
        % but it is bad if you sell when price is rising
        
        Reward_action = Reward_action + sum( abs(IndR(IndR<0))) - sum( abs(IndR(IndR>=0)));
        
        % Calculating the difference from the bought price
        diffPricesBought(sell_index) = stock_price{1,sell_index}./StockSaved.prevBoughtPrices(sell_index) -1;
        if isinf(diffPricesBought(sell_index))
            diffPricesBought(sell_index)=0;
        end
        
        % Selling action
        cash_in_hand = cash_in_hand + sum(stock_price{1,sell_index}.*StockSaved.stock_owned(sell_index));
        StockSaved.stock_owned(sell_index) = 0;
        
        % Reward calculation
        cur_val = sum(StockSaved.stock_owned.*stock_price{1,:}) + cash_in_hand;
        Reward_action = Reward_action*100; %scaling reward action
        Profit = cur_val - prev_val;
        Reward = Profit +Reward_action; %total reward is based of actions and profit when selling
    end
%% Handling buy action (buy one of each indexed stocks until no more money)
    if any(buy_index)
        buy_index =  find(buy_index);
       
        % Retrieving bad actions
        
        % its good if you can buy at least 1 stock
        noBadActionIndex = ~(stock_price{1,:} > cash_in_hand) & action_vec == 2;
        
        % it's bad to try and buy stocks if you have no cash to do so
        bad_actions = bad_actions + sum(stock_price{1,buy_index} > cash_in_hand);

        % Buy action
        can_buy = true;
        while can_buy
            for jj = 1:length(buy_index)
                index = buy_index(jj);
                if cash_in_hand > stock_price{1,index}
                    StockSaved.stock_owned(index) = StockSaved.stock_owned(index)+1;
                    cash_in_hand = cash_in_hand - stock_price{1,index};
                else
                    can_buy = false;
                end
            end
        end
        % Updating the previously bought prices
        if any(noBadActionIndex)
            StockSaved.prevBoughtPrices(noBadActionIndex)= stock_price{1,noBadActionIndex};
        end
    end
end

%% Reward calculation when stock is Held
cur_val = sum(StockSaved.stock_owned.*stock_price{1,:}) + cash_in_hand;
Profit = cur_val - prev_val;
StockSaved.profits(end+1) = cur_val;
if Reward > 0 || Profit > 0
    Reward = 1;
elseif Reward < 0 || Profit < 0
    Reward =-1;
end

%% Reward Calculation if any bad action occurs
% This means and bad action is heavily penalised
% This overwrites Reward from Selling / Holding 
if bad_actions > 0
    Reward = -bad_actions;
end

%% Updating new state
StockSaved.cash_in_hand = cash_in_hand;
StockSaved.State = [StockSaved.stock_owned,diffPricesBought.*100,StockSaved.cash_in_hand,Ind1.*100,Ind2.*100,Ind3.*100,Ind4.*100];
NextObs = StockSaved.State;

%% Updating last day prices buffer
StockSaved.last7(2:end,:) = StockSaved.last7(1:end-1,:);
StockSaved.last7(1,:) = stock_price{:,:};

%% Done condition
IsDone = (StockSaved.cur_step == StockSaved.total_step);

%% Profit plot
if IsDone && ~isTrain
    testDataR = table2array(trainData)./trainData{1,:};
    testDataR = 20000*testDataR;
    figure;
    plot(StockSaved.profits);hold on;
    plot(repelem(20000,numel(StockSaved.profits)));
    plot(testDataR);
    title('Profit on Test Data');
    legend({'Current Value','Initial invest','stock1','stock2','stock3'},'Location','northwest');
    xlabel('Days');
    ylabel('Money');
    ytickformat('usd');
end

%% Displaying state of step
disp('Step: '+string(StockSaved.cur_step)+'/'+string(StockSaved.total_step)+' Action: '+string(Action)+' Profit: '+string(cur_val-20000)+' Reward: '+string(Reward)+' Reward action: '+string(Reward_action));
end


