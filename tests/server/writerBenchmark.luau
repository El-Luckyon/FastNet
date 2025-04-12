--!strict
--!optimize 2
--!native

local DEFAULT_BUFFER_SIZE = 1024
local BUFFER_SCALE_FACTOR = 2

-- Cached buffer library methods
local bufferWritef32 = buffer.writef32
local len = buffer.len
local copy = buffer.copy
local create = buffer.create
local max = math.max

-- Global buffer state (for both implementations)
local buf = create(DEFAULT_BUFFER_SIZE)
local size = DEFAULT_BUFFER_SIZE
local cursor = 0

-- Original alloc function
local function alloc()
	if cursor > size then
		size = max(size * BUFFER_SCALE_FACTOR, cursor)
		local newbuf = create(size)
		copy(newbuf, 0, buf)
		buf = newbuf
	end
end

-- Optimized: Reserve helper that does one addition & alloc call
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

-- For our benchmark, we encode a CFrame as 6 floats: 3 for Position and 3 for rotation via AxisAngle
-- The rotation is encoded as (axis * angle), which is a simple representation.

-- Optimized method: Use reserve to compute the offset once.
local function writeCFrame_Reserve(value: CFrame)
	local base = reserve(24) -- 6 * 4 bytes
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

-- Direct method: Increment cursor inline with each write.
local function writeCFrame_Direct(value: CFrame)
	cursor += 24
	alloc()
	local x, y, z = value.X, value.Y, value.Z
	local axis, angle = value:ToAxisAngle()
	axis = axis * angle
	bufferWritef32(buf, cursor - 24, x)
	bufferWritef32(buf, cursor - 20, y)
	bufferWritef32(buf, cursor - 16, z)
	bufferWritef32(buf, cursor - 12, axis.X)
	bufferWritef32(buf, cursor - 8, axis.Y)
	bufferWritef32(buf, cursor - 4, axis.Z)
end

-- Benchmark code
local NUM_ITERATIONS = 1000000
local testCFrame = CFrame.new(1, 2, 3) * CFrame.Angles(math.pi / 4, math.pi / 6, math.pi / 3)

-- Benchmark for reserve method
cursor = 0
buf = create(DEFAULT_BUFFER_SIZE)
size = DEFAULT_BUFFER_SIZE
local startReserve = os.clock()
for i = 1, NUM_ITERATIONS do
	writeCFrame_Reserve(testCFrame)
end
local reserveTime = os.clock() - startReserve

-- Benchmark for direct method
cursor = 0
buf = create(DEFAULT_BUFFER_SIZE)
size = DEFAULT_BUFFER_SIZE
local startDirect = os.clock()
for i = 1, NUM_ITERATIONS do
	writeCFrame_Direct(testCFrame)
end
local directTime = os.clock() - startDirect

print("Reserve method time: " .. reserveTime)
print("Direct method time:  " .. directTime)

return 0
