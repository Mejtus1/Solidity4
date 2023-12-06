// LEARN BASICS OF LIQUIDITY and make notes of it 
// Uniswap pair creation ? what is it ? what is wrapped ether ? 
// add token to uniswap and add liquidity to it on ethreum network

/*
Adding Token to Uniswap:
Create Token: 
If you haven't already created token, you'll need to deploy ERC-20 token smart contract on Ethereum blockchain

Access Uniswap Interface: 
Uniswap Interface (https://app.uniswap.org/) on Ethereum mainnet

Import Token: 
Click on "Import" and paste token address or symbol to see if it's listed
If not, you might need to add it manually

Manually Add Token: 
If your token is not listed, you can manually add it by clicking on "Import it" and entering token address, symbol, and decimals

Providing Liquidity:
Access Pool: 
Once your token is listed, go to "Pool" tab on Uniswap

Add Liquidity:
Click on "Add Liquidity" and select tokens you want to provide liquidity for
You'll need equal value of both tokens to add liquidity

Approve Tokens: 
You'll need to approve Uniswap to spend your tokens
Follow the prompts to approve spending of both tokens

Add Liquidity: 
Enter amounts of each token you want to add as liquidity
Uniswap will calculate how many LP (liquidity provider) tokens you'll receive

Confirm and Supply: 
Confirm transaction on your wallet (such as MetaMask)
Once confirmed, you'll receive LP tokens representing your share of pool

Manage Liquidity: 
You can manage your liquidity by adding or removing funds at any time
Be cautious of impermanent loss, where value of your assets changes compared to holding them

These actions involve interacting with smart contracts and handling your tokens, so ensure you're using secure connection and only 
interacting with verified contracts and interfaces
Gas fees and availability of your token can affect these processes

// Liquidity pools explained 
// https://www.youtube.com/watch?v=cizLhxSKrAc&ab_channel=Finematics
/* 
- liquidity pools are pools of tokens that are locked in smart contract, used to facilitate trading, provide liquidity 

Why do we need liquidity pools 
- NYSE, NASDAQ, Binance, coinbase = book model, buyers and sellers meet 

Market makers 
- entities that facilitate trading by always willing to buy or sell a particular asset

Liquidity pool
- in simple terms, liquidity pools hold 2 tokens and each pool create a new market for that particular pool of tokens 
- in new pool, the first liquidity provider is the one who sets the price in pool
- first liq. provider is incentivised to supply equal value of both tokens otherwise there is instant arbitrage opportunity (lost capital to liq. provider)
LP
- when liquidity is provided, liq. provider recieves special LP tokens in relation to how much % of a pool he owns 
- 0,3% fee is distributed amongst all LP token holders
- if a liq. provider wants back their tokens, they need to burn their liquidity tokens

Automated market maker
- liquidity pools use different algorithms 
Uniswap
- basic liquidity pools 
- uniswap uses CONSTANT PRODUCT MARKET MAKER
 X x Y = k
X = token X quantity
Y = token Y quantity
k = constant
- product of the quantities of two supplied tokens always remains the same
- the pool can always provide liquidity no matter how large the trade is 
- algorithm asimpthotically increases price of token as desired quantity increases
Ratio of tokens in pool dictates the price
DAI/ETH pool 
- reduce supply of eth, increase supply of dai = results price of eth, decrease price of dai
- bigger the pool is in comparison to the trade lesser price impact (slippage)
Balancer
- incentivizes liquidity providers with extra tokens for supplying liquidity to certain pools (liquidity mining)
- there doesnt need to only be 2 tokens (balancer provides up to 8 tokens in a pool)
Curve
- realised that AMM of UNISWAP doesnt work well on assets with similar price (stablecoins, eth/weth)
- Curve offers lower fees and lower slippage
