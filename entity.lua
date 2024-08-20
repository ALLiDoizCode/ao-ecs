local json = require('json');
local ao = require('ao');
local bint = require('.bint')(256)

if not ComponentId then ComponentId = 1 end;

if not Components then Components = {} end;

Handlers.add("AddComponent", Handlers.utils.hasMatchingTag('Action', "AddComponent"), function(msg)
    local currentId = tostring(ComponentId);
    ComponentId = ComponentId + 1;
    local tokenComponent = TokenComponent(currentId, msg.Entity, msg.Minter, msg.Denomination, msg.Name, msg.Ticker,
        msg.Logo, msg.Description);
    AddComponent(tokenComponent);
end)

Handlers.add("Components", Handlers.utils.hasMatchingTag('Action', "Components"), function(msg)
    ao.send({
        Target = msg.From,
        Data = json.encode(Components),
    });
end)

function TokenComponent(Id, Entity, Minter, Denomination, Name, Ticker, Logo, Description)
    local Component = {
        Handlers = { "Transfer", "Mint", "Burn", "Credit-Notice", "Debit-Notice", "Mint-Notice", "Burn-Notice" },
        System = "Mq-EhTkmZ5nSBmnqzp3vl_d35WwMTGphtk90Z7wVr-o",
        Title = "Token Component",
        Description = "This component provides your process the ability to act as a fungible token",
        Data = {
            Entity = Entity,
            Id = Id,
            Balances = {},
            Minter = Minter,
            Denomination = Denomination,
            TotalSupply = "0",
            Name = Name,
            Ticker = Ticker,
            Logo = Logo,
            Description = Description
        }
    };

    return Component
end

function AddComponent(component)
    Components[component.Data.Id] = component;
    for i, v in ipairs(component.Handlers) do
        Handlers.add(v, Handlers.utils.hasMatchingTag('Action', v), function(msg)
            if(msg.From == component.System) then
                local data = json.decode(msg.Data);
                Components[data.Id] = data;
            else
                ao.send({
                    Target = component.System,
                    Action = v,
                    Data = json.encode(component.Data),
                    Tags = msg.Tags,
                    Sender = msg.From
                });
            end
        end)
    end
end
