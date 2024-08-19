local json = require('json');
local ao = require('ao');
local bint = require('.bint')(256)

if not Components then Components = {} end;

Component = {
    Handlers = { "Transfer", "Mint", "Init" },
    system = "Mq-EhTkmZ5nSBmnqzp3vl_d35WwMTGphtk90Z7wVr-o",
    Title = "Token Component",
    Description = "This component provides your process the ability to act as a fungible token",
    Data = {
        Balances = { [ao.id] = "100000000000000000" },
        Minter = "UOI4I9LmzHkobEIvs52vzY4SWk9FPi7JiYSHe4ZGmCI",
        Denomination = 8,
        TotalSupply = 0,
        Name = "Swappy",
        Ticker = "SWAP",
        Logo = "-RmetHQufxWySiJact95a9ON6pb-0s56dElmyJusGwQ",
        Description = "Test token for Swappy"
    }
};

Handlers.add("AddComponent", Handlers.utils.hasMatchingTag('Action', "AddComponent"), function(msg)
    --local component = json.decode(msg.Data);
    AddComponent(Component);
end)

function AddComponent(_component)
    for i, v in ipairs(_component.Handlers) do
        Handlers.add(v, Handlers.utils.hasMatchingTag('Action', v), function(msg)
            ao.send({
                Target = _component.system,
                Action = v,
                Data = json.encode(_component.Data),
                Tags = msg.Tags,
                Sender = msg.From
            });
        end)
    end
end
