local json = require('json');
local ao = require('ao');
local bint = require('.bint')(256)

if not ComponentId then ComponentId = 1 end;
if not Components then Components = {} end;

Handlers.add("AddComponent", Handlers.utils.hasMatchingTag('Action', "AddComponent"), function(msg)
    assert(msg.From == Owner,"Not Authorized");
    local component = json.decode(msg.Data);
    local currentId = tostring(ComponentId);
    ComponentId = ComponentId + 1;
    component["Id"] = currentId;
    AddComponent(component);
end)

Handlers.add("RemoveComponent", Handlers.utils.hasMatchingTag('Action', "RemoveComponent"), function(msg)
    assert(msg.From == Owner,"Not Authorized");
    local component = Components[msg.Id];
    RemoveComponent(component);
end)

Handlers.add("Components", Handlers.utils.hasMatchingTag('Action', "Components"), function(msg)
    ao.send({
        Target = msg.From,
        Data = json.encode(Components),
    });
end)

Handlers.add("Component", Handlers.utils.hasMatchingTag('Action', "Component"), function(msg)
    local component = Components[msg.Id];
    ao.send({
        Target = msg.From,
        Data = json.encode(component),
    });
end)

function AddComponent(component)
    Components[component.Data.Id] = component;
    for i, v in ipairs(component.Handlers) do
        Handlers.add(v, Handlers.utils.hasMatchingTag('Action', v), function(msg)
            if (msg.From == component.System) then
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

function RemoveComponent(component)
    for i, v in ipairs(component.Handlers) do
        Handlers.remove(v)
    end
    Components[component.Id] = {}
end
