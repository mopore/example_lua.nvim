-- This could have any name ('init' is not necessary).
-- Everything here gets executed when the plugin is loaded.
-- print("Hello from 'plugin/example.lua'!")

vim.keymap.set('n', 'asdf', ':echo "Hello from Example!"<CR>', { noremap = true })
