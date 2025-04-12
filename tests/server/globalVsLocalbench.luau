-- Number of iterations for the benchmark
local iterations = 10e6

-- Global variable (stored in _G)
local globalVar = 1

-- Function that benchmarks global variable access
local function benchmarkGlobal()
    local sum = 0
    local clock = os.clock
    local t0 = clock()
    for i = 1, iterations do
        sum = sum + globalVar
    end
    print("Global sum:", sum, "Time:", clock() - t0)
end

-- Function that benchmarks local variable access
local function benchmarkLocal()
    local localVar = 1  -- local variable inside the function
    local sum = 0
    local clock = os.clock
    local t0 = clock()
    for i = 1, iterations do
        sum = sum + localVar
    end
    print("Local sum:", sum, "Time:", clock() - t0)
end

-- Run the benchmarks
benchmarkGlobal()
benchmarkLocal()

return 0
