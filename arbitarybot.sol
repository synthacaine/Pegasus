pragma solidity ^0.6.6;

import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/libraries/UniswapV2Library.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IERC20.sol";

contract Arbitrage {
  address public factory;
  uint deadline = 1658821690;
  IUniswapV2Router02 public sushiRouter;
    constructor(address _factory, address _sushiRouter) public {
    factory = _factory;  
    sushiRouter = IUniswapV2Router02(_sushiRouter);
  }
  
  function startArbitrage(
    address token0, 
    address token1, 
    uint amount0, 
    uint amount1
  ) external {
    address pairAddress = IUniswapV2Factory(factory).getPair(token0, token1);
    require(pairAddress != address(0), "There is no such pool");
    bytes memory data = abi.encode(
            token0,
            amount0,
            token0,
            false,
            false,
            bytes("no data found")
        ); // note _tokenBorrow == _tokenPay
    IUniswapV2Pair(pairAddress).swap(
      amount0, 
      amount1, 
      address(this), 
      data /**+-Makes sure that this is not empty so it will Trigger the FlashLoan.(IGNORE THIS).*/

    );
  }
  
  function uniswapV2Call(
    address _sender, 
    uint _amount0, 
    uint _amount1, 
    bytes calldata _data
  ) external {

    address[] memory path = new address[](2);
    uint amountToken = _amount0 == 0 ? _amount1 : _amount0;
    
    address token0 = IUniswapV2Pair(msg.sender).token0();
    address token1 = IUniswapV2Pair(msg.sender).token1();

    require(
      msg.sender == UniswapV2Library.pairFor(factory, token0, token1), 
      'Unauthorized'
    ); 
    require(_amount0 == 0 || _amount1 == 0);

    path[0] = _amount0 == 0 ? token1 : token0;
    path[1] = _amount0 == 0 ? token0 : token1;

    IERC20 token = IERC20(_amount0 == 0 ? token1 : token0);
    
    token.approve(address(sushiRouter), amountToken);

    uint amountRequired = UniswapV2Library.getAmountsIn(
      factory, 
      amountToken, 
      path
    )[0];
    uint amountReceived = sushiRouter.swapExactTokensForTokens(
      amountToken, 
      amountRequired, 
      path, 
      address(this), 
      block.timestamp
    )[1];

    // IERC20 otherToken = IERC20(_amount0 == 0 ? token0 : token1);
    token.transfer(msg.sender,amountRequired+1); //Reimbursh Loan
    // token.transfer(tx.origin, amountReceived - amountRequired); //Keep Profit
  }

  function getBal(address _20address) external view returns(uint256){
        IERC20 otherToken = IERC20(_20address);
        otherToken.balanceOf(address(this));

  }
}