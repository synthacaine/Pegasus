// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
    Ropsten instances:
    - Uniswap V2 Router:                         0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    - Sushiswap V1 Router:                       0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506
    - DAI:                                       0xFf795577d9AC8bD7D90Ee22b6C1703490b6512FD
    - WETH:                                      0xd0A1E359811322d97991E03f863a0C30C2cF029C
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

    address public wethAddress;
    address public daiAddress;
    // address public uniswapRouterAddress;
    address public sushiswapRouterAddress;

    // enum Exchange {
    //     UNI,
    //     SUSHI,
    //     NONE
    // }

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
        // address _uniswapRouterAddress,
        address _sushiswapRouterAddress,
        address _weth,
        address _dai
    )
        public
        FlashLoanReceiverBase(ILendingPoolAddressesProvider(_addressProvider))
    {
        // uniswapRouterAddress = _uniswapRouterAddress;
        sushiswapRouterAddress = _sushiswapRouterAddress;
        owner = msg.sender;
        wethAddress = _weth;
        daiAddress = _dai;
    }

    //--------------------------------------------------------------------
    // ARBITRAGE FUNCTIONS/LOGIC

    function deposit(uint256 amount) public onlyOwner {
        require(amount > 0, "Deposit amount must be greater than 0");
        IERC20(wethAddress).transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(address _to,uint256 amount) public onlyOwner {
        uint256 wethBalance = getERC20Balance(_to);
        require(amount <= wethBalance, "Not enough amount deposited");
        IERC20(wethAddress).transferFrom(address(this), msg.sender, amount);
    }

    function makeArbitrage() public {
        uint256 amountIn = getERC20Balance(daiAddress);

            // sell ETH in uniswap for DAI with high price and buy ETH from sushiswap with lower price
            uint256 amountOut = _swap(
                amountIn,
                sushiswapRouterAddress,
                daiAddress,
                wethAddress
            );
            _swap(amountOut, sushiswapRouterAddress, wethAddress,daiAddress);
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

    function _checkPrice(uint256 amount) internal view returns (uint256) {
        uint256 uniswapPrice = _getPrice(
            uniswapRouterAddress,
            wethAddress,
            daiAddress,
            amount
        );
        // we try to sell ETH with higher price and buy it back with low price to make profit
        require(
                _checkIfArbitrageIsProfitable(
                    amount,
                    uniswapPrice
                ),"Arbitrage not profitable");
            return uniswapPrice;

        }
    

    function _checkIfArbitrageIsProfitable(
        uint256 amountIn,
        uint256 price
    ) internal pure returns (bool) {
        // uniswap & sushiswap have 0.3% fee for every exchange
        // so gain made must be greater than 2 * 0.3% * arbitrage_amount


        uint256 payed_fee = (2 * (amountIn * 3)) / 1000;

        if (price > payed_fee) {
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
        makeArbitrage();
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

    function myFlashLoanCall() public {
        address receiverAddress = address(this);

        address[] memory assets = new address[](1);
        assets[0] = address(daiAddress);
        // assets[1] = address(INSERT_ASSET_TWO_ADDRESS);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = getERC20Balance(wethAddress);
        // amounts[1] = INSERT_ASSET_TWO_AMOUNT;

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

}