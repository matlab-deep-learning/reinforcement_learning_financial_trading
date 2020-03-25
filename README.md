# **Reinforcement Learning For Financial Trading**  :chart_with_upwards_trend:

How to use Reinforcement learning for financial trading using Simulated Stock Data using **[MATLAB](https://www.mathworks.com/products/matlab.html)**.

## **Setup**

To run:

1. Open RL_trading_demo.prj
2. Open workflow.mlx (MATLAB Live Script **preferred**) or workflow.m (MATLAB script **viewable in GitHub**)
3. Run workflow.mlx

Environment and Reward can be found in:
myStepFunction.m

Requires

- [MATLAB R2019b](https://www.mathworks.com/products/matlab.html)
- [Deep Learning Toolbox](https://www.mathworks.com/products/deep-learning.html)
- [Reinforcement Learning Toolbox](https://www.mathworks.com/products/reinforcement-learning.html)
- [Financial Toolbox](https://www.mathworks.com/products/finance.html)

## Overview

The goal of the Reinforcement Learning agent is simple. Learn how to trade the financial markets without ever losing money. 

Note, this is different from learn how to trade the market and make the most money possible.

![](images/overview.png)

## Reinforcement Learning for Financial Trading

Lets apply some of the terminology and concepts of teaching a reinforcement learning agent to trade.

![](images/rloverview.png)

- The agent in this case study is the computer.
- It will observe financial market indicators (states).
- The financial market is the environment.
- The actions it can take are buy, hold sell.
- It needs to learn which action to take and when (policy).
- It learns by understanding what is a good trade or a bad trade via rewards.

## Case Study 

Our environment consists of 3 stocks, $20000 cash & 15 years of historical data:

Stocks are:

- Simulated via Geometric Brownian Motion or
- Historical Market data ([source: AlphaVantage](https://www.alphavantage.co/))

Actions (buy, sell ,hold) for 3 stocks = 27 total actions

The States being observed are:

- Stocks Owned
- Price Different when Bought
- Cash In Hand
- Price change from yesterday
- % Price change from 2 days ago
- % Price change from 7 days ago
- % Price change from average price of 7 days ago

## Strategy

- Given 3 stocks
- Try to find the best time to buy, sell, or hold each stock
- If selling a stock, sell all of it.
- If buying a stock, buy the maximum allowed given cash in hand.

## Reward

The reward system was what took the most time to develop and required several iterations.

The details are listed, but to simplify

A good reward is given when a trade results in a profit and a stock is bought/held/sold at the right time. For example buying a stock on the way up.

The reverse goes for giving a penalty except for one thing.

A large penalty is given if ANY trade of the 3 stocks is determined as a bad trade. WHY? In the first iteration of the reward system, this was not there. What was observed is that the agent quickly learnt the best of the 3 stocks to trade and ignored the other 2. 

- A good reward is given when
    - A selling trade results in profit
    - A selling trade occurs with momentum
        - I.e. selling when prices start to fall
    -Holding a stock results in the portfolio value increasing
- A bad reward is given when
    - Selling results in a negative profit
    - A selling trade occurs against momentum
        - I.e. selling when prices are increasing, buying when prices are falling
    - Holding a stock results in the portfolio value decreasing
    - A good reward is overwritten to be bad if any illogical trade occurs
        - I.e. sell a stock you don’t have or buy when you don’t had cash 

## Training

![](images/training.png)

- Based 12years of data
- 3000 episodes
- ~80hrs to train

Here is an overview of how long it took to learn. You might think 80hrs is a long time. But remember, how long do you think it takes a human to learn how to trade successfully over 12 years?

## Results

**Highlights**
- 100 Simulations of 3 years:
    - Average profit - ~$30k
    - 0 simulations returned negative
    - But most did not outperform individual stocks

**Histogram of 100 Simulations**

![](images/resultHistogram.png)

**Best Simulation**

![](images/resultBestSim.png)

**Worst Simulation**

![](images/resultWorstSim.png)


The histogram shows that for 100 simulations, not once did the agent ever lose money. So the goal was achieved! 

However, you can see that the range varies quite a bit. If you inspect the plots on the right,  just buying and holding 1 stock would returned a profit just as good if not better than the agent.

BUT – It’s easy to judge retrospectively. The agent was trading each day as it occurred.  None of the simulations resulted in a loss.

## Further Improvements 

The case study did ignore some common things to consider when trading the market.  Here a few areas that could improve the performance, and make the trained agent more robust:

- Include Transaction costs
- Cover the Hi/Lo spread
- Refined reward system
- Compare different agents

## Conclusion 

The aim of this example was to show:

- What reinforcement learning is
- How it can be applied to trading the financial markets
- Leave a starting point for financial professionals to use and enhance using their own domain expertise.

## For more information on Reinforcement Learning in MATLAB:

**[Download a free trial](https://www.mathworks.com/products/reinforcement-learning.html)**

**[Getting Started with Reinforcement Learning (YouTube series)](https://www.youtube.com/watch?v=pc-H4vyg2L4&feature=youtu.be)**

Copyright 2020 The MathWorks, Inc.

[![View Reinforcement Learning for Financial Trading on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/74176-reinforcement-learning-for-financial-trading)
