local json = require('json')
local bint = require('.bint')(256)

local utils = {
    add = function (a,b) 
      return tostring(bint(a) + bint(b))
    end,
    subtract = function (a,b)
      return tostring(bint(a) - bint(b))
    end
  }

-- Vote Action Handler
Handlers.vote = function(msg)
    local data = json.decode(msg.Data);
    local quantity = data.Stakers[msg.From].amount
    local target = msg.Tags.Target
    local side = msg.Tags.Side
    local deadline = tonumber(msg['Block-Height']) + tonumber(msg.Tags.Deadline)
    assert(quantity > 0, "No staked tokens to vote")
    data.Votes[target] = data.Votes[target] or { yay = 0, nay = 0, deadline = deadline }
    data.Votes[target][side] = data.Votes[target][side] + quantity
end

-- Stake Action Handler
Handlers.stake = function(msg)
    local data = json.decode(msg.Data);
    local quantity = bint(msg.Tags.Quantity)
    local delay = tonumber(msg.Tags.UnstakeDelay)
    local height = tonumber(msg['Block-Height'])
    assert(data.Balances[msg.From] and bint(data.Balances[msg.From]) >= quantity, "Insufficient balance to stake")
    data.Balances[msg.From] = utils.subtract(data.Balances[msg.From], msg.Tags.Quantity) 
    data.Stakers[msg.From] = data.Stakers[msg.From] or { amount = "0" }
    data.Stakers[msg.From].amount = utils.add(data.Stakers[msg.From].amount, msg.Tags.Quantity)  
    data.Stakers[msg.From].unstake_at = height + delay
    print("Successfully Staked " .. msg.Tags.Quantity)
    msg.reply({ Data = "Successfully Staked " .. msg.Tags.Quantity})
  end
  
  -- Unstake Action Handler
  Handlers.unstake = function(msg)
    local data = json.decode(msg.Data);
    local stakerInfo = data.Stakers[msg.From]
    assert(stakerInfo and bint(stakerInfo.amount) >= bint(msg.Tags.Quantity), "Insufficient staked amount")
    stakerInfo.amount = utils.subtract(stakerInfo.amount, msg.Tags.Quantity)
    data.Unstaking[msg.From] = {
        amount = msg.Quantity,
        release_at = stakerInfo.unstake_at
    }
    msg.reply({ Data = "Successfully unstaked " .. msg.Tags.Quantity})
  end
  

-- Finalization Handler
local finalizationHandler = function(msg)
    local data = json.decode(msg.Data);
    local currentHeight = tonumber(msg['Block-Height'])
    -- Process voting
    for target, voteInfo in pairs(data.Votes) do
        if currentHeight >= voteInfo.deadline then
            if voteInfo.yay > voteInfo.nay then
                print("Handle Vote")
            end
            -- Clear the vote record after processing
            data.Votes[target] = nil
        end
    end
    -- Process unstaking
  for address, unstakeInfo in pairs(data.Unstaking) do
    if currentHeight >= unstakeInfo.release_at then
        data.Balances[address] = utils.add(data.Balances[address] or "0", unstakeInfo.amount)
        data.Unstaking[address] = nil
    end
end
end

-- wrap function to continue handler flow
local function continue(fn)
    return function(msg)
        local result = fn(msg)
        if (result) == -1 then
            return 1
        end
        return result
    end
end

Handlers.add("vote",
    continue(Handlers.utils.hasMatchingTag("Action", "Vote")), Handlers.vote)
-- Finalization handler should be called for every message
Handlers.add("finalize", function(msg) return "continue" end, finalizationHandler)
-- Registering Handlers
Handlers.add("staking.stake",
  continue(Handlers.utils.hasMatchingTag("Action", "Stake")), Handlers.stake)
Handlers.add("staking.unstake",
  continue(Handlers.utils.hasMatchingTag("Action", "Unstake")), Handlers.unstake)
-- Finalization handler should be called for every message
-- changed to continue to let messages pass-through
Handlers.add("staking.finalize", function (msg) return "continue" end, finalizationHandler)
