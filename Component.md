```lua
--Token Component
local Component = {
    Handlers = { "Transfer", "Mint", "Burn", "Credit-Notice", "Debit-Notice", "Mint-Notice", "Burn-Notice" },
    System = "Mq-EhTkmZ5nSBmnqzp3vl_d35WwMTGphtk90Z7wVr-o",
    Title = "Token Component",
    Description = "This component provides your process the ability to act as a fungible token",
    Data = {
        Id = "",
        Balances = {},
        Minter = "",
        Denomination = "",,
        TotalSupply = "0",
        Name = "",,
        Ticker = "",,
        Logo = "",,
        Description = "",
    }
};
```

```lua
--Dao Component
local Component = {
    Handlers = {"Stake", "Unstake","Vote"},
    System = "JbCyKV0w5UaIX1v-RABhunY0UAciDSkCa5kO7Lnkii0",
    Title = "Staking Component",
    Description = "This component provides your process the ability to act as a Dao",
    Data = {
        Id = "",
        Stakers = Stakers or {}
        Unstaking = Unstaking or {}
        Balances = {},
        Votes = Votes or {}
    }
};
```