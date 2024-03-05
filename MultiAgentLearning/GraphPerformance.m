function GraphPerformance(experience, testData)


profit1 = reshape(experience(1).Observation.obs1.Data(1, 1, :), [1114, 1]) .* testData{:, 1};
profit2 = reshape(experience(1).Observation.obs1.Data(1, 2, :), [1114, 1]) .* testData{:, 2};
profit3 = reshape(experience(1).Observation.obs1.Data(1, 3, :), [1114, 1]) .* testData{:, 3};
profitInHand = reshape(experience(1).Observation.obs1.Data(1, 7, :), [1114, 1]);
plot(profit1 + profit2 + profit3 + profitInHand, DisplayName="Agent 1, Competing", LineWidth=5);
hold on

profit1 = reshape(experience(2).Observation.obs1.Data(1, 1, :), [1114, 1]) .* testData{:, 1};
profit2 = reshape(experience(2).Observation.obs1.Data(1, 2, :), [1114, 1]) .* testData{:, 2};
profit3 = reshape(experience(2).Observation.obs1.Data(1, 3, :), [1114, 1]) .* testData{:, 3};
profitInHand = reshape(experience(2).Observation.obs1.Data(1, 7, :), [1114, 1]);
plot(profit1 + profit2 + profit3 + profitInHand, DisplayName="Agent 2, Competing", LineWidth=5);

profit1 = reshape(experience(3).Observation.obs1.Data(1, 1, :), [1114, 1]) .* testData{:, 1};
profit2 = reshape(experience(3).Observation.obs1.Data(1, 2, :), [1114, 1]) .* testData{:, 2};
profit3 = reshape(experience(3).Observation.obs1.Data(1, 3, :), [1114, 1]) .* testData{:, 3};
profitInHand = reshape(experience(3).Observation.obs1.Data(1, 7, :), [1114, 1]);
plot(profit1 + profit2 + profit3 + profitInHand, DisplayName="Agent 3", LineWidth=5);

plot(testData{:, 1} * 20000 / testData{1, 1} , DisplayName="Stock 1");
plot(testData{:, 2} * 20000 / testData{1, 2} , DisplayName="Stock 2");
plot(testData{:, 3} * 20000 / testData{1, 3} , DisplayName="Stock 3");
legend('Location','northwest')
title('Performance')
hold off