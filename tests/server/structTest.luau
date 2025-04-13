--!strict
--!optimize 2


local FastNet = require(game.ReplicatedStorage.FastNet)
local TypeFactory = require(game.ReplicatedStorage.FastNet.Buffers.TypeFactory)
local Writer = require(game.ReplicatedStorage.FastNet.Buffers.Writer)

local struct = FastNet.struct{
    a = FastNet.boolean,
    b = FastNet.string,
    c = FastNet.unsigned_8Bit_Integer,
    d = FastNet.array(FastNet.vector3),
    e = FastNet.struct{
        a = FastNet.boolean,
        b = FastNet.string,
        c = FastNet.unsigned_8Bit_Integer,
        d = FastNet.array(FastNet.vector3),
        e = FastNet.struct{
            a = FastNet.boolean,
            b = FastNet.string,
            c = FastNet.unsigned_8Bit_Integer,
            d = FastNet.array(FastNet.vector3),
            e = FastNet.struct{
                a = FastNet.boolean,
                b = FastNet.string,
                c = FastNet.unsigned_8Bit_Integer,
                d = FastNet.array(FastNet.vector3),
                e = FastNet.struct{
                    a = FastNet.boolean,
                    b = FastNet.string,
                    c = FastNet.unsigned_8Bit_Integer,
                    d = FastNet.array(FastNet.vector3),
                    e = FastNet.struct{
                        a = FastNet.boolean,
                        b = FastNet.string,
                        c = FastNet.unsigned_8Bit_Integer,
                        d = FastNet.array(FastNet.vector3),
                        e = FastNet.struct{
                            a = FastNet.boolean,
                            b = FastNet.string,
                            c = FastNet.unsigned_8Bit_Integer,
                            d = FastNet.array(FastNet.vector3),
                            e = FastNet.struct{
                                a = FastNet.boolean,
                                b = FastNet.string,
                                c = FastNet.unsigned_8Bit_Integer,
                                d = FastNet.array(FastNet.vector3),
                            },
                        },
                    },
                },
            },
        },
    },
}

local structType = TypeFactory.get(struct)

if not structType then
    error("Failed to create struct type")
end

local st = os.clock()
structType.encoder{
    a = true,
    b = "hello",
    c = 1,
    d = {Vector3.new(1, 2, 3), Vector3.new(4, 5, 6)},
    e = {
        a = false,
        b = "world",
        c = 2,
        d = {Vector3.new(7, 8, 9), Vector3.new(10, 11, 12)},
        e = {
            a = true,
            b = "nested",
            c = 3,
            d = {Vector3.new(13, 14, 15), Vector3.new(16, 17, 18)},
            e = {
                a = false,
                b = "deep",
                c = 4,
                d = {Vector3.new(19, 20, 21), Vector3.new(22, 23, 24)},
                e = {
                    a = true,
                    b = "deeper",
                    c = 5,
                    d = {Vector3.new(25, 26, 27), Vector3.new(28, 29, 30)},
                    e = {
                        a = false,
                        b = "deepest",
                        c = 6,
                        d = {Vector3.new(31, 32, 33), Vector3.new(34, 35, 36)},
                        e = {
                            a = true,
                            b = "final",
                            c = 7,
                            d = {Vector3.new(37, 38, 39), Vector3.new(40, 41, 42)},
                            e = {
                                a = true,
                                b = "finalForSure",
                                c = 7,
                                d = {Vector3.new(43, 44, 45), Vector3.new(46, 47, 48)},
                            },
                        },
                    },
                },
            },
        },
    },
}

local encodedValue = Writer.pop()
print("Time taken to encode: " .. (os.clock() - st) .. " seconds")

print(buffer.len(encodedValue))
print(buffer.tostring(encodedValue))

st = os.clock()
local decodedValue = structType.decoder(encodedValue, 0)
print("Time taken to decode: " .. (os.clock() - st) .. " seconds")

print(decodedValue)


return 0