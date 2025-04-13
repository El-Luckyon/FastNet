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

local n = 0

local function registerPacket(id : number, encoder : Types.Encoder<any>) : ()
    if encoders[id] then
        error("Packet ID already registered: " .. id)
    end
    encoders[id] = encoder
end

local function enqueue(id : number, data : any) : ()
    local packetCollection = queue[id]
    if not packetCollection then
        queue[id] = {data}
    else
        table.insert(packetCollection, data)
    end
    n += 1
end

RunService.Heartbeat:Connect(function()
    if n > 0 then
        if n > 255 then
            error("Packet queue is too large: " .. n)
        end
        writeu8(n)
        for id, packetCollection in queue do
            local count = #packetCollection
            if count < 1 then
                error("Packet collection is too large: " .. count)
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
        local payload = Writer.pop()
        Remote:FireServer(payload)
    end
end)

return table.freeze{
    register = registerPacket,
    enqueue = enqueue,
}