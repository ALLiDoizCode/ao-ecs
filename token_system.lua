local bint = require('.bint')(256)
local ao = require('ao')
local json = require('json')

local utils = {
    add = function(a, b)
        return tostring(bint(a) + bint(b))
    end,
    subtract = function(a, b)
        return tostring(bint(a) - bint(b))
    end,
    toBalanceValue = function(a)
        return tostring(bint(a))
    end,
    toNumber = function(a)
        return tonumber(a)
    end
}

Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
    assert(type(msg.Recipient) == 'string', 'Recipient is required!')
    assert(type(msg.Quantity) == 'string', 'Quantity is required!')
    assert(bint.__lt(0, bint(msg.Quantity)), 'Quantity must be greater than 0')
    local data = json.decode(msg.Data);
    if not data.Balances[msg.From] then data.Balances[msg.From] = "0" end
    if not data.Balances[msg.Recipient] then data.Balances[msg.Recipient] = "0" end

    if bint(msg.Quantity) <= bint(data.Balances[msg.From]) then
        data.Balances[msg.From] = utils.subtract(data.Balances[msg.From], msg.Quantity)
        data.Balances[msg.Recipient] = utils.add(data.Balances[msg.Recipient], msg.Quantity)
        if data.Balances[msg.Recipient] == "0" then data.Balances[msg.Recipient] = nil end;
        --[[
         Only send the notifications to the Sender and Recipient
         if the Cast tag is not set on the Transfer message
       ]]
        --
        if not msg.Cast then
            -- Debit-Notice message template, that is sent to the Sender of the transfer
            local debitNotice = {
                Target = msg.From,
                Action = 'Debit-Notice',
                Recipient = msg.Recipient,
                Quantity = msg.Quantity,
                Sender = msg.Sender,
                Data = json.encode(data)
            }
            -- Credit-Notice message template, that is sent to the Recipient of the transfer
            local creditNotice = {
                Target = msg.Recipient,
                Action = 'Credit-Notice',
                Quantity = msg.Quantity,
                Data = Colors.gray ..
                    "You received " ..
                    Colors.blue .. msg.Quantity .. Colors.gray .. " from " .. Colors.green .. msg.From .. Colors.reset
            }

            -- Add forwarded tags to the credit and debit notice messages
            for tagName, tagValue in pairs(msg) do
                -- Tags beginning with "X-" are forwarded
                if string.sub(tagName, 1, 2) == "X-" then
                    debitNotice[tagName] = tagValue
                    creditNotice[tagName] = tagValue
                end
            end

            -- Send Debit-Notice and Credit-Notice
            ao.send(debitNotice)
            ao.send(creditNotice)
        end
    else
        ao.send({
            Target = msg.From,
            Action = 'Transfer-Error',
            ['Message-Id'] = msg.Id,
            Sender = msg.Sender,
            Error = 'Insufficient Balance!'
        })
    end
end)

--[[
    Mint
   ]]
--
Handlers.add('mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)
    assert(type(msg.Quantity) == 'string', 'Quantity is required!')
    assert(bint(0) < bint(msg.Quantity), 'Quantity must be greater than zero!')
    local data = json.decode(msg.Data);
    if not data.Balances[msg.Recipient] then data.Balances[msg.Recipient] = "0" end

    if msg.From == data.Minter then
        data.Balances[msg.Recipient] = utils.add(data.Balances[msg.Recipient], msg.Quantity)
        data.TotalSupply = utils.add(data.TotalSupply, msg.Quantity)
        ao.send({
            Target = msg.From,
            Action = "Mint-Notice",
            Data = json.encode(data)
        })
    else
        ao.send({
            Target = msg.Recipient,
            Action = 'Mint-Error',
            ['Message-Id'] = msg.Id,
            Sender = msg.Sender,
            Error = 'Only the Process Owner can mint new ' .. data.Ticker .. ' tokens!'
        })
    end
end)

Handlers.add('burn', Handlers.utils.hasMatchingTag('Action', 'Burn'), function(msg)
    local data = json.decode(msg.Data);
    assert(type(msg.Quantity) == 'string', 'Quantity is required!')
    assert(bint(msg.Quantity) <= bint(data.Balances[msg.From]), 'Quantity must be less than or equal to the current balance!')
    data.Balances[msg.From] = utils.subtract(data.Balances[msg.From], msg.Quantity)
    data.TotalSupply = utils.subtract(data.TotalSupply, msg.Quantity)

    ao.send({
        Target = msg.From,
        Action = "Burn-Notice",
        Sender = msg.Sender,
        Data = json.encode(data)
    })
end)