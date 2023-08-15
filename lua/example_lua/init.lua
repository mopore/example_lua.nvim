-- All here must be required

-- This will be printed on require time:
-- From command 'lua require("example_lua")'
-- print("Hello from 'example_lua/init.lua'")

local M = {}

M.setup = function(opts)
    M._setup_value = opts.test_value
end

--[[

Call with: 
lua require("example_lua").print_setup_value()

--]]

M.print_setup_value = function()
    print("My setup value is: ", M._setup_value)
end

return M
