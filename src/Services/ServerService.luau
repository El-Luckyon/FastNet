--!strict
--!optimize 2
--!native

-- ServerService.luau
-- Handles packet processing on the server

local RunService = game:GetService("RunService")
local Remote = script.Parent.Parent.RemoteEvent
local Writer = require(script.Parent.Parent.Buffers.Writer)
local Players = game:GetService("Players")

local Types = require(script.Parent.Parent.Types)
local queues = {}
local encoders = {}
local writeu8 = Writer.writeu8

local totalPackets = 0

Players.PlayerAdded:Connect(function(player : Player)
    queues[player] = {}
end)

local function registerPacket(id : number, encoder : Types.Encoder<any>) : ()
    if encoders[id] then
        error("Packet ID already registered: " .. id)
    end
    encoders[id] = encoder
end

local function enqueue(player : Player, id : number, data : any) : ()
    local playerQueue = queues[player]
    local packetCollection = playerQueue[id]
    if not packetCollection then
        playerQueue[id] = {data}
    else
        table.insert(packetCollection, data)
    end
    totalPackets += 1
end

RunService.Heartbeat:Connect(function()
    if totalPackets < 1 then return end
    for player, queue in pairs(queues) do
        local n = #queue
        if n < 1 then return end
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
        Remote:FireClient(player, payload)
    end
end)

return table.freeze{
    register = registerPacket,
    enqueue = enqueue,
}