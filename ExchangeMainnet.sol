// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
    Mainnet instances:
    - Uniswap V2 Router:                         0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    - Sushiswap V1 Router:                       0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F
    - Shibaswap V1 Router:                       0x03f7724180AA6b939894B5Ca4314783B0b36b329
    - UNI:                                       0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984  // exists on Sushi
    - USDT:                                      0xdAC17F958D2ee523a2206206994597C13D831ec7
    - DAI:                                       0x6B175474E89094C44Da98b954EedeAC495271d0F // Triangular 1000000000
    - WETH:                                      0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6 // Simple 10000000000000
    - Aave LendingPoolAddressesProvider(Mainnet):0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5
*/

/**
    Goerli instances:
    - Uniswap V2 Router:                         0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    - Sushiswap V1 Router:                       0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
    - Shibaswap V1 Router:                       0x03f7724180AA6b939894B5Ca4314783B0b36b329
    - UNI:                                       0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984  // exists on Sushi
    - USDT:                                      0xaa34a2eE8Be136f0eeD223C9Ec8D4F2d0BC472dd
    - DAI:                                       0xdc31Ee1784292379Fbb2964b3B9C4124D8F89C60 // Triangular 1000000000
    - WETH:                                      0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6 // Simple 10000000000000
    - Aave LendingPoolAddressesProvider(kovan):  0x5E52dEc931FFb32f609681B8438A51c675cc232d
    
*/

/**
    Kovan instances:
    - Uniswap V2 Router:                         0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    - Sushiswap V1 Router:                       0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
    - UNI:                                       0x075A36BA8846C6B6F53644fDd3bf17E5151789DC
    - USDT:                                      0x13512979ADE267AB5100878E2e0f485B568328a4
    - BUSD:                                      0x4c6E1EFC12FDfD568186b7BAEc0A43fFfb4bCcCf 
    - DAI:                                       0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD
    - WETH:                                      0xd0A1E359811322d97991E03f863a0C30C2cF029C
    - Aave LendingPoolAddressesProvider(kovan):  0x88757f2f99175387aB4C6a4b3067c77A695b0349
    
*/

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// File: @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol


interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// File: https://github.com/aave/protocol-v2/blob/master/contracts/dependencies/openzeppelin/contracts/Address.sol

/**
 * @dev Collection of functions related to the address type
 */
library Address {
  /**
   * @dev Returns true if `account` is a contract.
   *
   * [IMPORTANT]
   * ====
   * It is unsafe to assume that an address for which this function returns
   * false is an externally-owned account (EOA) and not a contract.
   *
   * Among others, `isContract` will return false for the following
   * types of addresses:
   *
   *  - an externally-owned account
   *  - a contract in construction
   *  - an address where a contract will be created
   *  - an address where a contract lived, but was destroyed
   * ====
   */
  function isContract(address account) internal view returns (bool) {
    // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
    // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
    // for accounts without code, i.e. `keccak256('')`
    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      codehash := extcodehash(account)
    }
    return (codehash != accountHash && codehash != 0x0);
  }

  /**
   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
   * `recipient`, forwarding all available gas and reverting on errors.
   *
   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
   * of certain opcodes, possibly making contracts go over the 2300 gas limit
   * imposed by `transfer`, making them unable to receive funds via
   * `transfer`. {sendValue} removes this limitation.
   *
   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
   *
   * IMPORTANT: because control is transferred to `recipient`, care must be
   * taken to not create reentrancy vulnerabilities. Consider using
   * {ReentrancyGuard} or the
   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
   */
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, 'Address: insufficient balance');

    // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
    (bool success, ) = recipient.call{value: amount}('');
    require(success, 'Address: unable to send value, recipient may have reverted');
  }
}

// File: https://github.com/aave/protocol-v2/blob/master/contracts/dependencies/openzeppelin/contracts/IERC20.sol

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: https://github.com/aave/protocol-v2/blob/master/contracts/dependencies/openzeppelin/contracts/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `+` operator.
   *
   * Requirements:
   * - Addition cannot overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath: addition overflow');

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, 'SafeMath: subtraction overflow');
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
   * overflow (when the result is negative).
   *
   * Counterpart to Solidity's `-` operator.
   *
   * Requirements:
   * - Subtraction cannot overflow.
   */
  function sub(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
   * overflow.
   *
   * Counterpart to Solidity's `*` operator.
   *
   * Requirements:
   * - Multiplication cannot overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, 'SafeMath: multiplication overflow');

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, 'SafeMath: division by zero');
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
   * division by zero. The result is rounded towards zero.
   *
   * Counterpart to Solidity's `/` operator. Note: this function uses a
   * `revert` opcode (which leaves remaining gas untouched) while Solidity
   * uses an invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function div(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, 'SafeMath: modulo by zero');
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
   * Reverts with custom message when dividing by zero.
   *
   * Counterpart to Solidity's `%` operator. This function uses a `revert`
   * opcode (which leaves remaining gas untouched) while Solidity uses an
   * invalid opcode to revert (consuming all remaining gas).
   *
   * Requirements:
   * - The divisor cannot be zero.
   */
  function mod(
    uint256 a,
    uint256 b,
    string memory errorMessage
  ) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// File: https://github.com/aave/protocol-v2/blob/master/contracts/dependencies/openzeppelin/contracts/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  using SafeMath for uint256;
  using Address for address;

  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
  }

  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      'SafeERC20: approve from non-zero to non-zero allowance'
    );
    callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
  }

  function callOptionalReturn(IERC20 token, bytes memory data) private {
    require(address(token).isContract(), 'SafeERC20: call to non-contract');

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory returndata) = address(token).call(data);
    require(success, 'SafeERC20: low-level call failed');

    if (returndata.length > 0) {
      // Return data is optional
      // solhint-disable-next-line max-line-length
      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');
    }
  }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor()public {
        owner = msg.sender;
    }
 
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner,"Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
}

contract SimpleSwap is Ownable {

    enum Exchange {
        EXCA,
        EXCB,
        NONE
    }    


    constructor() public {
    }

    function exchangeTokens(address _exchange, address _tokenA, address _tokenB, uint256 _amountIn) public payable {

        uint256 amountIn = 0;
        if(_tokenA == address(0)) {
          amountIn = msg.value;
        } else {
          amountIn = _amountIn; 
          IERC20(_tokenA).transferFrom(msg.sender, address(this), amountIn);
        }

        // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
        uint256 amountOut = _swap(
            amountIn,
            _exchange,
            _tokenA,
            _tokenB
        );

        uint256 amountOut_ = _swap(amountOut, _exchange, _tokenB, _tokenA);

        require(amountOut_ >= amountIn, "Trade Reverted, Arbitrage not profitable");

        if(_tokenA == address(0)) {
            payable(msg.sender).transfer(amountOut_);
        } else {
            IERC20(_tokenA).transfer(msg.sender, amountOut_);
        }
    }

    function _swap(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) internal returns (uint256) {

        address WETH = IUniswapV2Router02(routerAddress).WETH();
        
        if(sell_token == address(0)) {

            sell_token = WETH;

            // IERC20(sell_token).approve(routerAddress, amountIn);

            uint256 amountOutMin = (_getAmountOut(
                routerAddress,
                sell_token,
                buy_token,
                amountIn
            ) * 95) / 100;

            address[] memory path = new address[](2);
            path[0] = sell_token;
            path[1] = buy_token;

            uint256 amountOut = IUniswapV2Router02(routerAddress)
                .swapExactETHForTokens{value : amountIn}(
                    amountOutMin,
                    path,
                    address(this),
                    block.timestamp + 15 minutes
                )[1];

            // IERC20(buy_token).transfer(msg.sender, amountOut);

            return amountOut;

        } else if(buy_token == address(0)) {

            buy_token = WETH;

            IERC20(sell_token).approve(routerAddress, amountIn);

            uint256 amountOutMin = (_getAmountOut(
                routerAddress,
                sell_token,
                buy_token,
                amountIn
            ) * 95) / 100;

            address[] memory path = new address[](2);
            path[0] = sell_token;
            path[1] = buy_token;

            uint256 amountOut = IUniswapV2Router02(routerAddress)
                .swapExactTokensForETH(
                    amountIn,
                    amountOutMin,
                    path,
                    address(this),
                    block.timestamp + 15 minutes
                )[1];

            return amountOut;

        } else {
            IERC20(sell_token).approve(routerAddress, amountIn);

            uint256 amountOutMin = (_getAmountOut(
                routerAddress,
                sell_token,
                buy_token,
                amountIn
            ) * 95) / 100;

            address[] memory path = new address[](2);
            path[0] = sell_token;
            path[1] = buy_token;

            uint256 amountOut = IUniswapV2Router02(routerAddress)
                .swapExactTokensForTokens(
                    amountIn,
                    amountOutMin,
                    path,
                    address(this),
                    block.timestamp + 15 minutes
                )[1];

            return amountOut;
        }
    }

    function getTokenBalance(address _erc20Address)
        public
        view
        returns (uint256)
    {
        return IERC20(_erc20Address).balanceOf(address(this));
    }

    function getETHBalance()
        public
        view
        returns (uint256)
    {
        return address(this).balance;
    }

    function withdrawERC(address _tokenAddress, uint256 amount) public onlyOwner {
        uint256 erc20Balance = getTokenBalance(_tokenAddress);
        require(amount <= erc20Balance, "Not enough balance");
        IERC20(_tokenAddress).transfer(msg.sender, amount);
    }

    function withdrawETH(uint256 amount) public onlyOwner {
        uint256 ethBalance = getETHBalance();
        require(amount <= ethBalance, "Not enough balance");
        payable(owner).transfer(amount);
    }

    function _checkIfArbitrageIsProfitable(
        uint256 amountIn,
        uint256 higherPrice,
        uint256 lowerPrice
    ) internal pure returns (bool) {
        // uniswap & sushiswap have 0.3% fee for every exchange
        // so gain made must be greater than 2 * 0.3% * arbitrage_amount

        // difference in ETH
        uint256 difference = ((higherPrice - lowerPrice) * 10**18) /
            higherPrice;

        uint256 payed_fee = (amountIn * 3) / 1000;

        if (difference > payed_fee) {
            return true;
        } else {
            return false;
        }
    }

    function _swapPrice(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) internal view returns (uint256) {

        address WETH = IUniswapV2Router02(routerAddress).WETH();
        
        if(sell_token == address(0)) {
            sell_token = WETH;
        } else if(buy_token == address(0)) {
            buy_token = WETH;
        }             
        
        uint256 amountOutMin = (_getAmountOut(
            routerAddress,
            sell_token,
            buy_token,
            amountIn
        ) * 95) / 100;

        return amountOutMin;
        
    }

    function _getAmountOut(
        address routerAddress,
        address sell_token,
        address buy_token,
        uint256 amount
    ) internal view returns (uint256) {
        address[] memory pairs = new address[](2);
        pairs[0] = sell_token;
        pairs[1] = buy_token;
        uint256 price = IUniswapV2Router02(routerAddress).getAmountsOut(
            amount,
            pairs
        )[1];
        return price;
    }

    function _comparePrice(address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, uint256 amount) internal view returns (Exchange) {
        
        address WETH = IUniswapV2Router02(_exchangeA).WETH();
        
        if(_tokenA == address(0)) _tokenA = WETH;
        else if(_tokenB == address(0)) _tokenB = WETH;

        uint256 exchangeAPrice = _getAmountOut(
            _exchangeA,
            _tokenA,
            _tokenB,
            amount
        );
        uint256 exchangeBPrice = _getAmountOut(
            _exchangeB,
            _tokenA,
            _tokenB,
            amount
        );

        // we try to sell ETH with higher price and buy it back with low price to make profit
        if (exchangeAPrice > exchangeBPrice) {
            if(_checkIfArbitrageIsProfitable(amount, exchangeAPrice, exchangeBPrice)) {
                return Exchange.EXCA;
            } else {
                return Exchange.NONE;
            }
        } else if (exchangeAPrice < exchangeBPrice) {
            if(_checkIfArbitrageIsProfitable(amount, exchangeBPrice, exchangeAPrice)) {
                return Exchange.EXCB;
            } else {
                return Exchange.NONE;
            }
        } else {
            return Exchange.NONE;
        }
    }

    function getPriceSimple(address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, uint256 amountIn) public view returns(bool, uint256) {
        
        uint256 amountOut = 0;
        uint256 amountOut_ = 0;

        Exchange result = _comparePrice(_exchangeA, _exchangeB, _tokenA, _tokenB, amountIn);    // loan amountIn
        if (result == Exchange.EXCA) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            amountOut = _swapPrice(
                amountIn,
                _exchangeA,
                _tokenA,
                _tokenB
            );

        } else if (result == Exchange.EXCB) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            amountOut = _swapPrice(
                amountIn,
                _exchangeB,
                _tokenA,
                _tokenB
            );
        } else {
          return(false, 0);
        }

        Exchange result_ = _comparePrice(_exchangeA, _exchangeB, _tokenB, _tokenA, amountOut);    // loan amountIn

        if (result_ == Exchange.EXCA) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            amountOut_ = _swapPrice(
                amountOut,
                _exchangeA,
                _tokenB,
                _tokenA
            );
        } else if (result_ == Exchange.EXCB) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            amountOut_ = _swapPrice(
                amountOut,
                _exchangeB,
                _tokenB,
                _tokenA
            );
        } else {
          return(false, 0);
        }

        if(amountOut_ > amountIn) {
            return (true, amountOut_); 
        }
        else {
            return(false, 0);
        }
    }

    function getPriceTriangular(address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, address _tokenC, uint256 amountIn) public view returns(bool, uint256) {
        
        uint256 amountOut = 0;
        uint256 amountOut_ = 0;
        uint256 _amountOut_ = 0;

        Exchange result = _comparePrice(_exchangeA, _exchangeB, _tokenA, _tokenB, amountIn);    // loan amountIn    // loan amountIn
        if (result == Exchange.EXCA) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            amountOut = _swapPrice(
                amountIn,
                _exchangeA,
                _tokenA,
                _tokenB
            );
        } else if (result == Exchange.EXCB) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            amountOut = _swapPrice(
                amountIn,
                _exchangeB,
                _tokenA,
                _tokenB
            );
        } else {
          return(false, 0);
        }

        Exchange result_ = _comparePrice(_exchangeA, _exchangeB, _tokenB, _tokenC, amountOut);    // loan amountIn
        if (result_ == Exchange.EXCA) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            amountOut_ = _swapPrice(
                amountOut,
                _exchangeA,
                _tokenB,
                _tokenC
            );
        } else if (result_ == Exchange.EXCB) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            amountOut_ = _swapPrice(
                amountOut,
                _exchangeB,
                _tokenB,
                _tokenC
            );
        } else {
          return(false, 0);
        }

        Exchange _result_ = _comparePrice(_exchangeA, _exchangeB, _tokenC, _tokenA, amountOut_);    // loan amountIn
        if (_result_ == Exchange.EXCA) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            _amountOut_ = _swapPrice(
                amountOut_,
                _exchangeA,
                _tokenC,
                _tokenA
            );
        } else if (_result_ == Exchange.EXCB) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            _amountOut_ = _swapPrice(
                amountOut_,
                _exchangeB,
                _tokenC,
                _tokenA
            );
        } else {
          return(false, 0);
        }

        if(_amountOut_ > amountIn) {
            return (true, _amountOut_); 
        }
        else {
            return(false, 0);
        }
    }

    receive() external payable {}

}
