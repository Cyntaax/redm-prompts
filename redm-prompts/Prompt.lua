PROMPTGROUP = setmetatable({}, PROMPTGROUP)

PROMPTGROUP.__index = PROMPTGROUP

PROMPTGROUP.__call = function()
    return "PROMPTGROUP"
end

function PROMPTGROUP.new(text)
    local ID = GetRandomIntInRange(0, 0xffffff)

    local _PROMPTGROUP = {
        ID = ID,
        _Drawing = false,
        _Text = text,
        Prompts = {},
    }

    return setmetatable(_PROMPTGROUP, PROMPTGROUP)
end

--- Sets or return the prompt's text
--- @param text string | nil
--- @return nil | string
function PROMPTGROUP:Text(text)
    if type(text) == "string" then
        self._Text = text
    else
        return self._Text
    end
end

--- Don't use
---@private
function PROMPTGROUP:ShowThisFrame()
    local GroupName = CreateVarString(10, 'LITERAL_STRING', self:Text())
    PromptSetActiveGroupThisFrame(self.ID, GroupName)

    for k,v in pairs(self.Prompts) do
        if PromptHasHoldModeCompleted(v.Handle) then
            v.HoldCompleted()
            Wait(100)
        end
    end
end

--- Don't use
--- @private
function PROMPTGROUP:AddPrompt(prompt)
    local allowed = true
    for k,v in pairs(self.Prompts) do
        if v.Handle == prompt.Handle then
            allowed = false
            print('Skipping already added prompt')
        end
    end

    if allowed == true then
        prompt:SetGroup(prompt.Handle, self.ID)
        table.insert(self.Prompts, prompt)
    end
end


--- Shows the prompt group. Need only to call once. Will create a thread to manage this
--- @param prompts table An array of the prompts to be shown. See example
function PROMPTGROUP:Show(prompts)
    self._Drawing = true
    for k,v in pairs(prompts) do
        for b,z in pairs(self.Prompts) do
            if z.Handle == v.Handle then
                z:Enabled(true)
                z:Visible(true)
            end
        end
    end
    Citizen.CreateThread(function()
        while self._Drawing == true do
            Wait(0)
            self:ShowThisFrame()
        end
    end)
end

--- Stops the showing prompt thread. Will hide all prompts
function PROMPTGROUP:HideAll()
    for k,v in pairs(self.Prompts) do
        v:Enabled(false)
        v:Visible(false)
    end
    self._Drawing = false
end

--- @class PromptGroup
--- Creates the prompt group
--- @param text string The text to be shown at the bottom of the prompt group
function CreatePromptGroup(text)
    return PROMPTGROUP.new(text)
end

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

PROMPT = setmetatable({}, PROMPT)

PROMPT.__index = PROMPT

PROMPT.__call = function()
    return "PROMPT"
end

function PROMPT.new(text, control, hold, group)
    local str = text
    local prompt = Citizen.InvokeNative(0x04F97DE45A519419)
    PromptSetControlAction(prompt, control)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(prompt, str)


    if type(hold) == "boolean" then
        if hold == true then
            PromptSetHoldMode(prompt, true)
        end
    end

    PromptSetGroup(prompt, group.ID)

    PromptRegisterEnd(prompt)

    local _PROMPT = {
        Handle = prompt,
        _Enabled = false,
        _Visible = false,
        _Text = text,
        HoldCompleted = function()

        end
    }

    local mp = setmetatable(_PROMPT, PROMPT)

    group:AddPrompt(mp)

    return mp
end

--- Enables or disables a prompt
--- @param enabled boolean | nil Sets the prompt enabled status
--- @return boolean | nil
function PROMPT:Enabled(enabled)
    if type(enabled) == "boolean" then
        PromptSetEnabled(self.Handle, enabled)
        self._Enabled = enabled
    else
        return self._Enabled
    end
end

--- Sets the prompt's visibility
--- @param visible boolean Sets the prompt's visibility
function PROMPT:Visible(visible)
    if type(visible) == "boolean" then
        PromptSetVisible(self.Handle, visible)
        self._Visible = visible
    else
        return self._Visible
    end
end


--- @param group PromptGroup
--- Don't use
function PROMPT:SetGroup(group)
    if type(group) ~= "number" then
        print('Group must be a number')
        return
    end
    PromptSetGroup(self.Handle, group)
end

--- Sets the prompt's text
--- @param text string | nil The text to set on this prompt
--- @return text | nil
function PROMPT:Text(text)
    if type(text) == "string" then
        local str = CreateVarString(10, 'LITERAL_STRING', text)
        PromptSetText(self.Handle, str)
        self._Text = text
    end
end

-- Creates a prompt
--- @param text string The text of the prompt
--- @param control number The hash of which control to use
--- @param hold boolean whether this is a hold prompt or not (Hold should always be `true` for now)
--- @param group PromptGroup The prompt group to add this to
function CreatePrompt(text, control, hold, group)
    return PROMPT.new(text, control, hold, group)
end
