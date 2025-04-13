--!strict
--!optimize 2
--!native

-- ServerPacket.luau
-- Server packet consturctor.

local Types = require(script.Parent.Parent.Types)
local newSignal = require(script.Parent.Parent.Signal)
local ServerService = require(script.Parent.Parent.Services.ServerService)
local Remote = script.Parent.Parent.RemoteEvent
local TypeFactory = require(script.Parent.Parent.Buffers.TypeFactory)
local Players = game:GetService("Players")
local readu8 = buffer.readu8

local function illegalFireServer<T>(_data : T) : ()
    error("FireServer is not allowed on the server.")
end

local function invalidSignalEnvironment<T>()
    error("This signal is not allowed in the server.")
end

local illegalClientEvent = {
    Fire = invalidSignalEnvironment,
    Connect = invalidSignalEnvironment,
    Once = invalidSignalEnvironment,
    Wait = invalidSignalEnvironment,
    Destroy = invalidSignalEnvironment,
}

local decoders : {Types.Decoder<any>} = {}
local signals : {Types.Signal<...any>} = {}
local sizes : {number} = {}

local packetIdCounter = 1

Remote.OnServerEvent:Connect(function(player : Player, buf : buffer)
    local n = readu8(buf, 0)
    local offset = 1
    for i = 1, n do
        local id = readu8(buf, offset)
        local count = readu8(buf, offset + 1)
        offset += 2
        local decoder = decoders[id]
        local signal = signals[id]  
        for _ = 1, count do
            local data, size = decoder(buf, offset)
            if not size then
                size = sizes[id]
                if not size then
                    error("Invalid packet size: " .. id)
                end
                offset += size
            else
                offset += size
            end
            signal.Fire(player, data)
        end
    end
end)

return function<T>(sample : T) : Types.Packet<T>
    local packetType = TypeFactory.get(sample)

    if not packetType then
        error("Invalid packet type: " .. tostring(sample))
    end

    if packetIdCounter > 255 then
        error("Packet ID overflow: " .. packetIdCounter)
    end

    local id = packetIdCounter
    packetIdCounter += 1

    local serverEvent = newSignal()

    local function fireClient(player : Player, data : T) : ()
        ServerService.enqueue(player, id, data)
    end

    local function fireAllClients(data : T) : ()
        for _, player in Players:GetPlayers() do
            ServerService.enqueue(player, id, data)
        end
    end

    decoders[id] = packetType.decoder
    signals[id] = serverEvent

    local size = packetType.size
    if size then
        sizes[id] = size
    end

    return table.freeze{
        FireServer = illegalFireServer,
        FireClient = fireClient,
        FireAllClients = fireAllClients,
        OnServerEvent = serverEvent,
        OnClientEvent = illegalClientEvent,
    }
end

