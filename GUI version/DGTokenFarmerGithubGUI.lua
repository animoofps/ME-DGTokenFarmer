print("Dungeoneering token farmer v1.0 started")
local API = require("api")
local UTILS = require("utils")
local GUI = require("gui")
-----------------------------------------------
local foodName = "Shark"
local foodAmount = 25
local PIN = 1234
-----------------------------------------------
local WarsTP = "Wars Room"
local MaxGuildTP = "Max Guild"
local StartScript = "Start/Pause"
GUI.AddBackground("Background")
GUI.AddLabel("Title", "^-^ DG Token Farmer 2.0 ^-^", ImColor.new(255, 0, 0))
GUI.AddCheckbox(MaxGuildTP, "Max Guild")
GUI.AddCheckbox(WarsTP, "Wars Room")
GUI.AddCheckbox(StartScript, "Start/Pause")

local function hasTarget()
    local interacting = API.ReadLpInteracting()
    if interacting.Id ~= 0 and interacting.Life > 1 then
        return true
    else
        return false
    end
end

local function findNPC(npcid, distance)
    local distance = distance or 20
    local npcs = API.GetAllObjArrayInteract(type(npcid) == "table" and npcid or {npcid}, distance, {1})
    return #npcs > 0 and npcs[1] or false
end

local function findNpcOrObject(npcid, distance, objType)
    local distance = distance or 20

    return #API.GetAllObjArray1({npcid}, distance, {objType}) > 0
end

function UTILS.surge()
    local surgeAB = UTILS.getSkillOnBar("Surge")
    if surgeAB ~= nil then
        return API.DoAction_Ability_Direct(surgeAB, 1, API.OFF_ACT_GeneralInterface_route)
    end
    return false
end

function UTILS.dive(destinationTile)
    local diveAB = UTILS.getSkillOnBar("Dive")
    if diveAB ~= nil then
        return API.DoAction_Dive_Tile(destinationTile)
    end
    return false
end

local function MaxGuildTeleport()
    API.DoAction_Ability("Max guild Teleport", 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1200, 1000, 1500)
    API.WaitUntilMovingandAnimEnds()
    API.RandomSleep2(1200, 800, 1000)
end

local function WarsRoomTeleport()
    API.DoAction_Ability("War's Retreat Teleport", 1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(1200, 1000, 1500)
    API.WaitUntilMovingandAnimEnds()
    API.RandomSleep2(1200, 800, 1000)
end

local function DungeonEntrance()
    if findNpcOrObject(124285, 15, 12) then
        API.DoAction_Object1(0x39, 0, {124285}, 50)
        API.RandomSleep2(800, 600, 1000)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 300, 500)
        if API.Select_Option("Normal mode") then
            print("Normal mode found, continuing")
            API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1188, 8, -1, 2912)
        else
            print("Yes or No found, clicking on No.")
            API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1188, 13, -1, 2912)
            API.RandomSleep2(600, 300, 500)
            API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1188, 8, -1, 2912)
        end
        if not findNPC(29296, 15) then
            print("Sleeping untill we find the NPC")
            API.RandomSleep2(200, 400, 600)
        end
    end
end

local function DiveCheck()
    local DiveCheck = API.GetAllObjArray1({29296}, 50, {1})
    if #DiveCheck > 0 then
        local DiveChk = DiveCheck[1]
        if DiveChk.Tile_XYZ then
            local randomNumber = math.random(-1, 4)
            local newTileX = DiveChk.Tile_XYZ.x + 12 + randomNumber
            local newTileY = DiveChk.Tile_XYZ.y + 20
            local newTileZ = DiveChk.Tile_XYZ.z
            UTILS.dive(WPOINT.new(newTileX, newTileY, newTileZ))
            print("Random number: " .. randomNumber)
        end
    end
end

local function monstercheck1() -- path after the combo 1
    local knightNpc = API.GetAllObjArray1({29296}, 50, {1}) -- Switched to knight pathing calculation

    if #knightNpc > 0 then
        local cerberus = knightNpc[1]

        if cerberus.Tile_XYZ then
            local randomNumber = math.random(-1, 4)
            local newTileX = cerberus.Tile_XYZ.x + 19 + randomNumber
            local newTileY = cerberus.Tile_XYZ.y + 39 + randomNumber
            local newTileZ = cerberus.Tile_XYZ.z

            if not API.PInArea(newTileX, 1, newTileY, 1, newTileZ) then
                --    print("Walking to dog1")
                API.DoAction_WalkerW(WPOINT.new(newTileX, newTileY, newTileZ))
                print("Random number: " .. randomNumber)
                API.RandomSleep2(1200, 800, 1000)
            end
        end
    end
end

local function monstercheck2() -- path after the combo 2
    local KnightNpc = API.GetAllObjArray1({29296}, 50, {1}) -- switched to knight pathing calculation
    if #KnightNpc > 0 then
        local Cerberus = KnightNpc[1]

        if Cerberus.Tile_XYZ then
            local newTileXdog = Cerberus.Tile_XYZ.x + 19
            local newTileYdog = Cerberus.Tile_XYZ.y + 39
            local newTileZdog = Cerberus.Tile_XYZ.z
            API.RandomSleep2(500, 300, 400)

            if not API.PInArea(newTileXdog, 1, newTileYdog, 1, newTileZdog) then
                --    print("Walking to dog2")
                API.DoAction_WalkerW(WPOINT.new(newTileXdog, newTileYdog, newTileZdog))
                API.RandomSleep2(1200, 600, 400)

                if not UTILS.isDeflectMelee() then
                    API.DoAction_Ability("Deflect Melee", 1, API.OFF_ACT_GeneralInterface_route)
                    API.RandomSleep2(800, 300, 400)
                end

                API.DoAction_Ability("Conjure Skeleton Warrior", 1, API.OFF_ACT_GeneralInterface_route) -- remove if not using necromancy
                API.RandomSleep2(600, 500, 200) -- remove if not using necromancy

                API.DoAction_Ability("Conjure Vengeful Ghost", 1, API.OFF_ACT_GeneralInterface_route) -- remove if not using necromancy
                API.RandomSleep2(800, 500, 400) -- remove if not using necromancy
                API.WaitUntilMovingEnds()
            end
        end
    end
end

local function knightcheck1() -- initial walking before the combo 1
    local knightNpc = API.GetAllObjArray1({29296}, 50, {1})
    if #knightNpc > 0 then
        local knight = knightNpc[1]
        local tileXYZ = knight.Tile_XYZ
        local randomNumber = math.random(-1, 5)
        if tileXYZ then
            newTileX = knight.Tile_XYZ.x - 4
            newTileY = knight.Tile_XYZ.y + randomNumber
            newTileZ = knight.Tile_XYZ.z
            local SpotCheck = WPOINT.new(newTileX, newTileY, newTileZ)
            if findNpcOrObject(124355, 5, 12) then
                API.DoAction_WalkerW(WPOINT.new(newTileX, newTileY, newTileZ))
                print("Random number: " .. randomNumber)
                while not API.PInAreaW(SpotCheck, 1) do
                    API.RandomSleep2(100, 10, 10)
                end
            end
        end
    end
end

local function combo()
    UTILS.surge()
    API.RandomSleep2(20, 10, 20)
    DiveCheck()
    monstercheck1() -- remove this if you don't have double surge
    UTILS.surge() -- remove this if you don't have double surge
    API.RandomSleep2(200, 300, 400)
    monstercheck2()
end

local function knightcheck2() -- initial walking before the combo 2
    local KnightNpc = API.GetAllObjArray1({29296}, 50, {1})
    if #KnightNpc > 0 then
        local Knight = KnightNpc[1]
        local tileXYZ = Knight.Tile_XYZ
        if tileXYZ then
            local newTileXD = Knight.Tile_XYZ.x - 4
            local newTileYD = Knight.Tile_XYZ.y + 13
            local newTileZD = Knight.Tile_XYZ.z
            local SpotCheck2 = WPOINT.new(newTileXD, newTileYD, newTileZD)
            if API.PInArea(newTileX, 1, newTileY, 1, newTileZ) then
                --    print("Walking to knight check2")
                API.DoAction_WalkerW(WPOINT.new(newTileXD, newTileYD, newTileZD))
                while not API.PInAreaW(SpotCheck2, 1) do
                    API.RandomSleep2(10, 10, 10)
                end
                combo()
            end
        end
    end
end

local function needBank()
    return API.InvItemcount_String(foodName) < foodAmount
end

local function MaxGuildBanking()
    local shouldContinue = true
    API.RandomSleep2(500, 300, 500)
    API.DoAction_NPC(0x33, 1888, {19918}, 50) -- QUICKLOAD
    API.RandomSleep2(800, 500, 600)
    API.WaitUntilMovingEnds()
    API.DoBankPin(PIN)
    API.RandomSleep2(1500, 1000, 800) -- sleeping to heal off damage/poison
    if needBank() then
        API.DoAction_NPC(0x33, 1888, {19918}, 50) -- QUICKLOAD
        API.RandomSleep2(800, 500, 600)
        if needBank() then
            API.RandomSleep2(200, 200, 200)
            API.Write_LoopyLoop(false)
            print("No more food left, exiting the script!")
            shouldContinue = false
        end
    end
    if shouldContinue then
        if (API.GetPray_() < 600) then
            print("Prayer at " .. API.GetPray_() .. ", renewing it.")
            API.DoAction_Object1(0x29, 0, {92278}, 50)
            API.RandomSleep2(2000, 1500, 800)
            API.WaitUntilMovingandAnimEnds()
        end
    end
end

local function WarsBanking()
    local shouldContinue = true
    API.RandomSleep2(500, 300, 500)
    print("Clicking on the load preset (chest)")
    API.DoAction_Object1(0x33, 240, {114750}, 50) -- QUICKLOAD
    API.RandomSleep2(800, 500, 600)
    API.WaitUntilMovingEnds()
    API.DoBankPin(PIN)
    API.RandomSleep2(1500, 1000, 800) -- sleeping to heal off damage/poison
    if needBank() then -- retarded failsafe
        API.DoAction_Object1(0x33, 240, {114750}, 50) -- QUICKLOAD
        API.RandomSleep2(800, 500, 600)
        if needBank() then
            API.RandomSleep2(200, 200, 200)
            API.Write_LoopyLoop(false)
            print("No more food left, exiting the script!")
            shouldContinue = false
        end
    end
    if shouldContinue then
        if (API.GetPray_() < 700) then -- added a prayer check (edit for your liking/level)
            print("Renewing prayer because under 700 prayer points")
            API.DoAction_Object1(0x3d, 0, {114748}, 50) -- prayer renewal
            API.RandomSleep2(1200, 800, 600)
            API.WaitUntilMovingandAnimEnds()
        end
    end
end

local function NPCCheck()
    local finddog = findNPC(29302, 50)
    local findpyrefiend = findNPC(29272, 50)
    local findportal = findNpcOrObject(124361, 17, 0)
    local findWarAltar = findNpcOrObject(114748, 50, 0)
    if not finddog and findpyrefiend then
        if UTILS.isDeflectMelee() then
            API.DoAction_Ability("Deflect Melee", 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(500, 300, 200)
        end
        if GUI.GetComponentValue(MaxGuildTP) then
            MaxGuildTeleport()
        elseif GUI.GetComponentValue(WarsTP) then
            WarsRoomTeleport()
        end
    else
        if GUI.GetComponentValue(MaxGuildTP) then
            if findportal then
                if needBank() then
                    MaxGuildBanking()
                end
                if API.Read_LoopyLoop() then
                    API.DoAction_Object1(0x39, 0, {124361}, 50)
                    API.RandomSleep2(1200, 1000, 2000)
                    API.WaitUntilMovingandAnimEnds()
                else
                    API.RandomSleep2(200, 200, 200)
                end
            end
        end
        if GUI.GetComponentValue(WarsTP) then
            if findWarAltar then
                if needBank() then
                    WarsBanking()
                end
                if API.Read_LoopyLoop() then
                    API.DoAction_Object1(0x39, 0, {124362}, 50) -- zamorak war portal id
                    API.RandomSleep2(1200, 1000, 2000)
                    API.WaitUntilMovingandAnimEnds()
                else
                    API.RandomSleep2(200, 200, 200)
                end
            end
        end
    end
end

local function CerberusSlayer()
    if not hasTarget() then
        API.DoAction_NPC(0x2a, 1600, {29302}, 50, false, 100) -- cerberus id (29302)
        API.RandomSleep2(800, 600, 400)
    end
    NPCCheck()
end

local function healthCheck()
    local hp = API.GetHPrecent()
    local eatFoodAB = API.GetABs_name1("Eat Food")
    if hp < 70 then
        if eatFoodAB.id ~= 0 and eatFoodAB.enabled then
            print("Eating")
            API.DoAction_Ability_Direct(eatFoodAB, 1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(300, 200, 400)
        end
    elseif hp < 30 then
        print("Teleporting out")
        if GUI.GetComponentValue(MaxGuildTP) then
            MaxGuildTeleport()
        elseif GUI.GetComponentValue(WarsTP) then
            WarsBanking()
            print("Something funky happened, resetting")
        end
    end
end

local function deathCheck()
    if findNPC(27299, 50) then
        API.RandomSleep2(2500, 1500, 2000)
        print("You managed to die... (idiot), do we grab your things and go home?")
        API.RandomSleep2(1000, 800, 600)
        API.DoAction_NPC(0x29, 1776, {27299}, 50)
        API.RandomSleep2(800, 400, 600)
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1626, 47, -1, 3808)
        API.RandomSleep2(1000, 800, 600)
        API.DoAction_Interface(0xffffffff, 0xffffffff, 0, 1626, 72, -1, 2912)
        API.RandomSleep2(1500, 1000, 800)
        if GUI.GetComponentValue(MaxGuildTP) then
            MaxGuildTeleport()
        elseif GUI.GetComponentValue(WarsTP) then
            WarsRoomTeleport()
        end
    end
end

API.SetDrawTrackedSkills(true)
while API.Read_LoopyLoop() do
    GUI.Draw()
    if GUI.GetComponentValue(StartScript) then
        UTILS:antiIdle()
        healthCheck()
        deathCheck()
        DungeonEntrance()
        knightcheck1()
        knightcheck2()
        CerberusSlayer()
    else
        API.RandomSleep2(100, 100, 100)
    end
end