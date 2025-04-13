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
local playerQueueSizes = {}
local encoders = {}
local writeu8 = Writer.writeu8

local totalPackets = 0

Players.PlayerAdded:Connect(function(player : Player)
    queues[player] = {}
    playerQueueSizes[player] = 0
end)

Players.PlayerRemoving:Connect(function(player : Player)
    queues[player] = nil
    playerQueueSizes[player] = nil
end)

local function registerPacket(id : number, encoder : Types.Encoder<any>) : ()
    if encoders[id] then
        error("Packet ID already registered: " .. id)
    end
    encoders[id] = encoder
    for _, queue in queues do
        queue[id] = {}
    end
end

local function enqueue(player : Player, id : number, data : any) : ()
    local playerQueue = queues[player]
    local packetCollection = playerQueue[id]
    table.insert(packetCollection, data)
    if #packetCollection == 1 then
        playerQueueSizes[player] += 1
    end
    totalPackets += 1
end

RunService.Heartbeat:Connect(function()
    if totalPackets < 1 then return end
    for player, queue in pairs(queues) do
        local n = playerQueueSizes[player]
        if n < 1 then continue end
        if n > 255 then
            for _, packetCollection in queue do
                table.clear(packetCollection)
            end
            playerQueueSizes[player] = 0
            warn("Packet queue is too large: " .. n)
            return
        end
        writeu8(n)
        for id, packetCollection in queue do
            local count = #packetCollection
            if count < 1 then
                continue
            end
            if count > 255 then
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
        local payload = Writer.pop()
        playerQueueSizes[player] = 0
        Remote:FireClient(player, payload)
    end
    totalPackets = 0
end)

return table.freeze{
    register = registerPacket,
    enqueue = enqueue,
}