function [trainData,testData] = fetchStockData
% Copyright 2020 The MathWorks, Inc.
% helper function for downloading the data used for this example

% This example requires you to obtain an api-key
% To get your free api key go to:
% https://www.alphavantage.co/support/#api-key

%%%%%  Enter your api key here
apikey = '';
% Example:
% apikey = '6XRD9S9SYPOI0M96'; %note this is not a real key

%%%%%%
symbol = 'AMZN';
AMZN = fetchDaily(symbol,apikey);
symbol = 'GOOGL';
GOOGL = fetchDaily(symbol,apikey);
symbol = 'UNH';
UNH = fetchDaily(symbol,apikey);

dataC = synchronize(AMZN,GOOGL);
dataC = synchronize(dataC,UNH);

%setting dates for training and testing data sets
d1 = datetime('2004-08-19','InputFormat','yyyy-MM-dd');    
d2 = datetime('2014-12-11','InputFormat','yyyy-MM-dd');    
d3 = datetime('2014-12-12','InputFormat','yyyy-MM-dd');    
d4 = datetime('2019-05-16','InputFormat','yyyy-MM-dd'); 

I1 = find(dataC.Close_Date == d1);
I2 = find(dataC.Close_Date == d2);
I3 = find(dataC.Close_Date == d3);
I4 = find(dataC.Close_Date == d4);

trainData = dataC{I1:I2,:};
trainData = array2table(trainData);
testData = dataC{I3:I4,:};
testData = array2table(testData);