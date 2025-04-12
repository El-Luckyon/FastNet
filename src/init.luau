--!strict
--!optimize 2
--!native

-- FastNet.luau
-- Main script starts process and acts as the api.

local Writer = require(script.Buffers.Writer)
local Reader = require(script.Buffers.Reader)
local Factory = require(script.Buffers.TypeFactory)

local Config = require(script.Config)

return table.freeze{
    unsigned_8Bit_Integer = Factory.new(1, Writer.writeu8, buffer.readu8, 1),
    unsigned_16Bit_Integer = Factory.new(2, Writer.writeu16, buffer.readu16, 2),
    unsigned_32Bit_Integer = Factory.new(3, Writer.writeu32, buffer.readu32, 4),
    signed_8Bit_Integer = Factory.new(4, Writer.writei8, buffer.readi8, 1),
    signed_16Bit_Integer = Factory.new(5, Writer.writei16, buffer.readi16, 2),
    signed_32Bit_Integer = Factory.new(6, Writer.writei32, buffer.readi32, 4),
    float_32Bit = Factory.new(7, Writer.writef32, buffer.readf32, 4),
    float_64Bit = Factory.new(8, Writer.writef64, buffer.readf64, 8),
    boolean = Factory.new(false, Writer.writeBoolean, Reader.boolean, 1),
    buffer = Factory.new(buffer.create(1), Writer.writeBuffer, Reader.buffer),
    cframe = Factory.new(CFrame.new(), Writer.writeCFrame, Reader.cframe, 24),
    vector3 = Factory.new(Vector3.new(), Writer.writeVector3, Reader.vector3, 12),
    vector2 = Factory.new(Vector2.new(), Writer.writeVector2, Reader.vector2, 8),
    vector2int16 = Factory.new(Vector2int16.new(), Writer.writeVector2int16, Reader.vector2int16, 4),
    vector3int16 = Factory.new(Vector3int16.new(), Writer.writeVector3int16, Reader.vector3int16, 6),
    brickColor = Factory.new(BrickColor.new(1), Writer.writeBrickColor, Reader.brickColor, 2),
    numberRange = Factory.new(NumberRange.new(0, 1), Writer.writeNumberRange, Reader.numberRange, 8),
    NumberSequenceKeypoint = Factory.new(NumberSequenceKeypoint.new(0, 0, 0), Writer.writeNumberSequenceKeypoint, Reader.numberSequenceKeypoint, 12),
    color3 = Factory.new(Color3.new(), Writer.writeColor3, Reader.color3, 12),
    udim2 = Factory.new(UDim2.new(), Writer.writeUDim2, Reader.udim2, 16),
    udim = Factory.new(UDim.new(), Writer.writeUDim, Reader.udim, 8),
    colorSequenceKeypoint = Factory.new(ColorSequenceKeypoint.new(0, Color3.new()), Writer.writeColorSequenceKeypoint, Reader.colorSequenceKeypoint, 16),
    physicalProperties = Factory.new(PhysicalProperties.new(1, 1, 1), Writer.writePhysicalProperties, Reader.physicalProperties, 16),
    string = Factory.new("", Writer.writeString, Reader.string),

    array = Writer.array,


}