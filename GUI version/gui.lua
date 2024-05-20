local API = require("api")
local GUI = {}
local UIComponents = {}

local function GetComponentAmount()
    local amount = 0
    for i, v in pairs(UIComponents) do
        amount = amount + 1
    end
    return amount
end

---@param name string
---@param widthMultiplier number
---@param heightMultiplier number
---@param colour ImColor
---@return void
function GUI.AddBackground(name, widthMultiplier, heightMultiplier, colour)
    widthMultiplier = widthMultiplier or 1
    heightMultiplier = heightMultiplier or 1
    colour = colour or ImColor.new(15, 13, 18, 255)

    Background = API.CreateIG_answer();
    Background.box_name = "Background" .. GetComponentAmount();
    Background.box_start = FFPOINT.new(0, 0, 0)
    Background.box_size = FFPOINT.new(200 * widthMultiplier, 20 * heightMultiplier, 0)
    Background.colour = colour

    UIComponents[GetComponentAmount() + 1] = {name, Background, "Background"}
end

---@param name string
---@param text string
---@param colour ImColor
---@return void
function GUI.AddLabel(name, text, colour)
    colour = colour or ImColor.new(255, 255, 255)

    Label = API.CreateIG_answer()
    Label.box_name = "Label" .. GetComponentAmount()
    Label.colour = colour;
    Label.string_value = text

    UIComponents[GetComponentAmount() + 1] = {name, Label, "Label"}
end

---@param name string
---@param text string
---@return void
function GUI.AddCheckbox(name, text)
    CheckBox = API.CreateIG_answer()
    CheckBox.box_name = text

    UIComponents[GetComponentAmount() + 1] = {name, CheckBox, "CheckBox"}
end

---@param name string
---@param options table
---@return void
function GUI.AddComboBox(name, text, options)
    ComboBox = API.CreateIG_answer()
    ComboBox.box_name = text
    ComboBox.stringsArr = options
    ComboBox.box_size = FFPOINT.new(400, 0, 0)

    UIComponents[GetComponentAmount() + 1] = {name, ComboBox, "ComboBox"}
end

---@param name string
---@param options table
---@return void
function GUI.AddListBox(name, text, options)
    ListBox = API.CreateIG_answer()
    ListBox.box_name = text
    ListBox.stringsArr = options
    ListBox.box_size = FFPOINT.new(400, 0, 0)

    UIComponents[GetComponentAmount() + 1] = {name, ListBox, "ListBox"}
end

function GUI.Draw()
    for i = 1, GetComponentAmount() do
        local componentKind = UIComponents[i][3]
        local component = UIComponents[i][2]
        if componentKind == "Background" then
            component.box_size = FFPOINT.new(component.box_size.x, 25 * GetComponentAmount(), 0)
            API.DrawSquareFilled(component)
        elseif componentKind == "Label" then
            component.box_start = FFPOINT.new(10, 10 + ((i - 2) * 25), 0)
            API.DrawTextAt(component)
        elseif componentKind == "CheckBox" then
            component.box_start = FFPOINT.new(2.5, ((i - 2) * 25), 0)
            API.DrawCheckbox(component)
        elseif componentKind == "ComboBox" then
            component.box_start = FFPOINT.new(2.5, ((i - 2) * 25), 0)
            API.DrawComboBox(component, false)
        elseif componentKind == "ListBox" then
            component.box_start = FFPOINT.new(10, 10 + ((i - 2) * 25), 0)
            API.DrawListBox(component, false)
        end
    end
end

local function GetComponentByName(componentName)
    for i, v in pairs(UIComponents) do
        if v[1] == componentName then
            return v;
        end
    end
end

---@param componentName string
---@return IG_answer
function GUI.GetComponent(componentName)
    return GetComponentByName(componentName)[2]
end

---@param componentName string
---@return string, bool or nil
function GUI.GetComponentValue(componentName)
    local componentArr = GetComponentByName(componentName)
    local componentKind = componentArr[3]
    local component = componentArr[2]

    if componentKind == "Label" then
        return component.string_value
    elseif componentKind == "CheckBox" then
        return component.return_click
    elseif componentKind == "ComboBox" and component.string_value ~= "None" then
        return component.string_value
    elseif componentKind == "ListBox" and component.string_value ~= "None" then
        return component.string_value
    end

    return nil
end

---@param labelName string
---@param newText string
---@return void
function GUI.UpdateLabelText(labelName, newText)
    GetComponentByName(labelName)[2].string_value = newText
end

return GUI
