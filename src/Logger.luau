--!strict
--!optimize 2
--!native

-- Logger.luau
-- This module is responsible for logging messages to the console.

return function(format : string, ...: any): ()
   print("[Fast-Net] ", string.format(format, ...))
end