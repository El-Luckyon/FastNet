--!strict
--!optimize 2
--!native

-- TypeFactory.luau
-- This module is responsible for creating and managing buffer types.

export type Encoder<T> = (value: T, size: number?) -> ()
export type Decoder<T> = (buf: buffer, cursor: number) -> (T, number?)

export type BufferType<T> = {
    sample: T,
    encoder: Encoder<T>,
    decoder: Decoder<T>,
    size : number?,
}

local hashToType : {[string]: BufferType<any>} = {}

-- Returns a hash for the given sample
local function hashSample(sample: any): string
    local sampleType = typeof(sample)

    if sampleType == "number" then
        return "number/"..tostring(sample)
    elseif sampleType == "string" then
        return "string/"..sample
    elseif sampleType == "boolean" then
        return "bool/"..tostring(sample)
    elseif sampleType == "table" then
        return "table/"..tostring(sample)
    elseif sampleType == "buffer" then
        return "buffer/"..tostring(sample)
    elseif sampleType == "Vector3" then
        return "Vector3/"..sample.X
    elseif sampleType == "Vector2" then
        return "Vector2/"..sample.X
    elseif sampleType == "CFrame" then
        return "CFrame/"..sample.Position.X
    elseif sampleType == "UDim2" then
        return "UDim2/"..sample.X.Scale
    elseif sampleType == "UDim" then
        return "UDim/"..sample.Scale
    elseif sampleType == "Color3" then
        return "Color3/"..sample.R
    elseif sampleType == "ColorSequence" then
        return "ColorSequence/"..sample.Keypoints[1].Value.R
    elseif sampleType == "ColorSequenceKeypoint" then
        return "ColorSequenceKeypoint/"..sample.Value.R
    elseif sampleType == "NumberRange" then
        return "NumberRange/"..sample.Min
    elseif sampleType == "NumberSequence" then
        return "NumberSequence/"..sample.Keypoints[1].Value.R
    elseif sampleType == "NumberSequenceKeypoint" then
        return "NumberSequenceKeypoint/"..sample.Value
    elseif sampleType == "Ray" then
        return "Ray/"..sample.Origin.X
    elseif sampleType == "Rect" then
        return "Rect/"..sample.Min.X
    elseif sampleType == "Region3" then
        return "Region3/"..sample.CFrame.Position.X
    elseif sampleType == "Region3int16" then
        return "Region3int16/"..sample.CFrame.Position.X
    elseif sampleType == "BrickColor" then
        return "BrickColor/"..sample.Number
    elseif sampleType == "Vector2int16" then
        return "Vector2int16/"..sample.X
    elseif sampleType == "Vector3int16" then
        return "Vector3int16/"..sample.X
    elseif sampleType == "RaycastParams" then
        return "RaycastParams/"..tostring(sample.FilterDescendantsInstances)
    elseif sampleType == "RaycastResult" then
        return "RaycastResult/"..sample.Position.X
    elseif sampleType == "TweenInfo" then
        return "TweenInfo/"..sample.Time
    elseif sampleType == "PathWaypoint" then
        return "PathWaypoint/"..sample.Position.X
    elseif sampleType == "EnumItem" then
        return "EnumItem/"..sample.Name
    elseif sampleType == "Instance" then
        return "Instance/"..sample.ClassName.."/"..tostring(sample:GetFullName())
    elseif sampleType == "PhysicalProperties" then
        return "PhysicalProperties/"..sample.Density
    end

    return "null"
end

local function defineType<T>(sample: T, encoder: Encoder<T>, decoder: Decoder<T>, size : number?): T

    local hash = hashSample(sample)

    if hashToType[hash] then
        error(string.format("Type already defined for hash: %s", hash))
    end

    local bufferType: BufferType<T> = {
        sample = sample,
        encoder = encoder,
        decoder = decoder,
        size = size,
    }

    hashToType[hash] = bufferType
    return sample
end

local function getType<T>(sample: T): BufferType<T>?
    local hash = hashSample(sample)
    return hashToType[hash]
end

return {
    new = defineType,
    get = getType,
}