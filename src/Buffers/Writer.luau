--!strict
--!optimize 2
--!native

local Config = require(script.Parent.Parent.Config)
local DEFAULT_BUFFER_SIZE = Config.DEFAULT_BUFFER_SIZE
local BUFFER_SCALE_FACTOR = Config.BUFFER_SCALE_FACTOR
local STRING_HEADER_SIZE = Config.STRING_HEADER_SIZE
local STRING_HEADER_WRITER = Config.STRING_HEADER_WRITER

local bufferWriteu8     = buffer.writeu8
local bufferWriteu16    = buffer.writeu16
local bufferWriteu32    = buffer.writeu32
local bufferWritei8     = buffer.writei8
local bufferWritei16    = buffer.writei16
local bufferWritei32    = buffer.writei32
local bufferWritef32    = buffer.writef32
local bufferWritef64    = buffer.writef64
local bufferWriteString = buffer.writestring
local len               = buffer.len
local copy              = buffer.copy
local create            = buffer.create
local max               = math.max

local buf = create(DEFAULT_BUFFER_SIZE)
local size = DEFAULT_BUFFER_SIZE
local cursor = 0

-- Reserve n bytes and return the base offset from which to write
local function reserve(n: number): number
    local base = cursor
    cursor = cursor + n
    if cursor > size then
        size = max(size * BUFFER_SCALE_FACTOR, cursor)
        local newbuf = create(size)
        copy(newbuf, 0, buf, 0, base)
        buf = newbuf
    end
    return base
end

local function writeu8(value: number)
    local base = reserve(1)
    bufferWriteu8(buf, base, value)
end

local function writeu16(value: number)
    local base = reserve(2)
    bufferWriteu16(buf, base, value)
end

local function writeu32(value: number)
    local base = reserve(4)
    bufferWriteu32(buf, base, value)
end

local function writei8(value: number)
    local base = reserve(1)
    bufferWritei8(buf, base, value)
end

local function writei16(value: number)
    local base = reserve(2)
    bufferWritei16(buf, base, value)
end

local function writei32(value: number)
    local base = reserve(4)
    bufferWritei32(buf, base, value)
end

local function writef32(value: number)
    local base = reserve(4)
    bufferWritef32(buf, base, value)
end

local function writef64(value: number)
    local base = reserve(8)
    bufferWritef64(buf, base, value)
end

local function writeString(value: string)
    local l = #value
    local total = l + STRING_HEADER_SIZE
    local base = reserve(total)
    STRING_HEADER_WRITER(buf, base, l)
    bufferWriteString(buf, base, value)
end

local function writeVector2(value: Vector2)
    local base = reserve(8)
    bufferWritef32(buf, base + 0, value.X)
    bufferWritef32(buf, base + 4, value.Y)
end

local function writeVector3(value: Vector3)
    local base = reserve(12)
    bufferWritef32(buf, base + 0, value.X)
    bufferWritef32(buf, base + 4, value.Y)
    bufferWritef32(buf, base + 8, value.Z)
end

local function writeVector2int16(value: Vector2int16)
    local base = reserve(4)
    bufferWritei16(buf, base + 0, value.X)
    bufferWritei16(buf, base + 2, value.Y)
end

local function writeVector3int16(value: Vector3int16)
    local base = reserve(6)
    bufferWritei16(buf, base + 0, value.X)
    bufferWritei16(buf, base + 2, value.Y)
    bufferWritei16(buf, base + 4, value.Z)
end

local function writeBrickColor(value: BrickColor)
    local base = reserve(2)
    bufferWriteu16(buf, base, value.Number)
end

local function writeNumberRange(value: NumberRange)
    local base = reserve(8)
    bufferWritef32(buf, base + 0, value.Min)
    bufferWritef32(buf, base + 4, value.Max)
end

-- Write a CFrame as 6 floats (position and rotation encoded via AxisAngle)
local function writeCFrame(value: CFrame)
    local base = reserve(24)
    local x, y, z = value.X, value.Y, value.Z
    local axis, angle = value:ToAxisAngle()
    axis = axis * angle
    bufferWritef32(buf, base + 0, x)
    bufferWritef32(buf, base + 4, y)
    bufferWritef32(buf, base + 8, z)
    bufferWritef32(buf, base + 12, axis.X)
    bufferWritef32(buf, base + 16, axis.Y)
    bufferWritef32(buf, base + 20, axis.Z)
end

local function writeColor3(value: Color3)
    local base = reserve(12)
    bufferWritef32(buf, base + 0, value.R)
    bufferWritef32(buf, base + 4, value.G)
    bufferWritef32(buf, base + 8, value.B)
end

local function writeBuffer(value: buffer)
    local bufferSize = len(value)
    local base = reserve(bufferSize)
    copy(buf, base, value)
end


return table.freeze{
    writeu8 = writeu8,
    writeu16 = writeu16,
    writeu32 = writeu32,
    writei8 = writei8,
    writei16 = writei16,
    writei32 = writei32,
    writef32 = writef32,
    writef64 = writef64,
    writeString = writeString,
    writeVector2 = writeVector2,
    writeVector3 = writeVector3,
    writeVector2int16 = writeVector2int16,
    writeVector3int16 = writeVector3int16,
    writeBrickColor = writeBrickColor,
    writeNumberRange = writeNumberRange,
    writeCFrame = writeCFrame,
    writeBuffer = writeBuffer,
    writeColor3 = writeColor3,
    reserve = reserve,
}
