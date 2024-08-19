local bint = require('.bint')(256)
local ao = require('ao')

Handlers.add("Transfer", Handlers.utils.hasMatchingTag('Action', "Transfer"), function(msg)
    ao.send({
        Target = msg.From,
        Action = "Credit-Notice",
        Tags = msg.Tags,
        Sender = msg.Sender
    });
end)

Handlers.add("Balance", Handlers.utils.hasMatchingTag('Action', "Balance"), function(msg)
    ao.send({
        Target = msg.From,
        Action = "Balance-Notice",
        Sender = msg.Sender,
        Balance = "100000000000000000"
    });
end)