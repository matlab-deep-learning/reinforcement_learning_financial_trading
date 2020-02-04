%% Build data sets
opts = detectImportOptions('daily_AMZN.csv');
opts.VariableNames = ["timestamp", "Var2", "Var3", "Var4", "close", "Var6"];
opts.SelectedVariableNames = {'timestamp','close'};

amazon = table2timetable(readtable('daily_AMZN.csv',opts));
google = table2timetable(readtable('daily_GOOGL.csv',opts));
unh = table2timetable(readtable('daily_UNH.csv',opts));


data = synchronize(amazon,google,unh);
data = rmmissing(data);

index = round(height(data) * 0.7);

trainData = data(1:index,:);
testData = data(index+1:end,:);
writematrix(trainData{:,:},'data\trainData.csv','Delimiter',',','QuoteStrings',true);
writematrix(testData{:,:},'data\testData.csv','Delimiter',',','QuoteStrings',true);
