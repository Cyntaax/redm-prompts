RedM Prompts Wrapper
---------------------

This is just a little something to help make prompts easier to manage in RedM.

It **only** supports *prompt groups* for the time being, but you can still have just one prompt in a group

The **3<sup>rd</sup>** parameter of `CreatePrompt` should always be true for the time being until "tap" prompts are implemented.

Usage:

> fxmanifest.lua
```lua
client_scripts {
    '@prompts/Prompt.lua'
}
```

### Example

```lua
local promptGroup = CreatePromptGroup("Prompts wooo!")
local prompt1 = CreatePrompt("I'm a prompt!", 0xF84FA74F, true, promptGroup)
local prompt2 = CreatePrompt("I'm another prompt!", 0xC7B5340A, true, promptGroup)

prompt1.HoldCompleted = function()
    print('You have completed prompt 1!')
end

prompt2.HoldCompleted = function()
    print('You have completed prompt 2!')
end

RegisterCommand('enableprompt', function()
    promptGroup:Show({ prompt1, prompt2 })
    -- You can edit prompts at this point if need be
    prompt1:Enabled(false)
    prompt1:Text("I'm disabled now")
    SetTimeout(5000, function()
        prompt1:Enabled(true)
        prompt1:Text("Hey! I'm back!")
    end)
end, false)

RegisterCommand('disableprompt', function()
    promptGroup:HideAll()
end, false)
```