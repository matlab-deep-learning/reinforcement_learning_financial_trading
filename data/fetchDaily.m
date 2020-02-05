function data = fetchDaily(symbol,apikey)
% Copyright 2020 The MathWorks, Inc.

url = ['https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=',symbol,'&outputsize=full&apikey=',apikey,'&datatype=json'];

s = webread(url);
fnames = fieldnames(s.TimeSeries_Daily_);
C = struct2cell(s.TimeSeries_Daily_);

for i = 1:length(C)
    Close_Date(i,:) = datetime(fnames{i}(2:end),'InputFormat','yyyy_MM_dd');
    Close_Price(i,:) = str2num(C{i}.x4_Close);
end

data = table(Close_Date,Close_Price);
data = table2timetable(data);

