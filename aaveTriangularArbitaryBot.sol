// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
    Kovan instances:
    - Uniswap V2 Router:                         0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    - Sushiswap V1 Router:                       0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
    - swapToken(UNI):                            0x075A36BA8846C6B6F53644fDd3bf17E5151789DC
    - loanToken(USDT):                           0x13512979ADE267AB5100878E2e0f485B568328a4
    - Aave LendingPoolAddressesProvider(kovan):  0x88757f2f99175387aB4C6a4b3067c77A695b0349
    
*/

import "https://github.com/aave/protocol-v2/blob/master/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "https://github.com/aave/protocol-v2/blob/master/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/aave/protocol-v2/blob/master/contracts/interfaces/ILendingPool.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract FlashLoanArbitrage is FlashLoanReceiverBase {
    //--------------------------------------------------------------------
    // VARIABLES

    address public owner;

    address public loanTokenAddress;
    address public swapTokenAddress;
    address public uniswapRouterAddress;
    address public sushiswapRouterAddress;

    enum Exchange {
        UNI,
        SUSHI,
        NONE
    }

    //--------------------------------------------------------------------
    // MODIFIERS

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

    //--------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(
        address _addressProvider,
        address _uniswapRouterAddress,
        address _sushiswapRouterAddress,
        address _loanTokenAddress,
        address _swapTokenAddress
    )
        public
        FlashLoanReceiverBase(ILendingPoolAddressesProvider(_addressProvider))
    {
        uniswapRouterAddress = _uniswapRouterAddress;
        sushiswapRouterAddress = _sushiswapRouterAddress;
        owner = msg.sender;
        loanTokenAddress = _loanTokenAddress;
        swapTokenAddress = _swapTokenAddress;
    }

    //--------------------------------------------------------------------
    // ARBITRAGE FUNCTIONS/LOGIC

    function withdraw(address _erc20Address ,uint256 amount) public onlyOwner {
        uint256 erc20Balance = getERC20Balance(_erc20Address);
        require(amount <= erc20Balance, "Not enough amount deposited");
        IERC20(_erc20Address).transfer(msg.sender, amount);
    }

    function makeArbitrage(uint256 _amountIn) public {
        Exchange result = _comparePrice(_amountIn);    // loan _amountIn

        if (result == Exchange.UNI) {
            // sell loanToken in uniswap for swapToken with high price and buy loanToken from sushiswap with lower price
            uint256 amountOut = _swap(
                _amountIn,
                uniswapRouterAddress,
                loanTokenAddress,
                swapTokenAddress
            );
            _swap(amountOut, sushiswapRouterAddress, swapTokenAddress, loanTokenAddress);
        } else if (result == Exchange.SUSHI) {
            // sell loanToken in sushiswap for swapToken with high price and buy loanToken from uniswap with lower price
            uint256 amountOut = _swap(
                _amountIn,
                sushiswapRouterAddress,
                loanTokenAddress,
                swapTokenAddress
            );
            _swap(amountOut, uniswapRouterAddress, swapTokenAddress,loanTokenAddress);
        }
    }

    function _swap(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) internal returns (uint256) {
        IERC20(sell_token).approve(routerAddress, amountIn);

        uint256 amountOutMin = (_getPrice(
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
                block.timestamp
            )[1];
        return amountOut;
    }

    function _comparePrice(uint256 amount) internal view returns (Exchange) {
        uint256 uniswapPrice = _getPrice(
            uniswapRouterAddress,
            loanTokenAddress,
            swapTokenAddress,
            amount
        );
        uint256 sushiswapPrice = _getPrice(
            sushiswapRouterAddress,
            loanTokenAddress,
            swapTokenAddress,
            amount
        );

        // we try to sell ETH with higher price and buy it back with low price to make profit
        if (uniswapPrice > sushiswapPrice) {
            require(
                _checkIfArbitrageIsProfitable(
                    amount,
                    uniswapPrice,
                    sushiswapPrice
                ),
                "Arbitrage not profitable"
            );
            return Exchange.UNI;
        } else if (uniswapPrice < sushiswapPrice) {
            require(
                _checkIfArbitrageIsProfitable(
                    amount,
                    sushiswapPrice,
                    uniswapPrice
                ),
                "Arbitrage not profitable"
            );
            return Exchange.SUSHI;
        } else {
            return Exchange.NONE;
        }
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

        uint256 payed_fee = (2 * (amountIn * 3)) / 1000;

        if (difference > payed_fee) {
            return true;
        } else {
            return false;
        }
    }

    function _getPrice(
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

    //--------------------------------------------------------------------
    // FLASHLOAN FUNCTIONS

    /**
     * @dev This function must be called only be the LENDING_POOL and takes care of repaying
     * active debt positions, migrating collateral and incurring new V2 debt token debt.
     *
     * @param assets The array of flash loaned assets used to repay debts.
     * @param amounts The array of flash loaned asset amounts used to repay debts.
     * @param premiums The array of premiums incurred as additional debts.
     * @param initiator The address that initiated the flash loan, unused.
     * @param params The byte array containing, in this case, the arrays of aTokens and aTokenAmounts.
     */
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        //
        // Try to do arbitrage with the flashloan amount.
        //
        makeArbitrage(amounts[0]);
        // At the end of your logic above, this contract owes
        // the flashloaned amounts + premiums.
        // Therefore ensure your contract has enough to repay
        // these amounts.

        // Approve the LendingPool contract allowance to *pull* the owed amount
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }

        return true;
    }

    function myFlashLoanCall(uint256 _amount) public {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = address(loanTokenAddress);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        // amounts[0] = getERC20Balance(wethAddress);

        // 0 = no debt, 1 = stable, 2 = variable
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0;
        // modes[1] = INSERT_ASSET_TWO_MODE;

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }

    //--------------------------------------------------------------------
    // GETTER FUNCTIONS

    function getERC20Balance(address _erc20Address)
        public
        view
        returns (uint256)
    {
        return IERC20(_erc20Address).balanceOf(address(this));
    }

    function checkArbitrage(uint256 _amountIn) public view returns(string memory){
        Exchange result = _comparePrice(_amountIn);
        if (result == Exchange.UNI) {
            return "Arbitrage Chances in UniSwap";
        }else if(result == Exchange.SUSHI){
            return "Arbitrage Chances in SushiSwap";
        }else{
            return "No Availabe Arbitrage";
        }
        
    }
}