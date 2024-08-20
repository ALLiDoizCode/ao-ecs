local json = require('json');
local ao = require('ao');
local bint = require('.bint')(256)

if not EntityId then EntityId = 1 end;
if not ComponentId then ComponentId = 1 end;

if not Components then Components = {} end;
if not Entitys then Entitys = {} end;

Handlers.add("CreateEntity", Handlers.utils.hasMatchingTag('Action', "CreateEntity"), function(msg)
    local currentId = tostring(EntityId);
    EntityId = EntityId + 1;
    Entitys[currentId] = msg.From;
end)

Handlers.add("AddComponent", Handlers.utils.hasMatchingTag('Action', "AddComponent"), function(msg)
    local currentId = tostring(ComponentId);
    ComponentId = ComponentId + 1;
    local tokenComponent = TokenComponent(currentId, msg.Entity, msg.Minter, msg.Denomination, msg.Name, msg.Ticker, msg.Logo, msg.Description);
    AddComponent(tokenComponent);
end)

Handlers.add("Credit-Notice", Handlers.utils.hasMatchingTag('Action', "Credit-Notice"), function(msg)
    local data = json.decode(msg.Data);
    Components[data.Id] = data;
end)

Handlers.add("Debit-Notice", Handlers.utils.hasMatchingTag('Action', "Debit-Notice"), function(msg)
    local data = json.decode(msg.Data);
    Components[data.Id] = data;
end)

Handlers.add("Mint-Notice", Handlers.utils.hasMatchingTag('Action', "Mint-Notice"), function(msg)
    local data = json.decode(msg.Data);
    Components[data.Id] = data;
end)

Handlers.add("Burn-Notice", Handlers.utils.hasMatchingTag('Action', "Burn-Notice"), function(msg)
    local data = json.decode(msg.Data);
    Components[data.Id] = data;
end)

Handlers.add("Entitys", Handlers.utils.hasMatchingTag('Action', "Entitys"), function(msg)
    ao.send({
        Target = msg.From,
        Data = json.encode(Entitys),
    });
end)

Handlers.add("Components", Handlers.utils.hasMatchingTag('Action', "Components"), function(msg)
    ao.send({
        Target = msg.From,
        Data = json.encode(Components),
    });
end)

function TokenComponent(Id,Entity, Minter, Denomination, Name, Ticker, Logo, Description)
    local Component = {
        Handlers = { "Transfer", "Mint", "Burn" },
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
            ao.send({
                Target = component.System,
                Action = v,
                Data = json.encode(component.Data),
                Tags = msg.Tags,
                Sender = msg.From
            });
        end)
    end
end
