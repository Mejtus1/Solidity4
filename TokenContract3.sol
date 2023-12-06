// https://etherscan.io/token/0x32db8f7f81c60e6405064d935b6e7bc80cb070d1#code
// ETF token 
// TokenContract3(ETF) and TokenContract2(PEXEL) are identical (from same developer)


/**
 *Submitted for verification at Etherscan.io on 2023-09-29
*/

/*

TG:https://t.me/ETFApproval

*/
1. 
//====================================================================================================
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

abstract contract Context {
function _msgSender() internal view virtual returns (address) {
return msg.sender;
}
}
//====================================================================================================

2.
//====================================================================================================
// IERC20, public functions, 
interface IERC20 {
function totalSupply() external view returns (uint256);

function balanceOf(address account) external view returns (uint256);

function transfer(address recipient, uint256 amount) external returns (bool);

function allowance(address owner, address spender) external view returns (uint256);

function approve(address spender, uint256 amount) external returns (bool);

function transferFrom(
address sender,
address recipient,
uint256 amount
) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
//====================================================================================================

3.
//====================================================================================================
// contract ownership, renounce ownership 
contract Ownable is Context {
address private _owner;
address private _previousOwner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);

constructor() {
address msgSender = _msgSender();
_owner = msgSender;
emit OwnershipTransferred(address(0), msgSender);
}

function owner() public view returns (address) {
return _owner;
}

modifier onlyOwner() {
require(_owner == _msgSender(), "Ownable: caller is not the owner");
_;
}

function renounceOwnership() public virtual onlyOwner {
emit OwnershipTransferred(_owner, address(0));
_owner = address(0);
}

function transferOwnership(address newOwner) public virtual onlyOwner {
require(newOwner != address(0), "Ownable: new owner is the zero address");
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}

}
//====================================================================================================

4. 
//====================================================================================================
// Safe math library
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");
return c;
}

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
return sub(a, b, "SafeMath: subtraction overflow");
}

function sub(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b <= a, errorMessage);
uint256 c = a - b;
return c;
}

function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b, "SafeMath: multiplication overflow");
return c;
}

function div(uint256 a, uint256 b) internal pure returns (uint256) {
return div(a, b, "SafeMath: division by zero");
}

function div(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b > 0, errorMessage);
uint256 c = a / b;
return c;
}
}
//====================================================================================================


5.
//====================================================================================================
// Uniswap pair creation 
interface IUniswapV2Factory {
function createPair(address tokenA, address tokenB)
external
returns (address pair);
}

interface IUniswapV2Router02 {
function swapExactTokensForETHSupportingFeeOnTransferTokens(
uint256 amountIn,
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external;

function factory() external pure returns (address);

function WETH() external pure returns (address);

function addLiquidityETH(
address token,
uint256 amountTokenDesired,
uint256 amountTokenMin,
uint256 amountETHMin,
address to,
uint256 deadline
)
external
payable
returns (
uint256 amountToken,
uint256 amountETH,
uint256 liquidity
);
}
//====================================================================================================


6.
//====================================================================================================
// MAIN LONG CONTRACT 
contract etf is Context, IERC20, Ownable {

using SafeMath for uint256;

string private constant _name = "ETF";
string private constant _symbol = "ETF";
uint8 private constant _decimals = 9;

mapping(address => uint256) private _rOwned;
mapping(address => uint256) private _tOwned;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _isExcludedFromFee;
uint256 private constant MAX = ~uint256(0);
uint256 private constant _tTotal = 1000000000 * 10**9;
uint256 private _rTotal = (MAX - (MAX % _tTotal));
uint256 private _tFeeTotal;
uint256 private _redisFeeOnBuy = 0;
uint256 private _taxFeeOnBuy = 25;
uint256 private _redisFeeOnSell = 0;
uint256 private _taxFeeOnSell = 35;

//Original Fee
uint256 private _redisFee = _redisFeeOnSell;
uint256 private _taxFee = _taxFeeOnSell;

uint256 private _previousredisFee = _redisFee;
uint256 private _previoustaxFee = _taxFee;

mapping(address => bool) public bots; mapping (address => uint256) public _buyMap;
address payable private _developmentAddress = payable(0x631a4e3116D50C78B7ff30B2Bdb960b63e9AF9A8);
address payable private _marketingAddress = payable(0x1dDeff2632d805360CFEe5Bd434431BccB847812);

IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;

bool private tradingOpen = true;
bool private inSwap = false;
bool private swapEnabled = true;

uint256 public _maxTxAmount = 20000000 * 10**9;
uint256 public _maxWalletSize = 20000000 * 10**9;
uint256 public _swapTokensAtAmount = 7500000 * 10**9;

6.2 event and constructor 
//====================================================================================================

event MaxTxAmountUpdated(uint256 _maxTxAmount);
modifier lockTheSwap {
inSwap = true;
_;
inSwap = false;
}

constructor() {

_rOwned[_msgSender()] = _rTotal;

IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);//
uniswapV2Router = _uniswapV2Router;
uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
.createPair(address(this), _uniswapV2Router.WETH());

_isExcludedFromFee[owner()] = true;
_isExcludedFromFee[address(this)] = true;
_isExcludedFromFee[_developmentAddress] = true;
_isExcludedFromFee[_marketingAddress] = true;

emit Transfer(address(0), _msgSender(), _tTotal);
}

6.3 functions 
//====================================================================================================

function name() public pure returns (string memory) {
return _name;
}

function symbol() public pure returns (string memory) {
return _symbol;
}

function decimals() public pure returns (uint8) {
return _decimals;
}

function totalSupply() public pure override returns (uint256) {
return _tTotal;
}

function balanceOf(address account) public view override returns (uint256) {
return tokenFromReflection(_rOwned[account]);
}

function transfer(address recipient, uint256 amount)
public
override
returns (bool)
{
_transfer(_msgSender(), recipient, amount);
return true;
}

function allowance(address owner, address spender)
public
view
override
returns (uint256)
{
return _allowances[owner][spender];
}

function approve(address spender, uint256 amount)
public
override
returns (bool)
{
_approve(_msgSender(), spender, amount);
return true;
}

6.4 allowance, fees
//====================================================================================================

function transferFrom(
address sender,
address recipient,
uint256 amount
) public override returns (bool) {
_transfer(sender, recipient, amount);
_approve(
sender,
_msgSender(),
_allowances[sender][_msgSender()].sub(
amount,
"ERC20: transfer amount exceeds allowance"
)
);
return true;
}

function tokenFromReflection(uint256 rAmount)
private
view
returns (uint256)
{
require(
rAmount <= _rTotal,
"Amount must be less than total reflections"
);
uint256 currentRate = _getRate();
return rAmount.div(currentRate);
}

function removeAllFee() private {
if (_redisFee == 0 && _taxFee == 0) return;

_previousredisFee = _redisFee;
_previoustaxFee = _taxFee;

_redisFee = 0;
_taxFee = 0;
}

function restoreAllFee() private {
_redisFee = _previousredisFee;
_taxFee = _previoustaxFee;
}

6.5 approve / transfer 
//====================================================================================================

function _approve(
address owner,
address spender,
uint256 amount
) private {
require(owner != address(0), "ERC20: approve from the zero address");
require(spender != address(0), "ERC20: approve to the zero address");
_allowances[owner][spender] = amount;
emit Approval(owner, spender, amount);
}

function _transfer(
address from,
address to,
uint256 amount
) private {
require(from != address(0), "ERC20: transfer from the zero address");
require(to != address(0), "ERC20: transfer to the zero address");
require(amount > 0, "Transfer amount must be greater than zero");

6.6 trading start 
//====================================================================================================

if (from != owner() && to != owner()) {

//Trade start check
if (!tradingOpen) {
require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");
}

require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");

if(to != uniswapV2Pair) {
require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
}

uint256 contractTokenBalance = balanceOf(address(this));
bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

if(contractTokenBalance >= _maxTxAmount)
{
contractTokenBalance = _maxTxAmount;
}

if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
swapTokensForEth(contractTokenBalance);
uint256 contractETHBalance = address(this).balance;
if (contractETHBalance > 0) {
sendETHToFee(address(this).balance);
}
}
}

6.7 auto fees set 
//====================================================================================================
bool takeFee = true;

//Transfer Tokens
if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
takeFee = false;
} else {

//Set Fee for Buys
if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
_redisFee = _redisFeeOnBuy;
_taxFee = _taxFeeOnBuy;
}

//Set Fee for Sells
if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
_redisFee = _redisFeeOnSell;
_taxFee = _taxFeeOnSell;
}

}

_tokenTransfer(from, to, amount, takeFee);
}

6.8 swap 
//====================================================================================================

function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
address[] memory path = new address[](2);
path[0] = address(this);
path[1] = uniswapV2Router.WETH();
_approve(address(this), address(uniswapV2Router), tokenAmount);
uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
tokenAmount,
0,
path,
address(this),
block.timestamp
);
}

function sendETHToFee(uint256 amount) private {
_marketingAddress.transfer(amount);
}

function setTrading(bool _tradingOpen) public onlyOwner {
tradingOpen = _tradingOpen;
}

function manualswap() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractBalance = balanceOf(address(this));
swapTokensForEth(contractBalance);
}

function manualsend() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractETHBalance = address(this).balance;
sendETHToFee(contractETHBalance);
}

6.9 bots blocking 
//====================================================================================================

function blockBots(address[] memory bots_) public onlyOwner {
for (uint256 i = 0; i < bots_.length; i++) {
bots[bots_[i]] = true;
}
}

function unblockBot(address notbot) public onlyOwner {
bots[notbot] = false;
}


6.95 
//====================================================================================================

function _tokenTransfer(
address sender,
address recipient,
uint256 amount,
bool takeFee
) private {
if (!takeFee) removeAllFee();
_transferStandard(sender, recipient, amount);
if (!takeFee) restoreAllFee();
}

function _transferStandard(
address sender,
address recipient,
uint256 tAmount
) private {
(
uint256 rAmount,
uint256 rTransferAmount,
uint256 rFee,
uint256 tTransferAmount,
uint256 tFee,
uint256 tTeam
) = _getValues(tAmount);
_rOwned[sender] = _rOwned[sender].sub(rAmount);
_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
_takeTeam(tTeam);
_reflectFee(rFee, tFee);
emit Transfer(sender, recipient, tTransferAmount);
}

function _takeTeam(uint256 tTeam) private {
uint256 currentRate = _getRate();
uint256 rTeam = tTeam.mul(currentRate);
_rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
}

function _reflectFee(uint256 rFee, uint256 tFee) private {
_rTotal = _rTotal.sub(rFee);
_tFeeTotal = _tFeeTotal.add(tFee);
}

6.97
//====================================================================================================

receive() external payable {}

function _getValues(uint256 tAmount)
private
view
returns (
uint256,
uint256,
uint256,
uint256,
uint256,
uint256
)
{
(uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
_getTValues(tAmount, _redisFee, _taxFee);
uint256 currentRate = _getRate();
(uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
_getRValues(tAmount, tFee, tTeam, currentRate);
return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
}

function _getTValues(
uint256 tAmount,
uint256 redisFee,
uint256 taxFee
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 tFee = tAmount.mul(redisFee).div(100);
uint256 tTeam = tAmount.mul(taxFee).div(100);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
return (tTransferAmount, tFee, tTeam);
}

function _getRValues(
uint256 tAmount,
uint256 tFee,
uint256 tTeam,
uint256 currentRate
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 rAmount = tAmount.mul(currentRate);
uint256 rFee = tFee.mul(currentRate);
uint256 rTeam = tTeam.mul(currentRate);
uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
return (rAmount, rTransferAmount, rFee);
}


6.98
//====================================================================================================

function _getRate() private view returns (uint256) {
(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
return rSupply.div(tSupply);
}

function _getCurrentSupply() private view returns (uint256, uint256) {
uint256 rSupply = _rTotal;
uint256 tSupply = _tTotal;
if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
return (rSupply, tSupply);
}

function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
_redisFeeOnBuy = redisFeeOnBuy;
_redisFeeOnSell = redisFeeOnSell;
_taxFeeOnBuy = taxFeeOnBuy;
_taxFeeOnSell = taxFeeOnSell;
}


6.99 
//====================================================================================================

//Set minimum tokens required to swap.
function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
_swapTokensAtAmount = swapTokensAtAmount;
}

//Set minimum tokens required to swap.
function toggleSwap(bool _swapEnabled) public onlyOwner {
swapEnabled = _swapEnabled;
}

//Set maximum transaction
function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
_maxTxAmount = maxTxAmount;
}

function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
_maxWalletSize = maxWalletSize;
}

function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
for(uint256 i = 0; i < accounts.length; i++) {
_isExcludedFromFee[accounts[i]] = excluded;
}
}

}
// END OF MAIN LONG CONTRACT 
//=========================================================================================================
//=========================================================================================================
//=========================================================================================================
//=========================================================================================================
//=========================================================================================================





1.
//=========================================================================================================
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.9;

abstract contract Context {
function _msgSender() internal view virtual returns (address) {
return msg.sender;
}
}
//=========================================================================================================
/*
- defines Solidity contract named Context
- purpose = provide way for other contracts to access information about current execution context = address of sender of message

- purpose of Context contract is to provide convenient way for other contracts to access sender's address (msg.sender) 
without needing to repeat this code in every contract that requires such functionality
- contracts that inherit from Context can use _msgSender() function to obtain sender's address when needed
- this pattern is often used to simplify and standardize access to sender's address in Ethereum smart contracts

// SPDX-License-Identifier: Unlicensed:

- comment that provides information about license associated with code
- "Unlicensed" suggests that there may not be specific open-source license attached to this code 

pragma solidity ^0.8.9;:
- specifies version of the Solidity compiler that should be used to compile this contract

abstract contract Context:
- declares abstract contract named Context
- abstract contracts are contracts that cannot be deployed on blockchain themselves and are meant to be inherited by other contracts
- define set of functions and state variables that must be implemented by any derived contracts

function _msgSender() internal view virtual returns (address) { return msg.sender; }:
- this is function defined within Context contract
function _msgSender(): 
- this is function named _msgSender
It's defined with internal, view, and virtual modifiers.
internal: 
- function is only accessible from within contract and its derived contracts
view: 
- function does not modify state of contract and can be called without incurring gas costs
virtual: 
- function can be overridden by derived contracts if needed
returns (address): 
- function returns an address
*/
//=========================================================================================================








2.
//====================================================================================================
// IERC20, public functions, 
interface IERC20 {
function totalSupply() external view returns (uint256);

function balanceOf(address account) external view returns (uint256);

function transfer(address recipient, uint256 amount) external returns (bool);

function allowance(address owner, address spender) external view returns (uint256);

function approve(address spender, uint256 amount) external returns (bool);

function transferFrom(
address sender,
address recipient,
uint256 amount
) external returns (bool);

event Transfer(address indexed from, address indexed to, uint256 value);
event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}
//====================================================================================================
/*
interface IERC20:
- declares interface named IERC20
- interfaces in Solidity define set of functions that must be implemented by contracts that inherit from or "implement" interface
- in this case, IERC20 defines standard functions and events for ERC-20 tokens

Function Declarations:
- interface declares several functions that are common to ERC-20 tokens:

totalSupply() external view returns (uint256): 
- used to retrieve total supply of tokens
- marked as external = can be called from outside contract
- view indicating it doesn't modify contract state
- returns total supply as uint256

balanceOf(address account) external view returns (uint256): 
- function used to check balance of tokens for specific account
- takes account address as parameter, is external, and view, and it returns balance as uint256

transfer(address recipient, uint256 amount) external returns (bool): 
- used to transfer tokens from contract's caller to another address (recipient)
- external, returns boolean value to indicate success or failure

allowance(address owner, address spender) external view returns (uint256): 
- function allows contract to check how many tokens owner has approved for spender to spend on their behalf
- external, view, and returns allowance as uint256

approve(address spender, uint256 amount) external returns (bool): 
- function allows owner to approve spender to spend specified amount of tokens on their behalf
- external and returns boolean value to indicate success or failure

transferFrom(address sender, address recipient, uint256 amount) external returns (bool): 
- function used to transfer tokens from one address (sender) to another (recipient) when authorized by sender via approve function
- external and returns boolean value

Event Declarations:
interface also declares two events that are used to log important transactions:
 event Transfer(address indexed from, address indexed to, uint256 value): 
  - event is emitted when tokens are transferred from one address to another
  - logs sender, recipient, and amount transferred

 event Approval(address indexed owner, address indexed spender, uint256 value): 
  - event is emitted when approve function is called to record approval for spending tokens 
  - logs owner, spender, and approved value
*/
//====================================================================================================









3.
//====================================================================================================
// contract ownership, renounce ownership 
contract Ownable is Context {
address private _owner;
address private _previousOwner;
event OwnershipTransferred(
address indexed previousOwner,
address indexed newOwner
);

constructor() {
address msgSender = _msgSender();
_owner = msgSender;
emit OwnershipTransferred(address(0), msgSender);
}

function owner() public view returns (address) {
return _owner;
}

modifier onlyOwner() {
require(_owner == _msgSender(), "Ownable: caller is not the owner");
_;
}

function renounceOwnership() public virtual onlyOwner {
emit OwnershipTransferred(_owner, address(0));
_owner = address(0);
}

function transferOwnership(address newOwner) public virtual onlyOwner {
require(newOwner != address(0), "Ownable: new owner is the zero address");
emit OwnershipTransferred(_owner, newOwner);
_owner = newOwner;
}

}
//====================================================================================================
/*
Solidity smart contract named Ownable that is intended to manage ownership of another contract
- purpose is to facilitate ownership control, allowing current owner to transfer ownership to new address or renounce ownership entirely

contract Ownable is Context:
- defines new contract named Ownable, which inherits from Context contract
- context contract is meant to provide information about execution context, including sender of message

State Variables:
address private _owner;: 
- variable represents current owner of contract 
- marked as private, can only be accessed within contract
address private _previousOwner;: 
- variable represents previous owner of contract
- private
Events:
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner): 
- event is emitted when ownership of contract is transferred
- logs both previous owner and new owner

Constructor:
constructor(): 
- constructor function, executed when contract is deployed
- sets initial owner of contract to address of sender (msgSender) of deployment transaction
- emits OwnershipTransferred event to indicate initial ownership assignment
- previousOwner is set to address(0) to indicate that there was no previous owner, and newOwner is set to msgSender

function owner() public view returns (address):
- public view function that allows external entities to query current owner of contract
- returns _owner state variable, which represents current owner's address

Modifier: onlyOwner:
modifier onlyOwner() {...}: 
- modifier that is applied to other functions within contract 
Modifiers are used to add conditions to function execution
- in this case, onlyOwner modifier checks if caller of function is same as current owner
- if true function proceeds, otherwise throws error message

function renounceOwnership() public virtual onlyOwner:
- function allows current owner to renounce ownership of contract
- public can be called externally
- onlyOwner modifier ensures that only current owner can call this function
- Inside function, it emits OwnershipTransferred event to indicate ownership change, with previousOwner set to current owner's address, and newOwner set to address(0)
- sets _owner state variable to address(0), effectively renouncing ownership

function transferOwnership(address newOwner) public virtual onlyOwner:
- function allows current owner to transfer ownership to new address (newOwner)
- public can be called externally
- onlyOwner modifier ensures that only current owner can call this function
- checks that new owner's address is not zero address (address(0)), ensuring that ownership transfer is valid
- emits OwnershipTransferred event to log ownership transfer, with previousOwner as current owner and newOwner as provided address
- updates _owner state variable to new owner's address
*/
//====================================================================================================










4. 
//====================================================================================================
// Safe math library
library SafeMath {
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a, "SafeMath: addition overflow");
return c;
}

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
return sub(a, b, "SafeMath: subtraction overflow");
}

function sub(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b <= a, errorMessage);
uint256 c = a - b;
return c;
}

function mul(uint256 a, uint256 b) internal pure returns (uint256) {
if (a == 0) {
return 0;
}
uint256 c = a * b;
require(c / a == b, "SafeMath: multiplication overflow");
return c;
}

function div(uint256 a, uint256 b) internal pure returns (uint256) {
return div(a, b, "SafeMath: division by zero");
}

function div(
uint256 a,
uint256 b,
string memory errorMessage
) internal pure returns (uint256) {
require(b > 0, errorMessage);
uint256 c = a / b;
return c;
}
}
//====================================================================================================
// safe math library and overflow check 
//====================================================================================================












5.
//====================================================================================================
// Uniswap pair creation 
interface IUniswapV2Factory {
function createPair(address tokenA, address tokenB)
external
returns (address pair);
}

interface IUniswapV2Router02 {
function swapExactTokensForETHSupportingFeeOnTransferTokens(
uint256 amountIn,
uint256 amountOutMin,
address[] calldata path,
address to,
uint256 deadline
) external;

function factory() external pure returns (address);

function WETH() external pure returns (address);

function addLiquidityETH(
address token,
uint256 amountTokenDesired,
uint256 amountTokenMin,
uint256 amountETHMin,
address to,
uint256 deadline
)
external
payable
returns (
uint256 amountToken,
uint256 amountETH,
uint256 liquidity
);
}
//====================================================================================================
/*
code defines two interfaces: 
1. IUniswapV2Factory 
2. IUniswapV2Router02
- interfaces used to interact with Uniswap decentralized exchange protocol, particularly for creating liquidity pairs and performing token swaps

IUniswapV2Factory:
- interface used to interact with Uniswap V2 Factory contract, which is responsible for creating and managing liquidity pairs
Functions defined in this interface:
createPair(address tokenA, address tokenB) external returns (address pair): 
- function is used to create new liquidity pair (a trading pair) Uniswap
- takes two parameters, tokenA and tokenB, which are addresses of two tokens that will be paired
- returns address of created pair

IUniswapV2Router02:
- interface used to interact with Uniswap V2 Router contract, which is responsible for executing token swaps and providing liquidity
Functions defined in this interface:
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external: 
- function used to swap exact amount of tokens for ETH while supporting tokens that have fees transfers
parameters:
amountIn: exact amount of input tokens to swap
amountOutMin: minimum amount of output ETH that must be received
path: array of token addresses representing path to be taken for swap
to: address that will receive output ETH
deadline: timestamp specifying when swap must be executed

factory() external pure returns (address): 
- function returns address of Uniswap Factory contract

WETH() external pure returns (address): 
- function returns address of Wrapped Ether (WETH) contract
- WETH is wrapped version of Ether that can be traded on Uniswap

function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity): 
- function is used to add liquidity to trading pair by supplying both tokens and ETH
- takes various parameters, including token address, desired token and ETH amounts, minimum amounts, recipient address (to), and deadline 
- returns amounts of tokens, ETH, and resulting liquidity tokens received
*/
//====================================================================================================











6.
//====================================================================================================
// MAIN LONG CONTRACT 
contract etf is Context, IERC20, Ownable {

using SafeMath for uint256;

string private constant _name = "ETF";
string private constant _symbol = "ETF";
uint8 private constant _decimals = 9;

mapping(address => uint256) private _rOwned;
mapping(address => uint256) private _tOwned;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _isExcludedFromFee;
uint256 private constant MAX = ~uint256(0);
uint256 private constant _tTotal = 1000000000 * 10**9;
uint256 private _rTotal = (MAX - (MAX % _tTotal));
uint256 private _tFeeTotal;
uint256 private _redisFeeOnBuy = 0;
uint256 private _taxFeeOnBuy = 25;
uint256 private _redisFeeOnSell = 0;
uint256 private _taxFeeOnSell = 35;

//Original Fee
uint256 private _redisFee = _redisFeeOnSell;
uint256 private _taxFee = _taxFeeOnSell;

uint256 private _previousredisFee = _redisFee;
uint256 private _previoustaxFee = _taxFee;

mapping(address => bool) public bots; mapping (address => uint256) public _buyMap;
address payable private _developmentAddress = payable(0x631a4e3116D50C78B7ff30B2Bdb960b63e9AF9A8);
address payable private _marketingAddress = payable(0x1dDeff2632d805360CFEe5Bd434431BccB847812);

IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;

bool private tradingOpen = true;
bool private inSwap = false;
bool private swapEnabled = true;

uint256 public _maxTxAmount = 20000000 * 10**9;
uint256 public _maxWalletSize = 20000000 * 10**9;
uint256 public _swapTokensAtAmount = 7500000 * 10**9;
//====================================================================================================
/*
defines smart contract named etf

Inheritance:

contract etf is Context, IERC20, Ownable: 
- indicates that etf contract inherits from three other contracts: Context, IERC20, and Ownable 
- Inheritance allows etf contract to access and use functions and state variables defined in these parent contracts

Token Characteristics:
Several state variables are defined to describe token's characteristics:
_name: constant string representing token's name, set to "ETF"
_symbol: constant string representing token's symbol, set to "ETF"
_decimals: 8-bit unsigned integer representing number of decimal places for token, set to 9.

Token Data:
Various state variables are defined to manage token's data:
_rOwned and _tOwned: Mapping variables used to store token balances for addresses
_allowances: mapping used to manage allowances for token transfers
_isExcludedFromFee: mapping that determines whether specific addresses are excluded from transaction fees
_tTotal: constant representing total token supply
_rTotal: computed variable representing total reflected supply
_tFeeTotal: A variable to keep track of the total fees collected
_redisFeeOnBuy and _taxFeeOnBuy: Constants representing fees for buy transactions
_redisFeeOnSell and _taxFeeOnSell: Constants representing fees for sell transactions
_redisFee and _taxFee: Variables representing the current fee settings for transactions
_previousredisFee and _previoustaxFee: Variables to store previous fee settings
_developmentAddress and _marketingAddress: Addresses representing destinations for certain token-related activities
uniswapV2Router and uniswapV2Pair: Addresses for the Uniswap V2 Router and the Uniswap V2 Pair
tradingOpen, inSwap, and swapEnabled: Boolean variables that control trading and swap operations
_maxTxAmount: maximum allowed transaction size
_maxWalletSize: maximum allowed wallet size
_swapTokensAtAmount: amount of tokens required to trigger a swap operation

Constructor:
constructor function is not shown in provided code, but it is typically used for initializing contract when it is deployed

Address-Related Mapping and Variables:
bots: mapping used to identify bot addresses
_buyMap: mapping used to track buying activity for addresses
*/
//====================================================================================================



6.2 event and constructor 
//====================================================================================================

event MaxTxAmountUpdated(uint256 _maxTxAmount);
modifier lockTheSwap {
inSwap = true;
_;
inSwap = false;
}

constructor() {

_rOwned[_msgSender()] = _rTotal;

IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);//
uniswapV2Router = _uniswapV2Router;
uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
.createPair(address(this), _uniswapV2Router.WETH());

_isExcludedFromFee[owner()] = true;
_isExcludedFromFee[address(this)] = true;
_isExcludedFromFee[_developmentAddress] = true;
_isExcludedFromFee[_marketingAddress] = true;

emit Transfer(address(0), _msgSender(), _tTotal);
}
//====================================================================================================
/*
It initializes various contract variables and sets up some initial conditions. 

event MaxTxAmountUpdated(uint256 _maxTxAmount);:
- event declaration named MaxTxAmountUpdated
- events are used to log significant contract actions or state changes
- In this case, it is defined to log update of maximum transaction amount (_maxTxAmount)

modifier lockTheSwap:
- custom modifier named lockTheSwap
- Modifiers are used to add conditions to functions, and they are often used to execute some code before and after function call
Inside this modifier:
inSwap = true;: It sets a boolean variable inSwap to true before the function is executed.
_;: The underscore is a placeholder for the actual function code. After the function code is executed, the code following the underscore is executed.
inSwap = false;: It sets the inSwap variable back to false after the function is executed.

Constructor:
Constructors = special functions that are executed only once when contract is deployed

_rOwned[_msgSender()] = _rTotal;:
This line initializes the balance of the contract deployer (the sender of the deployment transaction) in the _rOwned mapping with the total reflected supply _rTotal. 
It's setting the deployer's balance to the entire supply of the token.

IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);:
- declares variable _uniswapV2Router of type IUniswapV2Router02 and assigns it instance of IUniswapV2Router02 contract, presumably with address 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
- likely instance of Uniswap V2 Router contract used to facilitate token swaps

uniswapV2Router = _uniswapV2Router;:
- assigns _uniswapV2Router instance to uniswapV2Router state variable, making it available for use throughout contract

uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());:
- creates Uniswap V2 liquidity pair for token
- uses createPair function from Uniswap V2 Factory contract by calling it with address(this) (contract's address) and _uniswapV2Router.WETH() (Wrapped Ether address)
- establishes trading pair between token and Wrapped Ether

_isExcludedFromFee[owner()] = true;:
- marks owner of contract as excluded from certain fees
- sets boolean flag in _isExcludedFromFee mapping

_isExcludedFromFee[address(this)] = true;:
- marks contract itself as excluded from certain fees

_isExcludedFromFee[_developmentAddress] = true;:
- marks _developmentAddress as excluded from certain fees

_isExcludedFromFee[_marketingAddress] = true;:
- marks _marketingAddress as excluded from certain fees

emit Transfer(address(0), _msgSender(), _tTotal);:
- emits Transfer event to log initial transfer of tokens from address 0 (usually indicating token minting operation) to address that deployed contract (_msgSender()) with total supply _tTotal
*/
//====================================================================================================





6.3 functions 
//====================================================================================================
function name() public pure returns (string memory) {
    return _name;
    }
    
    function symbol() public pure returns (string memory) {
    return _symbol;
    }
    
    function decimals() public pure returns (uint8) {
    return _decimals;
    }
    
    function totalSupply() public pure override returns (uint256) {
    return _tTotal;
    }
    
    function balanceOf(address account) public view override returns (uint256) {
    return tokenFromReflection(_rOwned[account]);
    }
    
    function transfer(address recipient, uint256 amount)
    public
    override
    returns (bool)
    {
    _transfer(_msgSender(), recipient, amount);
    return true;
    }
    
    function allowance(address owner, address spender)
    public
    view
    override
    returns (uint256)
    {
    return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount)
    public
    override
    returns (bool)
    {
    _approve(_msgSender(), spender, amount);
    return true;
    }
//====================================================================================================
/*
function name() public pure returns (string memory):
- function name
- returns name of token
- marked as pure, which means it doesn't modify contract's state
- returns string that represents name of token

function symbol() public pure returns (string memory):
- function named symbol 
- returns symbol of token (e.g., "BTC" for Bitcoin)
- name function, marked as pure returns string representing symbol of token
    
function decimals() public pure returns (uint8):
- function named decimals 
- returns number of decimal places token supports
- marked as pure and returns uint8 (8-bit unsigned integer representing number of decimal places)
    
function totalSupply() public pure override returns (uint256):
- function named totalSupply 
- returns total supply of token
- marked as pure and overrides same function from interface
- returns uint256 representing total supply of token

function balanceOf(address account) public view override returns (uint256):   
- function named balanceOf 
- returns token balance of specific account
- marked as view and overrides same function from interface
- takes address parameter (account) and returns uint256 representing token balance of specified account
    
function transfer(address recipient, uint256 amount) public override returns (bool):
- function is named transfer
- allows account to transfer tokens to another account
- marked as public and overrides same function from interface
- takes two parameters: 
 recipient (address to which tokens are transferred)
 amount (number of tokens to be transferred)
- returns boolean indicating whether transfer was successful (In this code, it always returns true)

function allowance(address owner, address spender) public view override returns (uint256):
- function named allowance
- returns  amount of tokens that spender is allowed to spend on behalf of owner
- marked as public and overrides same function from interface
- takes two parameters: 
owner (address that owns tokens) 
spender (address that is allowed to spend tokens on behalf of owner)
- returns uint256 representing allowed token amount
*/
//====================================================================================================




6.4 allowance, fees 
//====================================================================================================
function transferFrom(
    address sender,
    address recipient,
    uint256 amount
    ) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(
    sender,
    _msgSender(),
    _allowances[sender][_msgSender()].sub(
    amount,
    "ERC20: transfer amount exceeds allowance"
    )
    );
    return true;
    }
    
    function tokenFromReflection(uint256 rAmount)
    private
    view
    returns (uint256)
    {
    require(
    rAmount <= _rTotal,
    "Amount must be less than total reflections"
    );
    uint256 currentRate = _getRate();
    return rAmount.div(currentRate);
    }
    
    function removeAllFee() private {
    if (_redisFee == 0 && _taxFee == 0) return;
    
    _previousredisFee = _redisFee;
    _previoustaxFee = _taxFee;
    
    _redisFee = 0;
    _taxFee = 0;
    }
    
    function restoreAllFee() private {
    _redisFee = _previousredisFee;
    _taxFee = _previoustaxFee;
    }
//====================================================================================================
/*
function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool):
- function named transferFrom 
- used to transfer tokens from one address (sender) to another address (recipient) on behalf of caller (_msgSender())
- marked as public, it can be called externally
- overrides corresponding function from ERC-20 interface
- takes three parameters: 
sender (address that's sending tokens)
recipient (address receiving tokens)
amount (number of tokens to be transferred)
Inside function, does following:
- calls private _transfer function to perform actual token transfer
- calls private _approve function to decrease allowance of sender
- this ensures that caller cannot spend more tokens than allowed (returns true to indicate successful transfer)

function tokenFromReflection(uint256 rAmount) private view returns (uint256):
- private function named tokenFromReflection
- marked as private, meaning it can only be used within contract
- used to calculate token balance (in regular tokens, not "reflections") from given reflection balance (Reflections are often used to address issues related to token precision and fees)
- takes one parameter, rAmount, which is reflection balance to be converted to token balance
Inside function:
- checks that rAmount is less than or equal to _rTotal (the total reflections)
- calculates current exchange rate using _getRate() and then divides rAmount by current rate to get corresponding token balance
- returns token balance

function removeAllFee() private:
- private function named removeAllFee
- used to temporarily set fee variables to zero, effectively removing all fees for token transfers
Inside function:
- checks if both _redisFee and _taxFee are already zero (If they are, it returns without making any changes)
- stores current values of _redisFee and _taxFee in _previousredisFee and _previoustaxFee
- sets both _redisFee and _taxFee to zero

function restoreAllFee() private:
- private function named restoreAllFee
- used to restore fee variables to their previous values after they've been temporarily set to zero using removeAllFee
Inside function:
- sets _redisFee and _taxFee to their previous values stored in _previousredisFee and _previoustaxFee
*/
//====================================================================================================






6.5 approve, transfer 
//====================================================================================================
function _approve(
    address owner,
    address spender,
    uint256 amount
    ) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
    }
    
    function _transfer(
    address from,
    address to,
    uint256 amount
    ) private {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
//====================================================================================================
/*
_approve Function:
- responsible for approving another address (spender) to spend tokens on behalf of owner. 
- critical function for allowing controlled spending of tokens
Parameters:
owner: 
- address that approves spender to spend tokens
spender:
- address that is allowed to spend tokens on behalf of owner
amount: 
- maximum number of tokens spender is allowed to spend on behalf of owner
Visibility: private - function is only accessible within contract
Inside the function:
- checks that neither owner nor spender is zero address, which is common practice to prevent approval from or to non-existent address
- sets allowance in _allowances mapping for owner and spender to specified amount
- emits Approval event to log approval, indicating owner, spender, and allowed amount
    
_transfer Function:
- function used to transfer tokens from one address to another
- includes various checks to ensure validity of transfer
Parameters:
from: 
- address from which tokens are being transferred
to: 
- address to which tokens are being sent
amount: 
- number of tokens to be transferred
Visibility: 
private - function is only accessible within contract
Inside the function:
- checks that neither from address nor to address is zero address
- ensures that amount to be transferred is greater than zero, preventing transfers of negative or zero amounts
- all checks pass, function will execute token transfer, which should be found in code after this snippet
*/
//====================================================================================================









6.6 trading start
//====================================================================================================
if (from != owner() && to != owner()) {

    //Trade start check
    if (!tradingOpen) {
    require(from == owner(), "TOKEN: This account cannot send tokens until trading is enabled");
    }
    
    require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");
    require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!");
    
    if(to != uniswapV2Pair) {
    require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
    }
    
    uint256 contractTokenBalance = balanceOf(address(this));
    bool canSwap = contractTokenBalance >= _swapTokensAtAmount;
    
    if(contractTokenBalance >= _maxTxAmount)
    {
    contractTokenBalance = _maxTxAmount;
    }
    
    if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
    swapTokensForEth(contractTokenBalance);
    uint256 contractETHBalance = address(this).balance;
    if (contractETHBalance > 0) {
    sendETHToFee(address(this).balance);
    }
    }
    }
//====================================================================================================
/*
if (from != owner() && to != owner()):
This condition checks if neither the sender (from) nor the recipient (to) is the contract owner. If either the sender or the recipient is the owner, some of the subsequent checks and actions are bypassed.

if (!tradingOpen):
- checks if trading is currently open
- if trading is not open, function requires that sender must be contract owner to send tokens
- common practice to prevent token transfers until certain point in time

require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit"):
- checks if amount being transferred is less than or equal to maximum transaction amount (_maxTxAmount)
- if amount exceeds this limit, transaction is reverted with specified error message

require(!bots[from] && !bots[to], "TOKEN: Your account is blacklisted!"):
- checks if neither sender (from) nor recipient (to) is blacklisted account (commonly referred to as "bots")
- if either sender or recipient is blacklisted account, transaction is reverted with specified error message

if (to != uniswapV2Pair):
- condition checks if recipient is not Uniswap V2 pair contract 
If recipient is not Uniswap pair, it performs another check:
require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!") checks if the balance of the recipient after receiving the tokens would exceed a maximum wallet size (_maxWalletSize). If it would exceed this limit, the transaction is reverted.
uint256 contractTokenBalance = balanceOf(address(this));:

This line calculates the balance of tokens held by the contract itself (not owned by any address).
bool canSwap = contractTokenBalance >= _swapTokensAtAmount;:

This line sets a boolean variable canSwap to true if the contract's token balance is greater than or equal to a certain threshold _swapTokensAtAmount.

if (contractTokenBalance >= _maxTxAmount):
This condition checks if the contract's token balance exceeds the maximum transaction amount (_maxTxAmount). 
If it does, it sets the contractTokenBalance to _maxTxAmount, effectively limiting the amount available for transactions.
The following block of code checks if certain conditions are met and if so, it swaps tokens for ETH:

if (canSwap && !inSwap && from != uniswapV2Pair && swapEnabled && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]):
canSwap must be true (contract token balance is sufficient).
inSwap must be false, indicating that the contract is not currently in the process of swapping tokens (avoiding re-entrancy).
from must not be the Uniswap V2 pair (to avoid selling tokens during a buy).
swapEnabled must be true.
from and to must not be excluded from fees.
- if all these conditions are met, it calls swapTokensForEth function to swap tokens for ETH
- then checks contract's ETH balance and sends any available ETH to fee address using sendETHToFee function. 
- common mechanism for redistributing fees to designated address

- in summary, this code is series of checks and actions that help control token transfers, prevent unauthorized transfers, 
limit transaction amounts, and manage swapping of tokens for ETH, including fee distribution
- specifics of functions like swapTokensForEth and sendETHToFee are not provided in this code snippet but would be defined elsewhere in contract
*/
//====================================================================================================








6.7 auto fees set 
//====================================================================================================
bool takeFee = true;

//Transfer Tokens
if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
takeFee = false;
} else {

//Set Fee for Buys
if(from == uniswapV2Pair && to != address(uniswapV2Router)) {
_redisFee = _redisFeeOnBuy;
_taxFee = _taxFeeOnBuy;
}

//Set Fee for Sells
if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
_redisFee = _redisFeeOnSell;
_taxFee = _taxFeeOnSell;
}

}

_tokenTransfer(from, to, amount, takeFee);
}
//====================================================================================================
/*
bool takeFee = true;:

- initializes boolean variable takeFee and sets it to true
- suggests that by default, fees will be applied to token transfer
 
Condition: if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) { takeFee = false; }:
- conditional statement that determines whether fees should be applied to token transfer based on several conditions:
- checks if either sender (from) or recipient (to) is excluded from fees
- either of them is excluded, fees are not applied, and takeFee is set to false
- also checks if transfer is not between contract itself (uniswapV2Pair). 
- if transfer is not between contract and Uniswap V2 pair, fees are not applied, and takeFee is set to false
else:
- if conditions in previous if statement are not met (i.e., fees should be applied), code in else block is executed
- inside else block, code determines fee structure based on whether it's buy or sell transaction

if (from == uniswapV2Pair && to != address(uniswapV2Router)):
- condition checks if sender is Uniswap V2 pair (indicating a buy transaction) and recipient is not UniswapV2Router address
- if this condition is met, it sets _redisFee and _taxFee to values specified for buys (probably reducing fees for buy transactions)

if (to == uniswapV2Pair && from != address(uniswapV2Router)):
- checks if recipient is Uniswap V2 pair (indicating sell transaction) and sender is not UniswapV2Router address
- if this condition is met, it sets _redisFee and _taxFee to values specified for sells (probably increasing fees for sell transactions)

_tokenTransfer(from, to, amount, takeFee);:
- after determining whether fees should be applied and setting appropriate fee structure, this line calls _tokenTransfer
function with parameters from, to, amount, and takeFee variable as arguments. 
- function handles actual transfer of tokens, taking into account fee structure decided earlier 
*/
//====================================================================================================







6.8 swap 
//====================================================================================================
function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
address[] memory path = new address[](2);
path[0] = address(this);
path[1] = uniswapV2Router.WETH();
_approve(address(this), address(uniswapV2Router), tokenAmount);
uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
tokenAmount,
0,
path,
address(this),
block.timestamp
);
}

function sendETHToFee(uint256 amount) private {
_marketingAddress.transfer(amount);
}

function setTrading(bool _tradingOpen) public onlyOwner {
tradingOpen = _tradingOpen;
}

function manualswap() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractBalance = balanceOf(address(this));
swapTokensForEth(contractBalance);
}

function manualsend() external {
require(_msgSender() == _developmentAddress || _msgSender() == _marketingAddress);
uint256 contractETHBalance = address(this).balance;
sendETHToFee(contractETHBalance);
}
//====================================================================================================
/*
portal studenta - registrovany cely postup odovzdania zaverecnej prace. dobre skontrolovat zadanie (poslat skolitelovi, upravit anotaciu)
mozeme to pouzivat ako cloudove ulozisko nasej prace

swapTokensForEth(uint256 tokenAmount) private lockTheSwap:
- function allows contract to swap specified amount of tokens for ETH
- private, which means it can only be called from within contract itself
Parameters:
- tokenAmount: amount of tokens to be swapped for ETH
Modifier: 
lockTheSwap is applied, which suggests that some form of locking mechanism is in place during swap
Inside the function:
- defines array path to specify path for swap (here it's swapping tokens to WETH (Wrapped), so path consists of contract's address and WETH address)
- approves Uniswap router to spend specified tokenAmount from contract's address
- calls swapExactTokensForETHSupportingFeeOnTransferTokens function of Uniswap V2 router, swapping specified tokenAmount for ETH
- function likely interacts with Uniswap decentralized exchange to perform swap
- function doesn't return any value

sendETHToFee(uint256 amount) private:
- function is responsible for sending specified amount of ETH to fee address (probably marketing or development address)
- marked as private, so it can only be called from within contract
Parameters:
amount:
- amount of ETH to be sent to fee address
Inside function:
- uses .transfer() function to send specified amount of ETH to _marketingAddress
   
setTrading(bool _tradingOpen) public onlyOwner:
- function allows contract owner to set whether trading is open or closed
- marked as public, so it can be called externally, and it requires that caller is owner of contract
Parameters:
_tradingOpen:
- boolean flag indicating whether trading should be open (true) or closed (false)
Inside function:
- sets tradingOpen variable to value of _tradingOpen

manualswap() external:
- external function allows contract owner or specific address (development or marketing address) to manually trigger token-to-ETH swap operation
- might be useful for manually controlling token's liquidity
Inside function:
- checks that caller is either development address or marketing address
- calculates contract's token balance and then calls swapTokensForEth function to perform token-to-ETH swap
    
manualsend() external:
- similar to manualswap function
- external function allows contract owner or specific address to manually send contract's ETH balance to fee address
- function is likely used for managing and distributing collected fees
Inside function:
- checks that caller is either development address or marketing address
- calculates contract's ETH balance and then calls sendETHToFee function to send ETH to fee address
*/
//====================================================================================================






6.9 bots blocking 
//====================================================================================================
function blockBots(address[] memory bots_) public onlyOwner {
for (uint256 i = 0; i < bots_.length; i++) {
bots[bots_[i]] = true;
}
}

function unblockBot(address notbot) public onlyOwner {
bots[notbot] = false;
}
//====================================================================================================
/*
blockBots(address[] memory bots_) public onlyOwner:
- public
- takes array of addresses (bots_) as parameter
- array represents list of addresses that are suspected of being bots
- onlyOwner modifier is applied which ensures that only owner of contract can call this function
- inside function, there is loop that iterates over each address in bots_ array
- for each address in array, it sets bots mapping at that address to true (it marks each address in array as bot)

unblockBot(address notbot) public onlyOwner: 
- function is also declared as public and can be called externally
- takes single address (notbot) as parameter, which represents address that should be removed from list of suspected bots
- similar to previous function, onlyOwner modifier is applied to ensure that only owner of contract can call this function
- inside function, it sets bots mapping at provided notbot address to false
- this action effectively unblocks the specified address, indicating that it is not considered a bot anymore
*/
//====================================================================================================









6.95 
//====================================================================================================

function _tokenTransfer(
address sender,
address recipient,
uint256 amount,
bool takeFee
) private {
if (!takeFee) removeAllFee();
_transferStandard(sender, recipient, amount);
if (!takeFee) restoreAllFee();
}

function _transferStandard(
address sender,
address recipient,
uint256 tAmount
) private {
(
uint256 rAmount,
uint256 rTransferAmount,
uint256 rFee,
uint256 tTransferAmount,
uint256 tFee,
uint256 tTeam
) = _getValues(tAmount);
_rOwned[sender] = _rOwned[sender].sub(rAmount);
_rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);
_takeTeam(tTeam);
_reflectFee(rFee, tFee);
emit Transfer(sender, recipient, tTransferAmount);
}

function _takeTeam(uint256 tTeam) private {
uint256 currentRate = _getRate();
uint256 rTeam = tTeam.mul(currentRate);
_rOwned[address(this)] = _rOwned[address(this)].add(rTeam);
}

function _reflectFee(uint256 rFee, uint256 tFee) private {
_rTotal = _rTotal.sub(rFee);
_tFeeTotal = _tFeeTotal.add(tFee);
}
//====================================================================================================
/*
_tokenTransfer function:
- function responsible for transferring tokens from one address (sender) to another address (recipient) while considering whether to apply fees. 
- private 
- indicating that it can only be called from within contract
Parameters:
sender: 
- address sending tokens
recipient:
- address receiving tokens
amount: 
- amount of tokens to be transferred
takeFee:
- boolean flag that determines whether fees should be applied to this transfer
Inside function:
- if takeFee is false, it calls removeAllFee function to remove any fees for this transfer
- if then calls _transferStandard function to perform actual token transfer with specified parameters
- if takeFee is still false (indicating that fees were removed), it calls restoreAllFee function to restore fees

 _transferStandard function:
- function handles actual transfer of tokens and fee calculations
Parameters:
sender: 
- sender's address
recipient: 
- recipient's address
tAmount:
- amount of tokens to be transferred
Inside function:
- calls _getValues function to obtain values related to transfer, such as reflected amount, transfer amount, fees, and team allocation
- subtracts reflected amount (rAmount) from sender's balance and adds transferred amount (rTransferAmount) to recipient's balance
- calls _takeTeam function to handle allocation of tokens to team or other designated address
- calls _reflectFee function to update total reflected supply and total fee amount
- emits Transfer event to log transfer of tokens from sender to recipient
    
_takeTeam function:
- function is responsible for allocating portion of tokens to designated address (possibly team or specific contract address)
- used to handle specific token allocations
Parameters:
tTeam: 
- amount of tokens to be allocated
Inside function:
- calculates reflected amount of tokens to be allocated to designated address based on current rate (possibly rate of reflection to token)
- adds this reflected amount (rTeam) to the balance of the contract address (address(this))

_reflectFee function:
This function is used to update the total reflected supply and the total fee amount when fees are collected.
Parameters:
rFee: 
- amount of reflected tokens as fee
tFee: 
- amount of tokens as fee
Inside function:
- subtracts reflected fee (rFee) from total reflected supply (_rTotal)
- adds token fee amount (tFee) to total fee amount (_tFeeTotal)
*/
//====================================================================================================
    
    
    


    

6.97
//====================================================================================================
receive() external payable {}

function _getValues(uint256 tAmount)
private
view
returns (
uint256,
uint256,
uint256,
uint256,
uint256,
uint256
)
{
(uint256 tTransferAmount, uint256 tFee, uint256 tTeam) =
_getTValues(tAmount, _redisFee, _taxFee);
uint256 currentRate = _getRate();
(uint256 rAmount, uint256 rTransferAmount, uint256 rFee) =
_getRValues(tAmount, tFee, tTeam, currentRate);
return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTeam);
}

function _getTValues(
uint256 tAmount,
uint256 redisFee,
uint256 taxFee
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 tFee = tAmount.mul(redisFee).div(100);
uint256 tTeam = tAmount.mul(taxFee).div(100);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tTeam);
return (tTransferAmount, tFee, tTeam);
}

function _getRValues(
uint256 tAmount,
uint256 tFee,
uint256 tTeam,
uint256 currentRate
)
private
pure
returns (
uint256,
uint256,
uint256
)
{
uint256 rAmount = tAmount.mul(currentRate);
uint256 rFee = tFee.mul(currentRate);
uint256 rTeam = tTeam.mul(currentRate);
uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
return (rAmount, rTransferAmount, rFee);
}
//====================================================================================================
/*
receive() external payable {}:
- function external 
- receive function allows contract to receive Ether (ETH) when someone sends it directly to contract's address
- function is marked as external, meaning it can be called from outside contract, and payable indicates that it can receive Ether. 
However, this function does not contain any specific logic or operations.

_getValues(uint256 tAmount) private view returns (...):
- used to calculate various values related to token transfer.
- private 
- view 
Parameter:
tAmount:
- amount of tokens to be transferred
Inside function:
- calls _getTValues and _getRValues functions to calculate transfer amount, fees, and reflected amounts
- result is tuple of values, including rAmount, rTransferAmount, rFee, tTransferAmount, tFee, and tTeam, which represent various amounts and fees involved in transfer

_getTValues(uint256 tAmount, uint256 redisFee, uint256 taxFee) private pure returns (...):
- calculates values related to token transfers, fees, and team allocations. 
- private 
- pure (doesn't modify contract's state)
Parameters:
tAmount: 
- total amount of tokens to be transferred
redisFee:
- fee percentage to be applied as fee
taxFee: 
- fee percentage to be applied as tax
Inside function:
- calculates fee amount (tFee) and team allocation amount (tTeam) based on provided percentages
- computes transfer amount (tTransferAmount) by subtracting fee and team allocation from total amount
- function returns tuple with tTransferAmount, tFee, and tTeam
    
    
_getRValues(uint256 tAmount, uint256 tFee, uint256 tTeam, uint256 currentRate) private pure returns (...):
- calculates reflected values (in form of reflected tokens) based on provided token values
- private 
- pure
Parameters:
tAmount:
- total amount of tokens
tFee:
- fee amount in tokens
tTeam:
- team allocation amount in tokens
currentRate:
-  current rate, which may represent reflection rate
Inside function:
- calculates reflected amount (rAmount) by multiplying total token amount by current rate
- computes reflected fee amount (rFee) and reflected team allocation amount (rTeam) by multiplying respective token amounts by current rate
- calculates reflected transfer amount (rTransferAmount) by subtracting reflected fee and team allocation from reflected total amount
- function returns tuple with rAmount, rTransferAmount, and rFee
*/
//====================================================================================================









6.98
//====================================================================================================
function _getRate() private view returns (uint256) {
(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
return rSupply.div(tSupply);
}

function _getCurrentSupply() private view returns (uint256, uint256) {
uint256 rSupply = _rTotal;
uint256 tSupply = _tTotal;
if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
return (rSupply, tSupply);
}

function setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner {
_redisFeeOnBuy = redisFeeOnBuy;
_redisFeeOnSell = redisFeeOnSell;
_taxFeeOnBuy = taxFeeOnBuy;
_taxFeeOnSell = taxFeeOnSell;
}
//====================================================================================================
/*
_getRate() private view returns (uint256):
- calculates current rate of token, which is ratio of reflected supply (rSupply) to total supply (tSupply)
- returns rate as uint256 value
- rate is important factor in determining conversion between token amounts and their reflected values, especially in fee calculations
    
_getCurrentSupply() private view returns (uint256, uint256):
- function retrieves current reflected supply (rSupply) and total supply (tSupply) of token
- if reflected supply is less than calculated reflected supply based on total supply, it means there may be an issue, and function returns initial values of _rTotal and _tTotal to avoid potential problems
- it returns tuple with two uint256 values: 
reflected supply 
total supply
    
setFee(uint256 redisFeeOnBuy, uint256 redisFeeOnSell, uint256 taxFeeOnBuy, uint256 taxFeeOnSell) public onlyOwner:
- function allows contract owner to set fee parameters for different types of transactions, including buying and selling tokens
Parameters:
redisFeeOnBuy:
- fee percentage (in basis points) to be applied on buys
redisFeeOnSell: 
- fee percentage (in basis points) to be applied on sells
taxFeeOnBuy:
- fee percentage (in basis points) to be applied on buys
taxFeeOnSell:
- fee percentage (in basis points) to be applied on sells
Modifier:
onlyOwner: 
- function can only be called by owner of contract
Effect:
- sets fee parameters for buys and sells based on provided values
- these fees are often used to redistribute rewards, contribute to liquidity pools, or for other purposes as defined by token contract
*/
//====================================================================================================














6.99 
//====================================================================================================
//Set minimum tokens required to swap.
function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner {
_swapTokensAtAmount = swapTokensAtAmount;
}

//Set minimum tokens required to swap.
function toggleSwap(bool _swapEnabled) public onlyOwner {
swapEnabled = _swapEnabled;
}

//Set maximum transaction
function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
_maxTxAmount = maxTxAmount;
}

function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
_maxWalletSize = maxWalletSize;
}

function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
for(uint256 i = 0; i < accounts.length; i++) {
_isExcludedFromFee[accounts[i]] = excluded;
}
}
//====================================================================================================
/*
setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public onlyOwner:
- function allows contract owner to set minimum number of tokens required to trigger automatic swap (typically swapping tokens for ETH) 
- purpose of this function is to control when automatic swaps occur based on token balance of contract
Parameters:
swapTokensAtAmount: 
- minimum token balance at which an automatic swap should be triggered
Modifier:
onlyOwner: 
- function can only be called by owner of contract
Effect:
- sets _swapTokensAtAmount variable to  provided value, determining threshold for automatic swaps

toggleSwap(bool _swapEnabled) public onlyOwner:
- function allows contract owner to enable or disable automatic swaps 
- when swaps are enabled, contract will automatically swap tokens for ETH when conditions are met
Parameters:
_swapEnabled: 
- boolean value that determines whether automatic swaps should be enabled (true) or disabled (false)
Modifier:
onlyOwner: 
- function can only be called by owner of the contract
Effect:
- sets swapEnabled variable to provided value, controlling whether automatic swaps are active or not
    
setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner:
- function allows contract owner to set maximum transaction amount
- limits number of tokens that can be transferred in single transaction
Parameters:
maxTxAmount: 
- maximum amount of tokens allowed to be transferred in single transaction
Modifier:
onlyOwner: 
- function can only be called by owner of the contract
Effect:
- sets _maxTxAmount variable to provided value, restricting maximum transaction size
    
setMaxWalletSize(uint256 maxWalletSize) public onlyOwner:
- function allows contract owner to set maximum wallet size
- limits total number of tokens that can be held by wallet address
Parameters:
maxWalletSize: 
- maximum number of tokens wallet address can hold
Modifier:
onlyOwner: 
- function can only be called by owner of contract
Effect:
- sets _maxWalletSize variable to provided value, controlling maximum wallet size
    
excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner:
- function allows contract owner to include or exclude multiple accounts from transaction fees 
- accounts that are excluded from fees won't be subject to fees during token transfers
Parameters:
accounts: 
- array of addresses to be included or excluded from fees
excluded: 
- boolean value that determines whether accounts should be excluded (true) or included (false) from transaction fees
Modifier:
onlyOwner: 
- function can only be called by owner of contract
Effect:
- loops through provided array of addresses and sets or clears _isExcludedFromFee flag for each account based on excluded parameter
*/
//====================================================================================================
