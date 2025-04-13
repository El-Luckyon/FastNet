--!strict
--!optimize 2
--!native

-- Reader.luau
-- Reading data from buffers for datatypes that are not included in the Roblox buffer library.

local Config = require(script.Parent.Parent.Config)

local STRING_HEADER_READER = Config.STRING_HEADER_READER
local STRING_HEADER_SIZE = Config.STRING_HEADER_SIZE

local bufferReadString = buffer.readstring
local bufferReadu8 = buffer.readu8
local bufferReadu16 = buffer.readu16
local bufferReadu32 = buffer.readu32
local bufferReadi16 = buffer.readi16
local bufferReadf32 = buffer.readf32
local bufferCopy = buffer.copy
local bufferCreate = buffer.create

local function readString(buf: buffer, offset: number): (string, number)
    local size = STRING_HEADER_READER(buf, offset)
    local str = bufferReadString(buf, offset + STRING_HEADER_SIZE, size)
    return str, size + STRING_HEADER_SIZE
end

local function readBoolean(buf: buffer, offset: number): boolean
    return bufferReadu8(buf, offset) ~= 0
end

local function readBuffer(buf: buffer, offset: number): buffer
    local size = bufferReadu32(buf, offset)
    local newBuf = bufferCreate(size)
    bufferCopy(newBuf, 0, buf, offset + 4, size)
    return newBuf
end

local function readCFrame(buf: buffer, offset: number): CFrame
	local x = bufferReadf32(buf, offset)
	local y = bufferReadf32(buf, offset + 4)
	local z = bufferReadf32(buf, offset + 8)
	local rx = bufferReadf32(buf, offset + 12)
	local ry = bufferReadf32(buf, offset + 16)
	local rz = bufferReadf32(buf, offset + 20)

	local axis = Vector3.new(rx, ry, rz)
	local angle = axis.Magnitude

	return CFrame.fromAxisAngle(axis, angle) + Vector3.new(x, y, z)
end

local function readVector3(buf: buffer, offset: number): Vector3
    local x = bufferReadf32(buf, offset)
    local y = bufferReadf32(buf, offset + 4)
    local z = bufferReadf32(buf, offset + 8)
    return Vector3.new(x, y, z)
end

local function readVector2(buf: buffer, offset: number): Vector2
    local x = bufferReadf32(buf, offset)
    local y = bufferReadf32(buf, offset + 4)
    return Vector2.new(x, y)
end

local function readVector3int16(buf: buffer, offset: number): Vector3int16
    local x = bufferReadi16(buf, offset)
    local y = bufferReadi16(buf, offset + 2)
    local z = bufferReadi16(buf, offset + 4)
    return Vector3int16.new(x, y, z)
end

local function readVector2int16(buf: buffer, offset: number): Vector2int16
    local x = bufferReadi16(buf, offset)
    local y = bufferReadi16(buf, offset + 2)
    return Vector2int16.new(x, y)
end

local function readNumberRange(buf: buffer, offset: number): NumberRange
    local min = bufferReadf32(buf, offset)
    local max = bufferReadf32(buf, offset + 4)
    return NumberRange.new(min, max)
end

local function readbrickColor(buf: buffer, offset: number): BrickColor
    local colorNumber = bufferReadu16(buf, offset)
    return BrickColor.new(colorNumber)
end

local function readColor3(buf: buffer, offset: number): Color3
    local r = bufferReadf32(buf, offset)
    local g = bufferReadf32(buf, offset + 4)
    local b = bufferReadf32(buf, offset + 8)
    return Color3.new(r, g, b)
end

local function readNumberSequenceKeypoint(buf: buffer, offset: number): NumberSequenceKeypoint
    local time = bufferReadf32(buf, offset)
    local value = bufferReadf32(buf, offset + 4)
    local envelope = bufferReadf32(buf, offset + 8)
    return NumberSequenceKeypoint.new(time, value, envelope)
end

local function readUDim2(buf: buffer, offset: number): UDim2
    local xScale = bufferReadf32(buf, offset)
    local xOffset = bufferReadf32(buf, offset + 4)
    local yScale = bufferReadf32(buf, offset + 8)
    local yOffset = bufferReadf32(buf, offset + 12)
    return UDim2.new(xScale, xOffset, yScale, yOffset)
end

local function readUDim(buf: buffer, offset: number): UDim
    local scale = bufferReadf32(buf, offset)
    local valoffset = bufferReadf32(buf, offset + 4)
    return UDim.new(scale, valoffset)
end

local function readColorSequenceKeypoint(buf: buffer, offset: number): ColorSequenceKeypoint
    local time = bufferReadf32(buf, offset)
    local r = bufferReadf32(buf, offset + 4)
    local g = bufferReadf32(buf, offset + 8)
    local b = bufferReadf32(buf, offset + 12)
    return ColorSequenceKeypoint.new(time, Color3.new(r, g, b))
end

local function readPhysicalProperties(buf: buffer, offset: number): PhysicalProperties
    local density = bufferReadf32(buf, offset)
    local elasticity = bufferReadf32(buf, offset + 4)
    local friction = bufferReadf32(buf, offset + 8)
    local frictionWeight = bufferReadf32(buf, offset + 12)
    local elasticityWeight = bufferReadf32(buf, offset + 16)
    return PhysicalProperties.new(density, elasticity, friction, frictionWeight, elasticityWeight)
end

return table.freeze{
    string = readString,
    boolean = readBoolean,
    buffer = readBuffer,
    cframe = readCFrame,
    vector3 = readVector3,
    vector2 = readVector2,
    vector3int16 = readVector3int16,  
    vector2int16 = readVector2int16,
    numberRange = readNumberRange,
    brickColor = readbrickColor,
    color3 = readColor3,
    numberSequenceKeypoint = readNumberSequenceKeypoint,
    udim2 = readUDim2,
    udim = readUDim,
    colorSequenceKeypoint = readColorSequenceKeypoint,
    physicalProperties = readPhysicalProperties,
}
