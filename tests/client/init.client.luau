--!strict
--!optimize 2

-- Client.luau
-- Runs client tests.

if not game:IsLoaded() then
    game.Loaded:Wait()
end

require(script.FullTestClient)