//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// stake: Lock tokens into our smart contract
// withdraw: unlock tokens and pull out of the contract
// claimReward: users get their reward tokens
// whats good rewards mechanism?
// whats some good reward math/logic?

error Staking__TransferFailed();
error Staking__NeedsMoreThanZero();

contract Staking {
    IERC20 public s_stakingToken;
    IERC20 public s_rewardToken;
    mapping(address => uint256) public s_balances;
    uint256 public s_totalSupply;
    uint256 public s_rewardPerTokenStored;
    uint256 public s_lastUpdateTime;
    uint256 public constant REWARD_RATE = 100;
    mapping(address => uint256) public s_userRewardPerTokenPaid;
    mapping(address => uint256) public s_rewards;

    modifier updateReward(address account) {
        // how much reward per token?
        // last timestamp
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert Staking__NeedsMoreThanZero();
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

    function earned(address account) public view returns (uint256) {
        uint256 currentBalance = s_balances[account];
        uint256 amountPaid = s_userRewardPerTokenPaid[account];
        uint256 currentRewardPerToken = rewardPerToken();
        uint256 pastRewards = s_rewards[account];
        uint256 _earned = (currentBalance * (currentRewardPerToken - amountPaid)) /
            1e18 +
            pastRewards;
        return _earned;
    }

    constructor(address stakingToken, address rewardToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardToken = IERC20(rewardToken);
    }

    // only ERC20 token allowed
    function stake(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {
        // keep track of how much this user has staked
        // keep track of how much token we have total
        // transfer the tokens to this contract
        s_balances[msg.sender] += amount;
        s_totalSupply += amount;
        // emit event
        bool success = s_stakingToken.transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function withdraw(uint256 amount) external updateReward(msg.sender) moreThanZero(amount) {
        s_balances[msg.sender] -= amount;
        s_totalSupply -= amount;
        bool success = s_stakingToken.transfer(msg.sender, amount);
        if (!success) {
            revert Staking__TransferFailed();
        }
    }

    function claimReward() external updateReward(msg.sender) {
        uint256 reward = s_rewards[msg.sender];
        bool success = s_rewardToken.transfer(msg.sender, reward);
        if (!success) {
            revert Staking__TransferFailed();
        }
        // calculate reward
        // The contract is going to emit X tokens per second
        // and disperse them to all token stakers
        //
        // 100 reward tokens / second
        // transfer reward to user
        // staked: 50 reward tokens, 20 rewards, tokens, 30 reward tokens
        // rewards: 50 reward tokens, 20 rewards, tokens, 30 reward tokens
        //
        // the more people stake, the less every staker gets rewarded
        // staked: 100, 50, 20, 30 (total = 200)
        // rewards: 50, 25, 10, 15 (total = 100)
        //
        // not 1 to 1, will bankrupt the protocol
        //
        /*
        100 tokens / second
        Time = 0
        Person A: 80 staked
        Person B: 20 staked

        Time = 1
        PA: 80 staked, Earned: 80, Withdrawn: 0
        PB: 20 staked, Earned: 20, Withdrawn: 0

        Time = 2
        PA: 80 staked, Earned: 160, Withdrawn: 0
        PB: 20 staked, Earned: 40, Withdrawn: 0

        Time = 3
        PA: 80 staked, Earned: 240, Withdrawn: 0
        PB: 20 staked, Earned: 60, Withdrawn: 0

        New Person enters!
        Person C: 100 staked

        Time = 4
        PA: 80 staked, Earned: 240 + 40((80/200)*100), Withdrawn: 0
        PB: 20 staked, Earned: 80 + 10((20/200)*100), Withdrawn: 0
        PC: 100 staked, Earned: 50, Withdrawn: 0

        PA withdrew and claimed rewards on everything

        Time = 5
        PA: 0 staked, Earned: 0 , Withdrawn: 280
        PB: need to calculate
        PC: need to calculate
        */
    }
}
