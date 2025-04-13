--!strict
--!optimize 2
--!native

local Config = require(script.Parent.Parent.Config)
local Factory = require(script.Parent.TypeFactory)

local DEFAULT_BUFFER_SIZE = Config.DEFAULT_BUFFER_SIZE
local BUFFER_SCALE_FACTOR = Config.BUFFER_SCALE_FACTOR
local STRING_HEADER_SIZE = Config.STRING_HEADER_SIZE
local STRING_HEADER_WRITER = Config.STRING_HEADER_WRITER
local STRING_HEADER_READER = Config.STRING_HEADER_READER

local bufferWriteu8 = buffer.writeu8
local bufferWriteu16 = buffer.writeu16
local bufferWriteu32 = buffer.writeu32
local bufferWritei8 = buffer.writei8
local bufferWritei16 = buffer.writei16
local bufferWritei32 = buffer.writei32
local bufferWritef32 = buffer.writef32
local bufferWritef64 = buffer.writef64
local bufferWriteString = buffer.writestring
local len = buffer.len
local copy = buffer.copy
local create = buffer.create
local max = math.max

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
	bufferWriteString(buf, base + STRING_HEADER_SIZE, value)
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

local function writeNumberSequenceKeypoint(value: NumberSequenceKeypoint)
	local base = reserve(12)
	bufferWritef32(buf, base + 0, value.Time)
	bufferWritef32(buf, base + 4, value.Value)
	bufferWritef32(buf, base + 8, value.Envelope)
end

local function writeCFrame(value: CFrame)
	local base = reserve(24)
	local x, y, z = value.X, value.Y, value.Z
	local rx, ry, rz = value:ToEulerAnglesXYZ()
	bufferWritef32(buf, base + 0, x)
	bufferWritef32(buf, base + 4, y)
	bufferWritef32(buf, base + 8, z)
	bufferWritef32(buf, base + 12, rx)
	bufferWritef32(buf, base + 16, ry)
	bufferWritef32(buf, base + 20, rz)
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

local function writeBoolean(value: boolean)
	local base = reserve(1)
	bufferWriteu8(buf, base, value and 1 or 0)
end

local function writeUDim2(value: UDim2)
	local base = reserve(16)
	bufferWritef32(buf, base + 0, value.X.Scale)
	bufferWritef32(buf, base + 4, value.X.Offset)
	bufferWritef32(buf, base + 8, value.Y.Scale)
	bufferWritef32(buf, base + 12, value.Y.Offset)
end

local function writeUDim(value: UDim)
	local base = reserve(8)
	bufferWritef32(buf, base + 0, value.Scale)
	bufferWritef32(buf, base + 4, value.Offset)
end

local function writeColorSequenceKeypoint(value: ColorSequenceKeypoint)
	local base = reserve(16)
	local color = value.Value
	bufferWritef32(buf, base + 0, value.Time)
	bufferWritef32(buf, base + 4, color.R)
	bufferWritef32(buf, base + 8, color.G)
	bufferWritef32(buf, base + 12, color.B)
end

local function writePhysicalProperties(value: PhysicalProperties)
	local base = reserve(16)
	bufferWritef32(buf, base + 0, value.Density)
	bufferWritef32(buf, base + 4, value.Friction)
	bufferWritef32(buf, base + 8, value.Elasticity)
	bufferWritef32(buf, base + 12, value.FrictionWeight)
end

local function createArray<T>(sample: T) : {T}
	local bufferType = Factory.get(sample)

    if not bufferType then
        error("Array type requires a valid buffer type")
    end

    local typeSize = bufferType.size
	local typeEncoder = bufferType.encoder
    local typeDecoder = bufferType.decoder

	local encode, decode
	encode = function(val: {T})
		local n = #val
		local base = reserve(STRING_HEADER_SIZE)
		STRING_HEADER_WRITER(buf, base, n)
		for i = 1, n do
		   typeEncoder(val[i])
		end
	end

    if not typeSize then
		decode = function(bufToDecode: buffer, offset: number) : ({T}, number)
			local n = STRING_HEADER_READER(bufToDecode, offset)
			local startOffset = offset
			offset += STRING_HEADER_SIZE
			local arr = {}
			for i = 1, n do
				local val, valSize = typeDecoder(bufToDecode, offset)
				if not valSize then
					error("Failed to decode array element at index " .. i)
				end
				arr[i] = val
				offset += valSize
			end
			return arr, offset - startOffset
		end
	else		
		decode = function(bufToDecode: buffer, offset: number)
			local n = STRING_HEADER_READER(bufToDecode, offset)
			offset += STRING_HEADER_SIZE
			local arr = {}
			for i = 1, n do
				arr[i] = typeDecoder(bufToDecode, offset)
				offset += typeSize
			end
			return arr, STRING_HEADER_SIZE + (typeSize * n)
		end
    end   

	return Factory.new({sample}, encode, decode)
end

local function createStruct<T>(sample : T) : T
	if typeof(sample) ~= "table" then
		error("Struct type requires a table")
	end

	local keys = {}
	for k, _ in sample do
		table.insert(keys, k)
	end
	table.sort(keys)
	local n = #keys

	local encoders = {}
	local decoders = {}
	local sizes = {}
	local isStatic = true
	local totalSize = 0

	for i, key in keys do
		local value = sample[key]
		local bufferType = Factory.get(value)
		if not bufferType then
			error("Struct type requires a valid buffer type for field " .. key)
		end
		encoders[i] = bufferType.encoder
		decoders[i] = bufferType.decoder
		local typeSize = bufferType.size
		if not typeSize then
			isStatic = false
			continue
		end
		totalSize += typeSize
		sizes[i] = typeSize
	end

	local function encode(val: T)
		if typeof(val) ~= "table" then
			error("You cannot you cannot encode a non-table value as as struct")
		end
		for i = 1, n do
			local key = keys[i]
			local encoder = encoders[i]
			encoder(val[key])
		end
	end

	local decode

	if isStatic then
		decode = function(bufToDecode: buffer, offset: number) : (T, number?)
			local val = {} :: any
			for i = 1, n do
				local key = keys[i]
				local decoder = decoders[i]
				local valSize = sizes[i]

				val[key] = decoder(bufToDecode, offset)
				offset += valSize
			end
			return val :: T, totalSize
		end
	else
		decode = function(bufToDecode: buffer, offset: number) : (T, number?)
			local val = {} :: any
			local startOffset = offset
			for i = 1, n do
				local key = keys[i]
				local decoder = decoders[i]
				local decoded, valSize = decoder(bufToDecode, offset)
				val[key] = decoded
				if not valSize then
					valSize = sizes[i]
					if not valSize then
						error("Failed to decode struct, decoder did not return a valid size")
					end
					offset += valSize
				else
					offset += valSize
				end			
			end
			return val :: T, offset - startOffset
		end
	end

	return Factory.new(sample, encode, decode, isStatic and totalSize or nil)
end

local function pop() : buffer
	local newbuf = buffer.create(cursor)
	copy(newbuf, 0, buf, 0, cursor)
	cursor = 0
	return newbuf
end

return table.freeze({
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
	writeBoolean = writeBoolean,
	writeNumberSequenceKeypoint = writeNumberSequenceKeypoint,
	writeUDim2 = writeUDim2,
	writeUDim = writeUDim,
	writeColorSequenceKeypoint = writeColorSequenceKeypoint,
	writePhysicalProperties = writePhysicalProperties,
	array = createArray,
	struct = createStruct,
	pop = pop,
})
