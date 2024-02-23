# Org Checkbox
Small plugin to convert list into checkboxes and viceversa.

## Installation
To install the plugin, simply add the following lines with your favourite
plugin manager, the example below is using [Lazy](https://github.com/folke/lazy.nvim):

```lua
{
  "massix/org-checkbox.nvim",
  config = function()
    require("orgcheckbox").setup()
  end,
  ft = { "org" },
}
```

## Usage
The plugin automatically registers a buffer-local mapping set by default to
`<leader>oC` which, if triggered on a list item it will toggle it between a
checkbox and a standard list item.

If you want to change the default mapping, call `setup` with an `lhs` option:
```lua
{
  "massix/org-checkbox.nvim",
  config = function()
    require("orgcheckbox").setup({ lhs = "<leader>oT" })
  end,
}
```

