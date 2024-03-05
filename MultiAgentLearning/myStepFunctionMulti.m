function [NextObs,Rewards,IsDone,StockSaved] = myStepFunctionMulti(Actions,StockSaved,trainData,ActionVectors,isTrain, numAgents)
% Copyright 2024 The MathWorks, Inc.

NextObs = cell(1, numAgents);
Rewards = zeros(1, numAgents);

%% Iterate over each agent
for agentI=1:numAgents
    % Get information from each agent
    StockSavedAgent = StockSaved{agentI};
    Action = Actions{agentI};

    %% Init of needed variables
    cash_in_hand = StockSavedAgent.cash_in_hand;
    lastweek = StockSavedAgent.last7;
    Reward_action = 0;
    bad_actions = 0;
    Reward = 0;
    diffPricesBought = zeros(1,3);
    
    %% Updating base values of the new step
    prev_val = sum(StockSavedAgent.stock_owned.*lastweek(1,:)) + cash_in_hand;
    StockSavedAgent.cur_step = StockSavedAgent.cur_step + 1;
    stock_price = trainData(StockSavedAgent.cur_step, :);
    
    
    %% Check action is correct
    if ~ismember(Action,1:length(ActionVectors))
        error('Action must be an action combo');
    end
    
    %% Updating indicators
    % lastweek = StockSavedAgent.last7;
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
    
    if StockSavedAgent.cur_step > 7 % wating for the buffer to be full
        %% Getting actions by stocks
        action_vec = ActionVectors(Action,:);
        sell_index =  action_vec == 0;
        buy_index = action_vec == 2;
     
        %% Handling sell action (sell every things)
        if any(sell_index)
            sell_index =  find(sell_index);
            
            % Retrieving bad actions, you try to sell stocks you don't own
            bad_actions = bad_actions + sum(StockSavedAgent.stock_owned(sell_index) == 0);
            
            % Calculating the reward action regarding indicators
            IndR = [Ind1(sell_index),Ind2(sell_index),Ind3(sell_index),Ind4(sell_index)];
            
            % Selling is rewarded if the indicators are showing negative
            % momentum. I.e. if the price is falling, its a good time to sell
            % but it is bad if you sell when price is rising
            
            Reward_action = Reward_action + sum( abs(IndR(IndR<0))) - sum( abs(IndR(IndR>=0)));
            
            % Calculating the difference from the bought price
            diffPricesBought(sell_index) = stock_price{1,sell_index}./StockSavedAgent.prevBoughtPrices(sell_index) -1;
            if isinf(diffPricesBought(sell_index))
                diffPricesBought(sell_index)=0;
            end
            
            % Selling action
            cash_in_hand = cash_in_hand + sum(stock_price{1,sell_index}.*StockSavedAgent.stock_owned(sell_index));
            StockSavedAgent.stock_owned(sell_index) = 0;
            
            % Reward calculation
            cur_val = sum(StockSavedAgent.stock_owned.*stock_price{1,:}) + cash_in_hand;
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
                        StockSavedAgent.stock_owned(index) = StockSavedAgent.stock_owned(index)+1;
                        cash_in_hand = cash_in_hand - stock_price{1,index};
                    else
                        can_buy = false;
                    end
                end
            end
            % Updating the previously bought prices
            if any(noBadActionIndex)
                StockSavedAgent.prevBoughtPrices(noBadActionIndex)= stock_price{1,noBadActionIndex};
            end
        end
    end
    
    %% Reward calculation when stock is Held
    cur_val = sum(StockSavedAgent.stock_owned.*stock_price{1,:}) + cash_in_hand;
    Profit = cur_val - prev_val;
    StockSavedAgent.profits(end+1) = cur_val;
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
    StockSavedAgent.cash_in_hand = cash_in_hand;
    StockSavedAgent.State = [StockSavedAgent.stock_owned,diffPricesBought.*100,StockSavedAgent.cash_in_hand,Ind1.*100,Ind2.*100,Ind3.*100,Ind4.*100];
    NextObs{agentI} = {StockSavedAgent.State};
    
    %% Updating last day prices buffer
    StockSavedAgent.last7(2:end,:) = StockSavedAgent.last7(1:end-1,:);
    StockSavedAgent.last7(1,:) = stock_price{:,:};
    
    %% Done condition
    IsDone = (StockSavedAgent.cur_step == StockSavedAgent.total_step);
        
    %% Displaying state of step
    % disp('Step: '+string(StockSavedAgent.cur_step)+'/'+string(StockSavedAgent.total_step)+' Action: '+string(Action)+' Profit: '+string(cur_val-20000)+' Reward: '+string(Reward)+' Reward action: '+string(Reward_action));
    StockSaved{agentI} = StockSavedAgent;


    Rewards(agentI) = Reward;
end

%% Give reward to agent that has made more profit, penalize the other
profit1 = NextObs{1}{1}(1)* trainData{StockSaved{agentI}.cur_step, 1};
profit2 = NextObs{1}{1}(2)* trainData{StockSaved{agentI}.cur_step, 2};
profit3 = NextObs{1}{1}(3)* trainData{StockSaved{agentI}.cur_step, 3};
profitInHand = NextObs{1}{1}(7);

profitAgent1 = profit1 + profit2 + profit3 + profitInHand;

profit1 = NextObs{2}{1}(1)* trainData{StockSaved{agentI}.cur_step, 1};
profit2 = NextObs{2}{1}(2)* trainData{StockSaved{agentI}.cur_step, 2};
profit3 = NextObs{2}{1}(3)* trainData{StockSaved{agentI}.cur_step, 3};
profitInHand = NextObs{2}{1}(7);

profitAgent2 = profit1 + profit2 + profit3 + profitInHand;

if profitAgent1 > profitAgent2
    % Reward agent 1, penalize agent 2
    Rewards(1) = Rewards(1) + 0.5;
    Rewards(2) = Rewards(2) - 0.5;
else
    % Penalize agent 1, reward agent 2
    Rewards(1) = Rewards(1) - 0.5;
    Rewards(2) = Rewards(2) + 0.5;
end


