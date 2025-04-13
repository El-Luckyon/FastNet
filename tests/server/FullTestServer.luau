local packets = require(game.ReplicatedStorage.Tests.packets)
local RemoteEvent = game.ReplicatedStorage:WaitForChild("RemoteEvent")

local parts = {}
local partsFolder = Instance.new("Folder", workspace)
partsFolder.Name = "Server"

for i = 1, 100 do
    local part = Instance.new("Part")
    part.Parent = partsFolder
    part.Color = Color3.fromRGB(0, 255, 0)
    part.Anchored = true
    part.Transparency = 0.5
    table.insert(parts, part)
end

packets.testPacket.OnServerEvent.Connect(function(player, data)
    -- print("Received packet from player:", player, "Data:", data)
end)

packets.testPacket2.OnServerEvent.Connect(function(player, data)
    -- print("Received packet from player:", player, "Data:", data)
end)

packets.testPacket3.OnServerEvent.Connect(function(player, data)
    parts[data.Id].CFrame = data.CFrame
end)

packets.testPacket4.OnServerEvent.Connect(function(player, data)
    -- print("Received packet from player:", player, "Data:", data)
end)

packets.testPacket5.OnServerEvent.Connect(function(player, data)
    -- print("Received packet from player:", player, "Data:", data)
end)

RemoteEvent.OnServerEvent:Connect(function(player, cf, id)
    parts[id].CFrame = cf
end)

return 0