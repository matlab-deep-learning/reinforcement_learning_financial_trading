%% Experience generation
sim_100 = [];
testData = readtable('data\testData.csv');
simOpts = rlSimulationOptions('MaxSteps',4000);
for i = 1:100
    experience = sim(envT,agent,simOpts);
    prices = testData(end,:);
    nbStock = experience.Observation.StockTradingStates.Data(:,1:3,end);
    cash = experience.Observation.StockTradingStates.Data(:,7,end);
    cur_val = sum(nbStock.*prices{1,:}) + cash;
    sim_100(end+1) = cur_val;
end
sim_norm = sim_100 - 20000;

%% Analisis of the simulations
figure;
h1 = histogram(sim_norm,'Normalization','pdf');
pd = fitdist(sim_norm','Weibull');

x_pdf = linspace(min(sim_norm),max(sim_norm),100);
y = pdf(pd,x_pdf); %pdf calculation
line(x_pdf,y,'color','r')

val_5per = pd.icdf(0.05);
val_95per = pd.icdf(0.95);

prob_upto_mean = pd.cdf(pd.mean);

xlabel(['tph - prob of up to mean: ',num2str(round(100*prob_upto_mean)),'%'])
ylabel('count pdf')
title(['distribution fit of trading profit'])
xtickformat('usd');
% hold on
line([val_5per,val_5per],[0,max(h1.Values)],'color','m')
line([pd.mean,pd.mean],[0,max(h1.Values)])
line([val_95per,val_95per],[0,max(h1.Values)],'color','m')

legend('Distribution',pd.DistributionName,['Lower 5%: ',num2str(val_5per )],...
    ['Dist Mean: ',num2str(pd.mean) ] ,...
    ['Upper 5%: ',num2str(val_95per)]);
