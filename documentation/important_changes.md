# Important changes

Before working with Caelum, there are a few fundamental changes over the general EIP918 standard in terms of rewards.

### getMiningReward() vs getMiningRewardForPool()

On regular EIP918 contract, this method is used to determine the rewards that need to be payed. Since Caelum uses a masternode rewarding system, some changes have been made.

The `getMiningReward()` returns the **global** mining reward. This means, combined masternodes and proof of work reward.

To return the **current mining reward**, use the `getMiningRewardForPool()` function.
