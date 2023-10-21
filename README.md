# ferris.nvim 🦀
a neovim plugin for interacting with Rust Analyzer's LSP extensions

## installation & usage
_note: this plugin has only been tested with neovim 0.9+_

with lazy.nvim:
```lua
{
    'vxpm/ferris.nvim'
    opts = {
        -- your options here
    }
}
```
 
the available options (and their default values) are:
```lua
{
    -- If true, will automatically create commands for each LSP method
    create_commands = true, -- bool
    -- Handler for URL's (used for opening documentation)
    url_handler = "xdg-open", -- string | function(string)
}
```
 
you can also manually call the methods by requiring them:
```lua
local view_mem_layout = require("ferris.methods.view_memory_layout")

-- call the returned function to execute the request
view_mem_layout()
```
don't forget to call `setup` on `require("ferris")` beforehand, though! (not needed if
you're using the `opts` field in lazy.nvim)

## available methods
<sub><sup>please do not mind the terrible screenshots... i was too lazy</sub></sup>

<details>
<summary>Expand Macro</summary>

`require("ferris.methods.expand_macro")`

[![image.png](https://i.postimg.cc/8zfhSB9p/image.png)](https://postimg.cc/G4rBPYbV)
</details>

<details>
<summary>Join Lines</summary>

`require("ferris.methods.join_lines")`
</details>

<details>
<summary>View HIR</summary>

`require("ferris.methods.view_hir")`

[![image.png](https://i.postimg.cc/nr5CRNHv/image.png)](https://postimg.cc/bSxydCSJ)
</details>

<details>
<summary>View MIR</summary>

`require("ferris.methods.view_mir")`

[![image.png](https://i.postimg.cc/R0Rq5WSC/image.png)](https://postimg.cc/wt19DTRn)
</details>

<details>
<summary>View Memory Layout</summary>

`require("ferris.methods.view_memory_layout")`

[![image.png](https://i.postimg.cc/02wQ5WkB/image.png)](https://postimg.cc/56f1nmFB)
</details>

<details>
<summary>View Item Tree</summary>

`require("ferris.methods.view_item_tree")`
</details>

<details>
<summary>View Syntax Tree</summary>

`require("ferris.methods.view_syntax_tree")`
</details>

<details>
<summary>Open Cargo.toml</summary>

`require("ferris.methods.open_cargo_toml")`
</details>

<details>
<summary>Open Parent Module</summary>

`require("ferris.methods.open_parent_module")`
</details>

<details>
<summary>Open Documentation</summary>

`require("ferris.methods.open_documentation")`
</details>

<details>
<summary>Reload Workspace</summary>

`require("ferris.methods.reload_workspace")`
</details>


<details>
<summary>Rebuild Macros</summary>

`require("ferris.methods.rebuild_macros")`
</details>

## special thanks
[rust-tools](https://github.com/simrat39/rust-tools.nvim) for being the reason why this plugins exists.
initially, i didn't want any of the features it offered _except_ for recursive expansion of macros, so i made [rust-expand-macro.nvim](https://github.com/vxpm/rust-expand-macro.nvim).

however, i found myself wanting to use other methods as well, which led me to making ferris!

in comparison to rust-tools, this plugin is "simpler": it does not configure Rust Analyzer for you nor does it
provide debugging utilities. i myself consider this a benefit, but it's up to your judgement.
