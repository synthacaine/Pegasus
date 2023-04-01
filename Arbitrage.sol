//SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "https://github.com/aave/protocol-v2/blob/master/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "https://github.com/aave/protocol-v2/blob/master/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/aave/protocol-v2/blob/master/contracts/interfaces/ILendingPool.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

import "SimpleFlashloanArbitrage.sol";
import "TriangularFlashloanArbitrage.sol";
import "IRegistration.sol";

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

contract ArbitrageMain is Ownable {
    using SafeMath for uint256;

    address public providerAddress = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;  // Mainnet

    ISimpleArbitrage public simpleArbitrageContract;
    ITriangularArbitrage public triangularArbitrageContract;

    enum Exchange {
        EXCA,
        EXCB,
        NONE
    }

    event SimpleFlashLoanArbitrageDeployed(address user, address arbitrage);
    event TriangularFlashLoanArbitrageDeployed(address user, address arbitrage);

    constructor(address _simpleArbitrageContract, address _triangularArbitrageContract) public {
        simpleArbitrageContract = ISimpleArbitrage(_simpleArbitrageContract);
        triangularArbitrageContract = ITriangularArbitrage(_triangularArbitrageContract);
    }

    function modifyProviderAddress(address _providerAddress) external onlyOwner {
        providerAddress = _providerAddress;
    }

    function modifyArbitrageAddress(address _simpleArbitrageContract, address _triangularArbitrageContract) external onlyOwner {
        simpleArbitrageContract = ISimpleArbitrage(_simpleArbitrageContract);
        triangularArbitrageContract = ITriangularArbitrage(_triangularArbitrageContract);
    }

    function callSimpleArbitrage(address _user, address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, uint256 _amountIn) public payable {
        // address payable contractA = address(new FlashLoanSimpleArbitrage(providerAddress, _exchangeA, _exchangeB, _tokenA, _tokenB, _user));

        if(_tokenA == address(0)) {
          simpleArbitrageContract.simpleArbitrage{value:msg.value}(0, _exchangeA, _exchangeB, _tokenA, _tokenB, _user);
        } else {
          IERC20(_tokenA).transferFrom(_user, address(this), _amountIn);
          IERC20(_tokenA).transfer(address(simpleArbitrageContract), _amountIn);
          simpleArbitrageContract.simpleArbitrage(_amountIn, _exchangeA, _exchangeB, _tokenA, _tokenB, _user);
        }

        // IERC20(_tokenA).approve(contractA, amountIn);
        // IERC20(_tokenB).approve(contractA, amountIn);

        // emit SimpleArbitrageDeployed(_user, contractA);
    }  

    function callSimpleFlashLoan(address _user, address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, uint256 _amountIn) public payable {
        address payable contractA = address(new FlashLoanSimpleArbitrage(providerAddress, _exchangeA, _exchangeB, _tokenA, _tokenB, _user));

        if(_tokenA == address(0)) {
          FlashLoanSimpleArbitrage(contractA).flashloanArbitrage{value:msg.value}(0);
        } else {
          FlashLoanSimpleArbitrage(contractA).flashloanArbitrage(_amountIn);
        }

        emit SimpleFlashLoanArbitrageDeployed(_user, contractA);
    }

    function callTriangularArbitrage(address _user, address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, address _tokenC, uint256 _amountIn) public payable {
        // address payable contractA = address(new FlashLoanTriangularArbitrage(providerAddress, _exchangeA, _exchangeB, _tokenA, _tokenB, _tokenC, _user));

        if(_tokenA == address(0)) {
          triangularArbitrageContract.triangularArbitrage{value:msg.value}(0, _exchangeA, _exchangeB, _tokenA, _tokenB, _tokenC, _user);

        } else {
          IERC20(_tokenA).transferFrom(_user, address(this), _amountIn);
          IERC20(_tokenA).transfer(address(triangularArbitrageContract), _amountIn);
          triangularArbitrageContract.triangularArbitrage(_amountIn, _exchangeA, _exchangeB, _tokenA, _tokenB, _tokenC, _user);
        }

        // emit TriangularArbitrageDeployed(_user, contractA);
    }

    function callTriangularFlashLoan(address _user, address _exchangeA, address _exchangeB, address _tokenA, address _tokenB, address _tokenC, uint256 _amountIn) public payable {
        address payable contractA = address(new FlashLoanTriangularArbitrage(providerAddress, _exchangeA, _exchangeB, _tokenA, _tokenB, _tokenC, _user));

        if(_tokenA == address(0)) {
          FlashLoanTriangularArbitrage(contractA).flashloanArbitrage{value:msg.value}(0);   

        } else {
          FlashLoanTriangularArbitrage(contractA).flashloanArbitrage(_amountIn);
        }

        emit TriangularFlashLoanArbitrageDeployed(_user, contractA);
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

    receive() external payable {}

}
