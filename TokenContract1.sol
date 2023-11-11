// https://etherscan.io/token/0x655cfe8e28f86b9738fe04fb76c19b54bdbd46f7#code
// FC24 token contract code

/**
 *Submitted for verification at Etherscan.io on 2023-09-22
*/

// SPDX-License-Identifier: MIT


/** 

TG: https://t.me/FC24_ERC

Website: https://www.fc-24.app/

Twitter: Twitter.com/FC24_ERC

Betting Bot: https:FC24BettingBot
**/



pragma solidity 0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

//====================================================================================================
// 1.
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//=====================================================================================================


//=====================================================================================================
// 2. 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

//======================================================================================================


//======================================================================================================
// 3. 
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

}

//==========================================================================================================


//==========================================================================================================
// 4. 

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

//==========================================================================================================


//==========================================================================================================
// CONTRACT

contract FC24 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=25;
    uint256 private _reduceSellTaxAt=35;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    string private constant _name = unicode"FC24";
    string private constant _symbol = unicode"$FC24";
    uint256 public _maxTxAmount = 2000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 200000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1700000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

//====== CONTRACT PART 1

    event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }

//====== CONTRACT PART 2 <<

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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

//====== CONTRACT PART 3 <<

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

//====== CONTRACT PART 4 <<

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if(to == uniswapV2Pair && from!= address(this) ){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 50000000000000000) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

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

    function removeLimits() external onlyOwner{
        _maxTxAmount = _tTotal;
        _maxWalletSize=_tTotal;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }


    function openTrading() external onlyOwner() {
        require(!tradingOpen,"trading is already open");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenBalance=balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }
}


//====== CONTRACT PART 5 <<


//======================================================================================================
//======================================================================================================
//======================================================================================================
//======================================================================================================
//======================================================================================================






1. 
//======================================================================================================
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//========================================================================================================

function totalSupply() external view returns (uint256);
- returns the total supply of the ERC-20 token, which represents the total number of tokens that have been created.
- read-only function = view keyword(meaning it doesn't modify state of blockchain)
The return type is uint256, which is an unsigned integer representing the total supply.


function balanceOf(address account) external view returns (uint256);
- returns the token balance of a specific account or Ethereum wallet address
- takes one parameter = account(address for which you want to check token balance)
- read-only function (returns a uint256 representing the token balance of the specified account)


function transfer(address recipient, uint256 amount) external returns (bool);
- allows an account to send a certain amount of tokens to another account
- takes two parameters: recipient = address of the recipient
                        amount = number of tokens to transfer
- if the transfer is successful, it returns true 
- modifies state of the blockchain as it updates the token balances of both sender and recipient


function allowance(address owner, address spender) external view returns (uint256);
- check amount of tokens that a token owner (owner parameter) has allowed another address (spender parameter) to spend on their behalf
- read-only function and returns a uint256 value


function approve(address spender, uint256 amount) external returns (bool);
- allows an owner to grant permission to another address (the spender) to spend a certain amount of tokens from their balance.
- takes two parameters: spender = address being granted permission
                        amount = maximum number of tokens spender is allowed to transfer
- if successful returns true
- modifies the state of blockchain by updating the allowance


function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
The transferFrom function is used by a spender who has received approval to transfer tokens from the owner's balance.
It takes three parameters: sender, recipient, and amount.
If the transfer is successful, it returns true.
Like the transfer function, it modifies the state by updating the token balances of the sender and recipient.


Transfer Event:
- emitted whenever a successful token transfer occurs
parameters: from (sender address)
            to (recipient address)
            value (number of tokens transferred).


Approval Event:
- emitted when an owner approves a spender to spend a certain amount of tokens
parameters: owner (token owner address)
            spender (address being approved)
            value (allowance amount)





2. 
//=========================================================================================================
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}
//=============================================================================================================

library SafeMath;

- library safemath 
-  common pattern used in Ethereum smart contracts to perform arithmetic operations while avoiding vulnerabilities like 
integer overflow and division by zero

add Function:
function add(uint256 a, uint256 b) internal pure returns (uint256)
- function takes two uint256 (unsigned integers) as input: a and b
- performs addition operation, calculating c = a + b
- checks if c = a + b (if not it means overflow occured, and function will revert with error)

sub Function (with Error Message):
function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
- takes three parameters: a, b, and an errorMessage.
- calculates c = a - b.
require statement checks if b is less than or equal to a
- if it is not, function reverts with provided error message, indicating a subtraction overflow
- if the subtraction is safe, it returns the result c

sub Function (Without Error Message):
function sub(uint256 a, uint256 b) internal pure returns (uint256)
- this version takes only two parameters, a and b, without an error message
- convenience function for subtraction, and if an underflow occurs, it would revert with a standard error message: "SafeMath: subtraction overflow"

mul Function:
function mul(uint256 a, uint256 b) internal pure returns (uint256)
- takes two uint256 values, a and b
- performs multiplication: c = a * b 
- has an additional check to ensure that multiplying a and b does not result in an overflow
- checks if c divided by a is equal to b
- if multiplication is safe, it returns the result c

div Function (with Error Message):
function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256)
- overloaded div function 
- takes three parameters: a, b, and an errorMessage
- calculates c = a / b.
- require statement checks if b is greater than zero, if b is zero, it would result in division by zero, and function reverts with provided error message
- if division is safe (i.e., b is not zero), it returns result c

div Function (Without Error Message):
function div(uint256 a, uint256 b) internal pure returns (uint256)
- version of the div function takes only two parameters, a and b, without error message
- convenience function for division, and if division by zero occurs, it would revert with a standard error message: "SafeMath: division by zero"











3. 
//=========================================================================================================
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

}
//=========================================================================================================

The Solidity code you provided defines a contract called Ownable
- manage ownership and access control
- allows owner to perform privileged actions and transfer ownership as needed

----------------
State Variables:

address private _owner: 
- store address of contract owner

-------
Events:

event OwnershipTransferred(address indexed previousOwner, address indexed newOwner): 
- emitted when ownership of contract is transferred
- records previous owners address and new owners address

Constructor:
constructor (): 
- constructor function, which is executed once when contract is deployed
- it initializes _owner variable with address of sender who deployed contract (contract creator)
- emits an OwnershipTransferred event with address(0) as previous owner (indicating that there was no previous owner) and address of contract creator as new owner

Owner Function:
function owner() public view returns (address): 
- getter function allows external parties to query current owners address
- public visibility, can be called from outside contract, and it returns the value of _owner state variable

Modifier: 
onlyOwner:
modifier onlyOwner(): 
- custom modifier that restricts access to functions or parts of the contract to only the owner.
- checks if sender of current transaction (_msgSender()) is equal to current owner (i.e., _owner)
If sender is not owner, it reverts transaction with error message "Ownable: caller is not the owner"
If sender is owner, function or code block that uses this modifier is allowed to proceed

renounceOwnership Function:
function renounceOwnership() public virtual onlyOwner: 
- allows current owner to renounce their ownership, effectively transferring ownership to no one
- can only be called by the owner, as indicated by the onlyOwner modifier.
- (inside function) it emits an OwnershipTransferred event, transferring ownership from current owner (stored in _owner) 
to no one (address(0)), and it sets _owner to address(0), effectively removing owner






4. 
//=========================================================================================================

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}
//=========================================================================================================

- essential interfaces for interacting with Uniswap decentralized exchange in Ethereum smart contracts
- functions in these interfaces provide necessary functionality to perform swaps, create trading pairs, 
manage liquidity in the Uniswap ecosystem

1. IUniswapV2Factory Interface:
//-----------------------------------------------------------------------------------------:
interface IUniswapV2Factory {                                                            //:
    function createPair(address tokenA, address tokenB) external returns (address pair); //:
}                                                                                        //:
//-----------------------------------------------------------------------------------------:

- IUniswapV2Factory is interface that specifies a single function called createPair
- createPair is an external function, which means it can be called from outside contract that implements this interface
- takes two parameters, tokenA and tokenB, both of type address
- when called it is expected to return address ( address of newly created pair), which represents a trading pair on Uniswap exchange

2. IUniswapV2Router02 Interface:
//------------------------------------------------------------------------:
solidity                                                                //:
Copy code                                                               //:
interface IUniswapV2Router02 {                                          //:
    function swapExactTokensForETHSupportingFeeOnTransferTokens(        //:
        uint amountIn,                                                  //:
        uint amountOutMin,                                              //:
        address[] calldata path,                                        //:
        address to,                                                     //:
        uint deadline                                                   //:
    ) external;                                                         //: 
    function factory() external pure returns (address);                 //:
    function WETH() external pure returns (address);                      //:
    function addLiquidityETH(                                              //:
        address token,                                                      //:
        uint amountTokenDesired,                                             //:
        uint amountTokenMin,                                                  //: 
        uint amountETHMin,                                                     //:
        address to,                                                             //:
        uint deadline                                                            //:
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);//:
}                                                                                 //:
//----------------------------------------------------------------------------------:

- IUniswapV2Router02 is another interface that defines several functions for interacting with Uniswap Router

swapExactTokensForETHSupportingFeeOnTransferTokens: 
- used to swap an exact amount of tokens for ETH (Ether)
- takes several parameters, including input amount, minimum output amount, path of tokens to swap, recipient address, deadline

factory: 
- used to retrieve address of Uniswap Factory contract, and it returns address as a result

WETH: 
- used to retrieve the address of Wrapped Ether (WETH) token contract, and it returns address as a result

addLiquidityETH: 
- used to add liquidity to a trading pair by providing an amount of an ERC-20 token and Ether
- takes parameters such as token to add liquidity for, desired token amount, minimum token amount, minimum ETH amount, recipient address, deadline
- returns amount of tokens, amount of ETH, and amount of liquidity tokens received as a result








// Contract part 1
//=========================================================================================================
contract FC24 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private bots;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;
    address payable private _taxWallet;

    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=25;
    uint256 private _reduceSellTaxAt=35;
    uint256 private _preventSwapBefore=15;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;
    string private constant _name = unicode"FC24";
    string private constant _symbol = unicode"$FC24";
    uint256 public _maxTxAmount = 2000000 * 10**_decimals;
    uint256 public _maxWalletSize = 2000000 * 10**_decimals;
    uint256 public _taxSwapThreshold= 200000 * 10**_decimals;
    uint256 public _maxTaxSwap= 1700000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
//=========================================================================================================
/*
- code defines a token contract called "FC24" 
Inheritance and Imports:
- contract inherits from three other contracts: 
1. Context
2. IERC20
3. Ownable
- uses SafeMath library for safe mathematical operations(which you have previously inquired about)

----------------
State Variables:
- state variables initialized in contract == 
_balances: 
- mapping that tracks balance of tokens for each address
_allowances: 
- mapping to manage allowances for transferring tokens on behalf of other addresses
_isExcludedFromFee: 
- mapping to exclude specific addresses from transaction fees
bots: 
- mapping to identify bot addresses
_holderLastTransferTimestamp: 
- mapping to keep track of the last transfer timestamps for addresses
transferDelayEnabled: 
- boolean to control whether transfer delays are enabled
_taxWallet: 
- address variable for storing wallet that receives transaction taxes

----------------------
Tax-related variables:
_initialBuyTax, _initialSellTax: 
- Initial tax percentages for buys and sells
_finalBuyTax, _finalSellTax: 
- Final tax percentages for buys and sells
_reduceBuyTaxAt, _reduceSellTaxAt: 
- thresholds at which tax percentages are reduced
_preventSwapBefore: 
- threshold to prevent swaps
_buyCount:
- count of buy transactions

------------------------
Token-related variables:
_decimals: 
- number of decimal places token uses (9)
_tTotal: 
- total supply of tokens (100,000,000 tokens)
_name: 
- tokens name (FC24)
_symbol: 
- tokens symbol ($FC24)
_maxTxAmount: 
- maximum amount of tokens that can be transferred in single transaction
_maxWalletSize: 
- maximum size for an individual wallet
_taxSwapThreshold: 
- threshold for swapping tokens for taxes
_maxTaxSwap: 
- maximum number of tokens that can be swapped for taxes

--------------------------
Uniswap-related variables:
uniswapV2Router: 
- instance of Uniswap router contract
uniswapV2Pair: 
- address of Uniswap trading pair
tradingOpen: 
- boolean indicating whether trading is open
inSwap: 
- boolean to prevent recursive swaps
swapEnabled: 
- boolean to control whether swapping is enabled
*/







//Contract part 2
//=========================================================================================================
event MaxTxAmountUpdated(uint _maxTxAmount);
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxWallet] = true;

        emit Transfer(address(0), _msgSender(), _tTotal);
    }
//=========================================================================================================
/*
- code defines an event for updating maximum transaction amount, a modifier for managing reentrant calls in functions, and constructor that sets initial values and configurations for FC24 token contract
- constructor initializes tokens total supply and distributes initial tokens to contract creator while excluding certain addresses from transaction fees


MaxTxAmountUpdated Event:
- ethereum event declaration
- events are a way for a contract to communicate with external consumers, such as user interfaces or other smart contracts
- MaxTxAmountUpdated event is declared with a single parameter, _maxTxAmount, which represents the updated maximum transaction amount
- event is used to log and announce updates to maximum transaction amount to external systems for transparency and monitoring

lockTheSwap Modifier:
- modifier in Solidity is a piece of reusable code that can be applied to functions in a contract to add additional behavior
- lockTheSwap modifier does the following:
- sets inSwap variable to true at beginning of function that uses this modifier
- executes code within function (denoted by the _;)
- sets inSwap variable back to false after function's code has executed
- typically used to protect functions from reentrant calls, ensuring that certain operations are not executed concurrently

Constructor:
- constructor is a special function in a Solidity contract that is executed only once during contract deployment
- initializes contract's state variables and is often used for setting up initial values
constructor performs following tasks:
- sets _taxWallet variable by casting deployer's address (retrieved using _msgSender()) to payable address
- initializes balance of deployer's address (the contract creator) with total supply _tTotal
- excludes contract owner (owner()), contract itself (address(this)), and _taxWallet from transaction fees
- these addresses are not fee applicable 
- transfer event is emmitted of total supply from address 0 to deployers address 
*/






//Contract part 3
//=========================================================================================================
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
    return _balances[account];
}

function transfer(address recipient, uint256 amount) public override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
}

function allowance(address owner, address spender) public view override returns (uint256) {
    return _allowances[owner][spender];
}

function approve(address spender, uint256 amount) public override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
}
//=========================================================================================================

- defines various functions 
- overrides ERC-20 standard interface
- enable standard operations like querying balances, transferring tokens, approving spending limits for others

Functions: 

name() public pure returns (string memory): 
- returns name of token
- marked as pure because name doesnt change and is not dependent on state of contract
- returns value stored in _name variable

symbol() public pure returns (string memory): 
- similar to name() function
- this one returns symbol of token, which is usually a shorter representation of tokens name
- returns value stored in _symbol variable

decimals() public pure returns (uint8): 
- returns number of decimals used for token
- Decimals determine how many decimal places are used in representing token values
- returns the value stored in the _decimals variable

totalSupply() public pure override returns (uint256): 
- returns total supply of token, which is constant value
- marked as override to fulfill ERC-20 interface
- returns value stored in _tTotal variable

balanceOf(address account) public view override returns (uint256): 
- returns balance of a specific account (address)
- marked as view because it doesn't modify contract's state
- overrides standard ERC-20 balanceOf function and returns balance stored in _balances mapping for given account

transfer(address recipient, uint256 amount) public override returns (bool): 
- allows the sender to transfer a certain amount of tokens to a specified recipient
- marked as override to fulfill ERC-20 interface
- calls internal _transfer function to perform transfer, and if successful, returns true

allowance(address owner, address spender) public view override returns (uint256): 
- returns remaining allowance that spender is allowed to spend on behalf of owner
- marked as view and overrides standard ERC-20 allowance function
- queries allowance from _allowances mapping

approve(address spender, uint256 amount) public override returns (bool): 
- allows an owner to approve spender to spend a certain amount of tokens on their behalf
- marked as override and calls internal _approve function to set allowance
- if successful, returns true









// COntract part 4
//=========================================================================================================
function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
    return true;
}

function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}
//=========================================================================================================


transferFrom 
- enables spending on behalf of another address while ensuring allowance is not exceeded
_approve 
- used internally to manage allowances.


function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool): 
- used to transfer tokens from one address (the sender) to another address (the recipient)
- checks and updates allowance that sender has given to caller (_msgSender())
sender: - address from which tokens are being transferred
recipient: - address to which tokens are being transferred
amount: - number of tokens to transfer
- function does following:
1. calls internal _transfer function to transfer specified amount of tokens from sender to recipient
2. calls internal _approve function to update allowance of sender
3. decreases allowance by transferred amount
4. checks if allowance is sufficient to cover transfer and throws an error if it's not (i.e., "ERC20: transfer amount exceeds allowance")
5. Returns true if transfer is successful


function _approve(address owner, address spender, uint256 amount) private: 
- used to set or update allowance for a spender
- not meant to be called directly by external users but is called by other functions within contract
owner: - address that approves allowance
spender: - address to which allowance is given
amount: - amount of tokens to allow spender to spend
- function performs following tasks:
1. checks that neither owner nor spender addresses are zero address (address(0)), ensuring that approvals are made to and from valid addresses
2. updates _allowances mapping to record new allowance for spender
3. emits an Approval event to log approval details, including owner, spender, and approved amount








// Contract part 5 (probably will need to be sequenced into more parts)
//=========================================================================================================
function _transfer(address from, address to, uint256 amount) private {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    uint256 taxAmount=0;
    if (from != owner() && to != owner()) {
        taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

        if (transferDelayEnabled) {
              if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                  require(
                      _holderLastTransferTimestamp[tx.origin] <
                          block.number,
                      "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                  );
                  _holderLastTransferTimestamp[tx.origin] = block.number;
              }
          }

        if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
            require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }

        if(to == uniswapV2Pair && from!= address(this) ){
            taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
            swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 50000000000000000) {
                sendETHToFee(address(this).balance);
            }
        }
    }

    if(taxAmount>0){
      _balances[address(this)]=_balances[address(this)].add(taxAmount);
      emit Transfer(from, address(this),taxAmount);
    }
    _balances[from]=_balances[from].sub(amount);
    _balances[to]=_balances[to].add(amount.sub(taxAmount));
    emit Transfer(from, to, amount.sub(taxAmount));
}


function min(uint256 a, uint256 b) private pure returns (uint256){
  return (a>b)?b:a;
}

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

function removeLimits() external onlyOwner{
    _maxTxAmount = _tTotal;
    _maxWalletSize=_tTotal;
    transferDelayEnabled=false;
    emit MaxTxAmountUpdated(_tTotal);
}

function sendETHToFee(uint256 amount) private {
    _taxWallet.transfer(amount);
}


function openTrading() external onlyOwner() {
    require(!tradingOpen,"trading is already open");
    uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    _approve(address(this), address(uniswapV2Router), _tTotal);
    uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
    uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
    IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    swapEnabled = true;
    tradingOpen = true;
}

receive() external payable {}

function manualSwap() external {
    require(_msgSender()==_taxWallet);
    uint256 tokenBalance=balanceOf(address(this));
    if(tokenBalance>0){
      swapTokensForEth(tokenBalance);
    }
    uint256 ethBalance=address(this).balance;
    if(ethBalance>0){
      sendETHToFee(ethBalance);
    }
}
}
//=========================================================================================================


// ================================= 5.1 
function _transfer(address from, address to, uint256 amount) private {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    uint256 taxAmount=0;
    if (from != owner() && to != owner()) {
        taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);

        if (transferDelayEnabled) {
              if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                  require(
                      _holderLastTransferTimestamp[tx.origin] <
                          block.number,
                      "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                  );
                  _holderLastTransferTimestamp[tx.origin] = block.number;
              }
          }

        if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to] ) {
            require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }

        if(to == uniswapV2Pair && from!= address(this) ){
            taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && to   == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _buyCount>_preventSwapBefore) {
            swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
            uint256 contractETHBalance = address(this).balance;
            if(contractETHBalance > 50000000000000000) {
                sendETHToFee(address(this).balance);
            }
        }
    }

    if(taxAmount>0){
      _balances[address(this)]=_balances[address(this)].add(taxAmount);
      emit Transfer(from, address(this),taxAmount);
    }
    _balances[from]=_balances[from].sub(amount);
    _balances[to]=_balances[to].add(amount.sub(taxAmount));
    emit Transfer(from, to, amount.sub(taxAmount));
}
// Part 5.1 -----------------
- handle transfers of tokens between addresses
- features related to fees, anti-bot measures, liquidity management  
- ensures transfer meets specific conditions and updates balances accordingly


_transfer function:
//-------------------------------------------------------------------------
function _transfer(address from, address to, uint256 amount) private {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "Transfer amount must be greater than zero");
    uint256 taxAmount = 0;
//-------------------------------------------------------------------------
- function begins by checking that source (from) and destination (to) addresses are not zero
ensuring that transfer does not involve invalid addresses
- checks that transfer amount is greater than zero
- uint256 taxAmount is initialized to zero
- this variable will hold the amount of tokens deducted as a fee from the transfer


//---------------------------------------------
    if (from != owner() && to != owner()) {
//---------------------------------------------
- code then checks if neither source nor destination is contract owner (the token creator)
If they are not, it implies that transfer is a regular user-to-user transaction, and fee logic will be applied
//---------------------------------------------------------------------------------------------------
        taxAmount = amount.mul((_buyCount > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);
//---------------------------------------------------------------------------------------------------
- tax amount is calculated based on transfer amount (amount)
- tax is determined by _buyCount, with different tax rates for initial and final buy tax
- if _buyCount is greater than _reduceBuyTaxAt, _finalBuyTax is applied; otherwise, _initialBuyTax is applied
- tax amount is calculated as a percentage of transfer amount and stored in taxAmount


//---------------------------------------------------------------------------------------------------
        if (transferDelayEnabled) {
            if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                require(
                    _holderLastTransferTimestamp[tx.origin] < block.number,
                    "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                );
                _holderLastTransferTimestamp[tx.origin] = block.number;
            }
        }
//-----------------------------------------------------------------------------------------------------
- transferDelayEnabled == true, ensures that transfer only occurs once per block
- checks if to address is not Uniswap router or pair and validates that senders (tx.origin) last transfer timestamp is less than current block number
- anti-bot measure to prevent rapid and excessive trading
//--------------------------------------------------------------------------------------------------
        if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
            require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
            require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the maxWalletSize.");
            _buyCount++;
        }
//--------------------------------------------------------------------------------------------------
- from address is Uniswap pair (indicating a sale) and to address is not Uniswap router and recipient is not excluded from fees, it imposes restrictions
- checks if transfer amount does not exceed _maxTxAmount
- checks if balance of recipients wallet (including transferred amount) does not exceed _maxWalletSize
- increments _buyCount to keep track of purchases
//---------------------------------------------------------------------------------------------------------
        if (to == uniswapV2Pair && from != address(this)) {
            taxAmount = amount.mul((_buyCount > _reduceSellTaxAt) ? _finalSellTax : _initialSellTax).div(100);
        }
//---------------------------------------------------------------------------------------------------------
- if to address is Uniswap pair (indicating a sale) and from address is not token contract itself, a different tax rate is applied
- tax amount is calculated similarly to buy tax based on _buyCount, using _finalSellTax or _initialSellTax
//---------------------------------------------------------------------------------------------------------
        uint256 contractTokenBalance = balanceOf(address(this));
        if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
            swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 50000000000000000) {
                sendETHToFee(address(this).balance);
            }
        }
    }
//---------------------------------------------------------------------------------------------------------
- this code checks if transfer is made to Uniswap pair (to == uniswapV2Pair) and meets several conditions:
!inSwap: 
- Ensures swap process is not already in progress
swapEnabled: 
- indicates token swaps are allowed
- sufficient contractTokenBalance to perform swaps
- _buyCount is greater than _preventSwapBefore
- if all conditions are met, it invokes the swapTokensForEth function to exchange tokens for Ether, ensuring that swap size 
is capped at the smaller of amount, contractTokenBalance, or _maxTaxSwap
- after swapping, it checks if contract has accumulated a significant balance of Ether (contractETHBalance > 50000000000000000) and sends it to a designated fee wallet using sendETHToFee function
//---------------------------------------------------------------------------------------------------------
    if (taxAmount > 0) {
        _balances[address(this)] = _balances[address(this)].add(taxAmount);
        emit Transfer(from, address(this), taxAmount);
    }

    _balances[from] = _balances[from].sub(amount);
    _balances[to] = _balances[to].add(amount.sub(taxAmount));
    emit Transfer(from, to, amount.sub(taxAmount));
}
//---------------------------------------------------------------------------------------------------------
- if taxAmount is greater than zero (indicating fee is applied), it increases the token balance of contract (_balances[address(this)]) 
by taxAmount and emits a Transfer event from from to contract address, representing fee transfer
- it then updates balances of from and to addresses by subtracting transferred amount from sender and adding it to recipient
- transfer is adjusted to account for deducted taxAmount, and another Transfer event is emitted






// Part 5.2 -----------------
function min(uint256 a, uint256 b) private pure returns (uint256){
  return (a>b)?b:a;
}

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
// Part 5.2 -----------------

This part of code includes two functions: 
1. min (ensure that amount to swap doesnt exceed certain limits)
2. swapTokensForEth (prevents reentrancy issues by ensuring that only one swap can occur at time)
both used to facilitate swapping of tokens for (ETH) on Uniswap DEX
- swapTokensForEth function prepares token contract to swap tokens for Ether on Uniswap
- sets up swap route, approves router to spend tokens, and initiates swap 


//----------------------------------------------------------------------
min Function:
function min(uint256 a, uint256 b) private pure returns (uint256){
  return (a > b) ? b : a;
}
//----------------------------------------------------------------------
- takes two uint256 values, a and b, and returns smaller of two values
- If a is greater than b, it returns b; otherwise, it returns a. 
This function is used later in the swapTokensForEth function to determine the amount to swap, ensuring that it doesn't exceed certain limits.

swapTokensForEth Function:
//----------------------------------------------------------------------
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
//----------------------------------------------------------------------
- responsible for swapping tokens for Eth
- uses Uniswap V2 Router contract (uniswapV2Router) to facilitate swap
function step by step:
uint256 tokenAmount: 
- represents amount of tokens to be swapped for Eth
private lockTheSwap: 
- lockTheSwap modifier is applied to this function, ensuring that only one swap can occur at time to prevent reentrancy issues
address[] memory path = new address[](2): 
- array of addresses is created with a length of 2
- this path array defines swap route, indicating that swap will occur from token contract (address(this)) to WETH (Wrapped Ether)
_approve(address(this), address(uniswapV2Router), tokenAmount): 
- approves Uniswap V2 Router to spend tokenAmount of tokens on behalf of token contract
- essential to approve router to spend tokens before swapping

uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(...): 
- function initiates token-to-ETH swap using Uniswap V2 Router
following parameters:
tokenAmount: 
- amount of tokens to swap
0: 
- minimum amount of ETH to receive (it's set to 0)
path: 
- swap route defined earlier
address(this): 
- address to receive swapped ETH (in this case, token contract itself)
block.timestamp: 
- timestamp at which swap is executed





//=================== 5.3 
function removeLimits() external onlyOwner{
    _maxTxAmount = _tTotal;
    _maxWalletSize=_tTotal;
    transferDelayEnabled=false;
    emit MaxTxAmountUpdated(_tTotal);
}

function sendETHToFee(uint256 amount) private {
    _taxWallet.transfer(amount);
}
// =================== 5.3 
 
- functions part of a token contract 
- used to manage certain limitations 
- transfer Ether to a fee collection wallet
function removeLimits():
- removeLimits is function that allows owner to remove limitations on transfers, set maximum transfer amount and wallet size 
to total supply, and disable transfer delay
sendETHToFee Function:
- private function used to transfer collected Ether to fee collection wallet, which is often managed by project or contract owner
It is common practice collect fees in fee wallet for various purposes, such as project development or liquidity provisioning


removeLimits Function:
//-------------------------------------------
function removeLimits() external onlyOwner {
    _maxTxAmount = _tTotal;
    _maxWalletSize = _tTotal;
    transferDelayEnabled = false;
    emit MaxTxAmountUpdated(_tTotal);
}
//-------------------------------------------
- function allows owner of token contract to remove certain limitations that were previously imposed on token transfers 
external: 
- can be called externally by anyone, but it includes onlyOwner modifier, ensuring that only owner of contract can execute it
onlyOwner: 
- modifier that restricts function's execution to only owner of contract
_maxTxAmount = _tTotal;: 
- sets maximum transfer amount (_maxTxAmount) to total supply of token (_tTotal)
- removes any restrictions on maximum transfer amount
_maxWalletSize = _tTotal;: 
- sets the maximum wallet size (_maxWalletSize) to total supply of token, removing restrictions on maximum wallet size
transferDelayEnabled = false;: 
- disables transfer delay feature by setting transferDelayEnabled to false
- allows for immediate transfers without any delay restrictions
emit MaxTxAmountUpdated(_tTotal);: 
- emitted to signal that maximum transfer amount has been updated, it is set to total supply of token

//_-------------------------------------------------
sendETHToFee Function:
function sendETHToFee(uint256 amount) private {
    _taxWallet.transfer(amount);
}
//--------------------------------------------------
- used to transfer (ETH) to fee collection wallet
private: 
- marked as private, which means it can only be called from within contract itself(typically used for internal contract operations)
amount: 
- takes an amount parameter, which represents amount of Ether to be transferred to fee collection wallet
_taxWallet.transfer(amount);: 
- transfers specified amount of Ether from contract to the _taxWallet
- _taxWallet is typically address responsible for collecting fees generated by contract



