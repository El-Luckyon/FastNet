--!strict
--!optimize 2
--!native

-- Config.luau
-- Configuration for FastNet.

-----------------------CONFIGS----------------------------
local DEFAULT_BUFFER_SIZE = 256
local BUFFER_SCALE_FACTOR = 2
local STRING_HEADER_SIZE = 2 
local STRING_HEADER_WRITER = buffer.writeu16
local STRING_HEADER_READER = buffer.readu16
----------------------------------------------------------



return table.freeze{
    DEFAULT_BUFFER_SIZE = DEFAULT_BUFFER_SIZE,
    BUFFER_SCALE_FACTOR = BUFFER_SCALE_FACTOR,
    STRING_HEADER_SIZE = STRING_HEADER_SIZE,
    STRING_HEADER_WRITER = STRING_HEADER_WRITER,
    STRING_HEADER_READER = STRING_HEADER_READER,
}