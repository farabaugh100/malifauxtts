referenceCardsContainerGUID = "000888"
upgradeContainerGUID = "f5da9d"
controllerGUID = "e894f6"
missingNoContainerGUID = "db7b30"
boardBlueGUID = "5dd6ff"
boardRedGUID = "9f46fd"

referenceCardsContainerObject = nil
upgradeContainerObject = nil
missingNoContainerObject = nil
playerColor = ''
local workInProgress = false;

basePositionBlue = {x= -22, y=1.5,z=14}
basePositionRed = {x= 22, y=1.5,z=-14}

spawnedRefCards = {}
local prototypes = {
    base = '3ce58e',
}
local Factions = {};
Factions["Guild"] = Color(191/255, 26/255, 33/255);
Factions["Arcanists"] = Color(0/255, 90/255, 154/255);
Factions["Arcanist"] = Color(0/255, 90/255, 154/255);
Factions["Resurrectionists"] = Color(37/255, 136/255, 69/255);
Factions["Resurrectionist"] = Color(37/255, 136/255, 69/255);
Factions["Neverborn"] = Color(95/255, 53/255, 129/255);
Factions["Ten Thunders"] = Color(208/255, 95/255, 36/255);
Factions["Outcasts"] = Color(181/255, 143/255, 18/255);
Factions["Explorer's Society"] = Color(0/255, 114/255, 111/255);
Factions["Explorers Society"] = Color(0/255, 114/255, 111/255);
Factions["Bayou"] = Color(145/255, 93/255, 35/255);

local factionsBoardState = {}
factionsBoardState["Guild"] = 2;
factionsBoardState["Arcanists"] = 3;
factionsBoardState["Arcanist"] = 3;
factionsBoardState["Resurrectionist"] = 4;
factionsBoardState["Resurrectionists"] = 4;
factionsBoardState["Neverborn"] = 5;
factionsBoardState["Ten Thunders"] = 6;
factionsBoardState["Outcasts"] = 7;
factionsBoardState["Explorer's Society"] = 8;
factionsBoardState["Explorers Society"] = 8;
factionsBoardState["Bayou"] = 9;

function onload(saved_data)
    createAll()
end

function updateSave()
end

function createAll()
    s_color = {0.5, 0.5, 0.5, 95}
    f_color = {0,0,0,1}
    self.createButton({
      label="Retrieve Crew",
      click_function="retrieve_crew_ui",
      tooltip=ttText,
      function_owner=self,
      position={0,1,0.6},
      height=30,
      width=300,
      
      scale={x=-0.6, y=1, z=-0.6},
      font_size=30,
      font_color=f_color,
      color={0.8,0.8,0.9,1}
      })
end

function removeAll()
    self.removeButton(0)
end

function reloadAll()
    removeAll()
    createAll()
    updateSave()
end

function retrieve_crew_ui(_obj, _color, alt_click)
    if workInProgress == false then
        workInProgress = true;
        Wait.time( function() workInProgress =false;end,10);
        if _color ~= 'Red' and _color ~= 'Blue' then
            broadcastToAll("Please Select Color first, only Blue and Red are Valid");
        else
            playerColor = _color
            retrieve_crew()
        
        end
    else
        GetPlayerFromColor(playerColor).broadcast("Retrieving previous crew; wait 10 seconds",Color[_color])
    end
end
function retrieve_crew()
    for key,refCard in pairs(spawnedRefCards) do
        if refCard ~= nil and not refCard.isDestroyed() then
            refCard.call("destruct", {})
            refCard.destruct()
        end
    end
    spawnedRefCards = {}
    local placingReferences = false
   
    if referenceCardsContainerObject == nil then
        referenceCardsContainerObject = getObjectFromGUID(referenceCardsContainerGUID)
    end
    if upgradeContainerObject == nil then
        upgradeContainerObject = getObjectFromGUID(upgradeContainerGUID)
    end
    if missingNoContainerObject == nil then
        missingNoContainerObject = getObjectFromGUID(missingNoContainerGUID)
    end

   local modelPosition = 0
   local description = self.getData().Description
   local separatedCrew = mysplit(description)
   
   local faction = getFaction(separatedCrew[1])
   GetPlayerFromColor(playerColor).broadcast("Retrieving '"..separatedCrew[1].."' crew ",Color[playerColor])
   for key,value in pairs(separatedCrew) do
    local starterCharacter = string.sub(value, 1, 2)
    if starterCharacter == 'Si' and key >1 then
        local soulstones =string.sub(value,-2):gsub("%s+","")
        soulstones=tonumber(soulstones)
        
        if soulstones>6 then
            soulstones=6
        end
        getSoulstones(soulstones)
    end
    if starterCharacter == '  ' then
      local entity = string.sub(value, 3)
      local secondCharacter = string.sub(entity, 1, 2)
      if secondCharacter == '  ' then
        spawnUpgrade(string.sub(entity, 3),modelPosition)
        print('upgrade: ' .. string.sub(entity, 3))
      else
        spawnModel(entity,modelPosition,faction,placingReferences)
        --if spawnStatCard(entity,modelPosition,faction,placingReferences) then
        --    spawnModel(entity,modelPosition,faction,placingReferences)
        --end
        --print('model: ' .. entity)
        
        if placingReferences == false then
            modelPosition = modelPosition +1
        end
        
      end
    else
        if value == 'References:' then
            placingReferences = true    
            modelPosition = modelPosition + 2
        end

    end
    
   end
end
function getSoulstones(soulstones)
    local x=0
    local z=07
    --{-38.00, 0.86, 11.50}
    if playerColor=="Blue" then
        x=-38.000
        z=11.5
    elseif playerColor=="Red" then
        x=38.00
        z=-11.5
    end
    local soulstoneBag=getObjectFromGUID("ea5878")
    local wait=5
    local y=1
    for i = soulstones, 1, -1 do
        Wait.frames(function()soulstoneBag.takeObject({position = {x = x, y = y, z = z}}) y=y+1 end,wait)
        wait=wait+5
    end
end
function getFaction(firstCrewLine)
    for faction,color in pairs(Factions) do
        if ends_with(firstCrewLine,"(".. faction ..")") then
            setPlayerBoard(faction)
            return faction;
        end
    end
end

function setPlayerBoard(faction)
    local playerBoard
    if playerColor == "Blue" then
        playerBoard = getObjectFromGUID(boardBlueGUID)
    elseif playerColor == "Red" then
        playerBoard = getObjectFromGUID(boardRedGUID)
    end
    if playerBoard != nil then
        playerBoard.setState(factionsBoardState[faction])
    end
end
function spawnStatCard (modelName,modelSlot,faction,isReference)
    ismodel = false;
    local found = 0;
    local color = Factions[faction];
    local refrence = getObjectFromGUID("c78aef")
    local str = string.gsub(modelName, "%s+", "")
    str = string.gsub(str, ",", "")
    str = string.gsub(str, "-", "")
    local info=refrence.call("retriveModel",str)
    if info=="na" then
        return true
    else
        info["playerColor"]=playerColor
        info[faction]=faction
        local statCardPrototype = getObjectFromGUID(prototypes.base)
        local pos=getSlotPosition(modelSlot):add(Vector(0,1,0))
        local rot=getSlotRotation()
        local statCard = statCardPrototype.clone({position=pos,rotation=rot})
        Wait.frames(function() statCard.call("createStatCard",info) end,10)
        if string.match(info["characteristics"], "Master") then
            local crewCardinfo=refrence.call("retriveCrewCard",info["crewCard"])
            if crewCardinfo=="na" then
                return true
            else
                pos=getSlotPosition(18):add(Vector(0,1,0))
                local crewCard = statCardPrototype.clone({position=pos,rotation=rot})
                Wait.frames(function() crewCard.call("createCrewCard",crewCardinfo) end,10)
            end

        end
        return false
    end
end
function spawnModel(modelName,modelSlot,faction,isReference)
    ismodel = false;
    local found = 0;
    local color = Factions[faction];
    for key,containedObject in pairs(referenceCardsContainerObject.getObjects()) do
        local isEquivalentModel = containedObject.name:gsub("[%c%p]", "") == modelName:gsub("[%c%p]", "");
        if isReference and modelName~="" then
            isEquivalentModel = starts_with(containedObject.name:gsub("[%c%p]", ""),modelName:gsub("[%c%p]", ""));
        end
        if isEquivalentModel then
            ismodel = true
            
            referenceCardsContainerObject.takeObject({
                index = containedObject.index - found,
                position = getSlotPosition(modelSlot):add(Vector(0,1,0)),
                rotation = getSlotRotation(),
                callback_function = function(spawnedObject)
                    spawnedObject.setCustomObject({stackable = false})
                    spawnedObject.reload()
                    spawnedObject.clone({position=referenceCardsContainerObject.getPosition(),rotation={x=0,y=180,z=0}})
                    spawnedObject.call("rt_createModel", {faction=faction,r = color.r,g = color.g,b = color.b,isReference=isReference})
                    table.insert(spawnedRefCards, spawnedObject)
                end,
            })
            found = found +1;
            if isReference == false then
                break 
            else
            end
        else
            if isReference and found > 3 then
                break
            end
        end
    end

    if ismodel == false then
        spawnUpgrade (modelName,modelSlot)
    end
end

function spawnUpgrade (modelName,modelSlot)
    local found = false
    for key,containedObject in pairs(upgradeContainerObject.getObjects()) do
        if containedObject.name:gsub("[%c%p]", "") == modelName:gsub("[%c%p]", "") then
            found = true
            upgradeContainerObject.takeObject({
                index = containedObject.index,
                position = getSlotPosition(modelSlot-1.2),
                rotation = getSlotRotation(),
                callback_function = function(spawnedObject)
                    spawnedObject.setCustomObject({stackable = false})
                    spawnedObject.reload()
                    local newCard=spawnedObject.clone({position=upgradeContainerObject.getPosition(),rotation={x=0,y=180,z=0}})
                    Wait.frames(function()newCard.call("fetched",playerColor)end,1)
                    table.insert(spawnedRefCards, spawnedObject)
                end,
            })
            break 
        end
    end
    if found == false then
        spawnMissingNo(modelName,modelSlot)
    end
end

function spawnMissingNo(modelName,modelSlot)
    missingNoContainerObject.takeObject({
        position = getSlotPosition(modelSlot):add(Vector(0,1,0)),
        rotation = getSlotRotation(),
        callback_function = function(spawnedObject)
            spawnedObject.setCustomObject({stackable = false})
            spawnedObject.reload()
            spawnedObject.setName("MISSING (" .. modelName .. ")")
        end
    })
end

function getSlotPosition(modelSlot)
    local row = 0
    local targetPos = modelSlot
    while targetPos >= 8.5 do
        row = row + 1
        targetPos = targetPos - 9
    end

    if playerColor == 'Red' then
        return Vector( basePositionRed.x+ row * 6,basePositionRed.y  ,basePositionRed.z + ((targetPos) * ( 3.5)))
    end
    if playerColor == 'Blue' then
        return Vector( basePositionBlue.x+ row * -6,basePositionBlue.y  ,basePositionBlue.z + ((targetPos) * ( -3.5)))
    end
end


function getSlotRotation(modelSlot)
    if playerColor == 'Red' then
        return {x=0,y=90,z=0}
    end
    if playerColor == 'Blue' then
        return {x=0,y=-90,z=0}
    end
end


function mysplit (inputstr, sep)
    if sep == nil then
            sep = "%c"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

function updateVal()
    if tooltip_show then
        ttText = "     " .. val .. "\n" .. self.getName()
    else
        ttText = self.getName()
    end

    self.editButton({
        index = 0,
        label = tostring(val),
        tooltip = ttText
        })
end

function reset_val()
    val = 0
    updateVal()
    updateSave()
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function GetPlayerFromColor(color)
    for _, player in pairs(Player.getPlayers()) do
        if player.color == color then
            return player;
        end
    end
end
