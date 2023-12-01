https://etherscan.io/token/0xa3b7ce63001c2290d1f3b74a2d3b16a6745b0cfa
//PEXEL (PEPE) token contract code
// TokenContract3(ETF) and TokenContract2(PEXEL) are identical (from same developer)


/**
*Submitted for verification at Etherscan.io on 2023-10-19
*/

/*
I was rendered this way...

https://medium.com/@pexelcoineth/pepe-pexel-b98599a17128

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

contract Pepe is Context, IERC20, Ownable {

using SafeMath for uint256;

string private constant _name = "Pepe";
string private constant _symbol = "PEXEL";
uint8 private constant _decimals = 9;

mapping(address => uint256) private _rOwned;
mapping(address => uint256) private _tOwned;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _isExcludedFromFee;
uint256 private constant MAX = ~uint256(0);
uint256 private constant _tTotal = 420689899999994 * 10**9;
uint256 private _rTotal = (MAX - (MAX % _tTotal));
uint256 private _tFeeTotal;
uint256 private _redisFeeOnBuy = 0;
uint256 private _taxFeeOnBuy = 0;
uint256 private _redisFeeOnSell = 0;
uint256 private _taxFeeOnSell = 0;

//Original Fee
uint256 private _redisFee = _redisFeeOnSell;
uint256 private _taxFee = _taxFeeOnSell;

uint256 private _previousredisFee = _redisFee;
uint256 private _previoustaxFee = _taxFee;

mapping(address => bool) public bots; mapping (address => uint256) public _buyMap;
address payable private _developmentAddress = payable(0x6e2Fb680e61c4782a1DB460770Ff5bDC293D29F7);
address payable private _marketingAddress = payable(0x3C333Ee9E1fcc403c746432039D1aa11596DA680);

IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;
bool private tradingOpen = true;
bool private inSwap = false;
bool private swapEnabled = true;
uint256 public _maxTxAmount = 8400000000000 * 10**9;
uint256 public _maxWalletSize = 8400000000000 * 10**9;
uint256 public _swapTokensAtAmount = 4400000000000 * 10**9;


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

6.4 allowances / fees 
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

6.5 function approve / transfer
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

6.7auto fees set 
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
//====================================================================================================
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
// SPDX-License-Identifier: Unlicensed: 
- comment that specifies license under which code is released
- "Unlicensed" suggests that there may not be any specific license or that code is not intended to be used by others 
- always essential to include licensing information in your code to clarify how others can use or modify it

pragma solidity ^0.8.9;: 
- Solidity compiler directive
- tells Solidity compiler to use compiler version that is greater than or equal to 0.8.9
- compiler version specified here ensures that code will be compiled using rules and features of Solidity version 0.8.9

abstract contract Context { ... }: 
- defines abstract contract named Context
- abstract contract is contract that cannot be deployed on Ethereum blockchain but can be inherited by other contracts
- in this context, Context contract is meant to provide context-related functionality to other contracts that inherit from it

function _msgSender() internal view virtual returns (address) { ... }: 
- function definition within Context contract
here is what it does:

function _msgSender(): 
- defines function named _msgSender
- used to get Ethereum address of sender of message or transaction

internal view virtual: 
- function modifiers
internal function can be accessed only from within current contract or its derived contracts
view function does not modify contract's state; it only reads data
virtual allows derived contracts to override this function with their own implementation

returns (address): 
- specifies that function returns Ethereum address
//=========================================================================================================






2. 
//=========================================================================================================
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
//=========================================================================================================
interface IERC20 { ... }: 
- interface named IERC20
- interface is used to declare functions and events that must be implemented by any contract claiming to be ERC-20 token

function totalSupply() external view returns (uint256);: 
- function declaration within interface
- specifies that ERC-20 token must provide function called totalSupply with following characteristics:
external: 
- function can be called from outside contract
view: 
- function does not modify contract's state
- only reads data
returns (uint256): 
- returns 256-bit unsigned integer (uint256)

function balanceOf(address account) external view returns (uint256);
- specifies that ERC-20 token must provide balanceOf function
- allows querying balance of specific account

function transfer(address recipient, uint256 amount) external returns (bool);
function transfer();
- fundamental ERC-20 function that allows address to send certain amount of tokens to another address
- returns boolean value indicating whether transfer was successful

function allowance(address owner, address spender) external view returns (uint256);
- allows querying amount of tokens that owner has approved for spender to transfer from owner's account

function approve(address spender, uint256 amount) external returns (bool);: 
- used to grant permission to another address (spender) to transfer certain amount of tokens from caller's account

function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
- used to transfer tokens from one address (sender) to another (recipient)
- requires caller (msg.sender) to have received prior approval through approve function

event Transfer(address indexed from, address indexed to, uint256 value);
- event declaration
- events are emitted to log important information on blockchain
- transfer event should be emitted whenever tokens are transferred from one address to another

event Approval(address indexed owner, address indexed spender, uint256 value);
- event declaration
- approval event is emitted when owner approves spender to transfer certain amount of tokens

//=========================================================================================================







3.
//=========================================================================================================
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
contract Ownable is Context { ... }: 
- defines Solidity contract named Ownable that inherits from another contract named Context
- means Ownable contract has access to functions and variables defined in Context contract

address private _owner;: 
- declares private state variable _owner of type address, which will be used to store current owner's Ethereum address

address private _previousOwner;: 
- declares another private state variable _previousOwner of type address, which will be used to store previous owner's Ethereum address
- useful for tracking changes in ownership

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);: 
- declares event named OwnershipTransferred
- used to log ownership transfer events 
- includes addresses of previous and new owners as indexed parameters

constructor() { ... }: 
- constructor function for Ownable contract, and it is executed only once when contract is deployed
performs following actions:
- initializes _owner variable with Ethereum address of message sender (account that deploys contract)
- emits OwnershipTransferred event to indicate that ownership has been initially assigned to message sender

function owner() public view returns (address) { ... }: 
- public view function that allows external callers to retrieve current owner's address
- simply returns value of _owner variable

modifier onlyOwner() { ... }: 
- custom modifier named onlyOwner
- (Modifiers are used to add conditions to functions)
- modifier checks whether caller (message sender) is current owner (If not, it raises an error)
- if condition is met, underscore _ indicates where modified function's code should be inserted

function renounceOwnership() public virtual onlyOwner { ... }: 
- function allows current owner to renounce their ownership.
- onlyOwner modifier ensures that only current owner can call this function
performs the following actions:
- emits OwnershipTransferred event to indicate ownership transfer
- sets _owner variable to address(0) to effectively relinquish ownership

function transferOwnership(address newOwner) public virtual onlyOwner { ... }: 
- allows current owner to transfer ownership to new owner
- checks that provided newOwner address is not zero address and that caller is current owner (thanks to onlyOwner modifier)
performs following actions:
- emits OwnershipTransferred event to indicate change in ownership
- updates _owner variable with newOwner address, effectively transferring ownership

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
library SafeMath { ... }: 
- defines SafeMath library in Solidity

function add(uint256 a, uint256 b) internal pure returns (uint256) { ... }: 
- used to safely add two uint256 numbers
- takes two parameters, a and b, and returns their sum
function includes the following safety checks:
- calculates sum c of a and b
- checks whether c is greater than or equal to a
- this condition is not met, it raises error with message "SafeMath: addition overflow."
- If addition doesn't overflow, it returns result c

function sub(uint256 a, uint256 b) internal pure returns (uint256) { ... }: 
- used to safely subtract one uint256 number from another
- takes two parameters, a and b, and returns result of a - b
- function relies on another function for safety check -->

function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { ... }: 
- function performs subtraction with safety checks and custom error messages
- takes three parameters, a, b, and errorMessage
function works as follows:
- subtracts b from a to calculate c
- checks if b is less than or equal to 
- if not, it raises error with custom error message provided in errorMessage parameter
- if subtraction doesn't underflow, it returns result c

function mul(uint256 a, uint256 b) internal pure returns (uint256) { ... }: 
- safely multiplies two uint256 numbers
checks for potential multiplication overflow:
- if a is equal to 0, it immediately returns 0 to prevent multiplication overflow (Otherwise, it calculates product c of a and b)
- it then checks whether c divided by a equals b (If not, it raises error with message "SafeMath: multiplication overflow.")
- if multiplication doesn't overflow, it returns result c

function div(uint256 a, uint256 b) internal pure returns (uint256) { ... }: 
- function is used for safe division of two uint256 numbers. 
performs following checks:
- checks for division by zero by calling another function that includes custom error message
- calculates quotient c of a divided by b
- returns result c

function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) { ... }: 
This function performs division with safety check for division by zero. 
- takes three parameters, a, b, and errorMessage
works as follows:
- it checks if b is greater than 0 (non-zero)
- if b is zero, it raises an error with custom error message provided in errorMessage parameter
- if division is safe (not dividing by zero), it calculates quotient c and returns it
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
Let's break down each interface:

IUniswapV2Factory Interface:
- used to interact with Uniswap V2 Factory, which is responsible for creating and managing pairs on Uniswap exchange
Functions:

createPair(address tokenA, address tokenB) external returns (address pair): 
- used to create trading pair on Uniswap by providing addresses of two tokens, tokenA and tokenB
- returns address of created pair

IUniswapV2Router02 Interface:
- used to interact with Uniswap V2 Router, which facilitates token swaps and liquidity provision on Uniswap
functions:
swapExactTokensForETHSupportingFeeOnTransferTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external: 
- used to swap an exact amount of ERC-20 token (amountIn) for Ether (ETH)
- supports tokens with transfer fees on transfers
- function takes several parameters, including input amount, minimum output amount, path of tokens to be traded, recipient's address (to), and deadline for transaction

factory() external pure returns (address): 
- function returns address of Uniswap V2 Factory contract
- factory is responsible for creating trading pairs

WETH() external pure returns (address): 
- function returns address of Wrapped Ether (WETH) on Ethereum blockchain
- WETH is often used in decentralized exchanges to represent and trade Ether

addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity): 
- function is used to provide liquidity by depositing amount of ERC-20 token and specific amount of Ether
- takes several parameters, including token address, desired and minimum amounts of token and ETH, recipient's address (to), and deadline for transaction
- returns resulting amounts of token and ETH, as well as liquidity tokens received
//====================================================================================================







//====================================================================================================
// MAIN LONG CONTRACT 
contract Pepe is Context, IERC20, Ownable {

using SafeMath for uint256;

// name symbols and decimals 
string private constant _name = "Pepe";
string private constant _symbol = "PEXEL";
uint8 private constant _decimals = 9;

// mapping 
mapping(address => uint256) private _rOwned;
mapping(address => uint256) private _tOwned;
mapping(address => mapping(address => uint256)) private _allowances;
mapping(address => bool) private _isExcludedFromFee;
// amount of tokens 
uint256 private constant MAX = ~uint256(0);
uint256 private constant _tTotal = 420689899999994 * 10**9;
// fees 
uint256 private _rTotal = (MAX - (MAX % _tTotal));
uint256 private _tFeeTotal;
uint256 private _redisFeeOnBuy = 0;
uint256 private _taxFeeOnBuy = 0;
uint256 private _redisFeeOnSell = 0;
uint256 private _taxFeeOnSell = 0;

//Original Fee
uint256 private _redisFee = _redisFeeOnSell;
uint256 private _taxFee = _taxFeeOnSell;

uint256 private _previousredisFee = _redisFee;
uint256 private _previoustaxFee = _taxFee;

//Bots mapping & marketing and development address 
mapping(address => bool) public bots; mapping (address => uint256) public _buyMap;
address payable private _developmentAddress = payable(0x6e2Fb680e61c4782a1DB460770Ff5bDC293D29F7);
address payable private _marketingAddress = payable(0x3C333Ee9E1fcc403c746432039D1aa11596DA680);

// Uniswap interface (trading)
IUniswapV2Router02 public uniswapV2Router;
address public uniswapV2Pair;
bool private tradingOpen = true;
bool private inSwap = false;
bool private swapEnabled = true;
// Max transaction amout 
uint256 public _maxTxAmount = 8400000000000 * 10**9;
uint256 public _maxWalletSize = 8400000000000 * 10**9;
uint256 public _swapTokensAtAmount = 4400000000000 * 10**9;
}
//====================================================================================================
- contract Pepe inherits from three other contracts: 
Context, IERC20, and Ownable
- means it inherits their state variables and functions, which can be used and extended in Pepe contract

Use of SafeMath Library:
- SafeMath library is used for safe arithmetic operations with uint256 to prevent overflows and underflows

Token Properties:
_name: private constant string that defines the name of the token as "Pepe."
_symbol: private constant string that defines the symbol of the token as "PEXEL."
_decimals: private constant variable of type uint8, set to 9. 
- specifies number of decimal places for token, which is commonly used to represent fractions of token's value



Balances and Allowances:
_rOwned: 
- mapping that associates addresses with their reflected token balances
- reflected balances are used in some token designs, often for reflection and redistribution mechanisms
_tOwned: 
- mapping that associates addresses with their total token balances
_allowances: 
- mapping of mappings that stores allowances granted by one address to another, allowing spending of tokens on behalf of owner
_isExcludedFromFee: 
- mapping that keeps track of addresses that are excluded from specific fees
- can be used to exempt certain addresses from transaction fees

Constants and Maximum Values:
MAX: 
- constant variable representing maximum possible value for uint256
- bitwise negation of uint256(0), effectively representing largest possible integer value

_tTotal: 
- total supply of token is set to 420,689,899,999,994 multiplied by 10^9
- sets initial total supply with nine decimal places

_rTotal: 
- total reflected supply, which is derived from _tTotal and calculated as (MAX - (MAX % _tTotal))
- Reflected supply is used in some tokenomics models

Transaction Fees:
_redisFeeOnBuy and _taxFeeOnBuy: 
- these variables represent fees applicable to buy transactions

_redisFeeOnSell and _taxFeeOnSell: 
- these variables represent fees applicable to sell transactions
- fees are set to 0 by default but can be adjusted

// Original fee 
_redisFee and _taxFee: 
- private variables are used to store values of Redistribution fees and tax fees for token transactions
- initially set to _redisFeeOnSell and _taxFeeOnSell 
- fees can be adjusted based on whether transaction is sell or buy

_previousredisFee and _previoustaxFee: 
- private variables store previous values of Redis and tax fees
- are used to track previous fee settings



bots: 
- mapping of addresses to boolean values, which can be used to mark specific addresses as bots or non-bots
- often used to detect and handle automated trading activity

_buyMap: 
- mapping associates addresses with uint256 value
- purpose of this mapping isn't clear from provided code snippet, but it may be used to track certain properties related to buying

Development and Marketing Addresses:
_developmentAddress and _marketingAddress: 
- addresses used for development and marketing purposes
- type address payable, indicating that they can receive Ether



Uniswap Router and Pair:
uniswapV2Router: 
- holds instance of Uniswap V2 router contract (IUniswapV2Router02) and will be used for interaction with Uniswap decentralized exchange

uniswapV2Pair: 
- represents address of Uniswap V2 pair for this token
- assumed to be set once contract is deployed

Trading and Swap Settings:
tradingOpen: 
- boolean flag that determines whether trading of token is allowed
- tradingOpen is true, trading is open; if false, trading is restricted

inSwap: 
- boolean flag used to indicate whether swap operation is currently in progress

swapEnabled: 
- boolean flag that determines whether swap operation is enabled
- if swapEnabled is true, swapping tokens is allowed; if false, it is restricted

Transaction Amount Limits:
_maxTxAmount: 
- maximum amount of tokens that can be transferred in single transaction
= set to 8,400,000,000,000 times 10^9 (with nine decimal places)

_maxWalletSize: 
- represents maximum allowed balance for wallet
- set to same value as _maxTxAmount

_swapTokensAtAmount: 
- specifies threshold amount that, when reached, triggers automatic swap of tokens for Ether
//====================================================================================================
