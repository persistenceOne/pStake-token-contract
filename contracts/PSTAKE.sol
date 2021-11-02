// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./interfaces/IVestingTimelockV2.sol";

contract PSTAKE is
  ERC20Upgradeable,
  PausableUpgradeable,
  AccessControlUpgradeable
{
  // constants defining access control ROLES
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

  // variable pertaining to contract upgrades versioning
  uint256 public _version;

  // addresses pertaining to various tokenomics strategy
  address public _airdropPool;
  address public _seedSalePool;
  address public _strategicFoundationSalePool;
  address public _teamPool;
  address public _incentivisationPool;
  address public _xprtStakersPool;
  address public _protocolTreasuryPool;
  address public _communityDevelopmentFundPool;
  address public _communityDevelopmentFundPool2;

  // address of vesting timelock contract to enable several vesting strategy
  address public _vestingTimelockAddress;

  /**
   * @dev Constructor for initializing the UToken contract.
   * @param pauserAddress - address of the pauser admin.
   */
  function initialize(
    address pauserAddress,
    address vestingTimelockAddress,
    address airdropPool,
    address seedSalePool,
    address strategicFoundationSalePool,
    address teamPool,
    address incentivisationPool,
    address xprtStakersPool,
    address protocolTreasuryPool,
    address communityDevelopmentFundPool,
    address communityDevelopmentFundPool2
  ) public virtual initializer {
    __ERC20_init("pSTAKE Token", "PSTAKE");
    __AccessControl_init();
    __Pausable_init();
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(PAUSER_ROLE, pauserAddress);

    // PSTAKE is an erc20 token hence 18 decimal places
    _setupDecimals(18);

    // setup the version and vesting timelock contract
    _version = 1;
    _vestingTimelockAddress = vestingTimelockAddress;

    // allocate the various tokenomics strategy pool addresses
    _airdropPool = airdropPool;
    _seedSalePool = seedSalePool;
    _strategicFoundationSalePool = strategicFoundationSalePool;
    _teamPool = teamPool;
    _incentivisationPool = incentivisationPool;
    _xprtStakersPool = xprtStakersPool;
    _protocolTreasuryPool = protocolTreasuryPool;
    _communityDevelopmentFundPool = communityDevelopmentFundPool;
    _communityDevelopmentFundPool2 = communityDevelopmentFundPool2;

    // pre-allocate tokens to strategy pools
    _mint(_airdropPool, uint256(20000000e18));
    _mint(_incentivisationPool, uint256(20000000e18));
    _mint(_xprtStakersPool, uint256(2083334e18));
    _mint(_protocolTreasuryPool, uint256(6250000e18));
    _mint(_communityDevelopmentFundPool, uint256(3125000e18));

    // accumulate tokens to allocate for vesting strategies (total supply - initial circulating supply)
    _mint(address(this), uint256(448541666e18));

    // approve the vesting timelock contract to pull the tokens
    _approve(address(this), _vestingTimelockAddress, uint256(448541666e18));
    // create vesting strategies

    // airdrop pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _airdropPool,
      block.timestamp,
      (182 days + 12 hours),
      uint256(10000000e18),
      1,
      0,
      false
    );

    // seedSale pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _seedSalePool,
      block.timestamp,
      // 6 months
      (182 days + 12 hours),
      uint256(4166667e18),
      12,
      // 1 month
      (30 days + 10 hours),
      false
    );

    // strategicFoundationSale pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _strategicFoundationSalePool,
      block.timestamp,
      // 6 months
      (182 days + 12 hours),
      uint256(1250000e18),
      12,
      // 1 month
      (30 days + 10 hours),
      false
    );

    // team pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _teamPool,
      block.timestamp,
      // 12 months
      365 days,
      uint256(4166667e18),
      18,
      // 1 month
      (30 days + 10 hours),
      false
    );

    // incentivisation pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _incentivisationPool,
      block.timestamp,
      // 3 months
      (91 days + 6 hours),
      uint256(20000000e18),
      8,
      // 3 months
      (91 days + 6 hours),
      false
    );

    // xprtStakers pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _xprtStakersPool,
      block.timestamp,
      // 1 month
      (30 days + 10 hours),
      uint256(2083333e18),
      11,
      // 1 month
      (30 days + 10 hours),
      false
    );

    // protocolTreasury pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _protocolTreasuryPool,
      block.timestamp,
      // 3 months
      (91 days + 6 hours),
      uint256(6250000e18),
      11,
      // 3 months
      (91 days + 6 hours),
      false
    );

    // communityDevelopmentFund pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _communityDevelopmentFundPool,
      block.timestamp,
      // 3 months
      (91 days + 6 hours),
      uint256(3125000e18),
      14,
      // 3 months
      (91 days + 6 hours),
      false
    );

    // communityDevelopmentFund2 pool
    IVestingTimelockV2(_vestingTimelockAddress).addGrantAsInstalment(
      address(this),
      _communityDevelopmentFundPool2,
      block.timestamp,
      // 42 months
      (1277 days + 12 hours),
      uint256(3125000e18),
      1,
      // 0 months
      0,
      false
    );
  }

  /**
   * @dev Mint new PSTAKE for the provided 'address' and 'amount'
   *
   *
   * Emits a {MintTokens} event with 'to' set to address and 'tokens' set to amount of tokens.
   *
   * Requirements:
   *
   * - `amount` cannot be less than zero.
   *
   */
  function mint(address to, uint256 tokens) public returns (bool success) {
    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "PS2");

    _mint(to, tokens);
    return true;
  }

  /**
   * @dev Triggers stopped state.
   *
   * Requirements:
   *
   * - The contract must not be paused.
   */
  function pause() public returns (bool success) {
    require(hasRole(PAUSER_ROLE, _msgSender()), "PS3");
    _pause();
    return true;
  }

  /**
   * @dev Returns to normal state.
   *
   * Requirements:
   *
   * - The contract must be paused.
   */
  function unpause() public returns (bool success) {
    require(hasRole(PAUSER_ROLE, _msgSender()), "PS4");
    _unpause();
    return true;
  }

  /**
   * @dev Hook that is called before any transfer of tokens. This includes
   * minting and burning.
   *
   * Calling conditions:
   *
   * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
   * will be to transferred to `to`.
   * - when `from` is zero, `amount` tokens will be minted for `to`.
   * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
   * - `from` and `to` are never both zero.
   *
   */
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    require(!paused(), "PS5");
    super._beforeTokenTransfer(from, to, amount);
  }
}