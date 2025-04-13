--!strict
--!optimize 2
--!native

-- ClientService.luau
-- Handles packet processing on the client

local RunService = game:GetService("RunService")
local Remote = script.Parent.Parent.RemoteEvent
local Writer = require(script.Parent.Parent.Buffers.Writer)

local Types = require(script.Parent.Parent.Types)
local queue = {}
local encoders = {}
local writeu8 = Writer.writeu8
local pop = Writer.pop

local n = 0

local function registerPacket(id : number, encoder : Types.Encoder<any>) : ()
    if encoders[id] then
        error("Packet ID already registered: " .. id)
    end
    encoders[id] = encoder
    queue[id] = {}
end

local function enqueue(id : number, data : any) : ()
    local packetCollection = queue[id]
    table.insert(packetCollection, data)
    if #packetCollection == 1 then
        n += 1
    end
end

RunService.Heartbeat:Connect(function()
    if n < 1 then
      return        
    end
    if n > 255 then
        for _, packetCollection in queue do
            table.clear(packetCollection)
        end
        n = 0
        warn("Packet queue is too large: " .. n)
        return
    end
    writeu8(n)
    for id, packetCollection in queue do
        local count = #packetCollection
        if count < 1 then
            continue
        elseif count > 255 then
            warn("Packet collection is too large, Extra packets have been dropped: " .. count)
            count = 255
        end   
        local encoder = encoders[id]
        writeu8(id)
        writeu8(count)
        for i = 1, count do
            local data = packetCollection[i]
            encoder(data)
        end
        table.clear(packetCollection)
    end
    local payload = pop()
    Remote:FireServer(payload)
    n = 0
end)

return table.freeze{
    register = registerPacket,
    enqueue = enqueue,
}