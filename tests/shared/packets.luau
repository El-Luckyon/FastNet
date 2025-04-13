local FastNet = require(script.Parent.Parent.FastNet)

return table.freeze{
    testPacket = FastNet.packet(FastNet.boolean),
    testPacket2 = FastNet.packet(FastNet.string),
    testPacket3 = FastNet.packet(FastNet.struct{
        Id = FastNet.unsigned_8Bit_Integer,
        CFrame = FastNet.cframe,
    }),
    testPacket4 = FastNet.packet(FastNet.vector3),
    testPacket5 = FastNet.packet(FastNet.vector2),
}
