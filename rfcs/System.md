---
title: System
type: working-draft
draft: 1
---

```lua
Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)end)
Handlers.add('mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)end)
Handlers.add('burn', Handlers.utils.hasMatchingTag('Action', 'Burn'), function(msg)end)
```