local packets = require(game.ReplicatedStorage.Tests.packets)
local Runservice = game:GetService("RunService")
local RemoteEvent = game.ReplicatedStorage:WaitForChild("RemoteEvent")
local packet = packets.testPacket3

-- Runservice.Heartbeat:Connect(function()
--     for i = 1, 255 do
--         packets.testPacket.FireServer(true)
--     end
--     for i = 1, 255 do
--         packets.testPacket2.FireServer("Hello World")
--     end
--     -- for i = 1, 255 do
--     --     packets.testPacket3.FireServer(CFrame.new(1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4))
--     -- end
--     for i = 1, 255 do
--         packets.testPacket4.FireServer(Vector3.new())
--     end
--     for i = 1, 255 do
--         packets.testPacket5.FireServer(Vector2.new())
--     end
-- end)


local parts = {}
local partsFolder = Instance.new("Folder", workspace)
partsFolder.Name = "Client"

for i = 1, 100 do
    local part = Instance.new("Part")
    part.Parent = partsFolder
    part.Color = Color3.fromRGB(0, 17, 255)
    part.Anchored = true
    table.insert(parts, part)
end

Runservice.Heartbeat:Connect(function()
    for i, part in ipairs(parts) do
        packet.FireServer{
            Id = i,
            CFrame = part.CFrame
        }
    end
    -- for i, part in ipairs(parts) do
    --    RemoteEvent:FireServer(part.CFrame, i)
    -- end
end)


return 0