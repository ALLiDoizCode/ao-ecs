### Design Documentation: Using ECS architecture with AOS and Lua

This document provides the design guidelines for implementing and integrating the ECS architecture on the AO Computer (AOS) using Lua. This design aims to leverage the strengths of AOS's hyper-parallel blockchain and Lua's simplicity to create high-performance, modular applications following the ECS architecture.

---

## Table of Contents

1. [Overview](#overview)
2. [System Design](#system-design)
    - [Entities](#entities)
    - [Components](#components)
    - [Systems](#systems)
3. [Integration with AOS](#integration-with-aos)
4. [Lua Integration](#lua-integration)
5. [Parallel Processing with AOS](#parallel-processing-with-aos)
6. [Web3 App Store Integration](#web3-app-store-integration)
7. [Example Implementation](#example-implementation)
8. [Testing and Debugging](#testing-and-debugging)

---

## Overview

This design document describes the methodology and structure for using Lua to implement the ECS protocol on the AO computer. Lua is an ideal language for this system due to its lightweight nature, fast execution, and simple integration with AOS. The combination of Lua and the hyper-parallel blockchain capabilities of AOS enables high-performance decentralized applications and systems.

---

## System Design

### Entities

Entities in this system are lightweight, uniquely identifiable objects (such as players, NPCs, or in-game items) that serve as containers for various components. 

In AOS, entities can be represented as a process with a process `id` that holds a list of components. For example:

```lua
if not ComponentId then ComponentId = 1 end;
if not Components then Components = {} end;
```

### Components

Components are stateless data objects containing attributes and properties relevant to entities. They hold no logic and only represent the data attached to entities. Components will be simple Lua tables and can be dynamically added or removed from entities.

Example Component:

```lua
local Component = {
    Handlers = { "Transfer", "Mint", "Burn", "Credit-Notice", "Debit-Notice", "Mint-Notice", "Burn-Notice" },
    System = "Mq-EhTkmZ5nSBmnqzp3vl_d35WwMTGphtk90Z7wVr-o",
    Title = "Token Component",
    Description = "This component provides your process the ability to act as a fungible token",
    Data = {
        Id = "1",
        Balances = {},
        Minter = "KQjllcRQxYm7plP4DimIiNUBlrfjllfl3R84ZCsAqRs",
        Denomination = "8",,
        TotalSupply = "0",
        Name = "Enity Component System",,
        Ticker = "ECS",,
        Logo = "-RmetHQufxWySiJact95a9ON6pb-0s56dElmyJusGwQ",,
    }
};
```

### Systems

Systems contain the logic that operates on specific components. Systems in AOS should expose Handlers that process components.They MUST be stateless to maintain compatibility the ECS.

Example System:

```lua
Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
Handlers.add('mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
Handlers.add('burn', Handlers.utils.hasMatchingTag('Action', 'Burn'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
```

---

## Integration with AOS

### Script Structure

Each Lua script will follow a standardized structure to ensure compatibility with AOS and the ECS protocol:

```lua
local Component = {
    Handlers = {}, -- The list of Handlers that will be dynamically created upon adding the component to the entity
    System = "", -- The process Id of the system that contains the behavior and logic for this component
    Title = "", -- The title for this component(this can be the Dapp name)
    Description = "", -- The description explaining the features and functionality of the component(Dapp)
    Data = {} -- Arbitary data used by the system for example the balance table for a token component 
};
```
```lua
-- Entities are just Processes that hold a list or table of components 
if not ComponentId then ComponentId = 1 end;
if not Components then Components = {} end;
```
```lua
-- systems are processes that expose handlers that the entity forwards msgs to along with the data from the respective component
Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
Handlers.add('mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
Handlers.add('burn', Handlers.utils.hasMatchingTag('Action', 'Burn'), function(msg)
    -- do something with msg.Data
    -- then send a message back to msg.From with the mutated msg.Data
end)
```

**Entity Code**: The entity process adds components to its table and dyncamically creates handlers that it uses to forward messages along with the data from the respective component to the system specified by the component.

The entity **Must** forward messages to the system specified by the component and **Must** write data to the component when recieving a message from the system spcified by the component when data is available

```lua
-- Main Execution
if not ComponentId then ComponentId = 1 end;
if not Components then Components = {} end;

Handlers.add("AddComponent", Handlers.utils.hasMatchingTag('Action', "AddComponent"), function(msg)end)
Handlers.add("RemoveComponent", Handlers.utils.hasMatchingTag('Action', "RemoveComponent"), function(msg)end)
Handlers.add("Components", Handlers.utils.hasMatchingTag('Action', "Components"), function(msg)end)
Handlers.add("Component", Handlers.utils.hasMatchingTag('Action', "Component"), function(msg)end)

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
```
---

## Web3 App Store Integration

Each ECS component and system can be treated as an individual app. Users can browse and combine these modular apps to build their own custom applications.

- **Components as Apps**: Developers can publish reusable components as apps on the decentralized marketplace.
- **Systems as Services**: Systems can be executed as on-demand services within the Web3 ecosystem.
- **Revenue Model**: Developers can monetize their components and systems through blockchain-based transactions.

---

## Testing and Debugging

To ensure correctness and performance, you’ll need to test both locally and within the AOS environment:

1. **Local Testing**: Test Lua scripts locally for syntax errors and logic verification.
2. **AOS Integration Testing**: Deploy scripts to AOS and verify their behavior in a distributed environment. Ensure that entities, components, and systems behave correctly across nodes.
3. **Blockchain Verification**: Ensure that entity states are correctly stored and retrieved from the blockchain.

---

This design document provides a solid foundation for using Lua to implement the ECS protocol on the AO computer, leveraging AOS’s blockchain and parallel processing capabilities. Let me know if you need further details!