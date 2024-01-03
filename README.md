```
 _____                           _        _                
| ____|_  ____ _ _ __ ___  _ __ | | ___  | |   _   _  __ _ 
|  _| \ \/ / _` | '_ ` _ \| '_ \| |/ _ \ | |  | | | |/ _` |
| |___ >  < (_| | | | | | | |_) | |  __/ | |__| |_| | (_| |
|_____/_/\_\__,_|_| |_| |_| .__/|_|\___| |_____\__,_|\__,_|
                          |_|                              
```
This is an example for a lua plugin for neovim.

# Quick Local Development
To try out some Lua just create a file `test.lua`, save it and source it with:
`:so %`
You can than run any function in this file with `:lua <function_name>()`.


# Plugin Directory structure
```
.
├── lua
│   └── example_lua
│       ├── init.lua
│       └── utils.lua
└── plugin
    └── init.lua
```

All in `./lua` must be required to be loaded `:lua require("example_lua")`
The `example_lua` should match somehow with the plugin name.

All in `./plugin` will be executed when the plugin is loaded.
You can put here keymaps as an example (as shown in the source file).


# Loading a plugin
To add a local plugin add the following plugin information to your lazy.nvim 
setup:

```lua
require('lazy').setup({
-- ...
  {
    'mopore/example_lua.nvim',
    dev = true,
    dir = '/Users/jni/Dev/git_rep/example_lua.nvim',
    setup = true,  -- Triggers the loading of the setup function
  },
```


# Setup a plugin
The plugin must be setup by the name it is also required.

```lua
require('example_lua').setup({  -- JNI addition
  test_value = 'Input from setup callback',
})
```


# Implementation
Given the consumer is requiring `example_lua` the `lua/example_lua/init.lua` 
file will provide a table object with the setup function (as required above) 
and additional functions.

```lua
local M = {}

M.setup = function(opts)
    M._setup_value = opts.test_value
end

M.print_setup_value = function()
    print("My setup value is: ", M._setup_value)
end

return M
```


# Using a plugin function
The `print_setup_value` function can be called from the command line with 
`:lua require("example_lua").print_setup_value()`.


# Global function
A global function can be setup in the global init.lua file.

```lua
JNI_HELLO = function()
  print("Hello from JNI!")
end
```

It can be called from the command line with `:lua JNI_HELLO()`

# Miscellanous

## Commands
### User commands
A user command can be called like `:TestMe` and created like:
```lua
vim.api.nvim_create_user_command("TestMe", TestMe, {})
```

### Keymapping
```lua
vim.keymap.set('n', 'asdf', ':TestMe<CR>', { noremap = true })
```

### Autocommands
To attach to a Neovim event you can use "autocommands" like:
```lua
vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("JniAdditions", { clear = true }),
    callback = TestMe,
    pattern = "*.lua",
})
```
To open the documentation for events use `:h events`.
The group is there to avoid multiple registrations of the same event when
rerunning.

## Examples

### Example for reloading a plugin on save
(you need to source the file with `:so %`)
```lua
vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("JniAdditions", { clear = true }),
    callback = function ()
        -- Reload my plugin on saving a lua file
        package.loaded["JniAdditions"] = nil
        require("JniAdditions").load()
    end,
    pattern = "*.lua",
})
```

### Advanced example
Source with `:so %` 
This will add text to the current buffer from the output of a called command
`helloworld`.

```lua
local function writeInThisBuffer(data)
    -- Tow write into a specific buffer, you need to get its number.
    --
    -- Create new buffer with `:new` and get its number by entering
    -- `:echo nvim_get_current_buf()` (in command mode).

    local buffNr = vim.api.nvim_get_current_buf()
    -- vim.api.nvim_buf_set_lines(buffNr, 0, -1, false, data)  -- replace
    vim.api.nvim_buf_set_lines(buffNr, -1, -1, false, data)  -- append
end


function TestMe()
    local input_lines = {"helloworld", "{\"name\": \"Ben\"}"}
    vim.fn.jobstart(input_lines, {
        stdout_buffered = true,
        -- The content of data is the copied json input.
        on_stdout = function(_, data)
            if data then
                writeInThisBuffer(data)
            end
        end,
    })
end

-- Make the function available as user command "TestMe".
vim.api.nvim_create_user_command("TestMe", TestMe, {})

-- Type 'asdf' in normal mode to trigger the user command 'TestMe'.
vim.keymap.set('n', 'asdf', ':TestMe<CR>', { noremap = true })

-- Source this file once with 'so %', afterward you can use <leader>%
vim.keymap.set('n', '<leader>%', ':source %<CR>', { noremap = true })

```


