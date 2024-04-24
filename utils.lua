--[[
#Script Name:   <utils.lua>
# Description:  <Collection of utility functions>
# Autor:        <Dead (dea.d - Discord)>
# Version:      <3.0>
# Datum:        <2024.04.03>
--]]

local API = require("api")
local UTILS = {}

UTILS.__index = UTILS

function UTILS.new()
  local self = setmetatable({}, UTILS)
  self.afk = os.time()
  self.randomTime = math.random(180, 280)
  self.worldTime = os.time()
  self.stateFailCount = 0
  return self
end

--#region Variables
local MAX_IDLE_TIME_MINUTES = 5

UTILS.ORES = {
  COPPER = 436,
  TIN = 438,
  IRON = 440,
  SILVER = 442,
  GOLD = 444,
  MITHRIL = 447,
  ADAMANTITE = 449,
  RUNITE = 451,
  COAL = 453,
  BANITE = 21778,
  LUMINITE = 44820,
  ORICHALCITE = 44822,
  DRAKOLITH = 44824,
  NECRITE = 44826,
  PHASMATITE = 44828,
  LIGHT_ANIMICA = 44830,
  DARK_ANIMICA = 44832
}

UTILS.RUNES = {
  AIR = { ID = 556, INV_VB = 5886 },
  MIND = { ID = 558, INV_VB = 5902 },
  WATER = { ID = 555, INV_VB = 5887 },
  EARTH = { ID = 557, INV_VB = 5889 },
  FIRE = { ID = 554, INV_VB = 5888 },
  BODY = { ID = 559, INV_VB = 5896 },
  COSMIC = { ID = 564, INV_VB = 5897 },
  NATURE = { ID = 561, INV_VB = 5899 },
  CHAOS = { ID = 562, INV_VB = 5898 },
  LAW = { ID = 563, INV_VB = 5900 },
  DEATH = { ID = 560, INV_VB = 5901 },
  ASTRAL = { ID = 9075, INV_VB = 5903 },
  BLOOD = { ID = 565, INV_VB = 5904 },
  SOUL = { ID = 566, INV_VB = 5905 },
}

---@param rune UTILS.RUNES
---@return number
function UTILS.getRuneCountInventory(rune)
  return API.VB_FindPSettinOrder(rune.INV_VB, 1).state
end

--- The anti idle function we've all been using
---@return boolean
function UTILS:antiIdle()
  math.randomseed(os.time())
  local timeDiff = os.difftime(os.time(), self.afk)
  local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)
  if timeDiff > randomTime then
    API.PIdle2()
    self.afk = os.time()
    return true
  end
  return false
end

--- Function to tell if a string is empty
---@param s string
---@return boolean
function UTILS.isEmpty(s)
  return s == nil or s == ''
end

--- Function to check if a table inclues a value
---@param table table
---@param value any
---@return boolean
function UTILS.tableIncludes(table, value)
  for i = 1, #table do
    if table[i] == value then
      return true
    end
  end
  return false
end

--- Function to convert userdata to vector<string>
function UTILS.UserDataToVector(userdata)
  local vector = {}

  -- Iterate over the userdata values and extract them
  for i = 1, #userdata do
    vector[i] = userdata[i]
  end

  return vector
end

--- Function to sleep for milliseconds with a random delay
---@param milliseconds number
function UTILS.randomSleep(milliseconds)
  math.randomseed(os.time())
  local randomDelay = math.random(1, 200)
  local totalDelay = milliseconds + randomDelay
  local start = os.clock()
  local target = start + (totalDelay / 1000)
  while os.clock() < target do
    API.RandomSleep2(100, 0, 0)
  end
end

--- Function to convert userdata to string
function UTILS.UserDataToString(userdata)
  local vector = {}

  -- Iterate over the userdata values and extract them
  for i = 1, #userdata do
    vector[i] = userdata[i]
  end

  return table.concat(vector, "")
end

--- Function to convert a Lua table to string
---comment
---@param tbl table
---@return string
function UTILS.tableToString(tbl)
  local strTable = {}
  for _, innerTbl in ipairs(tbl) do
    local strInnerTable = {}
    for _, value in ipairs(innerTbl) do
      table.insert(strInnerTable, tostring(value))
    end
    table.insert(strTable, "{" .. table.concat(strInnerTable, ", ") .. "}")
  end
  return table.concat(strTable, ", ")
end

--- Function to check for various game states<br>
--- Checks if we're logged in and if API.Read_LoopyLoop() is true
---@return boolean
function UTILS:gameStateChecks()
  if API.GetGameState2() ~= 3 and self.stateFailCount > 5 then
    print('not logged in after 100 checks')
    API.Write_LoopyLoop(false)
    return false
  elseif API.GetGameState2() ~= 3 then
    UTILS.SleepUntilWithoutChecks(function() return API.GetGameState2() == 3 end,5,'state change to 3',true)
    print('not logged in ' .. tostring(self.stateFailCount))
    self.stateFailCount = self.stateFailCount + 1
  end
  if not API.Read_LoopyLoop() then
    print('LoopyLoop is false')
    return false
  end
  return true
end

--- Function to wait for an animation to complete, upto defined seconds
---@param animationId number
---@param maxWaitInSeconds number
---@return boolean
function UTILS.waitForAnimation(animationId, maxWaitInSeconds)
  local animation = animationId or 0
  local waitTime = maxWaitInSeconds or 5
  local exitLoop = false
  local start = os.time()
  while not exitLoop and os.time() - start < waitTime do
    if not (API.Read_LoopyLoop() or API.PlayerLoggedIn()) then
      exitLoop = true
      return false
    end
    if (API.ReadPlayerAnim() == animation) then
      exitLoop = true
      return true
    end
    UTILS.rangeSleep(50, 50, 50)
  end
end

--- After exiting combat, you can use a lodestone for a specific duration.<br>
--- This method tells you when you can use a lodestone
---@return boolean
function UTILS.CanUseLodestone()
  local vb = API.VB_FindPSett(7994)
  return vb.state == -1 or vb.stateAlt == -1
end

--- Function to wait for a player to reach a coords within a threshold, upto defined seconds
---comment
---@param coords WPOINT
---@param threshold number
---@param maxWaitInSeconds number
---@return boolean
function UTILS.waitForPlayerAtCoords(coords, threshold, maxWaitInSeconds)
  local waitTime = maxWaitInSeconds or 5
  local variance = threshold or 0
  local exitLoop = false
  local start = os.time()
  while not exitLoop and os.time() - start < waitTime do
    if not (API.Read_LoopyLoop() or API.PlayerLoggedIn()) then
      exitLoop = true
      return false
    end
    if (API.PInAreaW(coords, variance)) then
      exitLoop = true
      return true
    end
    UTILS.rangeSleep(50, 50, 50)
  end
  return false
end

--[[
  Example Usage

  local lodestone = {
    BanditCamp = {
        id = 9,
        x = 2899,
        y = 3544,
        z = 0
    }
  }

  print('Teleporting to ', UTILS.GetLabelFromArgument(lodestone.BanditCamp, lodestone))
  would print 'Teleporting to BanditCamp'
--]]
---
--- Function to get the label of the table element
---@param arg any
---@param table table
---@return any | nil
function UTILS.GetLabelFromArgument(arg, table)
  for label, record in pairs(table) do
    if record == arg then
      return label
    end
  end
  return nil
end

--- Function to concatenate tables
---@param ... table[]
---@return table
function UTILS.concatenateTables(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for _, value in ipairs(tbl) do
      table.insert(result, value)
    end
  end
  return result
end

--- Function to extract distinct values from a table
---@param inputTable table
---@return table
function UTILS.getDistinctValues(inputTable)
  local distinctValues = {}
  local seenValues = {}

  for _, value in ipairs(inputTable) do
    if not seenValues[value] then
      table.insert(distinctValues, value)
      seenValues[value] = true
    end
  end
  return distinctValues
end

--- Function to get you distinct values from the input table based on the property
---comment
---@param inputTable table
---@param property string
---@return table
function UTILS.getDistinctByProperty(inputTable, property)
  local distinctValues = {}
  local seenValues = {}

  for _, value in ipairs(inputTable) do
    local prop = value[property]
    if not seenValues[prop] then
      table.insert(distinctValues, value)
      seenValues[prop] = true
    end
  end
  return distinctValues
end

--[[
Handles the below random events
<br>18204 Chronicle fragment, other peopls 18205
<br>19884 Guthix butterfly       	
<br>26022 Seren spirit
<br>27228 Divine blessing
<br>27297 Forge phoenix
<br>28411 Catalyst
<br>30599 Halloween Pumpkin
<br>15451 Fire spirit
]]
---@return boolean
function UTILS.DO_RandomEvents()
  local F_obj = API.GetAllObjArrayInteract({ 19884, 26022, 27228, 27297, 28411, 30599, 15451 }, 20, 1)
  --if not (F_obj) == nil then
  if (F_Obj) ~= nil then
    print("Random event object detected: trying to click")
    UTILS.randomSleep(1000)
    if API.DoAction_NPC__Direct(0x29, API.InteractNPC_route, F_obj[1]) then
      UTILS.randomSleep(1000)
      return true
    end
  end
  return false
end

--- Function to load a primary action bar
---@param barNumber number
---@return boolean
function UTILS.LoadActionBar(barNumber)
  print("Loading action bar: " .. barNumber)
  local bars = {
    ONE = { number = 255, id = 1, offset = API.OFF_ACT_GeneralInterface_route },
    TWO = { number = 255, id = 2, offset = API.OFF_ACT_GeneralInterface_route },
    THREE = { number = 255, id = 3, offset = API.OFF_ACT_GeneralInterface_route },
    FOUR = { number = 255, id = 4, offset = API.OFF_ACT_GeneralInterface_route },
    FIVE = { number = 255, id = 5, offset = API.OFF_ACT_GeneralInterface_route },
    SIX = { number = 255, id = 6, offset = API.OFF_ACT_GeneralInterface_route2 },
    SEVEN = { number = 255, id = 7, offset = API.OFF_ACT_GeneralInterface_route2 },
    EIGHT = { number = 255, id = 8, offset = API.OFF_ACT_GeneralInterface_route2 },
    NINE = { number = 255, id = 9, offset = API.OFF_ACT_GeneralInterface_route2 },
    TEN = { number = 255, id = 10, offset = API.OFF_ACT_GeneralInterface_route2 },
    ELEVEN = { number = 254, id = 6, offset = API.OFF_ACT_GeneralInterface_route2 },
    TWELVE = { number = 254, id = 7, offset = API.OFF_ACT_GeneralInterface_route2 },
    THIRTEEN = { number = 254, id = 8, offset = API.OFF_ACT_GeneralInterface_route2 },
    FOURTEEN = { number = 254, id = 9, offset = API.OFF_ACT_GeneralInterface_route2 },
    FIFTEEN = { number = 254, id = 10, offset = API.OFF_ACT_GeneralInterface_route2 },
    SIXTEEN = { number = 253, id = 6, offset = API.OFF_ACT_GeneralInterface_route2 },
    SEVENTEEN = { number = 253, id = 7, offset = API.OFF_ACT_GeneralInterface_route2 },
    EIGHTEEN = { number = 253, id = 8, offset = API.OFF_ACT_GeneralInterface_route2 },
  }

  local selected = { id = nil, number = nil, offset = nil }

  -- Set [5th param in DO::DoAction_Interface]
  if barNumber >= 1 and barNumber <= 10 then
    selected.number = 255
  elseif barNumber >= 11 and barNumber <= 15 then
    selected.number = 254
  elseif barNumber >= 16 and barNumber <= 18 then
    selected.number = 253
  else
    print("Invalid bar number passed: " .. tostring(barNumber))
    return false
  end

  -- Set Offset [7th param in DO::DoAction_Interface]
  if barNumber >= 1 and barNumber <= 5 then
    selected.offset = API.OFF_ACT_GeneralInterface_route
  elseif barNumber >= 6 and barNumber <= 18 then
    selected.offset = API.OFF_ACT_GeneralInterface_route2
  end
  -- set number [3rd param in DO::DoAction_Interface]
  if barNumber == 10 or barNumber == 15 then
    selected.id = 10
  elseif barNumber >= 1 and barNumber <= 9 then
    selected.id = barNumber
  elseif barNumber >= 11 and barNumber <= 14 then
    selected.id = barNumber - 5
  elseif barNumber >= 16 and barNumber <= 18 then
    selected.id = barNumber - 10
  end

  -- print("selected is: {id: " .. selected.id .. ", number: " .. selected.number .. ", offset: " .. selected.offset)
  API.DoAction_Interface(0xffffffff, 0xffffffff, selected.id, 1430, selected.number, -1, selected.offset)
end

--- Waits for a number of ticks
---@param ticks number
---@return number -- number of ticks elapsed
function UTILS.countTicks(ticks)
  local currentTick = API.Get_tick()
  local ticker = currentTick + ticks
  while ticker >= currentTick do
    currentTick = API.Get_tick()
    UTILS.rangeSleep(10, 0, 0)
    if not UTILS.gameStateChecks() then
      return 0
    end
  end
  return ticks
end

-- Function to sleep for milliseconds with a random delay
---@param milliseconds number
---@param randMin number = 0
---@param randMax number = 0
function UTILS.rangeSleep(milliseconds, randMin, randMax)
  randMin = randMin or 0
  randMax = randMax or 0
  math.randomseed(os.time())
  local randomDelay = math.random(randMin, randMax)
  local totalDelay = milliseconds + randomDelay
  local start = os.clock()
  local target = start + (totalDelay / 1000)
  while os.clock() < target do
    API.RandomSleep2(50, 0, 0)
  end
end

--- Sleeps until the condition function returns true<br>
--- Checks for other random events,game state and API.Read_LoopyLoop
---@param conditionFunc function -- condition to evaluate
---@param timeout number -- max duration to wait
---@param message string -- message to print if condition is satisfied
---@param ... any -- arguments to condition function
---@return boolean
function UTILS.SleepUntil(conditionFunc, timeout, message, ...)
  local startTime = os.time()
  local sleepSuccessful = false
  while not conditionFunc(...) do
    API.DoRandomEvents()
    if os.difftime(os.time(), startTime) >= timeout then
      print("Stopped waiting for " .. message .. " after " .. timeout .. " seconds.")
      break
    end
    if not API.Read_LoopyLoop() then
      print("Script exited - breaking sleep.")
      break
    end
    if not UTILS:gameStateChecks() then
      print("State checks failed - breaking sleep.")
      break
    end
    API.RandomSleep2(50, 0, 0)
  end
  if conditionFunc(...) then
    print("Sleep condition met for " .. message)
    sleepSuccessful = true
  end
  return sleepSuccessful
end

--- Sleeps until the condition function returns true<br>
--- No checks
---@param conditionFunc function -- condition to evaluate
---@param timeout number -- max duration to wait
---@param message string -- message to print if condition is satisfied
---@param loopy boolean -- should check if script is still running
---@param ... any -- arguments to condition function
---@return boolean
function UTILS.SleepUntilWithoutChecks(conditionFunc, timeout, message, loopy, ...)
  local startTime = os.time()
  local sleepSuccessful = false
  local checkLoopy = loopy or false
  while not conditionFunc(...) do
    API.DoRandomEvents()
    if os.difftime(os.time(), startTime) >= timeout then
      print("Stopped waiting for " .. message .. " after " .. timeout .. " seconds.")
      break
    end
    if checkLoopy and not API.Read_LoopyLoop() then
      print("Script exited - breaking sleep.")
      break
    end
    API.RandomSleep2(50, 0, 0)
  end
  if conditionFunc(...) then
    print("Sleep condition met for " .. message)
    sleepSuccessful = true
  end
  return sleepSuccessful
end

--- Is the world selection window open
---@return boolean
function UTILS.isWorldSelectionOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 61
end

--- Is the Crafting interface open
---@return boolean
function UTILS.isCraftingInterfaceOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 1310738
end

--- Is the Choose Option interface open
---@return boolean
function UTILS.isChooseOptionInterfaceOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 12
end

--- Is the Cooking interface open
---@return boolean
function UTILS.isCookingInterfaceOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 18
end

--- Is the Smelting interface open
---@return boolean
function UTILS.isSmeltingInterfaceOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 85
end

--- Is the Jewelry Teleport interface open
---@return boolean
function UTILS.isTeleportSeedInterfaceOpen()
  return API.VB_FindPSett(2874, 1, 0).state == 13
end

--- Is there an active aura
---@return boolean
function UTILS.isAuraActive()
  return API.VB_FindPSett(7702).state > 0
end

--#region Abilities
local function findBarWithQueuedSkill()
  local queuedBar = API.VB_FindPSettinOrder(5861, 0).state
  if queuedBar == 0 then return nil end
  if queuedBar == 1003 then return 0 end
  if queuedBar == 1032 then return 1 end
  if queuedBar == 1033 then return 2 end
  if queuedBar == 1034 then return 3 end
  if queuedBar == 1035 then return 4 end
  return nil
end

local function isAbilityQueued()
  return API.VB_FindPSettinOrder(5861, 0).state ~= 0
end

local function getSlotOfQueuedSkill()
  return API.VB_FindPSettinOrder(4164, 0).state
end

--- Is a skill queued.
---@param skill string -- skillName
---@return boolean
function UTILS.isSkillQueued(skill)
  if not isAbilityQueued() then return false end
  local barNumber = findBarWithQueuedSkill()
  if barNumber == nil then return false end
  local skillbar = API.GetAB_name(barNumber, skill)
  local slot = getSlotOfQueuedSkill()
  if slot == 0 then return false end
  if skillbar.slot == slot then return true end
  return false
end

--- Can a skill be queued.
---@param skill string -- skillName
---@return boolean
function UTILS.canQueueSkill(skill)
  if UTILS.isSkillQueued(skill) then return false end
  if UTILS.canUseSkill(skill) then
    local skillFound = API.GetABs_name1(skill)
    if skillFound.cooldown_timer < 6 then return true end
  end
  return false
end
--- Can a skill be used.
---@param skill string -- skillName
---@return boolean
function UTILS.canUseSkill(skill)
  local skillFound = API.GetABs_name1(skill)
  if skillFound.id == 0 then return false end
  if not skillFound.enabled then return false end
  return true
end

--- Get's a skill on the ability bar<br>
--- Checks if it can be used<br>
--- Returns nil if the skill isn't found or can't be used
---@param skillName string
---@return Abilitybar | nil
function UTILS.getSkillOnBar(skillName)
  local skillOnAB = API.GetABs_name1(skillName)
  if UTILS.canUseSkill(skillName) then
    return skillOnAB
  else
    return nil
  end
end

--- Cast Surge.
---@return boolean
function UTILS.surge()
  local surgeAB = UTILS.getSkillOnBar("Surge")
  if surgeAB ~= nil then
    return API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
  end
  return false
end

--- Casts `Dive`.
---@param destinationTile WPOINT -- the tile to `Dive` to
---@return boolean
function UTILS.dive(destinationTile)
  local diveAB = UTILS.getSkillOnBar("Dive")
  if diveAB ~= nil then
    return API.DoAction_Dive_Tile(destinationTile)
  end
  return false
end

--#endregion

--- Finds an item in the inventory
---@param itemId number
---@return IInfo|nil
function UTILS.findItemInInventory(itemId)
  local inventory = API.ReadInvArrays33()
  local foundItem = nil
  for i = 1, #inventory do
    if inventory[i].itemid1 == itemId then
      foundItem = inventory[i]
      break
    end
  end
  return foundItem
end

--- Is the Choose Option interface open
---@return boolean
function UTILS.isPrayersTabOpen()
  return API.VB_FindPSettinOrder(3172, 1).state == 1
end

--- Is the player on Normal Prayers
---@return boolean
function UTILS.isUsingNormalPrayers()
  return API.VB_FindPSettinOrder(3277, 0).state & 1 == 0
end

--- Is the player on Curses
---@return boolean
function UTILS.isUsingCurses()
  return API.VB_FindPSettinOrder(3277, 0).state & 1 == 1
end

--- Is the player on Regular Magic spellbook
---@return boolean
function UTILS.isUsingNormalMagic()
  return API.VB_FindPSettinOrder(4, 0).state == 1280
end

--- Is the player on Ancient Magic spellbook
---@return boolean
function UTILS.isUsingAncientMagic()
  return API.VB_FindPSettinOrder(4, 0).state == 1281
end

--- Is the player on Lunar Magic spellbook
---@return boolean
function UTILS.isUsingLunarMagic()
  return API.VB_FindPSettinOrder(4, 0).state == 1282
end

--- Is Soul Split prayer on
---@return boolean
function UTILS.isSoulSplitting()
  return API.VB_FindPSettinOrder(3269, 0).state == 25
end

--- Is Deflect Melee prayer on
---@return boolean
function UTILS.isDeflectMelee()
  return API.VB_FindPSettinOrder(3275, 0).state == 512
end

--- Is Deflect Magic prayer on
---@return boolean
function UTILS.isDeflectMagic()
  return API.VB_FindPSettinOrder(3275, 0).state == 128
end

--- Is Deflect Range prayer on
---@return boolean
function UTILS.isDeflectRange()
  return API.VB_FindPSettinOrder(3275, 0).state == 256
end

--- Is Deflect Necromancy prayer on
---@return boolean
function UTILS.isDeflectNecro()
  return API.VB_FindPSettinOrder(5859, 0).state >> 16 & 0xffff == 2
end

--- Toggles visibility of the Prayer Window
---@return boolean
function UTILS.togglePrayerWindow()
  return API.DoAction_Interface(0xc2, 0xffffffff, 1, 1432, 5, 5, API.OFF_ACT_GeneralInterface_route)
end

--- Gets the duration left on the familiar
---@return number -- duration left
function UTILS.getFamiliarDuration()
  local value = API.VB_FindPSettinOrder(1786, 0).state
  if value == 0 then return 0 end
  return (math.floor(value / 2.1333333)) / 60
end

--- Is Chronicle Attraction prayer on
---@return boolean
function UTILS.isChronicleAttractionActive()
  return API.VB_FindPSettinOrder(6890, 0).state >> 16 & 0xffff == 4
end

--- Is Chronicle Attraction prayer available
---@return boolean
function UTILS.hasChronicleAttraction()
  if not UTILS.isUsingCurses() then
    print('not on curses')
    return false
  end
  local open = UTILS.isPrayersTabOpen()
  if not open then
    UTILS.togglePrayerWindow()
    UTILS.randomSleep(50)
  end
  local chronicleInterface = { { 1458, 4, -1, -1, 0 }, { 1458, 6, -1, 4, 0 }, { 1458, 8, -1, 6, 0 }, { 1458, 40, -1, 8, 0 }, { 1458, 40, 30, 40, 0 } }

  local inter = API.ScanForInterfaceTest2Get(false, chronicleInterface)
  local hasPrayer = false
  if (#inter > 0) then
    hasPrayer = inter[1].xs > 0
  end
  if not open then
    UTILS.togglePrayerWindow()
  end
  return hasPrayer
end

--- Checks if the player is within a specified area.<br>
-- This function can handle both rectangular and polygonal areas.<br>
-- For a rectangle, the area is defined by two opposite corners as four numbers `{x1, y1, x2, y2}`.<br>
-- For a polygon, the area is defined as a table of `WPOINT`.<br>
---@param area table The area definition. Can be either `{x1, y1, x2, y2}` for a rectangle, or an array of `WPOINT` for a polygon.<br>
---@return boolean -- True if the player is within the specified area, False otherwise.
---@usage
--
--      -- Example for a rectangle:
--        local rectangleArea = {3020, 3234, 3022, 3239}
--        local inRectangle = UTILS.playerInArea(rectangleArea)
--        print("Player is in rectangle area: ", inRectangle)
--
--      -- Example for a polygon:
--        local point = WPOINT.new(3021,3233,0)
--        local polygonArea = {
--          WPOINT.new(3020,3234,0),
--          WPOINT.new(3022,3234,0),
--          WPOINT.new(3022,3239,0),
--          WPOINT.new(3020,3239,0),
--        }
--     local inPolygon = UTILS.playerInArea(polygonArea)
--     print("Player is in polygon area: ", inPolygon)
function UTILS.playerInArea(area)
  return UTILS.isCoordInArea(API.PlayerCoord(), area)
end

--- Checks if the coordinate is within a specified area.<br>
-- This function can handle both rectangular and polygonal areas.<br>
-- For a rectangle, the area is defined by two opposite corners as four numbers `{x1, y1, x2, y2}`.<br>
-- For a polygon, the area is defined as a table of `WPOINT`.<br>
---@param area table The area definition. Can be either `{x1, y1, x2, y2}` for a rectangle, or an array of `WPOINT` for a polygon.<br>
---@return boolean -- True if the player is within the specified area, False otherwise.
---@usage
--
--      -- Example for a rectangle:
--        local point = WPOINT.new(3021,3233,0)
--        local rectangleArea = {3020, 3234, 3022, 3239}
--        local inRectangle = UTILS.isCoordInArea(point, rectangleArea)
--        print("Point is in rectangle area: ", inRectangle)
--
--      -- Example for a polygon:
--        local point = WPOINT.new(3021,3233,0)
--        local polygonArea = {
--          WPOINT.new(3020,3234,0),
--          WPOINT.new(3022,3234,0),
--          WPOINT.new(3022,3239,0),
--          WPOINT.new(3020,3239,0),
--        }
--        local inPolygon = UTILS.isCoordInArea(point,polygonArea)
--        print("Point is in polygon area: ", inPolygon)
function UTILS.isCoordInArea(coord, area)
  if coord.z ~= API.PlayerCoord().z then
    return false
  end

  -- Normalize area format
  if #area == 4 and type(area[1]) == "number" then
    -- Rectangle format: {x1, y1, x2, y2}
    local x1, y1, x2, y2 = area[1], area[2], area[3], area[4]
    area = {
      { x = x1, y = y1 },
      { x = x2, y = y1 },
      { x = x2, y = y2 },
      { x = x1, y = y2 }
    }
  elseif type(area[1]) == "table" and #area[1] == 2 then
    -- Array of WPOINT format: {WPOINT,WPOINT, ...}
    for i, point in ipairs(area) do
      area[i] = { x = point.x, y = point.y }
    end
  end

  local count = 0
  local n = #area
  for i = 1, n do
    local j = (i % n) + 1
    local vertex1 = area[i]
    local vertex2 = area[j]
    if ((vertex1.y > coord.y) ~= (vertex2.y > coord.y)) and
        (coord.x < (vertex2.x - vertex1.x) * (coord.y - vertex1.y) / (vertex2.y - vertex1.y) + vertex1.x) then
      count = count + 1
    end
  end

  -- Point is inside the polygon if count is odd
  return (count % 2) == 1
end

---Get number of ores in ore box
---@param oreId integer
---@return integer
--[[
    Ore IDs:

    436     Copper
    438     Tin
    440     Iron
    442     Silver
    444     Gold
    447     Mithril
    449     Adamantite
    451     Runite
    453     Coal
    21778   Banite
    44820   Luminite
    44822   Orichalcite
    44824   Drakolith
    44826   Necrite
    44828   Phasmatite
    44830   Light animica
    44832   Dark animica
]]
function UTILS.getAmountInOrebox(oreId)
  local state
  if oreId == 436 then       -- Copper ore
    state = API.VB_FindPSett(8309).state
  elseif oreId == 438 then   -- Tin ore
    state = API.VB_FindPSett(8310).state
  elseif oreId == 440 then   -- Iron ore
    state = API.VB_FindPSett(8311).state
  elseif oreId == 442 then   -- Silver ore
    state = API.VB_FindPSett(8313).state
  elseif oreId == 444 then   -- Gold ore
    state = API.VB_FindPSett(8317).state
  elseif oreId == 447 then   -- Mithril ore
    state = API.VB_FindPSett(8314).state
  elseif oreId == 449 then   -- Adamantite ore
    state = API.VB_FindPSett(8315).state
  elseif oreId == 451 then   -- Runite ore
    state = API.VB_FindPSett(8318).state
  elseif oreId == 453 then   -- Coal
    state = API.VB_FindPSett(8312).state
  elseif oreId == 21778 then -- Banite ore
    state = API.VB_FindPSett(8323).state
  elseif oreId == 44820 then -- Luminite
    state = API.VB_FindPSett(8316).state
  elseif oreId == 44822 then -- Orichalcite ore
    state = API.VB_FindPSett(8319).state
  elseif oreId == 44824 then -- Drakolith
    state = API.VB_FindPSett(8320).state
  elseif oreId == 44826 then -- Necrite ore
    state = API.VB_FindPSett(8321).state
  elseif oreId == 44828 then -- Phasmatite
    state = API.VB_FindPSett(8322).state
  elseif oreId == 44830 then -- Light animica
    state = API.VB_FindPSett(8324).state
  elseif oreId == 44832 then -- Dark animica
    state = API.VB_FindPSett(8325).state
  else
    return -1
  end
  return state >> 0 & 0x3fff
end

--- Notes item in inventory<br>
--- Supports both types of note paper
---@param item number
---@return boolean -- Was able to note
function UTILS.NoteItem(item)
  local inventory = API.ReadInvArrays33()
  local notepaper = {}
  local itemToNote = {}
  local foundNotepaper = false
  local foundItem = false

  for i = 1, #inventory do
    if inventory[i].itemid1 == 43045 or inventory[i].itemid1 == 30372 then
      notepaper = inventory[i]
      foundNotepaper = true
    end
    if inventory[i].itemid1 == item then
      itemToNote = inventory[i]
      foundItem = true
    end
  end

  if not foundNotepaper then
    API.logError("Couldn't find notepaper")
    print("Couldn't find notepaper")
    return false
  end

  if not foundItem then
    API.logError("Couldn't find item with id:" .. tostring(item))
    print("Couldn't find item with id:", item)
    return false
  end

  API.DoAction_Interface(0x24, notepaper.itemid1, 0, notepaper.id1, notepaper.id2, notepaper.id3,
    API.OFF_ACT_Bladed_interface_route)
  API.RandomSleep2(50, 100, 200)
  API.DoAction_Interface(0x24, itemToNote.itemid1, 0, itemToNote.id1, itemToNote.id2, itemToNote.id3,
    API.OFF_ACT_GeneralInterface_route1)
  return true
end

local instance = UTILS.new()
return instance
