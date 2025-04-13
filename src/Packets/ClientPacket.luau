--!strict
--!optimize 2
--!native

-- ClientPacket.luau
-- Client packet consturctor.

local Types = require(script.Parent.Parent.Types)
local TypeFactory = require(script.Parent.Parent.Buffers.TypeFactory)
local ClientService = require(script.Parent.Parent.Services.ClientService)
local Remote = script.Parent.Parent.RemoteEvent

local readu8 = buffer.readu8

local newSignal = require(script.Parent.Parent.Signal)

local function illegalFireClient<T>(_player: Player, _data: T) : ()
    error("FireServer is not allowed on the client.")
end

local function illegalFireAllClients<T>(_data: T) : ()
    error("FireServer is not allowed on the client.")
end

local function invalidSignalEnvironment<T>()
    error("This signal is not allowed in the server.")
end

local illegalServerEvent = {
    Fire = invalidSignalEnvironment,
    Connect = invalidSignalEnvironment,
    Once = invalidSignalEnvironment,
    Wait = invalidSignalEnvironment,
    Destroy = invalidSignalEnvironment,
}

local packetIdCounter = 1
local decoders : {Types.Decoder<any>} = {}
local signals : {Types.Signal<...any>} = {}
local sizes : {number} = {}

Remote.OnClientEvent:Connect(function(buf : buffer)
    local n = readu8(buf, 0)
    local offset = 1
    for i = 1, n do
        local id = readu8(buf, i)        
        local count = readu8(buf, i + 1)
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
            signal.Fire(data)
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

    local clientEvent = newSignal()
    local id = packetIdCounter
    packetIdCounter += 1

    local function fireServer(data: T): ()
        ClientService.enqueue(id, data)
    end

    ClientService.register(id, packetType.encoder)
    decoders[id] = packetType.decoder
    signals[id] = clientEvent

    local packetSize = packetType.size
    if packetSize then
        sizes[id] = packetSize
    end

    return table.freeze{
        FireServer = fireServer,
        FireClient = illegalFireClient,
        FireAllClients = illegalFireAllClients,
        OnServerEvent = illegalServerEvent,
        OnClientEvent = clientEvent,
    }
end

